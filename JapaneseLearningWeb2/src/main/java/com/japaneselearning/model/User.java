package com.japaneselearning.model;

import java.sql.Timestamp;

public class User {

    private int id;
    private String username;
    private String password;
    private String email;
    private String fullName;
    private String role;
    private String status;
    private Timestamp createdAt;
    private boolean isPremium;
    private Timestamp premiumUntil;
    private String googleId;

    // Constructor rỗng (bắt buộc cho Servlet/JSP)
    public User() {
    }

    // Constructor đầy đủ
    public User(int id, String username, String password, String email,
                String fullName, String role, String status, Timestamp createdAt) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullName;
        this.role = role;
        this.status = status;
        this.createdAt = createdAt;
    }

    // Constructor dùng cho đăng ký
    public User(String username, String password, String email, String fullName) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullName;
        this.role = "USER";
        this.status = "ACTIVE";
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public boolean isPremium() {
        return isPremium;
    }
    
    public void setPremium(boolean isPremium) {
        this.isPremium = isPremium;
    }
    
    public Timestamp getPremiumUntil() {
        return premiumUntil;
    }
    
    public void setPremiumUntil(Timestamp premiumUntil) {
        this.premiumUntil = premiumUntil;
    }
    
    public String getGoogleId() {
        return googleId;
    }
    
    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }
    
    // Helper method to check if Premium is still active
    public boolean hasPremiumAccess() {
        if (!isPremium) return false;
        if (premiumUntil == null) return false;
        return premiumUntil.after(new Timestamp(System.currentTimeMillis()));
    }
}