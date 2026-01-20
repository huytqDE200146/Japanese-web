package controller;

import dao.*;
import model.Lesson;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/lesson")
public class LessonDetailServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        LessonDAO ldao = new LessonDAO();
        Lesson lesson = ldao.getLessonById(id);
        request.setAttribute("lesson", lesson);

        if ("vocab".equals(lesson.getLessonType())) {
            request.setAttribute("vocabs", new VocabularyDAO().getByLessonId(id));
        } else if ("grammar".equals(lesson.getLessonType())) {
            request.setAttribute("grammars", new GrammarDAO().getByLessonId(id));
        }

        request.getRequestDispatcher("lesson.jsp").forward(request, response);
    }
}
