<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="portfolio.PortfolioServlet.Stock" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Portfolio</title>
	<link rel="stylesheet" type="text/css" href="styles/portfolio.css">
</head>
<body>
    <%
    // Get stocks from session
    @SuppressWarnings("unchecked")
    List<Stock> stocks = (List<Stock>) session.getAttribute("stocks");
    if (stocks == null) {
        stocks = new ArrayList<>();
    }
    
    // Calculate total value
    double totalValue = 0;
    for (Stock stock : stocks) {
        totalValue += stock.getPurchasePrice() * stock.getQuantity();
    }
    %>

    <!-- Navbar -->
     <nav class="navbar">
        <div class="container">
            <a href="#" class="logo">StockPro</a>
            <ul class="nav-links">
                <li><a href="http://127.0.0.1:5500/frontend/home.html">Home</a></li>
                <li><a href="http://127.0.0.1:5500/frontend/home.html#features">Features</a></li>
                <li><a href="http://127.0.0.1:5500/frontend/Dashboard.html">Dashboard</a></li>
                <li><a href="http://127.0.0.1:5500/frontend/contact.html">Contact</a></li>
                <li><a href="http://localhost:8080/StockDashboard/portfolio.jsp">Portfolio</a></li>
                <li><button id="logoutBtn" class="btn">Logout</button></li>
            </ul>
        </div>
    </nav>
    
    
    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1>My Investment Portfolio</h1>
            <p>Track and manage your stock investments in one place</p>
        </div>
    </div>

    <div class="container">
        <!-- Portfolio Summary -->
        <div class="portfolio-summary">
            <div class="summary-card">
                <h4>Total Portfolio Value</h4>
                <div class="value">$<%= String.format("%.2f", totalValue) %></div>
            </div>
            <div class="summary-card">
                <h4>Number of Stocks</h4>
                <div class="value"><%= stocks.size() %></div>
            </div>
        </div>

        <!-- Add Stock Form -->
        <div class="add-stock-form">
            <h2>Add New Stock</h2>
            <form action="portfolio" method="post">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="symbol">Stock Symbol</label>
                        <input type="text" id="symbol" name="symbol" placeholder="e.g. AAPL" required>
                    </div>
                    <div class="form-group">
                        <label for="companyName">Company Name</label>
                        <input type="text" id="companyName" name="companyName" placeholder="e.g. Apple Inc." required>
                    </div>
                    <div class="form-group">
                        <label for="quantity">Quantity</label>
                        <input type="number" id="quantity" name="quantity" placeholder="Number of shares" required min="1">
                    </div>
                    <div class="form-group">
                        <label for="purchasePrice">Purchase Price</label>
                        <input type="number" step="0.01" id="purchasePrice" name="purchasePrice" placeholder="Price per share" required min="0.01">
                    </div>
                    <div class="form-group">
                        <label for="purchaseDate">Purchase Date</label>
                        <input type="date" id="purchaseDate" name="purchaseDate" required>
                    </div>
                </div>
                <div class="form-actions">
                    <button type="submit">Add to Portfolio</button>
                </div>
            </form>
        </div>

        <!-- Stock List -->
        <div class="stock-list">
            <h2>Your Portfolio Holdings</h2>

            <% if (stocks.isEmpty()) { %>
                <div class="empty-state">
                    <p>No stocks in your portfolio yet. Add your first stock above!</p>
                </div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Symbol</th>
                            <th>Company</th>
                            <th>Quantity</th>
                            <th>Purchase Price</th>
                            <th>Purchase Date</th>
                            <th>Total Value</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Stock stock : stocks) { %>
                            <tr>
                                <td class="stock-symbol"><%= stock.getSymbol() %></td>
                                <td class="stock-company"><%= stock.getCompanyName() %></td>
                                <td><%= stock.getQuantity() %></td>
                                <td>$<%= String.format("%.2f", stock.getPurchasePrice()) %></td>
                                <td><%= stock.getPurchaseDate() %></td>
                                <td class="stock-value">$<%= String.format("%.2f", stock.getPurchasePrice() * stock.getQuantity()) %></td>
                                <td>
                                    <form action="portfolio" method="post">
                                        <input type="hidden" name="deleteSymbol" value="<%= stock.getSymbol() %>">
                                        <button type="submit" class="action-button">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                    <tfoot>
                        <tr class="total-row">
                            <td colspan="5">Total Portfolio Value:</td>
                            <td class="total-value">$<%= String.format("%.2f", totalValue) %></td>
                            <td></td>
                        </tr>
                    </tfoot>
                </table>
            <% } %>
        </div>
    </div>
</body>
</html>