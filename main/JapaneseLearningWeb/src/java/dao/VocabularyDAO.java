package dao;

import java.sql.*;
import java.util.*;
import model.Vocabulary;
import utils.DBConnection;

public class VocabularyDAO {

    public List<Vocabulary> getByLessonId(int lessonId) {
        List<Vocabulary> list = new ArrayList<>();
        String sql = "SELECT * FROM vocabulary WHERE lesson_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, lessonId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Vocabulary v = new Vocabulary(
                        rs.getInt("vocab_id"),
                        lessonId,
                        rs.getString("word"),
                        rs.getString("meaning"),
                        rs.getString("image_url")
                );
                list.add(v);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
