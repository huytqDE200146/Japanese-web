package com.japaneselearning.dao;

import com.japaneselearning.model.Payment;
import com.japaneselearning.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {
    
    /**
     * Tạo payment record mới
     */
    public int createPayment(Payment payment) {
        String sql = "INSERT INTO payments (user_id, order_code, amount, description, status, checkout_url) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, payment.getUserId());
            ps.setLong(2, payment.getOrderCode());
            ps.setInt(3, payment.getAmount());  
            ps.setString(4, payment.getDescription());
            ps.setString(5, payment.getStatus());
            ps.setString(6, payment.getCheckoutUrl());
            
            int affected = ps.executeUpdate();
            
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Tạo payment record đã thanh toán (dùng khi Admin cấp Premium)
     * Insert luôn paid_at và payment_method
     */
    public int createPaidPayment(int userId, int amount, String description, String paymentMethod) {
        String sql = "INSERT INTO payments (user_id, order_code, amount, description, status, checkout_url, payment_method, paid_at) " +
                     "VALUES (?, ?, ?, ?, 'PAID', '', ?, GETDATE())";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, userId);
            ps.setLong(2, System.currentTimeMillis());
            ps.setInt(3, amount);
            ps.setString(4, description);
            ps.setString(5, paymentMethod);
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }
    
    /**
     * Tìm payment theo order code
     */
    public Payment getPaymentByOrderCode(long orderCode) {
        String sql = "SELECT * FROM payments WHERE order_code = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, orderCode);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPayment(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Cập nhật trạng thái thanh toán
     */
    public boolean updatePaymentStatus(long orderCode, String status, String paymentMethod) {
        String sql = "UPDATE payments SET status = ?, payment_method = ?, paid_at = ? WHERE order_code = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setString(2, paymentMethod);
            ps.setTimestamp(3, Payment.STATUS_PAID.equals(status) ? new Timestamp(System.currentTimeMillis()) : null);
            ps.setLong(4, orderCode);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Lấy lịch sử thanh toán của user
     */
    public List<Payment> getPaymentsByUserId(int userId) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM payments WHERE user_id = ? ORDER BY created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return payments;
    }
    
    /**
     * Map ResultSet to Payment object
     */
    private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentId(rs.getInt("payment_id"));
        payment.setUserId(rs.getInt("user_id"));
        payment.setOrderCode(rs.getLong("order_code"));
        payment.setAmount(rs.getInt("amount"));
        payment.setDescription(rs.getString("description"));
        payment.setStatus(rs.getString("status"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setCheckoutUrl(rs.getString("checkout_url"));
        payment.setCreatedAt(rs.getTimestamp("created_at"));
        payment.setPaidAt(rs.getTimestamp("paid_at"));
        return payment;
    }

    // --- ADMIN METHODS ---

    /**
     * Get all payments for admin panel
     */
    public List<Payment> getAllPayments() {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM payments ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                payments.add(mapResultSetToPayment(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return payments;
    }

    /**
     * Get total revenue (only PAID status)
     */
    public long getTotalPaymentsAmount() {
        String sql = "SELECT SUM(amount) FROM payments WHERE status = 'PAID'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get monthly revenue for the last 6 months (for chart)
     * Returns LinkedHashMap with month label -> total amount
     */
    public java.util.LinkedHashMap<String, Long> getMonthlyRevenue() {
        java.util.LinkedHashMap<String, Long> monthlyData = new java.util.LinkedHashMap<>();
        String sql = "SELECT FORMAT(paid_at, 'MM/yyyy') AS month_label, SUM(amount) AS total " +
                     "FROM payments WHERE status = 'PAID' AND paid_at >= DATEADD(month, -5, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) " +
                     "GROUP BY FORMAT(paid_at, 'MM/yyyy'), YEAR(paid_at), MONTH(paid_at) " +
                     "ORDER BY YEAR(paid_at), MONTH(paid_at)";
        
        // Initialize last 6 months with 0
        java.time.LocalDate now = java.time.LocalDate.now();
        for (int i = 5; i >= 0; i--) {
            java.time.LocalDate m = now.minusMonths(i);
            String label = String.format("%02d/%d", m.getMonthValue(), m.getYear());
            monthlyData.put(label, 0L);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String label = rs.getString("month_label");
                long total = rs.getLong("total");
                if (monthlyData.containsKey(label)) {
                    monthlyData.put(label, total);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return monthlyData;
    }
}
