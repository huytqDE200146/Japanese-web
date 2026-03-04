package com.japaneselearning.filter;

import com.japaneselearning.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AdminFilter", urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo filter
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        // Kiểm tra xem user đã đăng nhập chưa
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            
            // Kiểm tra role
            if ("ADMIN".equals(user.getRole())) {
                // Cho phép truy cập
                chain.doFilter(request, response);
            } else {
                // Đăng nhập rồi nhưng không phải ADMIN -> Về trang chủ
                res.sendRedirect(req.getContextPath() + "/home");
            }
        } else {
            // Chưa đăng nhập -> Về trang login
            res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    @Override
    public void destroy() {
        // Hủy filter
    }
}
