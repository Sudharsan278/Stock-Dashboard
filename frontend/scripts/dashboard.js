import { API_KEY } from "./config.js";
let stockChartInstance = null;
let currentSymbol = '';
let currentRange = '1M';
let chartType = 'line';

console.log(API_KEY)

document.addEventListener('DOMContentLoaded', function() {
    
    document.getElementById('searchBtn').addEventListener('click', fetchStockData);
    document.getElementById('stockSymbol').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') fetchStockData();
    });
    
    // Time range buttons
    document.querySelectorAll('.time-range .time-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.time-range .time-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            currentRange = this.dataset.range;
            if (currentSymbol) fetchStockData();
        });
    });
    
   
    document.querySelectorAll('.chart-type .time-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.chart-type .time-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            chartType = this.dataset.type;
            if (currentSymbol) fetchStockData();
        });
    });
    
    //  Watchlist 
    document.getElementById('addToWatchlist').addEventListener('click', function() {
        if (!currentSymbol) return;
        addToWatchlist(currentSymbol, document.getElementById('currentPrice').textContent);
    });
    
    document.getElementById('stockSymbol').value = 'AAPL';
    fetchStockData();
});

function showLoader() {
    document.getElementById('loader').style.display = 'flex';
}

function hideLoader() {
    document.getElementById('loader').style.display = 'none';
}

async function fetchStockData() {
    
    const symbol = document.getElementById('stockSymbol').value.toUpperCase();
    if (!symbol) return;
    
    currentSymbol = symbol;
    showLoader();
    
    try {
        
        const endDate = new Date();
        let startDate = new Date();
        
        switch(currentRange) {
            case '1M':
                startDate.setMonth(endDate.getMonth() - 1);
                break;
            case '3M':
                startDate.setMonth(endDate.getMonth() - 3);
                break;
            case '6M':
                startDate.setMonth(endDate.getMonth() - 6);
                break;
            case 'YTD':
                startDate = new Date(endDate.getFullYear(), 0, 1);
                break;
            case '1Y':
                startDate.setFullYear(endDate.getFullYear() - 1);
                break;
            case '5Y':
                startDate.setFullYear(endDate.getFullYear() - 5);
                break;
        }
        
        const startDateStr = formatDate(startDate);
        const endDateStr = formatDate(endDate);
        
        const response = await fetch(`https://api.polygon.io/v2/aggs/ticker/${symbol}/range/1/day/${startDateStr}/${endDateStr}?apiKey=${API_KEY}`);
        const data = await response.json();
        
        if (!data.results || data.results.length === 0) {
            alert('No data found for this symbol!');
            hideLoader();
            return;
        }
        
        updateStockInfo(data);
        renderChart(data);
        document.getElementById('stockInfo').style.display = 'block';
        
        updateKeyStats(data);
        
    } catch (error) {
        console.error('Error fetching stock data:', error);
        alert('Failed to fetch stock data. Please check your input and try again.');
    } finally {
        hideLoader();
    }
}

function formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

function updateStockInfo(data) {
    const latestData = data.results[data.results.length - 1];
    const previousData = data.results[data.results.length - 2] || latestData;
    
    const currentPrice = latestData.c.toFixed(2);
    const openPrice = latestData.o.toFixed(2);
    const change = latestData.c - previousData.c;
    const changePercent = (change / previousData.c * 100).toFixed(2);
    const changeClass = change >= 0 ? 'positive' : 'negative';
    const changeSign = change >= 0 ? '+' : '';
    
    document.getElementById('currentPrice').textContent = `$${currentPrice}`;
    document.getElementById('openPrice').textContent = `$${openPrice}`;
    document.getElementById('dailyChange').textContent = `${changeSign}$${Math.abs(change).toFixed(2)} (${changeSign}${Math.abs(changePercent)}%)`;
    document.getElementById('dailyChange').className = `detail-value ${changeClass}`;
    document.getElementById('volume').textContent = numberWithCommas(latestData.v);
}

function updateKeyStats(data) {
    
    const latestPrice = data.results[data.results.length - 1].c;
    const allPrices = data.results.map(item => item.c);
    const highestPrice = Math.max(...allPrices).toFixed(2);
    const lowestPrice = Math.min(...allPrices).toFixed(2);
    
    const mockMarketCap = (latestPrice * 10000000).toFixed(0);
    const mockPE = (Math.random() * 30 + 10).toFixed(2);
    
    document.getElementById('marketCap').textContent = `$${formatLargeNumber(mockMarketCap)}`;
    document.getElementById('peRatio').textContent = mockPE;
    document.getElementById('weekHigh').textContent = `$${highestPrice}`;
    document.getElementById('weekLow').textContent = `$${lowestPrice}`;
}

