<%@ page contentType="text/html; charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lesson Detail</title>
    <style>
        body { font-family: Arial; }       ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
        table {
            border-collapse: collapse;
            width: 100%;
        }
        table, th, td {
            border: 1px solid #ccc;
        }
        th, td {
            padding: 8px;
            text-align: left;
        }
        img {
            max-width: 80px;
        }
        .grammar {
            background: #f9f9f9;
            padding: 10px;
            margin-bottom: 10px;
            border-left: 4px solid #3498db;
        }
    </style>
</head>
<body>

<h2>${lesson.title}</h2>
<p>${lesson.description}</p>

<hr/>

<!-- ===== VOCABULARY ===== -->
<c:if test="${lesson.lessonType == 'vocab' || lesson.lessonType == 'mixed'}">
    <h3>📘 Vocabulary</h3>

    <table>
        <tr>
            <th>Word</th>
            <th>Meaning</th>
            <th>Image</th>
        </tr>

        <c:forEach var="v" items="${vocabs}">
            <tr>
                <td>${v.word}</td>
                <td>${v.meaning}</td>
                <td>
                    <c:if test="${not empty v.imageUrl}">
                        <img src="${v.imageUrl}">
                    </c:if>
                </td>
            </tr>
        </c:forEach>
    </table>
</c:if>

<!-- ===== GRAMMAR ===== -->
<c:if test="${lesson.lessonType == 'grammar' || lesson.lessonType == 'mixed'}">
    <h3>📗 Grammar</h3>

    <c:forEach var="g" items="${grammars}">
        <div class="grammar">
            ${g.content}
        </div>
    </c:forEach>
</c:if>

<br/>
<a href="lessons">⬅ Back to Lesson List</a>

</body>
</html>
