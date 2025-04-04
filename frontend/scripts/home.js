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

