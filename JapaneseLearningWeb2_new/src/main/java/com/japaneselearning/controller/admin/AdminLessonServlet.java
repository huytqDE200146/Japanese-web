package com.japaneselearning.controller.admin;

import com.japaneselearning.dao.LessonDAO;
import com.japaneselearning.model.Lesson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminLessonServlet", urlPatterns = {"/admin/lessons"})
public class AdminLessonServlet extends HttpServlet {

    private LessonDAO lessonDAO = new LessonDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Lesson> lessonList = lessonDAO.getAllLessons();
        request.setAttribute("lessonList", lessonList);
        request.getRequestDispatcher("/admin/lessons.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Ensure UTF-8 encoding for Vietnamese characters
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/lessons");
            return;
        }

        try {
            if ("add".equals(action)) {
                Lesson lesson = new Lesson();
                lesson.setName(request.getParameter("name"));
                lesson.setLevel(request.getParameter("level"));
                lesson.setDescription(request.getParameter("description"));
                lesson.setContentPath(request.getParameter("contentPath"));
                
                if (lessonDAO.addLesson(lesson)) {
                    request.getSession().setAttribute("msgSuccess", "Thêm bài học thành công!");
                } else {
                    request.getSession().setAttribute("msgError", "Lỗi khi thêm bài học.");
                }
            } else if ("update".equals(action)) {
                Lesson lesson = new Lesson();
                lesson.setLessonId(Integer.parseInt(request.getParameter("lessonId")));
                lesson.setName(request.getParameter("name"));
                lesson.setLevel(request.getParameter("level"));
                lesson.setDescription(request.getParameter("description"));
                lesson.setContentPath(request.getParameter("contentPath"));
                
                if (lessonDAO.updateLesson(lesson)) {
                    request.getSession().setAttribute("msgSuccess", "Cập nhật bài học thành công!");
                } else {
                    request.getSession().setAttribute("msgError", "Lỗi khi cập nhật bài học.");
                }
            } else if ("delete".equals(action)) {
                int lessonId = Integer.parseInt(request.getParameter("lessonId"));
                
                if (lessonDAO.deleteLesson(lessonId)) {
                    request.getSession().setAttribute("msgSuccess", "Xoá bài học thành công!");
                } else {
                    request.getSession().setAttribute("msgError", "Lỗi khi xoá bài học.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("msgError", "Có lỗi xảy ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/lessons");
    }
}
