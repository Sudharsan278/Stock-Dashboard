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