function renderChart(data) {
    data.results.sort((a, b) => a.t - b.t);
    
    const ctx = document.getElementById('stockChart').getContext('2d');
    
    if (stockChartInstance) {
        stockChartInstance.destroy();
    }
    
    const labels = data.results.map(item => new Date(item.t).toLocaleDateString());
    const prices = data.results.map(item => item.c);
    const accentColor = getComputedStyle(document.documentElement).getPropertyValue('--accent-color') || '#4a6cff';

    
    // Creating a dataset based on chart type
    let dataset;
    if (chartType === 'line') {
        dataset = {
            label: `${currentSymbol} Price`,
            data: prices,
            borderColor: accentColor.trim(),
            backgroundColor: 'rgba(74, 108, 255, 0.1)',
            fill: true,
            tension: 0.3,
            pointRadius: 0,
            pointHoverRadius: 5
        };
    } else {
        // CandleStick chart 
        dataset = {
            label: `${currentSymbol} Price`,
            data: prices,
            backgroundColor: prices.map((p, i, arr) => 
                i > 0 && p >= arr[i-1] ? 'rgba(16, 185, 129, 0.7)' : 'rgba(239, 68, 68, 0.7)'
            ),
            borderColor: prices.map((p, i, arr) => 
                i > 0 && p >= arr[i-1] ? 'rgb(16, 185, 129)' : 'rgb(239, 68, 68)'
            ),
            borderWidth: 1
        };
    }
    
    stockChartInstance = new Chart(ctx, {
        type: chartType === 'line' ? 'line' : 'bar',
        data: {
            labels: labels,
            datasets: [dataset]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                intersect: false,
                mode: 'index',
            },
            scales: {
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        maxTicksLimit: 10,
                        maxRotation: 0
                    }
                },
                y: {
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    position: 'right'
                }
            },
            plugins: {
                tooltip: {
                    backgroundColor: 'rgba(30, 30, 47, 0.9)',
                    padding: 12,
                    bodyFont: {
                        size: 14
                    },
                    callbacks: {
                        label: function(context) {
                            return `${currentSymbol}: $${context.raw.toFixed(2)}`;
                        }
                    }
                },
                legend: {
                    display: false
                }
            }
        }
    });
}

function addToWatchlist(symbol, price) {
    const watchlistContainer = document.getElementById('watchlistContainer');
    
    const existingItems = watchlistContainer.querySelectorAll('.stock-name');
    for (let item of existingItems) {
        if (item.textContent === symbol) {
            alert(`${symbol} is already in your watchlist!`);
            return;
        }
    }
    
    const randomChange = (Math.random() * 2 - 1).toFixed(1);
    const changeClass = randomChange >= 0 ? 'positive' : 'negative';
    const changeSign = randomChange >= 0 ? '+' : '';
    
    const watchItem = document.createElement('div');
    watchItem.className = 'watch-item';
    watchItem.innerHTML = `
        <div class="stock-name">${symbol}</div>
        <div class="detail-value ${changeClass}">${price} (${changeSign}${Math.abs(randomChange)}%)</div>
    `;
    
    watchlistContainer.prepend(watchItem);
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function formatLargeNumber(num) {
    if (num >= 1e12) return (num / 1e12).toFixed(2) + 'T';
    if (num >= 1e9) return (num / 1e9).toFixed(2) + 'B';
    if (num >= 1e6) return (num / 1e6).toFixed(2) + 'M';
    if (num >= 1e3) return (num / 1e3).toFixed(2) + 'K';
    return num;
}

document.getElementById("logoutBtn").addEventListener("click", () => {
    fetch("http://localhost:8080/StockDashboard/LogoutServlet", {
        method: "POST", 
        credentials: "include",
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert("Logout successful!");
            window.location.href = "login.html";
        } else {
            console.error("Logout failed:", data.message);
        }
    })
    .catch(error => console.error("Error:", error));

    deleteAllCookies();
    
});

function deleteAllCookies() {

    const cookies = document.cookie.split(";");

    for (let i = 0; i < cookies.length; i++) {
        const cookie = cookies[i];
        const eqPos = cookie.indexOf("=");
        const name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
        document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
    }
}

