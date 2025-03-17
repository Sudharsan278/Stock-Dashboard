package authentication;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

	private static final String DB_USER = "root";
	private static final String DB_PASSWORD = "2782004";
	private static final String DB_NAME = "stock_dashboard";
	private static final String JDBC_URL = "jdbc:mysql://localhost:3306/"+DB_NAME;
	
	public static Connection getConnection() {
		
		Connection conn = null;
		
		try {
			
			Class.forName("com.mysql.cj.jdbc.Driver");
			conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
			
		}catch(Exception ex) {
			ex.printStackTrace();
		}
		
		
		return conn;
	}
}
