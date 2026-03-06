package com.japaneselearning.controller;

import com.japaneselearning.dao.LessonDAO;
import com.japaneselearning.model.Lesson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@WebServlet("/lesson-detail")
public class LessonDetailServlet extends HttpServlet {

    private LessonDAO lessonDAO;

    @Override
    public void init() {
        lessonDAO = new LessonDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");

        if (idRaw == null) {
            response.sendRedirect("lessons");
            return;
        }

        try {
            int id = Integer.parseInt(idRaw);
            Lesson lesson = lessonDAO.getLessonById(id);

            if (lesson == null) {
                response.sendRedirect("lessons");
                return;
            }

            // Read lesson content from file
            String content;
            try (InputStream is = getServletContext()
                    .getResourceAsStream("/" + lesson.getContentPath())) {

                if (is != null) {
                    content = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                } else {
                    content = "<p>Không tìm thấy nội dung bài học</p>";
                }
            }

            // Get adjacent lessons for navigation
            int[] adjacentIds = lessonDAO.getAdjacentLessonIds(id);
            int prevId = adjacentIds[0];
            int nextId = adjacentIds[1];
            
            // Get lesson names for navigation display
            Lesson prevLesson = prevId != -1 ? lessonDAO.getLessonById(prevId) : null;
            Lesson nextLesson = nextId != -1 ? lessonDAO.getLessonById(nextId) : null;

            request.setAttribute("lesson", lesson);
            request.setAttribute("lessonContent", content);
            request.setAttribute("prevLessonId", prevId);
            request.setAttribute("nextLessonId", nextId);
            request.setAttribute("prevLesson", prevLesson);
            request.setAttribute("nextLesson", nextLesson);

            request.getRequestDispatcher("/lessonDetail.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("lessons");
        }
    }
}