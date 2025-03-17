document.getElementById("loginForm").addEventListener("submit", function(event) {
    event.preventDefault();

    let email = document.getElementById("email").value;
    let password = document.getElementById("password").value;

    fetch("http://localhost:8080/StockDashboard/LoginServlet", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: `email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert("Login successful!");
            window.location.href = "home.html";
        } else {
            alert("Invalid email or password. Please try again.");
        }
    })
    .catch(error => {
        console.error("Error:", error);
        alert("Something went wrong. Please try again later.");
    });
});
