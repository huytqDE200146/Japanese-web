package com.japaneselearning.utils;

import com.japaneselearning.model.User;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory store for holding pending registrations across devices.
 * In a production environment, this should ideally be replaced with a
 * database table or distributed cache (like Redis) to survive server restarts.
 */
public class TokenStore {
    
    // Singleton instance
    private static TokenStore instance;
    
    // Stores the mapping from token UUID to User object
    private final Map<String, User> pendingUsers;

    private TokenStore() {
        pendingUsers = new ConcurrentHashMap<>();
    }

    public static synchronized TokenStore getInstance() {
        if (instance == null) {
            instance = new TokenStore();
        }
        return instance;
    }

    public void storeUser(String token, User user) {
        pendingUsers.put(token, user);
    }

    public User getUser(String token) {
        return pendingUsers.get(token);
    }

    public void removeUser(String token) {
        pendingUsers.remove(token);
    }
}
