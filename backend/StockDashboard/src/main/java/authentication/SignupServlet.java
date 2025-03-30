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

import org.json.JSONObject;
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
	        response.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
	        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
	        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
	        response.setHeader("Access-Control-Allow-Credentials", "true");
	        response.setStatus(HttpServletResponse.SC_OK);
	    }
	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	 protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	        		 
			response.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
	        response.setHeader("Access-Control-Allow-Credentials", "true");
	        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
	        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
	        response.setContentType("application/json");
	        
	        JSONObject jsonResponse = new JSONObject();

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

		                	Cookie userCookie = new Cookie("username", name);
		                	userCookie.setMaxAge(60 * 60 * 2);
		                	userCookie.setPath("/");
		                	userCookie.setDomain("127.0.0.1");
		                	userCookie.setHttpOnly(false);
		                	userCookie.setSecure(false);
		                	userCookie.setComment("SameSite=None");

		                	Cookie emailCookie = new Cookie("email", email);
		                	emailCookie.setMaxAge(60 * 60 * 2);
		                	emailCookie.setPath("/");
		                	emailCookie.setDomain("127.0.0.1");
		                	emailCookie.setHttpOnly(false);
		                	emailCookie.setSecure(false);
		                	emailCookie.setComment("SameSite=None");
		                	
		                	response.addCookie(userCookie);
		                	response.addCookie(emailCookie);
		                	
		                	jsonResponse.put("success", true);
		                	jsonResponse.put("username", name);
		                	jsonResponse.put("email", email);

		                	System.out.println("Cookie: - " + userCookie.getValue());
		                	System.out.println("Cookie" + userCookie.getMaxAge());
		                	System.out.println("Cookie: - " + emailCookie.getValue());

		                	System.out.println("123" + jsonResponse.toString());
		                	
		                	out.print(jsonResponse.toString());

		                } else {
 	                        jsonResponse.put("failure", true);
		                	out.print(jsonResponse.toString());
		                }
		                
		            }
		        } catch (SQLException ex) {
		            ex.printStackTrace();
		            out.write("Database error");
		        }
		    }
	 }
}