package com.japaneselearning.dao;

<<<<<<< HEAD
import com.japaneselearning.model.Progress;
import com.japaneselearning.utils.DBConnection;

import java.sql.*;
import java.time.LocalDate;

public class ProgressDAO {

    // ==============================
    // LẤY PROGRESS
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
    // TĂNG LESSON
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

    // ==============================
    // TĂNG QUIZ
    // ==============================
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
    // LOGIC STREAK (CHỈ XỬ LÝ LOGIC)
    // ==============================
    public void calculateStreak(Progress progress) {

        LocalDate today = LocalDate.now();
        LocalDate yesterday = today.minusDays(1);
        LocalDate lastDate = progress.getLastStudyDate();

        if (lastDate == null) {
            progress.setStreak(1);
        }
        else if (lastDate.isEqual(today)) {
            return; // đã học hôm nay rồi
        }
        else if (lastDate.isEqual(yesterday)) {
            progress.setStreak(progress.getStreak() + 1);
        }
        else {
            progress.setStreak(1);
        }

        progress.setLastStudyDate(today);

        if (progress.getStreak() > progress.getLongestStreak()) {
            progress.setLongestStreak(progress.getStreak());
        }
    }

    // ==============================
    // UPDATE FULL PROGRESS
    // ==============================
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
    // THỐNG KÊ
    // ==============================
    public int countCompletedLessons(int userId) {

        String sql = "SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND completed = 1";
=======
import com.japaneselearning.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ProgressDAO {

    public int countCompletedLessons(int userId) {
        String sql = "SELECT COUNT(*) "
                + "FROM progress "
                + "WHERE user_id = ? AND completed = 1";
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int countTotalLessons() {
<<<<<<< HEAD

        String sql = "SELECT COUNT(*) FROM lesson";
=======
        String sql = "SELECT COUNT(*) FROM lessons";
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b

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
<<<<<<< HEAD
    
    public int countTotalLessonsByLevel(String level) {
        String sql = "SELECT COUNT(*) FROM lesson WHERE level = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, level);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
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
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
=======
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
}