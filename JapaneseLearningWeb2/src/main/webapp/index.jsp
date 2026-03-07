<%@ page contentType="text/html;charset=UTF-8" %>
<%
<<<<<<< HEAD
    // Redirect to LoginServlet to check cookie/session
    response.sendRedirect(request.getContextPath() + "/login");
=======
    // Redirect to home.jsp (which now acts as both user dashboard and guest landing page)
    response.sendRedirect("home.jsp");
>>>>>>> f88f49bbc623c4dcecf2fbf29b3238f8f6b4161b
%>
