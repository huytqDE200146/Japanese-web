<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Chuyển hướng về LoginServlet để kiểm tra Cookie và Session tự động
    response.sendRedirect(request.getContextPath() + "/login");
%>