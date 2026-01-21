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

        List<Lesson> lessons = lessonDAO.getAllLessons();
        request.setAttribute("lessons", lessons);
        request.getRequestDispatcher("/lesson.jsp")
               .forward(request, response);
    }
}