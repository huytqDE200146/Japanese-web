package dao;

import java.sql.*;
import java.util.*;
import model.Grammar;
import utils.DBConnection;

public class GrammarDAO {

    public List<Grammar> getByLessonId(int lessonId) {
        List<Grammar> list = new ArrayList<>();
        String sql = "SELECT * FROM grammar WHERE lesson_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, lessonId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Grammar g = new Grammar(
                        rs.getInt("grammar_id"),
                        lessonId,
                        rs.getString("content")
                );
                list.add(g);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
