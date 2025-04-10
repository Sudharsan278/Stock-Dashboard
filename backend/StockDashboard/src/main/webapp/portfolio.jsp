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
    <link rel="stylesheet" type="text/css" href="/StockDashboard/styles/portfolio.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <%!

    private double calculateTotalValue(List<Stock> stocks) {
        double total = 0;
        if (stocks != null) {
            for (Stock stock : stocks) {
                total += stock.getPurchasePrice() * stock.getQuantity();
            }
        }
        return total;
    }
    %>

    <%
    @SuppressWarnings("unchecked")
    List<Stock> stocks = (List<Stock>) session.getAttribute("stocks");
    if (stocks == null) {
        stocks = new ArrayList<>();
    }
    
    double totalValue = calculateTotalValue(stocks);
    %>

     <nav class="navbar">
        <div class="container">
            <a href="#" class="logo">StockPro</a>
            <ul class="nav-links">
                <li><a href="http://127.0.0.1:5500/frontend/home.html">Home</a></li>
                <li><a href="http://127.0.0.1:5500/frontend/home.html#features">Features</a></li>
                <li><a href="http://127.0.0.1:5500/frontend/Dashboard.html">Dashboard</a></li>
                <li><a href ="http://127.0.0.1:5500/frontend/news.html">Market News</a>
                <li><a href="http://localhost/StockDashboard/contact.php">Contact</a></li>
                <li><a href="http://localhost:8080/StockDashboard/portfolio.jsp">Portfolio</a></li>                
            </ul>
        </div>
    </nav>
    
    
    <div class="page-header">
        <div class="container">
            <h1>My Investment Portfolio</h1>
            <p>Track and manage your stock investments in one place</p>
        </div>
    </div>

    <div class="container">
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
                                <td class="action-buttons">
                                    <div class="button-container">
                                        <form action="portfolio" method="post" class="action-form">
                                            <input type="hidden" name="deleteSymbol" value="<%= stock.getSymbol() %>">
                                            <button type="submit" class="action-button delete-btn">
                                                <i class="fas fa-trash-alt"></i> Delete
                                            </button>
                                        </form>
                                        <button class="action-button buy-btn" 
                                                onclick="openBuyModal('<%= stock.getSymbol() %>', '<%= stock.getCompanyName() %>', <%= stock.getPurchasePrice() %>)">
                                            <i class="fas fa-shopping-cart"></i> Wanna Buy?
                                        </button>
                                    </div>
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

    <%@ include file="paymentModal.jsp" %>

    <script>
        let currentSymbol = '';
        let currentCompany = '';
        let currentPrice = 0;
        
        function openBuyModal(symbol, company, price) {
            currentSymbol = symbol;
            currentCompany = company;
            currentPrice = price;
            
            document.getElementById('stockDetails').innerHTML = `<strong>${symbol}</strong> - ${company} @ <span class="stock-price">$${price.toFixed(2)}</span> per share`;
            updateTotalCost();
            
            resetForm();
            
            document.getElementById('paymentModal').style.display = 'block';
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            document.querySelector('.close-modal').addEventListener('click', closeModal);
            
            window.onclick = function(event) {
                if (event.target == document.getElementById('paymentModal')) {
                    closeModal();
                }
                if (event.target == document.getElementById('successModal')) {
                    closeSuccessModal();
                }
            }
            
            document.getElementById('decrease').addEventListener('click', function() {
                const quantityInput = document.getElementById('buyQuantity');
                const currentVal = parseInt(quantityInput.value) || 1;
                if (currentVal > 1) {
                    quantityInput.value = currentVal - 1;
                    updateTotalCost();
                }
            });
            
            document.getElementById('increase').addEventListener('click', function() {
                const quantityInput = document.getElementById('buyQuantity');
                const currentVal = parseInt(quantityInput.value) || 1;
                quantityInput.value = currentVal + 1;
                updateTotalCost();
            });
            
            document.getElementById('buyQuantity').addEventListener('change', function() {
                updateTotalCost();
                const quantity = this.value;
                const quantityValid = quantity && parseInt(quantity) > 0;
                showError('buyQuantity', 'quantityError', !quantityValid);
            });
            
            document.getElementById('cardNumber').addEventListener('input', function() {
                formatCardNumber(this);
            });
            
            document.getElementById('expDate').addEventListener('input', function() {
                formatExpiryDate(this);
            });
            
            document.getElementById('cardNumber').addEventListener('blur', function() {
                const cardNumber = this.value.replace(/\s/g, '');
                const cardNumberValid = /^[0-9]{15,19}$/.test(cardNumber);
                showError('cardNumber', 'cardNumberError', !cardNumberValid);
            });
            
            document.getElementById('expDate').addEventListener('blur', function() {
                const expDate = this.value;
                const expDatePattern = /^(0[1-9]|1[0-2])\/([0-9]{2})$/;
                let expDateValid = expDatePattern.test(expDate);
                
                if (expDateValid) {
                    const [month, year] = expDate.split('/');
                    const expiry = new Date(2000 + parseInt(year), parseInt(month) - 1);
                    const today = new Date();
                    expDateValid = expiry > today;
                }
                
                showError('expDate', 'expDateError', !expDateValid);
            });
            
            document.getElementById('cvv').addEventListener('blur', function() {
                const cvv = this.value;
                const cvvValid = /^[0-9]{3,4}$/.test(cvv);
                showError('cvv', 'cvvError', !cvvValid);
            });
            
            document.getElementById('cardName').addEventListener('blur', function() {
                const cardName = this.value.trim();
                const cardNameValid = cardName !== '';
                showError('cardName', 'cardNameError', !cardNameValid);
            });
        });
    </script>
</body>
</html>