<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Redirect to LoginServlet to check cookie/session
    response.sendRedirect(request.getContextPath() + "/login");
%>
