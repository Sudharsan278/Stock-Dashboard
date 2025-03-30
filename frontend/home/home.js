document.addEventListener("DOMContentLoaded", function () {
    const stockSymbols = ["AAPL", "MSFT", "TSLA", "AMZN", "NVDA"];

    stockSymbols.forEach(symbol => {
        fetch(`/StockDashboard/StockServlet?symbol=${symbol}`)
            .then(response => response.json())
            .then(data => {
                let stockPrice = data["Global Quote"]["05. price"];
                let stockChange = data["Global Quote"]["10. change percent"];

                document.querySelector(`.stock-item[data-symbol="${symbol}"] .stock-price`).textContent = `$${parseFloat(stockPrice).toFixed(2)}`;
                document.querySelector(`.stock-item[data-symbol="${symbol}"] .stock-change`).textContent = stockChange;
                document.querySelector(`.stock-item[data-symbol="${symbol}"] .stock-change`).classList.toggle("up", parseFloat(stockChange) > 0);
                document.querySelector(`.stock-item[data-symbol="${symbol}"] .stock-change`).classList.toggle("down", parseFloat(stockChange) < 0);
            })
            .catch(error => console.error("Error fetching stock data:", error));
    });
});