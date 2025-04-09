<?php
$servername = "localhost";
$username = "root";
$password = "2782004";
$dbname = "stock_dashboard";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$successMessage = "";
$errorMessage = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST['name'];
    $email = $_POST['email'];
    $message = $_POST['message'];
    
    $stmt = $conn->prepare("INSERT INTO queries (name, email, message) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $name, $email, $message);
    
    if ($stmt->execute()) {
        $successMessage = "Message sent successfully!";
    } else {
        $errorMessage = "Error: " . $stmt->error;
    }
    
    $stmt->close();
}
$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us | StockPro</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="styles/contact.css">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar">
        <div class="container">
            <a href="#" class="logo">StockPro</a>
            <ul class="nav-links">
                <li><a href="#home">Home</a></li>
                <li><a href="#features">Features</a></li>
                <li><a href="Dashboard.html">Dashboard</a></li>
                <li><a href="">Market News</a></li>
                <li><a href="contact.php">Contact</a></li>
                <li><a href="http://localhost:8080/StockDashboard/portfolio.jsp">Portfolio</a></li>
                <li><button id="logoutBtn" class="btn">Logout</button></li>
            </ul>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1>Contact Us</h1>
            <p>We're here to help with any questions about StockPro</p>
        </div>
    </div>

    <div class="container">
        <!-- Message Notifications -->
        <?php if (!empty($successMessage)): ?>
            <div class="alert success">
                <?php echo $successMessage; ?>
            </div>
        <?php endif; ?>
        
        <?php if (!empty($errorMessage)): ?>
            <div class="alert error">
                <?php echo $errorMessage; ?>
            </div>
        <?php endif; ?>

        <div class="contact-container">
            <h2>Send us a message</h2>
            <p>Have questions about our services or need assistance with your account? Drop us a message.</p>

            <form action="contact.php" method="POST" class="contact-form">
                <div class="input-group">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" placeholder="Enter your full name" required>
                </div>
                <div class="input-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" placeholder="Enter your email address" required>
                </div>
                <div class="input-group">
                    <label for="message">Message</label>
                    <textarea id="message" name="message" placeholder="Tell us how we can help you..." required></textarea>
                </div>
                <button type="submit">Submit Message</button>
            </form>
        </div>

        <!-- FAQ Section -->
        <div class="faq-container">
            <h2>Frequently Asked Questions</h2>
            <div class="faq-list">
                <?php
                $faqs = [
                    "How can I reset my password?" => "You can reset your password by clicking on 'Forgot Password' on the login page.",
                    "How do I track my stock portfolio?" => "Go to the Dashboard section and check your stock performance.",
                    "Can I export my stock data?" => "Yes, you can export your data in CSV format from the settings panel."
                ];

                foreach ($faqs as $question => $answer) {
                    echo "<div class='faq-item'>";
                    echo "<h3>$question</h3>";
                    echo "<p>$answer</p>";
                    echo "</div>";
                }
                ?>
            </div>
        </div>

        <!-- Contact Info Section -->
        <div class="contact-info">
            <div class="info-card">
                <h3>Email</h3>
                <p>contact@stockpro.com</p>
            </div>
            <div class="info-card">
                <h3>Phone</h3>
                <p>+1 (555) 123-4567</p>
            </div>
            <div class="info-card">
                <h3>Location</h3>
                <p>123 Financial District, New York, NY 10001</p>
            </div>
        </div>
    </div>
</body>
</html>