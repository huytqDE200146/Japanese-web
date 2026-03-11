<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Chuyển hướng người dùng vào trang chủ đầu tiên thay vì bắt phải đăng nhập
    response.sendRedirect(request.getContextPath() + "/home.jsp");
%>