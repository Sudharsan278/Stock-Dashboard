<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%!
private String generateTransactionId() {
    return "TRX" + Math.floor(Math.random() * 1000000);
}

private String getCurrentDateTime() {
    return new java.util.Date().toLocaleString();
}
%>

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
                        <input type="radio" id="credit-card" name="payment-method" value="credit-card" checked>
                        <label for="credit-card">
                            <span class="payment-icon"><i class="far fa-credit-card"></i></span>
                            Credit Card
                        </label>
                    </div>
                    <div class="payment-option">
                        <input type="radio" id="paypal" name="payment-method" value="paypal">
                        <label for="paypal">
                            <span class="payment-icon"><i class="fab fa-paypal"></i></span>
                            PayPal
                        </label>
                    </div>
                    <div class="payment-option">
                        <input type="radio" id="bank-transfer" name="payment-method" value="bank-transfer">
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

<div id="processingOverlay" class="processing-overlay">
    <div class="processing-content">
        <div class="loader"></div>
        <p>Processing your payment...</p>
    </div>
</div>

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
            <div id="successDetails" class="success-details">
                <div class="purchase-summary">
                    <div class="summary-row">
                        <span>Stock:</span>
                        <span>AAPL (Apple Inc.)</span>
                    </div>
                    <div class="summary-row">
                        <span>Quantity:</span>
                        <span>10 shares</span>
                    </div>
                    <div class="summary-row">
                        <span>Price per Share:</span>
                        <span>$178.72</span>
                    </div>
                    <div class="summary-row total">
                        <span>Total Amount:</span>
                        <span>$1,787.20</span>
                    </div>
                    <div class="summary-row">
                        <span>Transaction ID:</span>
                        <span>TRX483921</span>
                    </div>
                    <div class="summary-row">
                        <span>Date & Time:</span>
                        <span>Apr 17, 2025, 10:35 AM</span>
                    </div>
                </div>
            </div>
            <p class="confirmation-message">A confirmation email has been sent to your registered email address.</p>
        </div>
        <div class="modal-footer">
            <button class="done-btn" onclick="closeSuccessModal()">Done</button>
        </div>
    </div>
</div>

<script>
    function resetForm() {
        const inputs = document.querySelectorAll('#paymentForm input');
        inputs.forEach(input => {
            input.value = '';
        });
        
        const errorMessages = document.querySelectorAll('.error-message');
        errorMessages.forEach(errorMsg => {
            errorMsg.classList.remove('visible');
        });
        
        inputs.forEach(input => {
            input.classList.remove('input-error');
        });
        
        document.getElementById('buyQuantity').value = 1;
    }
    
    function closeModal() {
        document.getElementById('paymentModal').style.display = 'none';
    }
    
    function closeSuccessModal() {
        document.getElementById('successModal').style.display = 'none';
    }
    
    function updateTotalCost() {
        const quantity = parseInt(document.getElementById('buyQuantity').value) || 1;
        const total = quantity * currentPrice;
        document.getElementById('totalCost').textContent = `$${total.toFixed(2)}`;
    }
    
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
    
    function validateForm() {
        let isValid = true;
        
        const quantity = document.getElementById('buyQuantity').value;
        const quantityValid = quantity && parseInt(quantity) > 0;
        
        showError('buyQuantity', 'quantityError', !quantityValid);
        
        if (!quantityValid) isValid = false;
        
        if (document.getElementById('credit-card').checked) {
            const cardName = document.getElementById('cardName').value.trim();
            const cardNameValid = cardName !== '';
            showError('cardName', 'cardNameError', !cardNameValid);
            if (!cardNameValid) isValid = false;
            
            const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
            const cardNumberValid = /^[0-9]{15,19}$/.test(cardNumber);
            showError('cardNumber', 'cardNumberError', !cardNumberValid);
            if (!cardNumberValid) isValid = false;
            
            const expDate = document.getElementById('expDate').value;
            const expDatePattern = /^(0[1-9]|1[0-2])\/([0-9]{2})$/;
            let expDateValid = expDatePattern.test(expDate);
            
            if (expDateValid) {
                const [month, year] = expDate.split('/');
                const expiry = new Date(2000 + parseInt(year), parseInt(month) - 1);
                const today = new Date();
                expDateValid = expiry > today;
            }
            
            showError('expDate', 'expDateError', !expDateValid);
            if (!expDateValid) isValid = false;
            
            const cvv = document.getElementById('cvv').value;
            const cvvValid = /^[0-9]{3,4}$/.test(cvv);
            showError('cvv', 'cvvError', !cvvValid);
            if (!cvvValid) isValid = false;
        }
        
        return isValid;
    }
    
    function validateAndProcess() {
        if (validateForm()) {
            processPayment();
        }
    }
    
    function processPayment() {
        const quantity = parseInt(document.getElementById('buyQuantity').value) || 1;
        const transactionId = "<%= generateTransactionId() %>";
        const paymentMethodRadios = document.getElementsByName('payment-method');
        let paymentMethod = '';
        
        for (let i = 0; i < paymentMethodRadios.length; i++) {
            if (paymentMethodRadios[i].checked) {
                paymentMethod = paymentMethodRadios[i].value;
                break;
            }
        }
        
        document.getElementById('processingOverlay').style.display = 'flex';
        
        // Create a regular form data object
        const params = new URLSearchParams();
        params.append('transactionId', transactionId);
        params.append('symbol', currentSymbol);
        params.append('companyName', currentCompany);
        params.append('quantity', quantity.toString());
        params.append('price', currentPrice.toString());
        params.append('paymentMethod', paymentMethod);
        
        // Add card details if payment method is credit card
        if (paymentMethod === 'credit-card') {
            params.append('cardNumber', document.getElementById('cardNumber').value);
            params.append('cardHolder', document.getElementById('cardName').value);
        }
        
        // Send AJAX request to process payment
        fetch('processPayment', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: params.toString()
        })
        .then(response => response.json())
        .then(data => {
            document.getElementById('processingOverlay').style.display = 'none';
            
            if (data.success) {
                document.getElementById('paymentModal').style.display = 'none';
                
                // No longer calculating values dynamically - using hard-coded success data
                document.getElementById('successModal').style.display = 'block';
            } else {
                alert('Payment processing failed: ' + data.message);
            }
        })
        .catch(error => {
            document.getElementById('processingOverlay').style.display = 'none';
            console.error('Error processing payment:', error);
            alert('Error processing payment: ' + error);
        });
    }
    
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
    
    function formatExpiryDate(input) {
        let value = input.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
        
        if (value.length >= 2) {
            value = value.substring(0, 2) + '/' + value.substring(2, 4);
        }
        
        input.value = value;
    }
</script>