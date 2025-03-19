document.addEventListener("DOMContentLoaded", function () {
    console.log("Home page loaded, checking cookies...");

    function getCookie(name) {
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
    }
});
