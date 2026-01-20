<%@ page contentType="text/html; charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lesson List</title>
    <style>
        body { font-family: Arial; }
        .lesson {
            padding: 10px;
            margin: 8px 0;
            border: 1px solid #ccc;
            border-radius: 6px;
        }
        .lesson a {
            text-decoration: none;
            font-weight: bold;
            color: #2c3e50;
        }
        .type {
            font-size: 13px;
            color: #888;
        }
    </style>
</head>
<body>

<h2>📚 Lesson List</h2>

<c:if test="${empty lessons}">
    <p>No lesson found.</p>
</c:if>

<c:forEach var="l" items="${lessons}">
    <div class="lesson">
        <a href="lesson?id=${l.lessonId}">
            ${l.title}
        </a>
        <div class="type">
            Type: ${l.lessonType}
        </div>
        <p>${l.description}</p>
    </div>
</c:forEach>

<a href="home.jsp">⬅ Back to Home</a>

</body>
</html>
