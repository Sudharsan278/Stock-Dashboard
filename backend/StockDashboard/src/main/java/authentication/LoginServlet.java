package authentication;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.mindrot.jbcrypt.BCrypt;


/**
 * Servlet implementation class LoginServlet
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginServlet() {
        super();
        // TODO Auto-generated constructor stub
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
		// TODO Auto-generated method stub
	
		 response.setHeader("Access-Control-Allow-Origin", "*");
	        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
	        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
	        response.setContentType("application/json");

	        PrintWriter out = response.getWriter();
	        JSONObject jsonResponse = new JSONObject();

	        String email = request.getParameter("email");
	        String password = request.getParameter("password");

	        System.out.println(email + password);

	        try {
	            Class.forName("com.mysql.cj.jdbc.Driver");
	            Connection con = DBConnection.getConnection();

	            String sql = "SELECT PASSWORD FROM Users WHERE EMAIL = ?";
	            PreparedStatement stmt = con.prepareStatement(sql);
	            stmt.setString(1, email);

	            ResultSet rs = stmt.executeQuery();

	            if (rs.next()) {
	                String hashedPassword = rs.getString("PASSWORD");

	                // Compare the entered password with the hashed password
	                if (BCrypt.checkpw(password, hashedPassword)) {
	                    jsonResponse.put("success", true);
	                } else {
	                    jsonResponse.put("success", false);
	                }
	            } else {
	                jsonResponse.put("success", false);
	            }

	            rs.close();
	            stmt.close();
	            con.close();
	        } catch (Exception e) {
	            e.printStackTrace();
	            jsonResponse.put("success", false);
	        }

	        out.print(jsonResponse.toString());
	        out.flush();
	    }
}
