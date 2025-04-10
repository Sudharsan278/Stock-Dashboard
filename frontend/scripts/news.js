import { NEWS_KEY } from "./config.js";

document.addEventListener('DOMContentLoaded', function() {
    const newsGrid = document.getElementById('newsGrid');
    const searchInput = document.getElementById('searchInput');
    const loader = document.getElementById('loader');
    const filterButtons = document.querySelectorAll('.filter-btn');
    
    let newsData = [];
    let activeFilter = 'all';
    
    // Function to format date
    function formatDate(dateString) {
        if (!dateString) return 'Unknown date';
        
        try {
            const date = new Date(
                dateString.substring(0, 4),
                parseInt(dateString.substring(4, 6)) - 1,
                dateString.substring(6, 8),
                dateString.substring(9, 11),
                dateString.substring(11, 13),
                dateString.substring(13, 15)
            );
            
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric'
            });
        } catch (e) {
            return 'Unknown date';
        }
    }
    
    // Function to truncate text
    function truncateText(text, maxLength) {
        if (!text) return '';
        if (text.length <= maxLength) return text;
        return text.substring(0, maxLength) + '...';
    }
    
    // Function to determine news category
    function getNewsCategory(article) {
        if (!article) return 'other';
        
        const title = (article.title || '').toLowerCase();
        const summary = (article.summary || '').toLowerCase();
        const topics = article.topics || [];
        
        if (title.includes('bitcoin') || title.includes('crypto') || title.includes('btc') || 
            summary.includes('bitcoin') || summary.includes('crypto') || 
            topics.some(t => t.topic && t.topic.toLowerCase().includes('crypto'))) {
            return 'crypto';
        }
        
        if (title.includes('stock') || title.includes('nasdaq') || title.includes('dow') || 
            summary.includes('stock market') || 
            topics.some(t => t.topic && t.topic.toLowerCase().includes('stock'))) {
            return 'stocks';
        }
        
        if (title.includes('forex') || title.includes('currency') || title.includes('usd') || 
            summary.includes('forex') || summary.includes('currency') || 
            topics.some(t => t.topic && t.topic.toLowerCase().includes('forex'))) {
            return 'forex';
        }
        
        return 'other';
    }
    
    // Function to render news cards with premium layout
    function renderNews() {
        newsGrid.innerHTML = '';
        
        const searchTerm = searchInput.value.toLowerCase();
        
        const filteredNews = newsData.filter(article => {
            const matchesSearch = (article.title || '').toLowerCase().includes(searchTerm) || 
                                 (article.summary || '').toLowerCase().includes(searchTerm) ||
                                 (article.authors && article.authors.some(author => author.toLowerCase().includes(searchTerm)));
            
            const category = getNewsCategory(article);
            const matchesFilter = activeFilter === 'all' || category === activeFilter;
            
            return matchesSearch && matchesFilter;
        });
        
        if (filteredNews.length === 0) {
            newsGrid.innerHTML = '<div class="no-results">No news articles found matching your criteria.</div>';
            return;
        }
        
        filteredNews.forEach(article => {
            const card = document.createElement('div');
            card.className = 'news-card premium-card';
            
            const formattedDate = formatDate(article.time_published);
            const authors = article.authors && article.authors.length > 0 ? article.authors.join(', ') : 'Unknown';
            const truncatedSummary = truncateText(article.summary, 120);
            const source = article.source || 'Unknown source';
            
            // Determine if article has ticker data to display
            const hasTicker = article.ticker_sentiment && article.ticker_sentiment.length > 0;
            let tickerHtml = '';
            
            if (hasTicker) {
                const mainTicker = article.ticker_sentiment[0];
                tickerHtml = `
                    <div class="ticker-data">
                        <h3>${mainTicker.ticker}</h3>
                        <div class="price-container">
                            <span class="price">$${(Math.random() * 1000).toFixed(2)}</span>
                            <span class="change ${Math.random() > 0.5 ? 'positive' : 'negative'}">
                                ${Math.random() > 0.5 ? '↑' : '↓'} ${(Math.random() * 10).toFixed(2)}%
                            </span>
                        </div>
                    </div>
                `;
            }
            
            // Proper image handling with premium layout
            const imageHtml = article.banner_image ? 
                `<div class="news-image-container">
                    <img src="${article.banner_image}" alt="${article.title}" onerror="this.onerror=null; this.src='./assets/placeholder.jpg'; this.alt='Image not available'">
                 </div>` : 
                `<div class="news-image-container placeholder-image">
                    <div class="placeholder-text">Financial News</div>
                 </div>`;
            
            card.innerHTML = `
                ${imageHtml}
                <div class="news-content">
                    ${tickerHtml}
                    <a href="${article.url}" target="_blank" class="news-title">${article.title}</a>
                    <div class="news-summary">${truncatedSummary}</div>
                    <div class="news-meta">
                        <span class="news-source">${source}</span>
                        <span class="news-date">${formattedDate}</span>
                    </div>
                    <div class="news-author">
                        <span>${authors}</span>
                    </div>
                </div>
            `;
            
            newsGrid.appendChild(card);
        });
    }

    
    // Fetch news data from Alpha Vantage API
    function fetchNews() {
        loader.style.display = 'flex';
        newsGrid.innerHTML = '';
        
        // Alpha Vantage API endpoint with parameters
        const apiUrl = `https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers=COIN,CRYPTO:BTC,FOREX:USD&timefrom=20220410T0130&limit=1000&apikey=${NEWS_KEY}`;
        
        fetch(apiUrl)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                if (data && data.feed && Array.isArray(data.feed) && data.feed.length > 0) {
                    newsData = data.feed;
                    renderNews();
                } else {
                    newsGrid.innerHTML = '<div class="no-results">No news data available. Please try again later.</div>';
                    console.warn('API returned invalid data format');
                }
            })
            .catch(error => {
                newsGrid.innerHTML = '<div class="no-results">Error loading news data. Please try again later.</div>';
                console.error('Error fetching news:', error);
            })
            .finally(() => {
                loader.style.display = 'none';
            });
    }
    
    // Initialize the app
    fetchNews();
    
    // Event listeners
    searchInput.addEventListener('input', renderNews);
    
    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            filterButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            activeFilter = this.getAttribute('data-filter');
            renderNews();
        });
    });
});