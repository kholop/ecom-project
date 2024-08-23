package com.ecom.e.com.project.servlets;

import com.ecom.e.com.project.dao.OrderDao;
import com.ecom.e.com.project.dao.OrderItemsDao;
import com.ecom.e.com.project.entities.OrderItems;
import com.ecom.e.com.project.entities.Orders;
import com.ecom.e.com.project.helper.FactoryProvider;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet implementation class CreateOrder
 */
@WebServlet(name = "CreateOrder", urlPatterns = {"/CreateOrder"})
public class CreateOrder extends HttpServlet {

    /**
     * Handles the HTTP POST method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            StringBuilder jsonBuilder = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }
            String jsonString = jsonBuilder.toString();
            JSONObject jsonRequest = new JSONObject(jsonString);

            if (jsonRequest.has("razorpay_payment_id")) {
                // Handle payment verification
                String paymentId = jsonRequest.getString("razorpay_payment_id");
                String orderId = jsonRequest.getString("razorpay_order_id");
                String signature = jsonRequest.getString("razorpay_signature");

                JSONObject orderRequest = new JSONObject();
                orderRequest.put("razorpay_payment_id", paymentId);
                orderRequest.put("razorpay_order_id", orderId);
                orderRequest.put("razorpay_signature", signature);

                boolean status = Utils.verifyPaymentSignature(orderRequest, "PkLFACfS0EDDNSJUHJiT8lA2"); // Replace with your actual secret key
                if (status) {
                    response.sendRedirect("/e-com-project/thankyou.jsp");
                } else {
                    response.sendRedirect("/e-com-project/");
                }
            } else {
                // Handle order creation
                JSONArray itemsArray = jsonRequest.getJSONArray("items");

                // Fetch additional order details
                Long userId = jsonRequest.getLong("userId");

                String userAddress = jsonRequest.getString("userAddress");
                double totalAmount = jsonRequest.getDouble("totalAmount");

                // Calculate total price (already provided in request as totalAmount)
                int totalPriceInPaise = (int) (totalAmount * 100);

                // Initialize Razorpay client
                RazorpayClient client = new RazorpayClient("rzp_test_KhlNyqIlFpE2HK", "PkLFACfS0EDDNSJUHJiT8lA2"); // Replace with your actual secret key
                JSONObject orderRequest = new JSONObject();
                orderRequest.put("amount", totalPriceInPaise);
                orderRequest.put("currency", "INR");
                orderRequest.put("receipt", "receipt#1");
                orderRequest.put("payment_capture", true);

                // Create order
                Order razorpayOrder = client.orders.create(orderRequest);
                System.out.println("Created order...");
                // Create and save Orders entity
                String razorpayOrderId = razorpayOrder.get("id");
                Orders orders = new Orders();
                orders.setPaymentStatus("pending");
                orders.setUserId(userId);
                orders.setShippingAddress(userAddress);
                orders.setTotalAmount(totalAmount);
                orders.setRazorpayOrderId(razorpayOrderId);

                OrderDao orderDao = new OrderDao(FactoryProvider.getFactory());
                System.out.println("Saving order...");
                Long createdOrderId = orderDao.saveOrder(orders);

                System.out.println("Order saved with ID: " + createdOrderId);
                // Make sure saveOrder returns the ID or adjust accordingly
                System.out.println("Saving orderItemssss...");
                // Create and save each OrderItems entity
                for (int i = 0; i < itemsArray.length(); i++) {
                    JSONObject item = itemsArray.getJSONObject(i);

                    OrderItems orderItem = new OrderItems();
                    orderItem.setProductId(item.getLong("productId"));
                    orderItem.setQuantity(item.getInt("productQuantity"));
                    orderItem.setPrice(item.getDouble("productPrice"));
                    orderItem.setProductName(item.getString("productName"));
                    orderItem.setOrder(orders); // Associate the item with the order

                    OrderItemsDao orderItemDao = new OrderItemsDao(FactoryProvider.getFactory());
                    Long orderItemId = orderItemDao.saveOrderItem(orderItem); // Handle Long type
                }
                System.out.println("Saved orderItemss...");
                // Create JSON response
                JSONObject jsonResponse = new JSONObject();
                jsonResponse.put("id", razorpayOrder.get("id").toString());
                jsonResponse.put("amount", razorpayOrder.get("amount").toString());
                jsonResponse.put("currency", razorpayOrder.get("currency").toString());
                jsonResponse.put("receipt", razorpayOrder.get("receipt").toString());

                // Log JSON response for debugging
                System.out.println("JSON Response: " + jsonResponse.toString());

                out.print(jsonResponse.toString());
                out.flush();
            }
        } catch (RazorpayException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Internal Server Error\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"An unexpected error occurred\"}");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Servlet for creating and verifying orders";
    }
}
