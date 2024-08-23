/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ecom.e.com.project.dao;

import com.ecom.e.com.project.entities.Orders;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import java.util.List;
import org.hibernate.SessionFactory;

public class OrderDao {

    private SessionFactory factory;

    public OrderDao(SessionFactory factory) {
        this.factory = factory;
    }

    public Long saveOrder(Orders order) {
        Session session = this.factory.openSession();
        Transaction tx = session.beginTransaction();
        Long orderId = (Long) session.save(order);  // Cast to Long instead of int
        tx.commit();
        session.close();
        return orderId;
    }

    // Get a list of all orders
    public List<Orders> getOrders() {
        Session session = this.factory.openSession();
        Query query = session.createQuery("from Order");
        List<Orders> list = query.list();
        session.close();
        return list;
    }

    // Get an order by its ID
    public Orders getOrderById(int orderId) {
        Orders order = null;
        try {
            Session session = this.factory.openSession();
            order = session.get(Orders.class, orderId);
            session.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return order;
    }

    // Update an order
    public void updateOrder(Orders order) {
        Session session = this.factory.openSession();
        Transaction tx = session.beginTransaction();
        session.update(order);
        tx.commit();
        session.close();
    }
      // Get an order by Razorpay order ID
    public Orders getOrderByRazorPayOrderId(String razorpayOrderId) {
        Orders order = null;
        try {
            Session session = this.factory.openSession();
            Query<Orders> query = session.createQuery("from Orders where razorpay_order_id = :razorpayOrderId", Orders.class);
            query.setParameter("razorpayOrderId", razorpayOrderId);
            order = query.uniqueResult();
            session.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return order;
    }
}
