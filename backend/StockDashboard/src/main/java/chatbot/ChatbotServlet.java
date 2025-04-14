package chatbot;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

/**
 * Servlet implementation class ChatbotServlet
 */
@WebServlet("/ChatbotServlet")
public class ChatbotServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ChatbotServlet() {
        super();
        // TODO Auto-generated constructor stub
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
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	
	 private static final List<Map<String, String>> qaPairs = new ArrayList<>();
	    
	    static {
	        addQAPair("hello", "Hey there, investor! Ready to conquer the markets today? Let's track some stocks and ride those trends! 📈");
	        addQAPair("how to add stocks in portfolio", "To add stocks in portfolio, go to the Portfolio page and click on the '+ New' button. From there, you can search for stocks and add them to your personalized portfolio. You can add multiple stocks in your respective portfolio for different investment strategies.");
	        addQAPair("what markets do you cover", "StockPro covers all major global markets including NYSE, NASDAQ, LSE, TSE, and 30+ other exchanges. We provide data for stocks, ETFs, mutual funds, indices, forex, and cryptocurrencies.");
	        addQAPair("do you offer realtime data", "Yes! StockPro provides real-time market data with millisecond precision for all premium subscribers. Our Basic plan includes 15-minute delayed quotes, while Premium and Professional plans offer real-time streaming data.");
	        addQAPair("how much does it cost", "StockPro is entirely free to our privileged users. We take immense pride in offering our service free to all our customers.");
	        addQAPair("do you have a mobile app", "No, Currently that work is in progress. Currently this website is the only service that we are providing. We'll be launching our app in both play store and app store very soon!");
	        addQAPair("how do i read stock charts", "Stock charts display price movements over time. In StockPro, you can access different chart types (candlestick, line, OHLC) and add technical indicators by clicking on the 'Indicators' button above any chart. We also offer a comprehensive 'Chart Reading Guide' in our Learning Center.");
	        addQAPair("what technical indicators are available", "StockPro offers 100+ technical indicators including popular ones like Moving Averages, RSI, MACD, Bollinger Bands, and Fibonacci Retracements. Premium users can also create custom indicators using our scripting language.");
	        addQAPair("how to set price alerts", "To set price alerts, navigate to any stock detail page and click the bell icon. You can create alerts based on price movements, percentage changes, volume spikes, or technical indicator crossovers. Alerts can be delivered via email, SMS, or push notifications.");
	        addQAPair("can i import my existing portfolio", "Yes, you can import your existing portfolio by going to the Portfolio section and clicking 'Import Portfolio'. We support imports from CSV files, direct connections to major brokerages, and manual entry options.");
	        addQAPair("do you provide ai stock predictions", "Yes, our Premium and Professional plans include AI-powered market predictions and trend analysis. Our machine learning algorithms analyze thousands of data points to identify potential market movements with proven accuracy rates above industry averages.");
	    }
	    
	    private static void addQAPair(String question, String answer) {
	        Map<String, String> pair = new HashMap<>();
	        pair.put("question", question);
	        pair.put("answer", answer);
	        qaPairs.add(pair);
	    }
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		
		 response.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
         response.setHeader("Access-Control-Allow-Credentials", "true");
         response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
         response.setHeader("Access-Control-Allow-Headers", "Content-Type");
         response.setContentType("application/json");

		
         response.setContentType("application/json");
         response.setCharacterEncoding("UTF-8");
	        
	     String message = request.getParameter("message");
        
         String answer = findAnswer(message);
        
         JSONObject jsonResponse = new JSONObject();
         jsonResponse.put("response", answer);
        
         PrintWriter out = response.getWriter();
         out.print(jsonResponse.toString());
         out.flush();
	}
	
	private String findAnswer(String question) {
        
		if (question == null || question.trim().isEmpty()) {
            return "I didn't catch that. Could you please repeat your question?";
        }
        
        String normalizedQuestion = question.toLowerCase().replaceAll("[^\\w\\s]", "");
        System.out.println(normalizedQuestion);
        
        for (Map<String, String> pair : qaPairs) {
        	System.out.println(question);
            if (normalizedQuestion.contains(pair.get("question"))) {
            	System.out.println(pair);
                return pair.get("answer");
            }
        }
        
        return "I'm sorry, I don't have specific information about that question yet. Please contact our support team for more assistance or try asking about our features, pricing, or how to use StockPro.";
    }

}
