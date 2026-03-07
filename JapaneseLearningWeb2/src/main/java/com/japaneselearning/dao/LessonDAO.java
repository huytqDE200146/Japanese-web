package com.japaneselearning.dao;


import com.japaneselearning.model.Lesson;
import com.japaneselearning.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


public class LessonDAO {

    public List<Lesson> getAllLessons() {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT * FROM lesson ORDER BY lesson_id";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Lesson l = mapResultSetToLesson(rs);
                list.add(l);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Lesson getLessonById(int id) {
        String sql = "SELECT * FROM lesson WHERE lesson_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToLesson(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get lessons grouped by category (name field)
     * Returns a LinkedHashMap to maintain insertion order
     */
    public Map<String, List<Lesson>> getLessonsGroupedByCategory() {
        Map<String, List<Lesson>> groupedLessons = new LinkedHashMap<>();
        List<Lesson> allLessons = getAllLessons();
        
        for (Lesson lesson : allLessons) {
            String category = lesson.getName();
            groupedLessons.computeIfAbsent(category, k -> new ArrayList<>()).add(lesson);
        }
        
        return groupedLessons;
    }
    
    /**
     * Get adjacent lesson IDs for navigation (previous and next)
     * Returns int[2] where [0] = previousId, [1] = nextId
     * Value of -1 means no previous/next lesson exists
     */
    public int[] getAdjacentLessonIds(int currentId) {
        int[] result = {-1, -1}; // [previousId, nextId]
        String sql = "SELECT lesson_id FROM lesson ORDER BY lesson_id";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            List<Integer> ids = new ArrayList<>();
            while (rs.next()) {
                ids.add(rs.getInt("lesson_id"));
            }
            
            int currentIndex = ids.indexOf(currentId);
            if (currentIndex > 0) {
                result[0] = ids.get(currentIndex - 1); // previous
            }
            if (currentIndex < ids.size() - 1 && currentIndex != -1) {
                result[1] = ids.get(currentIndex + 1); // next
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return result;
    }
    
    private Lesson mapResultSetToLesson(ResultSet rs) throws SQLException {
        Lesson l = new Lesson();
        l.setLessonId(rs.getInt("lesson_id"));
        l.setName(rs.getString("name"));
        l.setLevel(rs.getString("level"));
        l.setDescription(rs.getString("description"));
        l.setContentPath(rs.getString("content_path"));
        l.setCreatedAt(rs.getTimestamp("created_at"));
        return l;
    }

    // --- ADMIN METHODS ---

    /**
     * Add a new lesson
     */
    public boolean addLesson(Lesson lesson) {
        String sql = "INSERT INTO lesson (name, level, description, content_path) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, lesson.getName());
            ps.setString(2, lesson.getLevel());
            ps.setString(3, lesson.getDescription());
            ps.setString(4, lesson.getContentPath());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update an existing lesson
     */
    public boolean updateLesson(Lesson lesson) {
        String sql = "UPDATE lesson SET name=?, level=?, description=?, content_path=? WHERE lesson_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, lesson.getName());
            ps.setString(2, lesson.getLevel());
            ps.setString(3, lesson.getDescription());
            ps.setString(4, lesson.getContentPath());
            ps.setInt(5, lesson.getLessonId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete a lesson
     */
    public boolean deleteLesson(int lessonId) {
        String sql = "DELETE FROM lesson WHERE lesson_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, lessonId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get total number of lessons
     */
    public int getTotalLessons() {
        String sql = "SELECT COUNT(*) FROM lesson";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public boolean markLessonCompleted(int userId, int lessonId) {
        
        // BƯỚC 1: Kiểm tra xem user này đã hoàn thành bài này chưa
        String checkSql = "SELECT 1 FROM lesson_progress WHERE user_id = ? AND lesson_id = ?";
        try (Connection conn = com.japaneselearning.utils.DBConnection.getConnection();
             PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            
            psCheck.setInt(1, userId);
            psCheck.setInt(2, lessonId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    System.out.println("DEBUG - Bài học " + lessonId + " ĐÃ ĐƯỢC HỌC TỪ TRƯỚC.");
                    return false; // Đã học rồi thì không insert nữa
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        // BƯỚC 2: Nếu chưa học, thực hiện Insert với cột completed_date
        String insertSql = "INSERT INTO lesson_progress (user_id, lesson_id, completed, completed_date) VALUES (?, ?, 1, GETDATE())";
        try (Connection conn = com.japaneselearning.utils.DBConnection.getConnection();
             PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
            
            psInsert.setInt(1, userId);
            psInsert.setInt(2, lessonId);
            
            int rows = psInsert.executeUpdate();
            System.out.println("DEBUG - Đã INSERT thành công bài " + lessonId + ". Số dòng: " + rows);
            
            // Nếu rows = 1 tức là insert thành công
            return rows > 0; 
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public java.util.List<Integer> getCompletedLessonIds(int userId) {
        java.util.List<Integer> list = new java.util.ArrayList<>();
        
        // QUAN TRỌNG: Phải đọc từ bảng 'lesson_progress', tuyệt đối KHÔNG đọc từ bảng 'progress' cũ
        String sql = "SELECT lesson_id FROM lesson_progress WHERE user_id = ? AND completed = 1";

        try (java.sql.Connection conn = com.japaneselearning.utils.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("lesson_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}