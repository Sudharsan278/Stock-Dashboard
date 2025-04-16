package portfolio;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/processPayment")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    public PaymentServlet() {
        super();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
        	System.out.println("Received parameters:");
        	for (String paramName : request.getParameterMap().keySet()) {
        	    System.out.println(paramName + ": " + request.getParameter(paramName));
        	}
            // Extract payment details from request
            String transactionId = request.getParameter("transactionId");
            String stockSymbol = request.getParameter("symbol");
            String companyName = request.getParameter("companyName");
            String quantityStr = request.getParameter("quantity");          
            int quantity = 0; // Default value

            if (quantityStr != null && !quantityStr.isEmpty()) {
                quantity = Integer.parseInt(quantityStr);
            } else {
                throw new ServletException("Quantity parameter is required");
            }
            String priceStr = request.getParameter("price");
            double pricePerShare = 0.0;

            if (priceStr != null && !priceStr.isEmpty()) {
                pricePerShare = Double.parseDouble(priceStr);
            } else {
                throw new ServletException("Price parameter is required");
            }
            double totalAmount = quantity * pricePerShare;
            String paymentMethod = request.getParameter("paymentMethod");
            
            // Card details (in production, these should be encrypted)
            String cardNumber = request.getParameter("cardNumber");
            String cardHolder = request.getParameter("cardHolder");
            
            // For security, we'll only store the last 4 digits of the card number
            if (cardNumber != null && cardNumber.length() > 4) {
                cardNumber = "XXXX-XXXX-XXXX-" + cardNumber.substring(cardNumber.length() - 4);
            }
            
            // Store payment details in database
            storePaymentTransaction(transactionId, stockSymbol, companyName, quantity, 
                                   pricePerShare, totalAmount, paymentMethod, cardNumber, cardHolder);
            
            // Send success response
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":true,\"message\":\"Payment processed successfully\"}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Error processing payment: " + e.getMessage() + "\"}");
        }
    }
    
    private void storePaymentTransaction(String transactionId, String stockSymbol, 
            String companyName, int quantity, double pricePerShare, double totalAmount, 
            String paymentMethod, String cardNumber, String cardHolder) throws SQLException {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // Get connection from DatabaseConnection utility
            conn = DatabaseConnection.getConnection();
            
            // Prepare SQL statement
            String sql = "INSERT INTO payment_transactions (transaction_id, stock_symbol, company_name, " +
                         "quantity, price_per_share, total_amount, payment_method, card_number, card_holder) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, transactionId);
            pstmt.setString(2, stockSymbol);
            pstmt.setString(3, companyName);
            pstmt.setInt(4, quantity);
            pstmt.setDouble(5, pricePerShare);
            pstmt.setDouble(6, totalAmount);
            pstmt.setString(7, paymentMethod);
            pstmt.setString(8, cardNumber);
            pstmt.setString(9, cardHolder);
            
            // Execute the statement
            pstmt.executeUpdate();
            
        } finally {
            // Close resources
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            
            // Close connection using utility
            DatabaseConnection.closeConnection(conn);
        }
    }
}