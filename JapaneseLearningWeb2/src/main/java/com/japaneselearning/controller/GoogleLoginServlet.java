package com.japaneselearning.controller;

import com.japaneselearning.dao.UserDAO;
import com.japaneselearning.model.User;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;

@WebServlet("/google-login")
public class GoogleLoginServlet extends HttpServlet {

    private static final String GOOGLE_CLIENT_ID = "912023989681-0fehc1j8pvssrm274qgetn523c92aik9.apps.googleusercontent.com";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String credential = request.getParameter("credential");

        if (credential == null || credential.isEmpty()) {
            request.setAttribute("error", "Không nhận được thông tin từ Google!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            // Verify Google ID Token
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(GOOGLE_CLIENT_ID))
                    .build();

            GoogleIdToken idToken = verifier.verify(credential);

            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();

                String googleId = payload.getSubject(); // Google unique ID
                String email = payload.getEmail();
                String fullName = (String) payload.get("name");

                UserDAO dao = new UserDAO();

                // Tìm user theo Google ID
                User user = dao.findByGoogleId(googleId);

                if (user == null) {
                    // Chưa có tài khoản → tự động đăng ký
                    user = dao.registerGoogleUser(googleId, email, fullName);
                }

                if (user != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("user", user);

                    // Phân quyền
                    if ("ADMIN".equals(user.getRole())) {
                        response.sendRedirect("admin/home.jsp");
                    } else {
                        response.sendRedirect("home.jsp");
                    }
                } else {
                    request.setAttribute("error", "Không thể tạo tài khoản. Vui lòng thử lại!");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Token Google không hợp lệ!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi xác thực Google: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
