package portfolio;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONObject;

@WebServlet("/processPayment")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/stock_dashboard";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "2782004";  
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        JSONObject jsonResponse = new JSONObject();
        
        try {
            String transactionId = request.getParameter("transactionId");
            String symbol = request.getParameter("symbol");
            String companyName = request.getParameter("companyName");
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            double price = Double.parseDouble(request.getParameter("price"));
            double totalAmount = Double.parseDouble(request.getParameter("totalAmount"));
            String paymentMethod = request.getParameter("paymentMethod");
            String paymentDate = request.getParameter("paymentDate");
            
            String additionalDetails = "";
            
            switch(paymentMethod) {
                case "credit-card":
                    String cardNumber = request.getParameter("cardNumber"); 
                    String cardHolder = request.getParameter("cardHolder");
                    additionalDetails = "Card ending in " + cardNumber + ", Holder: " + cardHolder;
                    break;
                    
                case "upi":
                    additionalDetails = "UPI Transaction";
                    break;
                    
                case "bank-transfer":
                    String senderAccountNumber = request.getParameter("senderAccountNumber");
                    String senderIfscCode = request.getParameter("senderIfscCode");
                    additionalDetails = "Account: " + senderAccountNumber + ", IFSC: " + senderIfscCode;
                    break;
            }
            
            boolean paymentSaved = savePaymentToDatabase(
                transactionId, 
                symbol, 
                companyName, 
                quantity, 
                price, 
                totalAmount, 
                paymentMethod, 
                paymentDate,
                additionalDetails
            );
            
            if (paymentSaved) {
                // Add the stock to user's portfolio if payment is successful
                // This assumes the PortfolioServlet already has a method to add stocks
                // and the stocks are stored in a session attribute
                
                // You'd need to implement the actual stock add logic here or call the relevant method
                
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Payment processed successfully");
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Failed to save payment information");
            }
            
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error processing payment: " + e.getMessage());
            e.printStackTrace();
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private boolean savePaymentToDatabase(
            String transactionId, 
            String symbol, 
            String companyName, 
            int quantity, 
            double price, 
            double totalAmount, 
            String paymentMethod, 
            String paymentDate,
            String additionalDetails) {
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            // Load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection to the database
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // SQL statement to insert payment record
            String sql = "INSERT INTO payments (transaction_id, stock_symbol, company_name, quantity, " +
                         "price_per_share, total_amount, payment_method, payment_date, additional_details) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, transactionId);
            stmt.setString(2, symbol);
            stmt.setString(3, companyName);
            stmt.setInt(4, quantity);
            stmt.setDouble(5, price);
            stmt.setDouble(6, totalAmount);
            stmt.setString(7, paymentMethod);
            stmt.setString(8, paymentDate);
            stmt.setString(9, additionalDetails);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            // Close resources
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}