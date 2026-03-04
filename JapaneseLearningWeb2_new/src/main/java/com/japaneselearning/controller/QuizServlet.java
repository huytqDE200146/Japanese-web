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

@WebServlet("/quiz")
public class QuizServlet extends HttpServlet {

    private LessonDAO lessonDAO;

    @Override
    public void init() {
        lessonDAO = new LessonDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Load grouped lessons for the quiz page
        Map<String, List<Lesson>> groupedLessons = lessonDAO.getLessonsGroupedByCategory();
        request.setAttribute("groupedLessons", groupedLessons);
        
        request.getRequestDispatcher("/quiz.jsp").forward(request, response);
    }
}
