document.addEventListener('DOMContentLoaded', function() {
    const signupButton = document.querySelector('.signup-button');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const repeatPasswordInput = document.getElementById('repeat-password');

    signupButton.addEventListener('click', function() {
        const email = emailInput.value.trim();
        const password = passwordInput.value;
        const repeatPassword = repeatPasswordInput.value;

        if (!email || !password || !repeatPassword) {
            alert("Please fill out all fields.");
            return;
        }

        if (password !== repeatPassword) {
            alert("Passwords do not match.");
            return;
        }

        let users = JSON.parse(localStorage.getItem("users")) || [];       
        if(users.some(user => user.email === email)){
            alert("User with the same email already exists! Try with a different email.");
            return; // Prevents navigation to home.html if email already exists
        }

        users.push({email, password});
        localStorage.setItem("users", JSON.stringify(users));

        // Add your signup logic here (e.g., sending data to a server)
        console.log("Email:", email);
        console.log("Password:", password);
        console.log("Signup successful!");
        alert("Signup successful!");

        window.location.href = "home.html"; // Only redirects if email doesn't exist
    });
});
