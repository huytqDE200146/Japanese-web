package com.japaneselearning.dao;


import com.japaneselearning.model.Lesson;
import com.japaneselearning.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class LessonDAO {

    public List<Lesson> getAllLessons() {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT * FROM lesson";

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