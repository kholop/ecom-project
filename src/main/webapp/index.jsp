
<%@page import="com.ecom.e.com.project.helper.Helper"%>
<%@page import="com.ecom.e.com.project.entities.Category"%>
<%@page import="com.ecom.e.com.project.dao.CategoryDao"%>
<%@page import="java.util.List"%>
<%@page import="com.ecom.e.com.project.entities.Product"%>
<%@page import="com.ecom.e.com.project.dao.ProductDao"%>
<%@page import="com.ecom.e.com.project.helper.FactoryProvider"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quick-Mart</title>
        <%@include file="components/common_css_js.jsp"%>

    </head>
    <body>
        <%@include file="components/navbar.jsp" %>
        <div class="row mt-3 mx-2">
            <%                String cat = request.getParameter("category");
                //out.println(cat);

                ProductDao dao = new ProductDao(FactoryProvider.getFactory());
                List<Product> list = null;

                if (cat == null || cat.trim().equals("all")) {
                    list = dao.getAllProducts();

                } else {

                    int cid = Integer.parseInt(cat.trim());
                    list = dao.getAllProductsById(cid);

                }

                CategoryDao cdao = new CategoryDao(FactoryProvider.getFactory());
                List<Category> clist = cdao.getCategories();

            %>
            <!--show categories-->
            <div class="col-md-2">
                <div class="list-group mt-4 ">

                    <%            // Get the selected category from the request parameters
                        String selectedCategory = request.getParameter("category");
                        if (selectedCategory == null) {
                            selectedCategory = "all"; // Default to 'all' if no category is selected
                        }
                    %>

                    <a href="index.jsp?category=all" class="list-group-item list-group-item-action <%= "all".equals(selectedCategory) ? "active" : ""%>">
                        All Products
                    </a>

                    <% for (Category c : clist) {
                String categoryId = String.valueOf(c.getCategoryId()); // Convert int to String
%>
                    <a href="index.jsp?category=<%= categoryId%>" class="list-group-item list-group-item-action <%= categoryId.equals(selectedCategory) ? "active" : ""%>">
                        <%= c.getCategoryTitle()%>
                    </a>
                    <% } %>

                </div>
            </div>



            <!--show products-->
            <div class="col-md-10">

                <div class="col-md-10">


                    <!--row-->
                    <div class="row mt-4">

                        <!--col:12-->
                        <div class="col-md-12">

                            <div class="card-columns">

                                <!--traversing products-->

                                <%
                                    for (Product p : list) {

                                %>


                                <!--product card-->
                                <div class="card product-card">

                                    <div class="container text-center">
                                        <img src="img/products/<%= p.getpPhoto()%>" style="max-height: 200px;max-width: 100%;width: auto; " class="card-img-top m-2" alt="...">

                                    </div>

                                    <div class="card-body">

                                        <h5 class="card-title"><%= p.getpName()%></h5>

                                        <p class="card-text">
                                            <%= Helper.get10Words(p.getpDesc())%>

                                        </p>

                                    </div>

                                    <div class="card-footer text-center">
                                        <button class="btn custom-bg text-white" onclick="add_to_cart(<%= p.getpId()%>, '<%= p.getpName()%>',<%= p.getPriceAfterApplyingDiscount()%>)">Add to Cart</button>
                                        <button class="btn  btn-outline-success ">  &#8377; <%= p.getPriceAfterApplyingDiscount()%>/-  <span class="text-secondary discount-label">  &#8377; <%= p.getpPrice()%> , <%= p.getpDiscount()%>% off </span>  </button>

                                    </div>



                                </div>






                                <%}

                                    if (list.size() == 0) {
                                        out.println("<h3>No item in this category</h3>");
                                    }


                                %>


                            </div>                     



                        </div>                   

                    </div>



                </div>



            </div>
        </div>
        <%@include  file="components/common_modals.jsp" %>
    </body>
</html>
 