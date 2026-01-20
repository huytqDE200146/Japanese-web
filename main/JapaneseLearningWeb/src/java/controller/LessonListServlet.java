package controller;

import dao.LessonDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/lessons")
public class LessonListServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LessonDAO dao = new LessonDAO();
        request.setAttribute("lessons", dao.getAllLessons());
        request.getRequestDispatcher("course.jsp").forward(request, response);
    }
}
