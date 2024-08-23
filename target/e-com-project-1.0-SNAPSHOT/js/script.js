function add_to_cart(pid, pname, price)
{

    let cart = localStorage.getItem("cart");
    if (cart == null)
    {
        //no cart yet  
        let products = [];
        let product = {productId: pid, productName: pname, productQuantity: 1, productPrice: price}
        products.push(product);
        localStorage.setItem("cart", JSON.stringify(products));
//        console.log("Product is added for the first time")
        showToast("Item is added to cart")
    } else
    {
        //cart is already present
        let pcart = JSON.parse(cart);

        let oldProduct = pcart.find((item) => item.productId == pid)
        console.log(oldProduct)
        if (oldProduct)
        {
            //we have to increase the quantity
            oldProduct.productQuantity = oldProduct.productQuantity + 1
            pcart.map((item) => {

                if (item.productId === oldProduct.productId)
                {
                    item.productQuantity = oldProduct.productQuantity;
                }

            })
            localStorage.setItem("cart", JSON.stringify(pcart));
            console.log("Product quantity is increased")
            showToast(oldProduct.productName + " quantity is increased , Quantity = " + oldProduct.productQuantity)

        } else
        {
            //we have add the product
            let product = {productId: pid, productName: pname, productQuantity: 1, productPrice: price}
            pcart.push(product)
            localStorage.setItem("cart", JSON.stringify(pcart));
            console.log("Product is added")
            showToast("Product is added to cart")
        }


    }


    updateCart();

}

//update cart:

function updateCart()
{
    let cartString = localStorage.getItem("cart");
    let cart = JSON.parse(cartString);
    if (cart == null || cart.length == 0)
    {
        console.log("Cart is empty !!");
        $(".cart-items").html("( 0 )");
        $(".cart-body").html("<h3>Cart does not have any items </h3>");
        $(".checkout-btn").attr('disabled', true);
    } else
    {


        //there is some in cart to show
        console.log(cart);
        $(".cart-items").html(`( ${cart.length} )`);
        let table = `
            <table class='table'>
            <thead class='thread-light'>
                <tr>
                <th>Item Name </th>
                <th>Price </th>
                <th>Quantity </th>
                <th>Total Price </th>
                <th>Action</th>
                
        
                </tr>
        
            </thead>

        


            `;

        let totalPrice = 0;
        cart.map((item) => {


            table += `
                    <tr>
                        <td> ${item.productName} </td>
                        <td> ${item.productPrice} </td>
                        <td> ${item.productQuantity} </td>
                        <td> ${item.productQuantity * item.productPrice} </td>
                        <td> <button onclick='increaseQuantity(${item.productId})' class='btn btn-success btn-sm'>Add</button> </td>    
                        <td> <button onclick='deleteItemFromCart(${item.productId})' class='btn btn-danger btn-sm'>Remove</button> </td>    
                     </tr>
                 `

            totalPrice += item.productPrice * item.productQuantity;


        })


        localStorage.setItem('totalPrice', totalPrice);


        table = table + `
            <tr id="totalPriceRow"><td colspan='5' class='text-right font-weight-bold m-5'> Total Price : ${totalPrice} </td></tr>
         </table>`
        $(".cart-body").html(table);
        $(".checkout-btn").attr('disabled', false)
        console.log("removed")

    }

}


////delete item 
//function deleteItemFromCart(pid)
//{
//    let cart = JSON.parse(localStorage.getItem('cart'));
//
//    let newcart = cart.filter((item) => item.productId != pid);
//
//    localStorage.setItem('cart', JSON.stringify(newcart));
//
//    updateCart();
//
//    showToast("Item is removed from cart ");
//
//}

// Delete item one by one
function deleteItemFromCart(pid) {
    // Get the cart from localStorage
    let cart = JSON.parse(localStorage.getItem('cart'));

    // Loop through the cart to find the item
    cart = cart.map((item) => {
        if (item.productId === pid) {
            item.productQuantity -= 1; // Decrease the quantity by 1
        }
        return item;
    }).filter((item) => item.productQuantity > 0); // Remove the item if quantity reaches 0

    // Save the updated cart back to localStorage
    localStorage.setItem('cart', JSON.stringify(cart));

    // Update the cart UI
    updateCart();

    // Show a toast notification
    showToast("Item quantity decreased");
}

