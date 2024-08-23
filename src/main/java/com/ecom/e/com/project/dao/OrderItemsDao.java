/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ecom.e.com.project.dao;

import com.ecom.e.com.project.entities.OrderItems;
import java.util.List;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

/**
 *
 * @author kholoplongkho
 */
public class OrderItemsDao {

    private SessionFactory factory;

    public OrderItemsDao(SessionFactory factory) {
        this.factory = factory;
    }

    // Save the order item to the database
    public Long saveOrderItem(OrderItems orderItem) {
        Session session = this.factory.openSession();
        Transaction tx = session.beginTransaction();
        Long orderItemId = (Long) session.save(orderItem);
        tx.commit();
        session.close();
        return orderItemId;
    }

    // Get a list of all order items
    public List<OrderItems> getOrderItems() {
        Session session = this.factory.openSession();
        Query query = session.createQuery("from OrderItems");
        List<OrderItems> list = query.list();
        session.close();
        return list;
    }

    // Get an order item by its ID
    public OrderItems getOrderItemById(int orderItemId) {
        OrderItems orderItem = null;
        try {
            Session session = this.factory.openSession();
            orderItem = session.get(OrderItems.class, orderItemId);
            session.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orderItem;
    }

    // Update an order item
    public void updateOrderItem(OrderItems orderItem) {
        Session session = this.factory.openSession();
        Transaction tx = session.beginTransaction();
        session.update(orderItem);
        tx.commit();
        session.close();
    }
}
