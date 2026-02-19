/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.japaneselearning.dao;



import com.japaneselearning.model.User;
import com.japaneselearning.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    // Đăng ký
    public boolean register(User user) {
        String sql = "INSERT INTO users(username, password, email, full_name, role, status) "
                   + "VALUES (?, ?, ?, ?, 'USER', 'ACTIVE')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getFullName());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Đăng nhập
    public User login(String username, String password) {
        String sql = "SELECT * FROM users WHERE username=? AND password=? AND status='ACTIVE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Tìm user theo Google ID
    public User findByGoogleId(String googleId) {
        String sql = "SELECT * FROM users WHERE google_id=? AND status='ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, googleId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Đăng ký user từ Google (không có password)
    public User registerGoogleUser(String googleId, String email, String fullName) {
        String sql = "INSERT INTO users(username, password, email, full_name, role, status, google_id) "
                   + "VALUES (?, '', ?, ?, 'USER', 'ACTIVE', ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            // Dùng email làm username (loại bỏ @...)
            String username = email.split("@")[0];
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, fullName);
            ps.setString(4, googleId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    return getUserById(keys.getInt(1));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Kiểm tra username tồn tại
    public boolean isUsernameExist(String username) {
        String sql = "SELECT id FROM users WHERE username=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            return ps.executeQuery().next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Nâng cấp user lên Premium
     * @param userId ID của user
     * @param daysToAdd Số ngày Premium
     */
    public boolean upgradeToPremium(int userId, int daysToAdd) {
        String sql = "UPDATE users SET is_premium = 1, premium_until = DATEADD(day, ?, " +
                     "CASE WHEN premium_until IS NULL OR premium_until < GETDATE() " +
                     "THEN GETDATE() ELSE premium_until END) WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, daysToAdd);
            ps.setInt(2, userId);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Cập nhật thông tin profile user
     */
    public boolean updateProfile(int userId, String fullName, String email, String password) {
        String sql;
        if (password != null && !password.trim().isEmpty()) {
            sql = "UPDATE users SET full_name=?, email=?, password=? WHERE id=?";
        } else {
            sql = "UPDATE users SET full_name=?, email=? WHERE id=?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            if (password != null && !password.trim().isEmpty()) {
                ps.setString(3, password);
                ps.setInt(4, userId);
            } else {
                ps.setInt(3, userId);
            }

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy thông tin user theo ID (bao gồm Premium info)
     */
    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Map ResultSet to User (với Premium fields)
     */
    private User mapResultSetToUser(ResultSet rs) throws Exception {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setFullName(rs.getString("full_name"));
        u.setRole(rs.getString("role"));
        u.setStatus(rs.getString("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Premium fields (với null check cho cột mới)
        try {
            u.setPremium(rs.getBoolean("is_premium"));
            u.setPremiumUntil(rs.getTimestamp("premium_until"));
        } catch (Exception e) {
            // Columns might not exist yet
            u.setPremium(false);
            u.setPremiumUntil(null);
        }
        
        // Google ID field
        try {
            u.setGoogleId(rs.getString("google_id"));
        } catch (Exception e) {
            u.setGoogleId(null);
        }
        
        return u;
    }
}