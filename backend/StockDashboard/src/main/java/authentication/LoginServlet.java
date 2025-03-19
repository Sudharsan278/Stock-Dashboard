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

/**
 * Servlet implementation class LoginServlet
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public LoginServlet() {
        super();
    }

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:5500");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setStatus(HttpServletResponse.SC_OK);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:5500");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setContentType("application/json");

        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();

        String email = request.getParameter("email");
        String password = request.getParameter("password");

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

                    // Set cookies for username and email
                    Cookie userCookie = new Cookie("username", username);
                    userCookie.setPath("/");
                    userCookie.setDomain("localhost");
                    userCookie.setHttpOnly(false);
                    userCookie.setSecure(false);
                    userCookie.setMaxAge(60 * 60 * 24);
                    userCookie.setComment("SameSite=None");

                    Cookie emailCookie = new Cookie("email", email);
                    emailCookie.setPath("/");
                    emailCookie.setDomain("localhost");
                    emailCookie.setHttpOnly(false);
                    emailCookie.setSecure(false);
                    emailCookie.setMaxAge(60 * 60 * 24);
                    emailCookie.setComment("SameSite=None");

                    response.addCookie(userCookie);
                    response.addCookie(emailCookie);

                    jsonResponse.put("success", true);
                    jsonResponse.put("username", username);
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Invalid password");
                }
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "User not found");
            }

            rs.close();
            stmt.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "An error occurred");
        }

        out.print(jsonResponse.toString());
        out.flush();
    }
}
