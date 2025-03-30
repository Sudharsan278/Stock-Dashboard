<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="portfolio.PortfolioServlet.Stock" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Portfolio</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .add-stock-form { margin-bottom: 20px; }
        .add-stock-form input { margin-right: 10px; padding: 5px; }
    </style>
</head>
<body>
    <%
    
       
    // Get stocks from session
    @SuppressWarnings("unchecked")
    List<Stock> stocks = (List<Stock>) session.getAttribute("stocks");
    if (stocks == null) {
        stocks = new ArrayList<>();
    }
    %>

    <h1>Welcome to the Portfolio</h1>

    <div class="add-stock-form">
        <h2>Add New Stock</h2>
        <form action="portfolio" method="post">
            <input type="text" name="symbol" placeholder="Stock Symbol" required>
            <input type="text" name="companyName" placeholder="Company Name" required>
            <input type="number" name="quantity" placeholder="Quantity" required min="1">
            <input type="number" step="0.01" name="purchasePrice" placeholder="Purchase Price" required min="0.01">
            <input type="date" name="purchaseDate" required>
            <button type="submit">Add Stock</button>
        </form>
    </div>

    <div class="stock-list">
        <h2>Your Stocks</h2>

        <% if (stocks.isEmpty()) { %>
            <p>No stocks in your portfolio.</p>
        <% } else { %>
            <%
                double totalValue = 0;
                for (Stock stock : stocks) {
                    totalValue += stock.getPurchasePrice() * stock.getQuantity();
                }
            %>

            <table>
                <thead>
                    <tr>
                        <th>Symbol</th>
                        <th>Company</th>
                        <th>Quantity</th>
                        <th>Purchase Price</th>
                        <th>Purchase Date</th>
                        <th>Total Value</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Stock stock : stocks) { %>
                        <tr>
                            <td><%= stock.getSymbol() %></td>
                            <td><%= stock.getCompanyName() %></td>
                            <td><%= stock.getQuantity() %></td>
                            <td>$<%= String.format("%.2f", stock.getPurchasePrice()) %></td>
                            <td><%= stock.getPurchaseDate() %></td>
                            <td>$<%= String.format("%.2f", stock.getPurchasePrice() * stock.getQuantity()) %></td>
                            <td>
                                <form action="portfolio" method="post">
                                    <input type="hidden" name="deleteSymbol" value="<%= stock.getSymbol() %>">
                                    <button type="submit">Delete</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="5">Total Portfolio Value:</td>
                        <td>$<%= String.format("%.2f", totalValue) %></td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
        <% } %>
    </div>
</body>
</html>