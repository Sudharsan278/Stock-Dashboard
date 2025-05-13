package authentication;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    public AdminServlet() {
        super();
    }
    
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setStatus(HttpServletResponse.SC_OK);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        setupCorsHeaders(response);
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        try {
            Connection con = DBConnection.getConnection();
            String sql = "SELECT ID, NAME, EMAIL, CREATED_AT FROM Users";
            PreparedStatement stmt = con.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            
            JSONArray users = new JSONArray();
            
            while (rs.next()) {
            	System.out.println(rs.getString("NAME"));
                JSONObject user = new JSONObject();
                user.put("id", rs.getInt("ID"));
                user.put("name", rs.getString("NAME"));
                user.put("email", rs.getString("EMAIL"));
                user.put("createdAt", rs.getString("CREATED_AT"));
                users.put(user);
            }
            
            jsonResponse.put("success", true);
            jsonResponse.put("users", users);
            
            rs.close();
            stmt.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Failed to retrieve users: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        setupCorsHeaders(response);
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        try {
            StringBuilder buffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
            }
            
            String body = buffer.toString();
            Map<String, String> parameters = parseFormData(body);
            
            String idStr = parameters.get("id");
            int id = Integer.parseInt(idStr); 
            
            String name = parameters.get("name");
            String email = parameters.get("email");
            String password = parameters.get("password");
            
            System.out.println(id + " " + name + " " + email + " " + password);
            
            
            Connection con = DBConnection.getConnection();

            String sql;
            PreparedStatement stmt;
            
            if (password != null && !password.trim().isEmpty()) {
                String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
                sql = "UPDATE Users SET NAME = ?, EMAIL = ?, PASSWORD = ? WHERE ID = ?";
                stmt = con.prepareStatement(sql);
                stmt.setString(1, name);
                stmt.setString(2, email);
                stmt.setString(3, hashedPassword);
                stmt.setInt(4, id);
            } else {
                sql = "UPDATE Users SET NAME = ?, EMAIL = ? WHERE ID = ?";
                stmt = con.prepareStatement(sql);
                stmt.setString(1, name);
                stmt.setString(2, email);
                stmt.setInt(3, id);
            }
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                jsonResponse.put("success", true);
                jsonResponse.put("message", "User updated successfully");
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "User not found or no changes made");
            }
            
            stmt.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Failed to update user: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
    }

   
    private Map<String, String> parseFormData(String formData) {
        Map<String, String> map = new HashMap<>();
        String[] pairs = formData.split("&");
        for (String pair : pairs) {
            int idx = pair.indexOf("=");
            try {
                String key = URLDecoder.decode(pair.substring(0, idx), "UTF-8");
                String value = URLDecoder.decode(pair.substring(idx + 1), "UTF-8");
                map.put(key, value);
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        }
        return map;
    }
    
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        setupCorsHeaders(response);
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
       
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            
            Connection con = DBConnection.getConnection();
            String sql = "DELETE FROM Users WHERE ID = ?";
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setInt(1, id);
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                jsonResponse.put("success", true);
                jsonResponse.put("message", "User deleted successfully");
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "User not found");
            }
            
            stmt.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Failed to delete user: " + e.getMessage());
        }
        
        out.print(jsonResponse.toString());
    }
    
    private void setupCorsHeaders(HttpServletResponse response) {
        response.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
    }
}