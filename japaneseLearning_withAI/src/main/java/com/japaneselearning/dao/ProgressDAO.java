package com.japaneselearning.dao;

import com.japaneselearning.model.Progress;
import com.japaneselearning.utils.DBConnection;

import java.sql.*;
import java.time.LocalDate;

public class ProgressDAO {

    // ==============================
    // LẤY PROGRESS NGƯỜI DÙNG
    // ==============================
    public Progress getProgressByUserId(int userId) {
        String sql = "SELECT * FROM user_progress WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Progress p = new Progress();
                p.setUserId(rs.getInt("user_id"));
                p.setStreak(rs.getInt("streak"));
                p.setLongestStreak(rs.getInt("longest_streak"));
                p.setTotalLessons(rs.getInt("total_lessons"));
                p.setTotalQuizzes(rs.getInt("total_quizzes"));

                Date date = rs.getDate("last_study_date");
                if (date != null) {
                    p.setLastStudyDate(date.toLocalDate());
                }
                return p;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ==============================
    // CẬP NHẬT TỔNG SỐ BÀI HỌC/QUIZ
    // ==============================
    public void increaseTotalLesson(int userId) {
        String sql = "UPDATE user_progress SET total_lessons = total_lessons + 1 WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void increaseTotalQuiz(int userId) {
        String sql = "UPDATE user_progress SET total_quizzes = total_quizzes + 1 WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // LOGIC TÍNH TOÁN CHUỖI NGÀY HỌC (STREAK)
    // ==============================
    public void calculateStreak(Progress progress) {
        LocalDate today = LocalDate.now();
        LocalDate yesterday = today.minusDays(1);
        LocalDate lastDate = progress.getLastStudyDate();

        if (lastDate == null) {
            progress.setStreak(1);
        } else if (lastDate.isEqual(today)) {
            return; // Đã học hôm nay rồi, không cần tính lại
        } else if (lastDate.isEqual(yesterday)) {
            progress.setStreak(progress.getStreak() + 1);
        } else {
            progress.setStreak(1);
        }

        progress.setLastStudyDate(today);
        if (progress.getStreak() > progress.getLongestStreak()) {
            progress.setLongestStreak(progress.getStreak());
        }
    }

    public void updateProgress(Progress progress) {
        String sql = "UPDATE user_progress "
                + "SET streak = ?, longest_streak = ?, total_lessons = ?, total_quizzes = ?, last_study_date = ? "
                + "WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, progress.getStreak());
            ps.setInt(2, progress.getLongestStreak());
            ps.setInt(3, progress.getTotalLessons());
            ps.setInt(4, progress.getTotalQuizzes());

            if (progress.getLastStudyDate() != null) {
                ps.setDate(5, Date.valueOf(progress.getLastStudyDate()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setInt(6, progress.getUserId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==============================
    // THỐNG KÊ TIẾN ĐỘ THEO LEVEL
    // ==============================
    public int countCompletedLessons(int userId) {
        // Đã đổi sang đọc từ bảng lesson_progress như đã thống nhất
        String sql = "SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND completed = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countTotalLessons() {
        String sql = "SELECT COUNT(*) FROM lesson";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countTotalLessonsByLevel(String level) {
        String sql = "SELECT COUNT(*) FROM lesson WHERE level = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, level);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countCompletedLessonsByLevel(int userId, String level) {
        String sql = "SELECT COUNT(*) FROM lesson_progress lp " +
                     "JOIN lesson l ON lp.lesson_id = l.lesson_id " +
                     "WHERE lp.user_id = ? AND lp.completed = 1 AND l.level = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, level);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}