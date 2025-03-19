package authentication;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Servlet implementation class SignupServlet
 */
@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SignupServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	 @Override
	    protected void doOptions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	        response.setHeader("Access-Control-Allow-Origin", "*");
	        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
	        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
	        response.setStatus(HttpServletResponse.SC_OK);
	    }
	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	 protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	        
		 response.setHeader("Access-Control-Allow-Origin", "*"); 
		    response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
		    response.setHeader("Access-Control-Allow-Headers", "Content-Type");
		    response.setContentType("text/plain");

		    try (PrintWriter out = response.getWriter()) {
		        String email = request.getParameter("email");
		        String password = request.getParameter("password");
		        String name = request.getParameter("name");

		        System.out.println("Signup Request - Name: " + name + ", Email: " + email);
		        
		        if (name == null || email == null || password == null || 
		            name.isEmpty() || email.isEmpty() || password.isEmpty()) {
		            out.write("Missing required fields");
		            return;
		        }

		        try (Connection conn = DBConnection.getConnection()) {
		            if (conn == null) {
		                out.write("Database connection failed");
		                return;
		            }

		            String checkEmailQuery = "SELECT 1 FROM Users WHERE EMAIL = ?";
		            try (PreparedStatement stm = conn.prepareStatement(checkEmailQuery)) {
		                stm.setString(1, email);
		                stm.setMaxRows(1);

		                try (ResultSet rs = stm.executeQuery()) {
		                    if (rs.next()) {
		                        out.write("Email already registered");
		                        return;
		                    }
		                }
		            }

		            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(14));

		            String insertUserQuery = "INSERT INTO Users (NAME, EMAIL, PASSWORD) VALUES (?, ?, ?)";
		            try (PreparedStatement stm = conn.prepareStatement(insertUserQuery)) {
		                stm.setString(1, name);
		                stm.setString(2, email);
		                stm.setString(3, hashedPassword);

		                int rowsAffected = stm.executeUpdate();
		                if (rowsAffected > 0) {
		                    // Create cookies for user details
		                    Cookie nameCookie = new Cookie("username", name);
		                    Cookie emailCookie = new Cookie("useremail", email);

		                    // Set cookie expiration time (e.g., 1 day)
		                    nameCookie.setMaxAge(24 * 60 * 60);
		                    emailCookie.setMaxAge(24 * 60 * 60);

		                    // Secure cookies (optional, remove for development)
		                    nameCookie.setHttpOnly(true);
		                    emailCookie.setHttpOnly(true);

		                    // Add cookies to the response
		                    response.addCookie(nameCookie);
		                    response.addCookie(emailCookie);

		                    out.write("success");
		                } else {
		                    out.write("failure");
		                }
		            }
		        } catch (SQLException ex) {
		            ex.printStackTrace();
		            out.write("Database error");
		        }
		    }
	 }
}
