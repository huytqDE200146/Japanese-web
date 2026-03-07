package com.japaneselearning.controller;

import com.japaneselearning.dao.LessonDAO;
import com.japaneselearning.model.Lesson;
import com.japaneselearning.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
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

        // 1. Kiểm tra session và lấy thông tin người dùng
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 2. Lấy danh sách ID các bài học đã hoàn thành để hiện dấu tick ✅
        List<Integer> completedIds = new ArrayList<>();
        if (user != null) {
            // Sử dụng hàm getCompletedLessonIds đã sửa trong LessonDAO để đọc từ bảng lesson_progress
            completedIds = lessonDAO.getCompletedLessonIds(user.getId());
        }
        request.setAttribute("completedIds", completedIds);

        // 3. Lấy danh sách bài học đã được nhóm theo Category (Hiragana, Katakana, Kanji...)
        Map<String, List<Lesson>> groupedLessons = lessonDAO.getLessonsGroupedByCategory();
        request.setAttribute("groupedLessons", groupedLessons);

        // 4. Lấy danh sách phẳng (flat list) để tương thích với các phần cũ nếu cần
        List<Lesson> lessons = lessonDAO.getAllLessons();
        request.setAttribute("lessons", lessons);

        // 5. Chuyển hướng dữ liệu sang trang lesson.jsp
        request.getRequestDispatcher("/lesson.jsp").forward(request, response);
    }
}