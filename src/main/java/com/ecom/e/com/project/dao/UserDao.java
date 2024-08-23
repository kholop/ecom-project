
package com.ecom.e.com.project.dao;

import com.ecom.e.com.project.entities.User;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import javax.persistence.TypedQuery;
import javax.persistence.NoResultException;


public class UserDao {
    
    private SessionFactory factory;

    public UserDao(SessionFactory factory) {
        this.factory = factory;
    }
    
    //get user by email and passsword
    


public User getUserByEmailAndPassword(String email, String password) {
    User user = null;

    try {
        String query = "from User where userEmail = :e and userPassword = :p";
        Session session = this.factory.openSession();
        
        // Use TypedQuery for type safety
        TypedQuery<User> q = session.createQuery(query, User.class);
        q.setParameter("e", email);
        q.setParameter("p", password);

        
        user = q.getSingleResult();
       

        session.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    return user;
}

}
