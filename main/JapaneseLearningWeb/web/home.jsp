<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Home</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
</head>

<body>

<!-- ===== NAVBAR ===== -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="home.jsp">Japanese Learning</a>

        <div class="collapse navbar-collapse">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">

                <li class="nav-item">
                    <a class="nav-link" href="course.jsp">Course</a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="quiz.jsp">Quiz</a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="process.jsp">Process</a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="ai-chat.jsp">AI Chats</a>
                </li>
            </ul>

            <span class="navbar-text text-white me-3">
                Xin chào, <strong><%= user.getFullName() %></strong>
            </span>

            <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<!-- ===== CONTENT ===== -->
<div class="container mt-4">

    <h3>👋 Welcome to Japanese Learning Website</h3>

    <div class="card mt-3">
        <div class="card-body">

            <h5 class="card-title">Thông tin người dùng</h5>

            <p><strong>Username:</strong> <%= user.getUsername() %></p>
            <p><strong>Email:</strong> <%= user.getEmail() %></p>
            <p><strong>Họ tên:</strong> <%= user.getFullName() %></p>
            <p><strong>Role:</strong> <%= user.getRole() %></p>
            <p><strong>Trạng thái:</strong> <%= user.getStatus() %></p>
        </div>
    </div>

</div>

</body>
</html>