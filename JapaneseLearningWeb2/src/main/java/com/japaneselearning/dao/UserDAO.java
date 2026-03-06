package com.japaneselearning.dao;


import com.japaneselearning.model.User;
import com.japaneselearning.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    // Đăng ký
    public boolean register(User user) {
        String sql = "INSERT INTO users(username, password, email, full_name, level, role, status) "
                   + "VALUES (?, ?, ?, ?,5, 'USER', 'ACTIVE')";

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
        String sql = "INSERT INTO users(username, password, email, full_name, level, role, status, google_id) "
                   + "VALUES (?, '', ?, ?,5, 'USER', 'ACTIVE', ?)";

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
        u.setLevel(rs.getInt("level"));
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

    // --- ADMIN METHODS ---

    /**
     * Get all users for admin panel
     */
    public java.util.List<User> getAllUsers() {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Update user role (ADMIN/USER)
     */
    public boolean updateUserRole(int userId, String role) {
        String sql = "UPDATE users SET role=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update user status (ACTIVE/BAN)
     */
    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update premium status for a user (Admin toggle)
     * @param userId ID of the user
     * @param isPremium true to grant, false to revoke
     * @param days number of premium days to add (only used when isPremium=true)
     */
    public boolean updatePremiumStatus(int userId, boolean isPremium, int days) {
        String sql;
        if (isPremium) {
            sql = "UPDATE users SET is_premium = 1, premium_until = DATEADD(day, ?, GETDATE()) WHERE id = ?";
        } else {
            sql = "UPDATE users SET is_premium = 0, premium_until = NULL WHERE id = ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (isPremium) {
                ps.setInt(1, days);
                ps.setInt(2, userId);
            } else {
                ps.setInt(1, userId);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get total number of users
     */
    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Xoá user (xoá payments trước do foreign key)
     */
    public boolean deleteUser(int userId) {
        String deletePayments = "DELETE FROM payments WHERE user_id = ?";
        String deleteUser = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            // Xoá payments liên quan
            try (PreparedStatement ps = conn.prepareStatement(deletePayments)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            // Xoá user
            try (PreparedStatement ps = conn.prepareStatement(deleteUser)) {
                ps.setInt(1, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}