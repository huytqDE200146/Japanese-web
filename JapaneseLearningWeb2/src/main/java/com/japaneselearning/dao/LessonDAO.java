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
}