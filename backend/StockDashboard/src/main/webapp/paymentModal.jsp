<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%!
private String generateTransactionId() {
    return "TRX" + String.format("%010d", (int)(Math.random() * 10000000000L));
}

private String getCurrentDateTime() {
    return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
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
                        <input type="radio" id="upi" name="payment-method" value="upi">
                        <label for="upi">
                            <span class="payment-icon"><i class="fas fa-mobile-alt"></i></span>
                            UPI
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

            <!-- Credit Card Payment Form -->
            <div class="payment-form" id="creditCardForm">
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
                        <div class="error-message" id="expDateError">Please enter a valid expiry date</div>
                    </div>
                    <div class="form-group">
                        <label for="cvv">CVV *</label>
                        <input type="text" id="cvv" placeholder="123" maxlength="4">
                        <div class="error-message" id="cvvError">Please enter a valid CVV</div>
                    </div>
                </div>
            </div>

            <!-- UPI Payment Form -->
            <div class="payment-form" id="upiForm" style="display: none;">
                <div class="upi-info">
                    <div class="upi-qr-container">
                        <div class="qr-code">
                            <i class="fas fa-qrcode fa-5x"></i>
                        </div>
                        <p>Scan QR code to pay</p>
                    </div>
                    <div class="upi-details">
                        <p class="upi-id">UPI ID: <strong>stockpro@ybl</strong></p>
                        <p>Please complete the payment using your UPI app and enter the transaction ID below</p>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="upiTransactionId">UPI Transaction ID *</label>
                        <input type="text" id="upiTransactionId" placeholder="Enter the transaction ID from your UPI app">
                        <div class="error-message" id="upiTransactionIdError">Please enter a valid transaction ID</div>
                    </div>
                </div>
            </div>

            <!-- Bank Transfer Form -->
            <div class="payment-form" id="bankTransferForm" style="display: none;">
                <div class="bank-info">
                    <p>Please use the following bank details to complete your transfer:</p>
                    <div class="bank-details">
                        <div class="detail-row">
                            <span class="detail-label">Account Name:</span>
                            <span class="detail-value">StockPro Trading</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Account Number:</span>
                            <span class="detail-value">1234567890</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">IFSC Code:</span>
                            <span class="detail-value">SBIN0001234</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Bank Name:</span>
                            <span class="detail-value">State Bank of India</span>
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="senderAccountNumber">Your Account Number *</label>
                        <input type="text" id="senderAccountNumber" placeholder="Your bank account number">
                        <div class="error-message" id="senderAccountNumberError">Please enter a valid account number</div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="senderIfscCode">Your Bank IFSC Code *</label>
                        <input type="text" id="senderIfscCode" placeholder="IFSC Code of your bank">
                        <div class="error-message" id="senderIfscCodeError">Please enter a valid IFSC code</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="cancel-btn" onclick="closeModal()">Cancel</button>
            <button class="process-btn" onclick="validateAndProcess()">
                <i class="fas fa-lock"></i> Complete Purchase
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
                        <span id="summaryStock"></span>
                    </div>
                    <div class="summary-row">
                        <span>Quantity:</span>
                        <span id="summaryQuantity"></span>
                    </div>
                    <div class="summary-row">
                        <span>Price per Share:</span>
                        <span id="summaryPrice"></span>
                    </div>
                    <div class="summary-row total">
                        <span>Total Amount:</span>
                        <span id="summaryTotal"></span>
                    </div>
                    <div class="summary-row">
                        <span>Payment Method:</span>
                        <span id="summaryPaymentMethod"></span>
                    </div>
                    <div class="summary-row">
                        <span>Transaction ID:</span>
                        <span id="summaryTransactionId"></span>
                    </div>
                    <div class="summary-row">
                        <span>Date & Time:</span>
                        <span id="summaryDateTime"></span>
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
    // Form display logic based on payment method selection
    document.addEventListener('DOMContentLoaded', function() {
        const paymentMethods = document.getElementsByName('payment-method');
        paymentMethods.forEach(method => {
            method.addEventListener('change', function() {
                togglePaymentForms(this.value);
            });
        });
    });

    function togglePaymentForms(paymentMethod) {
        document.getElementById('creditCardForm').style.display = 'none';
        document.getElementById('upiForm').style.display = 'none';
        document.getElementById('bankTransferForm').style.display = 'none';
        
        switch(paymentMethod) {
            case 'credit-card':
                document.getElementById('creditCardForm').style.display = 'block';
                break;
            case 'upi':
                document.getElementById('upiForm').style.display = 'block';
                break;
            case 'bank-transfer':
                document.getElementById('bankTransferForm').style.display = 'block';
                break;
        }
    }

    function resetForm() {
        const inputs = document.querySelectorAll('.payment-form input');
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
        
        // Reset to credit card as default payment method
        document.getElementById('credit-card').checked = true;
        togglePaymentForms('credit-card');
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
        
        // Validate quantity
        const quantity = document.getElementById('buyQuantity').value;
        const quantityValid = quantity && parseInt(quantity) > 0;
        showError('buyQuantity', 'quantityError', !quantityValid);
        if (!quantityValid) isValid = false;
        
        // Get selected payment method
        const paymentMethodRadios = document.getElementsByName('payment-method');
        let paymentMethod = '';
        
        for (let i = 0; i < paymentMethodRadios.length; i++) {
            if (paymentMethodRadios[i].checked) {
                paymentMethod = paymentMethodRadios[i].value;
                break;
            }
        }
        
        // Validate based on payment method
        switch(paymentMethod) {
            case 'credit-card':
                isValid = validateCreditCardForm() && isValid;
                break;
            case 'upi':
                isValid = validateUpiForm() && isValid;
                break;
            case 'bank-transfer':
                isValid = validateBankTransferForm() && isValid;
                break;
        }
        
        return isValid;
    }
    
    function validateCreditCardForm() {
        let isValid = true;
        
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
        
        return isValid;
    }
    
    function validateUpiForm() {
        let isValid = true;
        
        const upiTransactionId = document.getElementById('upiTransactionId').value.trim();
        const upiTransactionIdValid = upiTransactionId.length >= 6;
        showError('upiTransactionId', 'upiTransactionIdError', !upiTransactionIdValid);
        if (!upiTransactionIdValid) isValid = false;
        
        return isValid;
    }
    
    function validateBankTransferForm() {
        let isValid = true;
        
        const senderAccountNumber = document.getElementById('senderAccountNumber').value.trim();
        const accountNumberValid = /^[0-9]{9,18}$/.test(senderAccountNumber);
        showError('senderAccountNumber', 'senderAccountNumberError', !accountNumberValid);
        if (!accountNumberValid) isValid = false;
        
        const senderIfscCode = document.getElementById('senderIfscCode').value.trim();
        const ifscCodeValid = /^[A-Z]{4}0[A-Z0-9]{6}$/.test(senderIfscCode);
        showError('senderIfscCode', 'senderIfscCodeError', !ifscCodeValid);
        if (!ifscCodeValid) isValid = false;
        
        return isValid;
    }
    
    function validateAndProcess() {
        if (validateForm()) {
            processPayment();
        }
    }
    
    function processPayment() {
        const quantity = parseInt(document.getElementById('buyQuantity').value) || 1;
        const totalAmount = quantity * currentPrice;
        
        // Get payment method
        const paymentMethodRadios = document.getElementsByName('payment-method');
        let paymentMethod = '';
        let paymentMethodDisplay = '';
        
        for (let i = 0; i < paymentMethodRadios.length; i++) {
            if (paymentMethodRadios[i].checked) {
                paymentMethod = paymentMethodRadios[i].value;
                break;
            }
        }
        
        // Get transaction ID based on payment method
        let transactionId = '';
        
        switch(paymentMethod) {
            case 'credit-card':
                transactionId = "<%= generateTransactionId() %>";
                paymentMethodDisplay = 'Credit Card';
                break;
            case 'upi':
                transactionId = document.getElementById('upiTransactionId').value.trim();
                paymentMethodDisplay = 'UPI';
                break;
            case 'bank-transfer':
                transactionId = "<%= generateTransactionId() %>";
                paymentMethodDisplay = 'Bank Transfer';
                break;
        }
        
        document.getElementById('processingOverlay').style.display = 'flex';
        
        // Create a form data object with all payment details
        const params = new URLSearchParams();
        params.append('transactionId', transactionId);
        params.append('symbol', currentSymbol);
        params.append('companyName', currentCompany);
        params.append('quantity', quantity.toString());
        params.append('price', currentPrice.toString());
        params.append('totalAmount', totalAmount.toFixed(2));
        params.append('paymentMethod', paymentMethod);
        params.append('paymentDate', '<%= getCurrentDateTime() %>');
        
        // Add payment method specific details
        switch(paymentMethod) {
            case 'credit-card':
                params.append('cardNumber', document.getElementById('cardNumber').value.replace(/\s/g, '').substr(-4));
                params.append('cardHolder', document.getElementById('cardName').value);
                break;
            case 'upi':
                // UPI transaction ID is already added above
                break;
            case 'bank-transfer':
                params.append('senderAccountNumber', document.getElementById('senderAccountNumber').value);
                params.append('senderIfscCode', document.getElementById('senderIfscCode').value);
                break;
        }
        
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
                
                // Update success modal with purchase details
                document.getElementById('summaryStock').textContent = `${currentSymbol} (${currentCompany})`;
                document.getElementById('summaryQuantity').textContent = `${quantity} shares`;
                document.getElementById('summaryPrice').textContent = `$${currentPrice.toFixed(2)}`;
                document.getElementById('summaryTotal').textContent = `$${totalAmount.toFixed(2)}`;
                document.getElementById('summaryPaymentMethod').textContent = paymentMethodDisplay;
                document.getElementById('summaryTransactionId').textContent = transactionId;
                document.getElementById('summaryDateTime').textContent = '<%= new java.text.SimpleDateFormat("MMM dd, yyyy, hh:mm a").format(new java.util.Date()) %>';
                
                document.getElementById('successModal').style.display = 'block';
            } else {
                alert('Payment processing failed: ' + (data.message || 'Unknown error'));
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
    });
</script>