// Increase quantity of an item in the cart
function increaseQuantity(pid) {
    // Get the cart from localStorage
    let cart = JSON.parse(localStorage.getItem('cart')) || [];

    // Flag to check if the item exists in the cart
    let itemExists = false;

    // Loop through the cart to find the item
    cart = cart.map((item) => {
        if (item.productId === pid) {
            // If item found, increase its quantity
            item.productQuantity += 1; // Use 'productQuantity' instead of 'quantity'
            itemExists = true;
        }
        return item;
    });

    // If item doesn't exist in the cart, add it with quantity 1
    if (!itemExists) {
        cart.push({productId: pid, productQuantity: 1}); // Use 'productQuantity'
    }

    // Save the updated cart back to localStorage
    localStorage.setItem('cart', JSON.stringify(cart));

    // Update the cart UI
    updateCart();

    // Show a toast notification
    showToast("Item quantity increased in the cart");
}


$(document).ready(function () {

    updateCart();
});


function showToast(content) {
    $("#toast").addClass("display");
    $("#toast").html(content);
    setTimeout(() => {
        $("#toast").removeClass("display");
    }, 2000);
}


function goToCheckout() {

    window.location = "checkout.jsp";
}
function continueShopping() {
    window.location.href = 'normal.jsp'; // Redirect to index.jsp
}


//razor pay

//var xhttp = new XMLHttpRequest();
//var RazorpayOrderId;
//function CreateOrderId() {
//    xhttp.open("GET", "http://localhost:9494/e-com-project/OrderCreation", false);
//    xhttp.onreadystatechange = function () {
//        if (xhttp.readyState === 4 && xhttp.status === 200) {
//            var response = JSON.parse(xhttp.responseText);
//            RazorpayOrderId = response.id;  // Get the order_id from the response
//            OpenCheckout();
//        }
//    };
//    xhttp.send();
//}
//function OpenCheckout() {
//    var options = {
//        "key": "rzp_test_KhlNyqIlFpE2HK", // Enter the Key ID generated from the Dashboard
//        "amount": "50000", // Amount is in currency subunits
//        "currency": "INR",
//        "name": "Acme Corp",
//        "description": "Test Transaction",
//        "image": "https://example.com/your_logo",
//        "order_id": RazorpayOrderId, // Use the generated order_id here
//        "handler": function (response) {
//            // Send response details to your server for verification
//            var xhttp = new XMLHttpRequest();
//            xhttp.open("POST", "/OrderCreation", true);
//            xhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//            xhttp.onreadystatechange = function () {
//                if (this.readyState === 4 && this.status === 200) {
//                    var serverResponse = this.responseText;
//                    if (serverResponse.includes("Payment verification failed")) {
//                        alert("Payment verification failed.");
//                    } else {
//                        window.location.href = "/thankyou.jsp";
//                    }
//                }
//            };
//            xhttp.send("razorpay_payment_id=" + response.razorpay_payment_id +
//                    "&razorpay_order_id=" + response.razorpay_order_id +
//                    "&razorpay_signature=" + response.razorpay_signature);
//        },
//        "prefill": {
//            "name": "Gaurav Kumar",
//            "email": "gaurav.kumar@example.com",
//            "contact": "9000090000"
//        },
//        "notes": {
//            "address": "Razorpay Corporate Office"
//        },
//        "theme": {
//            "color": "#3399cc"
//        }
//    };
//    var rzp1 = new Razorpay(options);
//    rzp1.on('payment.failed', function (response) {
//        alert(response.error.code);
//        alert(response.error.description);
//        alert(response.error.source);
//        alert(response.error.step);
//        alert(response.error.reason);
//        alert(response.error.metadata.order_id);
//        alert(response.error.metadata.payment_id);
//    });
//    rzp1.open();
//}