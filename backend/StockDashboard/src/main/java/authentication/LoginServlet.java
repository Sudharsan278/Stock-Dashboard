package authentication;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    public LoginServlet() {
        super();
    }


    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setStatus(HttpServletResponse.SC_OK);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
     
    	   response.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
           response.setHeader("Access-Control-Allow-Credentials", "true");
           response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
           response.setHeader("Access-Control-Allow-Headers", "Content-Type");
           response.setContentType("application/json");

           PrintWriter out = response.getWriter();
           JSONObject jsonResponse = new JSONObject();

           String email = request.getParameter("email");
           String password = request.getParameter("password");
           
           System.out.println("Login: - "+email);
           
           try {
               Class.forName("com.mysql.cj.jdbc.Driver");
               Connection con = DBConnection.getConnection();

               String sql = "SELECT * FROM Users WHERE EMAIL = ?";
               PreparedStatement stmt = con.prepareStatement(sql);
               stmt.setString(1, email);
               ResultSet rs = stmt.executeQuery();
               
               if (rs.next()) {
               
            	   String hashedPassword = rs.getString("PASSWORD");
            	   
            	   if (BCrypt.checkpw(password, hashedPassword)) {
                       String username = rs.getString("NAME");
                       
                       Cookie userCookie = new Cookie("username", username);
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
                       jsonResponse.put("username", username);
                       jsonResponse.put("email", email);

                       
            	   }else {
            		   jsonResponse.put("success", false);
                       jsonResponse.put("message", "Invalid password");

            	   }
            	    rs.close();
                    stmt.close();
                    con.close();
               }   
           }catch(Exception ex) {
        	   ex.printStackTrace();
               jsonResponse.put("success", false);
               jsonResponse.put("message", "An error occurred");

           }           
           out.print(jsonResponse.toString());
    }
}