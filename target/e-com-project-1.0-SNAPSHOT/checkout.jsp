<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.ecom.e.com.project.entities.User"%>
<%@page import="org.apache.commons.text.StringEscapeUtils"%>

<%
    User user = (User) session.getAttribute("current-user");
    if (user == null) {
        session.setAttribute("message", "You are not logged in !! Login first to access checkout page");
        response.sendRedirect("login.jsp");
        return;
    }

    // Escape special characters in user address for use in JavaScript
    String userAddress = user.getUserAddress();
    String escapedUserAddress = userAddress.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\f", "\\f")
            .replace("\b", "\\b");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
        <script>
            var RazorpayOrderId;

            function CreateOrderId(event) {
                event.preventDefault(); // Prevent the default form submission

                var userId = "<%= user.getUserId()%>";
                var userEmail = "<%= user.getUserEmail()%>";
                var userPhone = "<%= user.getUserPhone()%>";
                var userAddress = "<%= escapedUserAddress%>";

                // Fetch the cart from localStorage
                let cartString = localStorage.getItem("cart");
                let cart = [];
                if (cartString) {
                    try {
                        cart = JSON.parse(cartString);
                    } catch (e) {
                        console.error("Failed to parse cart JSON:", e);
                        return;
                    }
                }

                // Fetch total price from localStorage
                let totalPrice = parseFloat(localStorage.getItem('totalPrice')) || 0;

                // Validate and log the user details
                console.log("User Details:", {userId, userEmail, userPhone});
                console.log("Total Price:", totalPrice);

                // Prepare the data to send to the servlet
                let data = {
                    userId: userId,
                    userEmail: userEmail,
                    userPhone: userPhone,
                    totalAmount: totalPrice,
                    userAddress: userAddress,
                    items: cart.map(item => {
                        if (typeof item.productPrice !== 'number' || isNaN(item.productPrice)) {
                            console.error("Invalid product price:", item.productPrice);
                            return null;
                        }
                        return {
                            productId: item.productId,
                            productQuantity: item.productQuantity,
                            productPrice: item.productPrice,
                            productName: item.productName
                        };
                    }).filter(item => item !== null) // Remove invalid items
                };

                console.log("Data to send:", data);

                var xhttp = new XMLHttpRequest();
                xhttp.open("POST", "/e-com-project/CreateOrder", true); // Use POST request
                xhttp.setRequestHeader("Content-Type", "application/json"); // Set content type to JSON
                xhttp.onreadystatechange = function () {
                    if (this.readyState === 4) {
                        if (this.status === 200) {
                            try {
                                if (this.responseText.trim() === "") {
                                    console.error("Empty response received from server.");
                                    return;
                                }

                                var response = JSON.parse(this.responseText);
                                console.log("Response:", response);
                                if (response.id) {
                                    RazorpayOrderId = response.id; // Get the order_id from the response
                                    OpenCheckout(); // Proceed to the payment
                                } else {
                                    console.error("Invalid response format: Missing 'id'");
                                }
                            } catch (e) {
                                console.error("Failed to parse JSON response:", e);
                            }
                        } else {
                            console.error("Request failed with status:", this.status);
                        }
                    }
                };

                // Send the data object as a JSON string
                xhttp.send(JSON.stringify(data));
            }



            function OpenCheckout() {
                let totalPrice = parseFloat(localStorage.getItem('totalPrice')) || 0;
                let amount = Math.round(totalPrice * 100); // Convert to paise
                var options = {
                    "key": "rzp_test_KhlNyqIlFpE2HK", // Your Razorpay Key ID
                    "amount": amount, // Amount is in currency subunits (paise)
                    "currency": "INR",
                    "name": "QuickMart",
                    "description": "Test Transaction",
                    "image": "https://example.com/your_logo",
                    "order_id": RazorpayOrderId, // Use the generated order_id here
                    "handler": function (response) {
                        // Send response details to your server for verification
                        var xhttp = new XMLHttpRequest();
                        xhttp.open("POST", "/e-com-project/CreateOrder", true); // Adjust path to match your servlet
                        xhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                        xhttp.onreadystatechange = function () {
                            if (this.readyState === 4 && this.status === 200) {
                                var serverResponse = this.responseText;
                                if (serverResponse.includes("Payment verification failed")) {
                                    alert("Payment verification failed.");
                                } else {
                                    updatePaymentStatus(
                                            response.razorpay_payment_id,
                                            response.razorpay_order_id,
                                            "paid"
                                            );
                                    window.location.href = "/e-com-project/thankyou.jsp";
                                }
                            }
                        };
                        xhttp.send("razorpay_payment_id=" + response.razorpay_payment_id +
                                "&razorpay_order_id=" + response.razorpay_order_id +
                                "&razorpay_signature=" + response.razorpay_signature);
                    },
                    "prefill": {
                        "name": "",
                        "email": "",
                        "contact": "9000090000"
                    },
                    "notes": {
                        "address": "Razorpay Corporate Office"
                    },
                    "theme": {
                        "color": "#3399cc"
                    }
                };
                var rzp1 = new Razorpay(options);
                rzp1.on('payment.failed', function (response) {
                    alert(response.error.code);
                    alert(response.error.description);
                    alert(response.error.source);
                    alert(response.error.step);
                    alert(response.error.reason);
                    alert(response.error.metadata.order_id);
                    alert(response.error.metadata.payment_id);
                });
                rzp1.open();
            }

            function updatePaymentStatus(paymentId, orderId, status) {
                // Prepare the data to send to the servlet
                let data = {
                    paymentId: paymentId,
                    orderId: orderId,
                    status: status
                };

                console.log("Data to send:", data);

                // Create a new XMLHttpRequest object
                var xhttp = new XMLHttpRequest();

                // Configure it: POST-request for the URL /UpdatePaymentStatus
                xhttp.open("POST", "/e-com-project/UpdatePaymentStatus", true);

                // Set the request header for form data
                xhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

                // Prepare the data in URL-encoded format
                var encodedData = 'paymentId=' + encodeURIComponent(data.paymentId) +
                        '&orderId=' + encodeURIComponent(data.orderId) +
                        '&status=' + encodeURIComponent(data.status);

                // Define the callback function
                xhttp.onreadystatechange = function () {
                    if (this.readyState === 4) {
                        if (this.status === 200) {
                            try {
                                console.log('Payment status updated successfully:', this.responseText);
                            } catch (e) {
                                console.error('Failed to parse server response:', e);
                            }
                        } else {
                            console.error('Failed to update payment status:', this.status, this.statusText);
                        }
                    }
                };

                // Send the request with the data
                xhttp.send(encodedData);
            }


        </script>

        <title>Checkout</title>
        <%@include file="components/common_css_js.jsp" %>

    </head>
    <body>
        <%@include file="components/navbar.jsp" %>

        <div class="container">
            <div class="row mt-5">                
                <div class="col-md-6">
                    <!-- Card for selected items -->
                    <div class="card">
                        <div class="card-body">
                            <h3 class="text-center mb-5">Your selected items</h3>
                            <div class="cart-body"></div>
                        </div> 
                    </div>
                </div>
                <div class="col-md-6">
                    <!-- Card for order details -->
                    <div class="card">
                        <div class="card-body">
                            <h3 class="text-center mb-5">Your details for order</h3>
                            <form action="">
                                <div class="form-group">
                                    <label for="Email1">Email address</label>
                                    <input value="<%= user.getUserEmail()%>" type="email" class="form-control" id="Email1" aria-describedby="emailHelp" placeholder="Enter email">
                                    <small id="emailHelp" class="form-text text-muted">We'll never share your email with anyone else.</small>
                                </div>
                                <div class="form-group">
                                    <label for="name">Your name</label>
                                    <input value="<%= user.getUserName()%>" type="text" class="form-control" id="name" aria-describedby="emailHelp" placeholder="Enter name">
                                </div>
                                <div class="form-group">
                                    <label for="contact">Your contact</label>
                                    <input value="<%= user.getUserPhone()%>" type="text" class="form-control" id="contact" aria-describedby="emailHelp" placeholder="Enter contact number">
                                </div>
                                <div class="form-group">
                                    <label for="address">Your shipping address</label>
                                    <textarea class="form-control" id="address" placeholder="Enter your address" rows="3"><%= user.getUserAddress()%></textarea>
                                </div>
                                <div class="container text-center">
                                    <button class="btn btn-outline-success" onclick="CreateOrderId(event)">Order Now</button>
                                    <button class="btn btn-outline-primary" onclick="continueShopping()">Continue Shopping</button>
                                </div>
                            </form>    
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%@include file="components/common_modals.jsp" %>
    </body>
</html>
