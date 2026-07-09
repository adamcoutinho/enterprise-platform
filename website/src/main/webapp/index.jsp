<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>Document</title>

  <!-- CSS gerados pelo Vite -->
  <c:forEach var="css" items="${cssFiles}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/${css}" />
  </c:forEach>

</head>

<body>

<div id="root"></div>

<!-- JavaScript gerados pelo Vite -->
<c:forEach var="js" items="${jsFiles}">
  <script type="module"
          src="${pageContext.request.contextPath}/${js}"></script>
</c:forEach>

</body>

</html>
