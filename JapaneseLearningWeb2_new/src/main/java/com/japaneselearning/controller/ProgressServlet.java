package com.japaneselearning.controller;

import com.japaneselearning.dao.ProgressDAO;
import com.japaneselearning.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/progress")
public class ProgressServlet extends HttpServlet {

    private ProgressDAO dao;

    @Override
    public void init() {
        dao = new ProgressDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");

        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        int userId = user.getId();

        int completed = dao.countCompletedLessons(userId);
        int total = dao.countTotalLessons();

        double percent = 0;
        if (total > 0) {
            percent = (completed * 100.0) / total;
        }

        request.setAttribute("completed", completed);
        request.setAttribute("total", total);
        request.setAttribute("percent", percent);

        request.getRequestDispatcher("progress.jsp")
               .forward(request, response);
    }
}