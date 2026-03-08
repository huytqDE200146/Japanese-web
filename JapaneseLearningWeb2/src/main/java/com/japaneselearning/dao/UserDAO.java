package com.japaneselearning.dao;

import com.japaneselearning.model.User;
import com.japaneselearning.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // Đăng ký người dùng mới
    public boolean register(User user) {
        String sql = "INSERT INTO users(username, password, email, full_name, level, role, status) "
                   + "VALUES (?, ?, ?, ?, 0, 'USER', 'ACTIVE')";

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
        String sql = "SELECT * FROM users WHERE username=? AND password=? AND (status='ACTIVE' OR status='BANNED' OR status='BAN')";

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
        String sql = "SELECT * FROM users WHERE google_id=? AND (status='ACTIVE' OR status='BANNED' OR status='BAN')";
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

    // Đăng ký user từ Google
    public User registerGoogleUser(String googleId, String email, String fullName) {
        String sql = "INSERT INTO users(username, password, email, full_name, level, role, status, google_id) "
                   + "VALUES (?, '', ?, ?, 0, 'USER', 'ACTIVE', ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

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

    // Khởi tạo bảng tiến độ khi đăng ký
    public void registerProgress(int userId) {
        String sql = "INSERT INTO user_progress (user_id, streak, total_lessons, total_quizzes) VALUES (?, 0, 0, 0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean isUsernameExist(String username) {
        String sql = "SELECT id FROM users WHERE username=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            return ps.executeQuery().next();
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean isEmailExist(String email) {
        String sql = "SELECT id FROM users WHERE email=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email=? AND (status='ACTIVE' OR status='BANNED' OR status='BAN')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean updatePasswordByEmail(String email, String newPassword) {
        String sql = "UPDATE users SET password=? WHERE email=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean upgradeToPremium(int userId, int daysToAdd) {
        String sql = "UPDATE users SET is_premium = 1, premium_until = DATEADD(day, ?, " +
                     "CASE WHEN premium_until IS NULL OR premium_until < GETDATE() " +
                     "THEN GETDATE() ELSE premium_until END) WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, daysToAdd);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

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
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    private User mapResultSetToUser(ResultSet rs) throws Exception {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setFullName(rs.getString("full_name"));
        u.setRole(rs.getString("role"));
        u.setStatus(rs.getString("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        
        try { u.setLevel(rs.getInt("level")); } catch (Exception e) { u.setLevel(0); }
        
        try {
            u.setPremium(rs.getBoolean("is_premium"));
            u.setPremiumUntil(rs.getTimestamp("premium_until"));
        } catch (Exception e) {
            u.setPremium(false);
            u.setPremiumUntil(null);
        }
        
        try { u.setGoogleId(rs.getString("google_id")); } catch (Exception e) { u.setGoogleId(null); }
        
        return u;
    }

    // Cập nhật level cho user (phiên bản cuối cùng)
    public boolean updateUserLevel(int userId, int level) {
        String sql = "UPDATE users SET level=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, level);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateUserRole(int userId, String role) {
        String sql = "UPDATE users SET role=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

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
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public boolean deleteUser(int userId) {
        String deletePayments = "DELETE FROM payments WHERE user_id = ?";
        String deleteLessonProgress = "DELETE FROM lesson_progress WHERE user_id = ?";
        String deleteUserProgress = "DELETE FROM user_progress WHERE user_id = ?";
        String deleteUser = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(deletePayments)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(deleteLessonProgress)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(deleteUserProgress)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(deleteUser)) {
                ps.setInt(1, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
}