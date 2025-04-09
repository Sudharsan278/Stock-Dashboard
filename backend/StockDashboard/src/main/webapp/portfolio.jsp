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
    <%
    
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
                <li><a href="http://localhost/StockDashboard/contact.php">Contact</a></li>
                <li><a href="http://localhost:8080/StockDashboard/portfolio.jsp">Portfolio</a></li>                
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

    <!-- Payment Modal -->
    <div id="paymentModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2>Purchase Stocks</h2>
            </div>
            <div class="modal-body">
                <div class="purchase-info">
                    <div class="purchase-item">
                        <span id="stockDetails"></span>
                    </div>
                    <div class="form-group quantity-control">
                        <label for="buyQuantity">Quantity</label>
                        <div class="quantity-input">
                            <button type="button" id="decrease">−</button>
                            <input type="number" id="buyQuantity" name="buyQuantity" value="1" min="1">
                            <button type="button" id="increase">+</button>
                        </div>
                        <div class="error-message" id="quantityError">Please enter a valid quantity</div>
                    </div>
                    <div class="purchase-total">
                        <span>Total Cost: </span>
                        <span id="totalCost" class="highlighted-cost"></span>
                    </div>
                </div>

                <div class="payment-method">
                    <h3>Payment Method</h3>
                    <div class="payment-options">
                        <div class="payment-option">
                            <input type="radio" id="credit-card" name="payment-method" checked>
                            <label for="credit-card">
                                <span class="payment-icon"><i class="far fa-credit-card"></i></span>
                                Credit Card
                            </label>
                        </div>
                        <div class="payment-option">
                            <input type="radio" id="paypal" name="payment-method">
                            <label for="paypal">
                                <span class="payment-icon"><i class="fab fa-paypal"></i></span>
                                PayPal
                            </label>
                        </div>
                        <div class="payment-option">
                            <input type="radio" id="bank-transfer" name="payment-method">
                            <label for="bank-transfer">
                                <span class="payment-icon"><i class="fas fa-university"></i></span>
                                Bank Transfer
                            </label>
                        </div>
                    </div>
                </div>

                <div class="payment-form" id="paymentForm">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="cardName">Cardholder Name *</label>
                            <input type="text" id="cardName" placeholder="John Doe">
                            <div class="error-message" id="cardNameError">Please enter the cardholder name</div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="cardNumber">Card Number *</label>
                            <div class="card-input">
                                <input type="text" id="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19">
                                <span class="card-icons">
                                    <i class="fab fa-cc-visa"></i>
                                    <i class="fab fa-cc-mastercard"></i>
                                    <i class="fab fa-cc-amex"></i>
                                </span>
                            </div>
                            <div class="error-message" id="cardNumberError">Please enter a valid card number</div>
                        </div>
                    </div>
                    <div class="form-row two-col">
                        <div class="form-group">
                            <label for="expDate">Expiry Date *</label>
                            <input type="text" id="expDate" placeholder="MM/YY" maxlength="5">
                            <div class="error-message" id="expDateError">Please enter a valid expiry date (MM/YY)</div>
                        </div>
                        <div class="form-group">
                            <label for="cvv">CVV *</label>
                            <input type="text" id="cvv" placeholder="123" maxlength="4">
                            <div class="error-message" id="cvvError">Please enter a valid CVV</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="cancel-btn" onclick="closeModal()">Cancel</button>
                <button class="process-btn" onclick="validateAndProcess()">
                    <i class="fas fa-lock"></i> Process Payment
                </button>
            </div>
        </div>
    </div>

    <!-- Processing Overlay -->
    <div id="processingOverlay" class="processing-overlay">
        <div class="processing-content">
            <div class="loader"></div>
            <p>Processing your payment...</p>
        </div>
    </div>

    <!-- Success Modal -->
    <div id="successModal" class="modal success-modal">
        <div class="modal-content">
            <div class="success-header">
                <div class="success-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h2>Payment Successful!</h2>
            </div>
            <div class="modal-body">
                <p>Your stock purchase has been completed successfully.</p>
                <div id="successDetails" class="success-details"></div>
                <p class="confirmation-message">A confirmation email has been sent to your registered email address.</p>
            </div>
            <div class="modal-footer">
                <button class="done-btn" onclick="closeSuccessModal()">Done</button>
            </div>
        </div>
    </div>
    <script>
        // Global variables
        let currentSymbol = '';
        let currentCompany = '';
        let currentPrice = 0;
        
        // Open buy modal
        function openBuyModal(symbol, company, price) {
            currentSymbol = symbol;
            currentCompany = company;
            currentPrice = price;
            
            document.getElementById('stockDetails').innerHTML = `<strong>${symbol}</strong> - ${company} @ <span class="stock-price">$${price.toFixed(2)}</span> per share`;
            updateTotalCost();
            
            // Reset form and clear error messages
            resetForm();
            
            document.getElementById('paymentModal').style.display = 'block';
        }
        
        // Reset form and clear all error messages
        function resetForm() {
            // Cannot use reset() on an element ID - need to create a form reference
            const inputs = document.querySelectorAll('#paymentForm input');
            inputs.forEach(input => {
                input.value = '';
            });
            
            // Clear all error messages
            const errorMessages = document.querySelectorAll('.error-message');
            errorMessages.forEach(errorMsg => {
                errorMsg.classList.remove('visible');
            });
            
            // Clear input errors
            inputs.forEach(input => {
                input.classList.remove('input-error');
            });
            
            // Reset quantity to 1
            document.getElementById('buyQuantity').value = 1;
        }
        
        // Close modal
        function closeModal() {
            document.getElementById('paymentModal').style.display = 'none';
        }
        
        // Close success modal
        function closeSuccessModal() {
            document.getElementById('successModal').style.display = 'none';
        }
        
        // Update total cost when quantity changes
        function updateTotalCost() {
            const quantity = parseInt(document.getElementById('buyQuantity').value) || 1;
            const total = quantity * currentPrice;
            document.getElementById('totalCost').textContent = `$${total.toFixed(2)}`;
        }
        
        // Show error
        function showError(inputId, errorId, isError) {
            const input = document.getElementById(inputId);
            const errorElement = document.getElementById(errorId);
            
            if (isError) {
                input.classList.add('input-error');
                errorElement.classList.add('visible');
            } else {
                input.classList.remove('input-error');
                errorElement.classList.remove('visible');
            }
        }
        
        // Validate form inputs
        function validateForm() {
            let isValid = true;
            
            // Validate quantity
            const quantity = document.getElementById('buyQuantity').value;
            const quantityValid = quantity && parseInt(quantity) > 0;
            showError('buyQuantity', 'quantityError', !quantityValid);
            if (!quantityValid) isValid = false;
            
            // Only validate payment details if credit card is selected
            if (document.getElementById('credit-card').checked) {
                // Validate cardholder name
                const cardName = document.getElementById('cardName').value.trim();
                const cardNameValid = cardName !== '';
                showError('cardName', 'cardNameError', !cardNameValid);
                if (!cardNameValid) isValid = false;
                
                // Validate card number (should be 16-19 digits, spaces allowed)
                const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
                const cardNumberValid = /^[0-9]{15,19}$/.test(cardNumber);
                showError('cardNumber', 'cardNumberError', !cardNumberValid);
                if (!cardNumberValid) isValid = false;
                
                // Validate expiry date (format MM/YY)
                const expDate = document.getElementById('expDate').value;
                const expDatePattern = /^(0[1-9]|1[0-2])\/([0-9]{2})$/;
                let expDateValid = expDatePattern.test(expDate);
                
                // Check if date is in the future
                if (expDateValid) {
                    const [month, year] = expDate.split('/');
                    const expiry = new Date(2000 + parseInt(year), parseInt(month) - 1);
                    const today = new Date();
                    expDateValid = expiry > today;
                }
                
                showError('expDate', 'expDateError', !expDateValid);
                if (!expDateValid) isValid = false;
                
                // Validate CVV (3-4 digits)
                const cvv = document.getElementById('cvv').value;
                const cvvValid = /^[0-9]{3,4}$/.test(cvv);
                showError('cvv', 'cvvError', !cvvValid);
                if (!cvvValid) isValid = false;
            }
            
            return isValid;
        }
        
        // Validate and process payment
        function validateAndProcess() {
            if (validateForm()) {
                processPayment();
            }
        }
        
        // Process payment
        function processPayment() {
            const quantity = parseInt(document.getElementById('buyQuantity').value) || 1;
            
            // Show processing overlay
            document.getElementById('processingOverlay').style.display = 'flex';
            
            // Simulate processing time (3 seconds)
            setTimeout(() => {
                // Hide processing overlay
                document.getElementById('processingOverlay').style.display = 'none';
                
                // Close payment modal
                document.getElementById('paymentModal').style.display = 'none';
                
                // Get current date and time string
                const dateTimeStr = new Date().toLocaleString();
                
                // Populate success details
                const total = quantity * currentPrice;
                document.getElementById('successDetails').innerHTML = `
                    <div class="purchase-summary">
                        <div class="summary-row">
                            <span>Stock:</span>
                            <span>${currentSymbol} (${currentCompany})</span>
                        </div>
                        <div class="summary-row">
                            <span>Quantity:</span>
                            <span>${quantity} shares</span>
                        </div>
                        <div class="summary-row">
                            <span>Price per Share:</span>
                            <span>$${currentPrice.toFixed(2)}</span>
                        </div>
                        <div class="summary-row total">
                            <span>Total Amount:</span>
                            <span>$${total.toFixed(2)}</span>
                        </div>
                        <div class="summary-row">
                            <span>Transaction ID:</span>
                            <span>TRX${Math.floor(Math.random() * 1000000)}</span>
                        </div>
                        <div class="summary-row">
                            <span>Date & Time:</span>
                            <span>${dateTimeStr}</span>
                        </div>
                    </div>
                `;
                
                // Show success modal
                document.getElementById('successModal').style.display = 'block';
            }, 3000);
        }
        
        // Format card number with spaces
        function formatCardNumber(input) {
            let value = input.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
            let formattedValue = '';
            
            for (let i = 0; i < value.length; i++) {
                if (i > 0 && i % 4 === 0) {
                    formattedValue += ' ';
                }
                formattedValue += value[i];
            }
            
            input.value = formattedValue;
        }
        
        // Format expiry date
        function formatExpiryDate(input) {
            let value = input.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
            
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            
            input.value = value;
        }
        
        // Event listeners
        document.addEventListener('DOMContentLoaded', function() {
            // Close modal when clicking on X
            document.querySelector('.close-modal').addEventListener('click', closeModal);
            
            // Close modal when clicking outside
            window.onclick = function(event) {
                if (event.target == document.getElementById('paymentModal')) {
                    closeModal();
                }
                if (event.target == document.getElementById('successModal')) {
                    closeSuccessModal();
                }
            }
            
            // Quantity controls
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
                // Validate quantity on change
                const quantity = this.value;
                const quantityValid = quantity && parseInt(quantity) > 0;
                showError('buyQuantity', 'quantityError', !quantityValid);
            });
            
            // Format card number when typing
            document.getElementById('cardNumber').addEventListener('input', function() {
                formatCardNumber(this);
            });
            
            // Format expiry date when typing
            document.getElementById('expDate').addEventListener('input', function() {
                formatExpiryDate(this);
            });
            
            // Real-time validation for card number
            document.getElementById('cardNumber').addEventListener('blur', function() {
                const cardNumber = this.value.replace(/\s/g, '');
                const cardNumberValid = /^[0-9]{15,19}$/.test(cardNumber);
                showError('cardNumber', 'cardNumberError', !cardNumberValid);
            });
            
            // Real-time validation for expiry date
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
            
            // Real-time validation for CVV
            document.getElementById('cvv').addEventListener('blur', function() {
                const cvv = this.value;
                const cvvValid = /^[0-9]{3,4}$/.test(cvv);
                showError('cvv', 'cvvError', !cvvValid);
            });
            
            // Real-time validation for cardholder name
            document.getElementById('cardName').addEventListener('blur', function() {
                const cardName = this.value.trim();
                const cardNameValid = cardName !== '';
                showError('cardName', 'cardNameError', !cardNameValid);
            });
        });
    </script>
</body>
</html>