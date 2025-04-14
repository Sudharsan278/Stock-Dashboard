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
            try {
                const loginDate = new Date(loginTime);
                document.getElementById("login-time").textContent = loginDate.toLocaleString();
            } catch (e) {
                document.getElementById("login-time").textContent = loginTime;
            }
        } else {
            document.getElementById("login-time").textContent = "Not available";
        }
        
        const userAvatar = document.getElementById("user-avatar");
        const userDropdown = document.getElementById("user-dropdown");
        
        userAvatar.addEventListener("click", function() {
            userDropdown.classList.toggle("active");
        });
        
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
        
        const CHATBOT_SERVLET_URL = 'http://localhost:8080/StockDashboard/ChatbotServlet';
        chatbotToggle.addEventListener('click', function() {
            chatbotWindow.classList.add('active');
            scrollToBottom();
        });
        
        chatbotClose.addEventListener('click', function() {
            chatbotWindow.classList.remove('active');
        });
        
        function sendMessage() {
            const message = chatInput.value.trim();
            if (message === '') return;
            
            console.log(message);
            addMessage(message, 'user');
            chatInput.value = '';
            
            showTypingIndicator();
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', CHATBOT_SERVLET_URL, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    removeTypingIndicator();
                    const response = JSON.parse(xhr.responseText);
                    console.log("response: - ", response);
                    addMessage(response.response, 'bot');
                } else if (xhr.readyState === 4) {
                    removeTypingIndicator();
                    addMessage("Sorry, there was an error processing your request. Please try again later.", 'bot');
                }
            };
            xhr.send('message=' + encodeURIComponent(message));
        }
        
        sendBtn.addEventListener('click', sendMessage);
        
        chatInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                sendMessage();
            }
        });
        
        suggestionChips.forEach(chip => {
            chip.addEventListener('click', function() {
                const question = this.textContent;
                chatInput.value = question;
                sendMessage();
            });
        });
        
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
        
        function showTypingIndicator() {
            const indicator = document.createElement('div');
            indicator.classList.add('typing-indicator');
            indicator.innerHTML = '<span></span><span></span><span></span>';
            indicator.id = 'typing-indicator';
            messagesContainer.appendChild(indicator);
            scrollToBottom();
        }
        
        function removeTypingIndicator() {
            const indicator = document.getElementById('typing-indicator');
            if (indicator) {
                indicator.remove();
            }
        }
        
        function getCurrentTime() {
            const now = new Date();
            const hours = now.getHours().toString().padStart(2, '0');
            const minutes = now.getMinutes().toString().padStart(2, '0');
            return `${hours}:${minutes}`;
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