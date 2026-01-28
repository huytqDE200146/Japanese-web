<%--<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.japaneselearning.model.Lesson" %>



<%
    List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
%>

<h2>Lesson List</h2>

<% if (lessons == null || lessons.isEmpty()) { %>
    <p>Chưa có lesson nào.</p>
<% } else { %>
    <ul>
    <% for (Lesson l : lessons) { %>
        <li>
            <a href="lesson-detail?id=<%= l.getLessonId() %>">
                <%= l.getName() %> - <%= l.getLevel() %>
            </a>
        </li>
    <% } %>
    </ul>
<% } %>--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.japaneselearning.model.Lesson" %>

<%
    List<Lesson> lessons = (List<Lesson>) request.getAttribute("lessons");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Lesson List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            margin: 0;
            padding: 0;
        }

        .container {
            width: 85%;
            margin: 30px auto;
        }

        h2 {
            color: #2c3e50;
            margin-bottom: 20px;
        }

        .lesson-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
        }

        .lesson-card {
            background: #ffffff;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.08);
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .lesson-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 18px rgba(0,0,0,0.12);
        }

        .lesson-title {
            font-size: 18px;
            font-weight: bold;
            color: #34495e;
            margin-bottom: 8px;
        }

        .lesson-level {
            display: inline-block;
            padding: 4px 10px;
            background: #3498db;
            color: white;
            border-radius: 20px;
            font-size: 13px;
            margin-bottom: 12px;
        }

        .lesson-link {
            display: inline-block;
            margin-top: 10px;
            text-decoration: none;
            color: white;
            background: #2ecc71;
            padding: 8px 14px;
            border-radius: 6px;
            font-size: 14px;
        }

        .lesson-link:hover {
            background: #27ae60;
        }
        
        .lesson-description {
            font-size: 10px;
            font-weight: bold;
            color: #34495e;
            margin-bottom: 8px;
        }

        .empty {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            color: #888;
        }
    </style>
</head>

<body>
<div class="container">

    <h2>📘 Lesson List</h2>

    <% if (lessons == null || lessons.isEmpty()) { %>
        <div class="empty">Chưa có lesson nào.</div>
    <% } else { %>

        <div class="lesson-grid">
            <% for (Lesson l : lessons) { %>
                <div class="lesson-card">
                    <div class="lesson-title">
                        <%= l.getName() %>
                    </div>

                    <div class="lesson-level">
                        Level: <%= l.getLevel() %>
                    </div>

                    <div class="lesson-description">
                        <%= l.getDescription()%>
                    </div>
                    
                    <br>

                    <a class="lesson-link"
                       href="lesson-detail?id=<%= l.getLessonId() %>">
                        Xem bài học →
                    </a>
                </div>
            <% } %>
        </div>

    <% } %>

</div>
</body>
</html>
