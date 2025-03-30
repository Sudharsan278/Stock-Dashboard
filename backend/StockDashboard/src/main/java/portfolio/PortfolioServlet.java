package portfolio;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class PortfolioServlet
 */
@WebServlet("/portfolio")
public class PortfolioServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public PortfolioServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("portfolio.jsp");
    }
    
    // Stock class for session storage
    public static class Stock {
        private String symbol;
        private String companyName;
        private double purchasePrice;
        private int quantity;
        private String purchaseDate;

        public Stock(String symbol, String companyName, double purchasePrice, int quantity, String purchaseDate) {
            this.symbol = symbol;
            this.companyName = companyName;
            this.purchasePrice = purchasePrice;
            this.quantity = quantity;
            this.purchaseDate = purchaseDate;
        }

        // Getters
        public String getSymbol() { return symbol; }
        public String getCompanyName() { return companyName; }
        public double getPurchasePrice() { return purchasePrice; }
        public int getQuantity() { return quantity; }
        public String getPurchaseDate() { return purchaseDate; }
    }
    
    private void addStock(HttpServletRequest request) throws ParseException {
        HttpSession session = request.getSession(true);
        
        // Extract stock details from request
        String symbol = request.getParameter("symbol");
        String companyName = request.getParameter("companyName");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        double purchasePrice = Double.parseDouble(request.getParameter("purchasePrice"));
        String purchaseDate = request.getParameter("purchaseDate");

        // Get stocks from session or create new list
        @SuppressWarnings("unchecked")
        List<Stock> stocks = (List<Stock>) session.getAttribute("stocks");
        if (stocks == null) {
            stocks = new ArrayList<>();
        }
        
        // Add new stock
        stocks.add(new Stock(symbol, companyName, purchasePrice, quantity, purchaseDate));
        
        // Update session
        session.setAttribute("stocks", stocks);
    }

    private void deleteStock(HttpServletRequest request, String symbolToDelete) {
        HttpSession session = request.getSession(false);
        if (session == null) return;
        
        @SuppressWarnings("unchecked")
        List<Stock> stocks = (List<Stock>) session.getAttribute("stocks");
        if (stocks == null) return;
        
        // Remove stock with matching symbol
        Iterator<Stock> iterator = stocks.iterator();
        while (iterator.hasNext()) {
            Stock stock = iterator.next();
            if (stock.getSymbol().equals(symbolToDelete)) {
                iterator.remove();
                break;
            }
        }
        
        // Update session
        session.setAttribute("stocks", stocks);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String symbol = request.getParameter("symbol");
        String deleteSymbol = request.getParameter("deleteSymbol");

        try {
            // Handle adding a new stock
            if (symbol != null && !symbol.isEmpty()) {
                addStock(request);
            }

            // Handle deleting a stock
            if (deleteSymbol != null && !deleteSymbol.isEmpty()) {
                deleteStock(request, deleteSymbol);
            }

            // Redirect back to the portfolio page
            response.sendRedirect("portfolio.jsp");

        } catch (Exception e) {
            // Log error and send error response
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                             "Error processing stock: " + e.getMessage());
        }
    }
}