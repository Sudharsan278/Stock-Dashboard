document.getElementById("loginForm").addEventListener("submit", function(event) {
    event.preventDefault();

    let email = document.getElementById("email").value;
    let password = document.getElementById("password").value;

    let users = JSON.parse(localStorage.getItem("users")) || [];

    let validUser = users.find(user => user.email === email && user.password === password);

    if (validUser) {
        alert("Login successful!");
        window.location.href = "../home/home.html"; 
    } else {
        alert("Invalid email or password. Please try again.");
    }
});
