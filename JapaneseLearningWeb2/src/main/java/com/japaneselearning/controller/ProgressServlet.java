package com.japaneselearning.controller;

import com.japaneselearning.dao.ProgressDAO;
<<<<<<< HEAD
import com.japaneselearning.model.Progress;
import com.japaneselearning.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
=======
import com.japaneselearning.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
import java.io.IOException;

@WebServlet("/progress")
public class ProgressServlet extends HttpServlet {

<<<<<<< HEAD
=======
    private ProgressDAO dao;

    @Override
    public void init() {
        dao = new ProgressDAO();
    }

>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

<<<<<<< HEAD
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        ProgressDAO progressDAO = new ProgressDAO();
        Progress progress = progressDAO.getProgressByUserId(user.getId());

        // 1. Tạo chuỗi Level hiện tại (Ví dụ: user.getLevel() là 5 -> currentLevel = "N5")
        String currentLevel = "N" + user.getLevel();

        // 2. Chỉ đếm số bài học của đúng Level hiện tại
        int completedInLevel = progressDAO.countCompletedLessonsByLevel(user.getId(), currentLevel);
        int totalInLevel = progressDAO.countTotalLessonsByLevel(currentLevel);

        // 3. Tính toán phần trăm (chỉ trong phạm vi Level đó)
        int percent = (totalInLevel > 0) ? (completedInLevel * 100 / totalInLevel) : 0;

        // 4. Gửi dữ liệu sang JSP
        request.setAttribute("completedCount", completedInLevel);
        request.setAttribute("totalCount", totalInLevel);
        request.setAttribute("percent", percent);
        request.setAttribute("currentLevelStr", currentLevel); // Gửi thêm biến này để in chữ "N5" ra giao diện

        if (progress != null) {
            request.setAttribute("streak", progress.getStreak());
            request.setAttribute("longestStreak", progress.getLongestStreak());
        } else {
            request.setAttribute("streak", 0);
            request.setAttribute("longestStreak", 0);
        }

        request.getRequestDispatcher("/progress.jsp").forward(request, response);
=======
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
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
    }
}