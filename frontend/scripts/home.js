document.addEventListener("DOMContentLoaded", function () {
    console.log("Home page loaded, checking cookies...");

    function getCookie(name) {
        console.log(document.cookie)
        let cookies = document.cookie.split('; ');
        for (let cookie of cookies) {
            let [key, value] = cookie.split('=');
            if (key === name) return decodeURIComponent(value);
        }
        return null;
    }

    let username = getCookie("username");
    let email = getCookie("email");

    console.log("Cookies found:", document.cookie);

    if (!username || !email) {
        console.warn("🔄 No valid cookies found. Redirecting to login...");
        setTimeout(() => {
            window.location.href = "login.html";
        }, 500);
    } else {
        console.log("User Authenticated:", { username, email });

        if (document.getElementById("username-display")) {
            document.getElementById("username-display").textContent = username;
        }
        if (document.getElementById("email-display")) {
            document.getElementById("email-display").textContent = email;
        }
    }


    fetch("http://localhost/StockDashboard/fetchXMLData.php")
        .then((response) => response.json())
        .then((data) => {
            const stockList = document.querySelector(".stock-list");
            
            if (data.error) {
                stockList.innerHTML = `<p style="color: red;">${data.error}</p>`;
                return;
            }

            data.forEach(stock => {
                const stockCard = document.createElement("div");
                stockCard.className = "stock-card";
                stockCard.innerHTML = `
                    <h4>${stock.symbol} - ${stock.name}</h4>
                    <p>Price: $${stock.price.toFixed(2)}</p>
                `;
                stockList.appendChild(stockCard);
            });
        })
        .catch((error) => {
            console.error("Error loading watchlist:", error);
        });

        const loginTime = localStorage.getItem("loginTime");


        if (username) {
            document.getElementById("username-display").textContent = username;
            // Set initials in the avatar
            const initials = username.split(' ')
                .map(name => name[0])
                .join('')
                .toUpperCase()
                .substring(0, 2);
            document.getElementById("user-avatar").textContent = initials;
        } else {
            document.getElementById("username-display").textContent = "Guest User";
            document.getElementById("user-avatar").textContent = "GU";
        }
        
        if (email) {
            document.getElementById("email-display").textContent = email;
        } else {
            document.getElementById("email-display").textContent = "Not available";
        }
        
        if (loginTime) {
            // Format login time nicely
            try {
                const loginDate = new Date(loginTime);
                document.getElementById("login-time").textContent = loginDate.toLocaleString();
            } catch (e) {
                document.getElementById("login-time").textContent = loginTime;
            }
        } else {
            document.getElementById("login-time").textContent = "Not available";
        }
        
        // Toggle user dropdown
        const userAvatar = document.getElementById("user-avatar");
        const userDropdown = document.getElementById("user-dropdown");
        
        userAvatar.addEventListener("click", function() {
            userDropdown.classList.toggle("active");
        });
        
        // Close dropdown when clicking outside
        document.addEventListener("click", function(event) {
            if (!userAvatar.contains(event.target) && !userDropdown.contains(event.target)) {
                userDropdown.classList.remove("active");
            }
        });


        const chatbotToggle = document.querySelector('.chatbot-toggle');
            const chatbotWindow = document.querySelector('.chatbot-window');
            const chatbotClose = document.querySelector('.chatbot-close');
            const chatInput = document.getElementById('chat-input');
            const sendBtn = document.getElementById('send-btn');
            const messagesContainer = document.querySelector('.chatbot-messages');
            const suggestionChips = document.querySelectorAll('.suggestion-chip');
            
            // Predefined questions and answers
            const qaPairs = [
                {
                    question: "hello",
                    answer: "Hey there, investor! Ready to conquer the markets today? Let’s track some stocks and ride those trends! 📈"
                },                
                {
                    question: "how to add stocks in portfolio",
                    answer: "To add stocks in portfolio, go to the Portfolio page and click on the '+ New' button. From there, you can search for stocks and add them to your personalized portfolio. You can add multiple stocks in your respective portfolio for different investment strategies."
                },
                {
                    question: "what markets do you cover",
                    answer: "StockPro covers all major global markets including NYSE, NASDAQ, LSE, TSE, and 30+ other exchanges. We provide data for stocks, ETFs, mutual funds, indices, forex, and cryptocurrencies."
                },
                {
                    question: "do you offer real-time data",
                    answer: "Yes! StockPro provides real-time market data with millisecond precision for all premium subscribers. Our Basic plan includes 15-minute delayed quotes, while Premium and Professional plans offer real-time streaming data."
                },
                {
                    question: "how much does it cost",
                    answer: "StockPro is entirely free to our priviliged users. We take immense proud in offering our service free to all our customers"
                },
                {
                    question: "do you have a mobile app",
                    answer: "No, Currently that work is in progress.. Currently this website is the only service that we are providing. We'll be launching our app in both play store and app store very soon!."
                },
                {
                    question: "how do i read stock charts",
                    answer: "Stock charts display price movements over time. In StockPro, you can access different chart types (candlestick, line, OHLC) and add technical indicators by clicking on the 'Indicators' button above any chart. We also offer a comprehensive 'Chart Reading Guide' in our Learning Center."
                },
                {
                    question: "what technical indicators are available",
                    answer: "StockPro offers 100+ technical indicators including popular ones like Moving Averages, RSI, MACD, Bollinger Bands, and Fibonacci Retracements. Premium users can also create custom indicators using our scripting language."
                },
                {
                    question: "how to set price alerts",
                    answer: "To set price alerts, navigate to any stock detail page and click the bell icon. You can create alerts based on price movements, percentage changes, volume spikes, or technical indicator crossovers. Alerts can be delivered via email, SMS, or push notifications."
                },
                {
                    question: "can i import my existing portfolio",
                    answer: "Yes, you can import your existing portfolio by going to the Portfolio section and clicking 'Import Portfolio'. We support imports from CSV files, direct connections to major brokerages, and manual entry options."
                },
                {
                    question: "do you provide ai stock predictions",
                    answer: "Yes, our Premium and Professional plans include AI-powered market predictions and trend analysis. Our machine learning algorithms analyze thousands of data points to identify potential market movements with proven accuracy rates above industry averages."
                }
            ];
            
            chatbotToggle.addEventListener('click', function() {
                chatbotWindow.classList.add('active');
                scrollToBottom();
            });
            
            chatbotClose.addEventListener('click', function() {
                chatbotWindow.classList.remove('active');
            });
            
            // Handle sending messages
            function sendMessage() {
                const message = chatInput.value.trim();
                if (message === '') return;
                
                // Add user message to chat
                addMessage(message, 'user');
                chatInput.value = '';
                
                // Show typing indicator
                showTypingIndicator();
                
                // Process the message and respond after a delay
                setTimeout(() => {
                    removeTypingIndicator();
                    const response = findAnswer(message);
                    addMessage(response, 'bot');
                }, 1000);
            }
            
            // Send message on button click
            sendBtn.addEventListener('click', sendMessage);
            
            // Send message on Enter key
            chatInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    sendMessage();
                }
            });
            
            // Handle suggestion chips
            suggestionChips.forEach(chip => {
                chip.addEventListener('click', function() {
                    const question = this.textContent;
                    chatInput.value = question;
                    sendMessage();
                });
            });
            
            // Add message to chat
            function addMessage(text, sender) {
                const messageDiv = document.createElement('div');
                messageDiv.classList.add('message', sender);
                
                const messageContent = document.createElement('div');
                messageContent.classList.add('message-content');
                messageContent.textContent = text;
                
                const messageTime = document.createElement('span');
                messageTime.classList.add('message-time');
                messageTime.textContent = getCurrentTime();
                
                messageDiv.appendChild(messageContent);
                messageDiv.appendChild(messageTime);
                
                messagesContainer.appendChild(messageDiv);
                scrollToBottom();
            }
            
            // Show typing indicator
            function showTypingIndicator() {
                const indicator = document.createElement('div');
                indicator.classList.add('typing-indicator');
                indicator.innerHTML = '<span></span><span></span><span></span>';
                indicator.id = 'typing-indicator';
                messagesContainer.appendChild(indicator);
                scrollToBottom();
            }
            
            // Remove typing indicator
            function removeTypingIndicator() {
                const indicator = document.getElementById('typing-indicator');
                if (indicator) {
                    indicator.remove();
                }
            }
            
            // Find answer for a question
            function findAnswer(question) {
                // Normalize the question (lowercase, remove punctuation)
                const normalizedQuestion = question.toLowerCase().replace(/[^\w\s]/g, '');
                
                // Find matching Q&A pair
                for (const pair of qaPairs) {
                    if (normalizedQuestion.includes(pair.question)) {
                        return pair.answer;
                    }
                }
                
                return "I'm sorry, I don't have specific information about that question yet. Please contact our support team for more assistance or try asking about our features, pricing, or how to use StockPro.";
            }
            
            function getCurrentTime() {
                const now = new Date();
                let hours = now.getHours();
                let minutes = now.getMinutes();
                const ampm = hours >= 12 ? 'PM' : 'AM';
                
                hours = hours % 12;
                hours = hours ? hours : 12; 
                minutes = minutes < 10 ? '0' + minutes : minutes;
                
                return `${hours}:${minutes} ${ampm}`;
            }
            
            function scrollToBottom() {
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            }

});

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