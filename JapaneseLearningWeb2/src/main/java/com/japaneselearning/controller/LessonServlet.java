package com.japaneselearning.controller;

import com.japaneselearning.dao.LessonDAO;
import com.japaneselearning.model.Lesson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/lessons")
public class LessonServlet extends HttpServlet {

    private LessonDAO lessonDAO;

    @Override
    public void init() {
        lessonDAO = new LessonDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get lessons grouped by category for better display
        Map<String, List<Lesson>> groupedLessons = lessonDAO.getLessonsGroupedByCategory();
        request.setAttribute("groupedLessons", groupedLessons);
        
        // Also pass flat list for backward compatibility
        List<Lesson> lessons = lessonDAO.getAllLessons();
        request.setAttribute("lessons", lessons);
        
        request.getRequestDispatcher("/lesson.jsp")
               .forward(request, response);
    }
}