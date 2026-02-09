package com.japaneselearning.model;

import java.sql.Timestamp;

public class Payment {
    
    private int paymentId;
    private int userId;
    private long orderCode;
    private int amount;
    private String description;
    private String status; // PENDING, PAID, CANCELLED, EXPIRED
    private String paymentMethod;
    private String checkoutUrl;
    private Timestamp createdAt;
    private Timestamp paidAt;
    
    // Constructor rỗng
    public Payment() {
    }
    
    // Constructor đầy đủ
    public Payment(int paymentId, int userId, long orderCode, int amount, 
                   String description, String status, String paymentMethod,
                   String checkoutUrl, Timestamp createdAt, Timestamp paidAt) {
        this.paymentId = paymentId;
        this.userId = userId;
        this.orderCode = orderCode;
        this.amount = amount;
        this.description = description;
        this.status = status;
        this.paymentMethod = paymentMethod;
        this.checkoutUrl = checkoutUrl;
        this.createdAt = createdAt;
        this.paidAt = paidAt;
    }
    
    // Constructor cho tạo mới
    public Payment(int userId, long orderCode, int amount, String description) {
        this.userId = userId;
        this.orderCode = orderCode;
        this.amount = amount;
        this.description = description;
        this.status = "PENDING";
    }
    
    // Getters & Setters
    public int getPaymentId() { return paymentId; }
    public void setPaymentId(int paymentId) { this.paymentId = paymentId; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public long getOrderCode() { return orderCode; }
    public void setOrderCode(long orderCode) { this.orderCode = orderCode; }
    
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    
    public String getCheckoutUrl() { return checkoutUrl; }
    public void setCheckoutUrl(String checkoutUrl) { this.checkoutUrl = checkoutUrl; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }
    
    // Status constants
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_PAID = "PAID";
    public static final String STATUS_CANCELLED = "CANCELLED";
    public static final String STATUS_EXPIRED = "EXPIRED";
    
    public boolean isPaid() {
        return STATUS_PAID.equals(this.status);
    }
}
