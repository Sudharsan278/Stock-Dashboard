document.getElementById("loginForm").addEventListener("submit", async function (event) {
    event.preventDefault();

    let email = document.getElementById("email").value;
    let password = document.getElementById("password").value;

    let response = await fetch("http://127.0.0.1:8080/StockDashboard/LoginServlet", {
        method: "POST",
        credentials: "include",  
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: `email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`
    });

    let data = await response.json();
    console.log("Login Response:", data);

    if (data.success) {
        alert("Login successful!");
        window.location.href = "home.html";
    } else {
        alert("Login failed: " + data.message);
    }
});
