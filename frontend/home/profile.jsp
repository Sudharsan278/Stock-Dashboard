<%@ page import="java.io.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile</title>
    <link rel="stylesheet" href="dashboard.css">
</head>
<body>
    <nav class="navbar">
        <div class="container">
            <a href="home.jsp" class="logo">StockPro</a>
            <ul class="nav-links">
                <li><a href="home.jsp">Home</a></li>
                <li><a href="dashboard.jsp">Dashboard</a></li>
                <li><a href="contact.jsp">Contact</a></li>
                <li><a href="profile.jsp" class="active">Profile</a></li>
            </ul>
        </div>
    </nav>
    
    <section class="profile">
        <div class="container">
            <h2>User Profile</h2>
            <div class="profile-details">
                <p><strong>Username:</strong> JohnDoe</p>
                <p><strong>Email:</strong> johndoe@example.com</p>
                <p><strong>Project:</strong> Real-Time Stock Dashboard</p>
                <p><strong>Description:</strong> This project provides live stock price updates using the Twelve Data API.</p>
            </div>
        </div>
    </section>
</body>
</html>
