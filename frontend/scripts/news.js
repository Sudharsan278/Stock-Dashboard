import {API_KEY} from './config.js'

// Market News AJAX functionality
const API_URL = 'https://api.polygon.io/v2/reference/news';
console.log(API_KEY);
let currentPage = 1;
let currentCategory = 'all';
let currentSearchTerm = '';
let nextUrl = null;

// Filter buttons functionality
const filterButtons = document.querySelectorAll('.filter-btn');
filterButtons.forEach(button => {
    button.addEventListener('click', function() {
        filterButtons.forEach(btn => btn.classList.remove('active'));
        this.classList.add('active');
        
        currentCategory = this.getAttribute('data-category');
        currentPage = 1;
        loadNews();
    });
});

// Search functionality
const searchInput = document.getElementById('news-search');
let searchTimeout;

searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        currentSearchTerm = searchInput.value;
        currentPage = 1;
        loadNews();
    }, 500);
});

// Load more button functionality
document.getElementById('load-more-btn').addEventListener('click', function() {
    currentPage++;
    loadNews();
});

// Function to load news via AJAX
function loadNews() {
    if (currentPage === 1) {
        document.getElementById('news-container').innerHTML = '';
        document.getElementById('no-results').style.display = 'none';
    }
    
    document.getElementById('loading-spinner').style.display = 'flex';
    document.getElementById('load-more-btn').style.display = 'none';
    
    // Build URL based on current filters and pagination
    let url;
    if (currentPage === 1 || !nextUrl) {
        url = `${API_URL}?order=asc&limit=10&sort=published_utc&apiKey=${API_KEY}`;
        
        // Add category filter if not 'all'
        if (currentCategory !== 'all') {
            url += `&ticker.any_of=${currentCategory}`;
        }
        
        // Add search term if provided
        if (currentSearchTerm) {
            url += `&search=${encodeURIComponent(currentSearchTerm)}`;
        }
    } else {
        // Use the next_url provided in the previous response
        url = nextUrl + `&apiKey=${API_KEY}`;
    }
    
    // Make AJAX request
    const xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    
    xhr.onreadystatechange = function() {
        if (this.readyState === 4) {
            document.getElementById('loading-spinner').style.display = 'none';
            
            if (this.status === 200) {
                const response = JSON.parse(this.responseText);
                
                // Render news items
                renderNews(response);
                
                // Update next URL for pagination
                nextUrl = response.next_url;
                if (nextUrl) {
                    document.getElementById('load-more-btn').style.display = 'block';
                } else {
                    document.getElementById('load-more-btn').style.display = 'none';
                }
                
                // Show no results message if needed
                if (response.results.length === 0 && currentPage === 1) {
                    document.getElementById('no-results').style.display = 'block';
                }
            } else {
                console.error('Error loading news:', this.status);
                if (currentPage === 1) {
                    document.getElementById('no-results').style.display = 'block';
                }
            }
        }
    };
    
    xhr.send();
}

// Function to render news items
function renderNews(response) {
    const newsContainer = document.getElementById('news-container');
    const results = response.results;
    
    results.forEach(news => {
        const newsCard = document.createElement('div');
        newsCard.className = 'news-card';
        
        // Determine sentiment class
        let sentimentClass = 'sentiment-neutral';
        let sentimentText = 'Neutral';
        
        if (news.insights && news.insights.length > 0) {
            if (news.insights[0].sentiment === 'positive') {
                sentimentClass = 'sentiment-positive';
                sentimentText = 'Positive';
            } else if (news.insights[0].sentiment === 'negative') {
                sentimentClass = 'sentiment-negative';
                sentimentText = 'Negative';
            }
        }
        
        // Format publication date
        const publishDate = new Date(news.published_utc);
        const formattedDate = publishDate.toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        });
        
        // Ensure tickers array exists
        const tickers = news.tickers || [];
        
        // Create news card HTML
        newsCard.innerHTML = `
            <div class="news-img">
                <img src="${news.image_url || '/api/placeholder/600/300'}" alt="${news.title}" onerror="this.src='/api/placeholder/600/300'">
                <div class="news-source">
                    <img src="${news.publisher && news.publisher.favicon_url ? news.publisher.favicon_url : '/api/placeholder/16/16'}" alt="${news.publisher ? news.publisher.name : 'Source'}" onerror="this.src='/api/placeholder/16/16'">
                    ${news.publisher ? news.publisher.name : 'Unknown Source'}
                </div>
                <div class="news-sentiment ${sentimentClass}">${sentimentText}</div>
            </div>
            <div class="news-content">
                <div class="news-meta">
                    <div class="date">
                        <i class="far fa-calendar-alt"></i>
                        ${formattedDate}
                    </div>
                    <div class="tickers">
                        ${tickers.slice(0, 3).map(ticker => `<span class="ticker-tag">${ticker}</span>`).join('')}
                        ${tickers.length > 3 ? `<span class="ticker-tag">+${tickers.length - 3}</span>` : ''}
                    </div>
                </div>
                <h3 class="news-title">${news.title}</h3>
                <p class="news-description">${news.description || 'No description available.'}</p>
                <div class="news-footer">
                    <div class="news-author">By ${news.author || 'Unknown'}</div>
                    <a href="${news.article_url}" target="_blank" class="read-more">
                        Read More <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
            </div>
        `;
        
        newsContainer.appendChild(newsCard);
    });
}

// Initial load
document.addEventListener('DOMContentLoaded', function() {
    loadNews();
});