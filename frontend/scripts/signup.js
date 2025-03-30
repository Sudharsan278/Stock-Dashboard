document.addEventListener('DOMContentLoaded', function() {
    
    const signupButton = document.querySelector('.signup-button');
    const nameInput = document.getElementById('name');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const repeatPasswordInput = document.getElementById('confirm-password');

    signupButton.addEventListener('click', function(event) {
        event.preventDefault();  

        const name = nameInput.value.trim();
        const email = emailInput.value.trim();
        const password = passwordInput.value.trim();
        const repeatPassword = repeatPasswordInput.value.trim();

        console.log(name);
        console.log(email);
        console.log(password);

        const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        const passwordRegex = /^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;

        if (!name || !email || !password || !repeatPassword) {
            alert("Please fill out all fields.");
            return;
        }

        if (name.length < 3) { 
            alert("Name must be at least 3 characters long.");
            return;
        }
        

        if (!emailRegex.test(email)) {
            alert("Invalid email format.");
            return;
        }

        if (!passwordRegex.test(password)) {
            alert("Password must be at least 8 characters long, contain one uppercase letter, one number, and one special character.");
            return;
        }

        if (password !== repeatPassword) {
            alert("Passwords do not match.");
            return;
        }

        fetch("http://localhost:8080/StockDashboard/SignupServlet", {
            method: "POST",
            credentials : "include",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: `name=${encodeURIComponent(name)}&email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`,
        })
        .then(response => response.json())
        .then(data => {

            console.log("Response data:", data);  

            if (data.success === true) {
                alert("Signup Successful!");
                window.location.href = "login.html";
            } else {
                alert("Signup Failed! The email might already exist or there was an error.");
            }
        })
        .catch(error => {
            console.error("Error:", error);
            alert("An error occurred. Please try again later.");
        });
    });
});
