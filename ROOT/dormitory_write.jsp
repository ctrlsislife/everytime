<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.InformationDTO" %>
<%
    Boolean turnstileValidated = (Boolean) session.getAttribute("turnstileValidated");
    if (turnstileValidated == null || !turnstileValidated) {
        // 현재 페이지 주소 저장 (쿼리스트링도 포함)
        String thisURL = request.getRequestURI();
        if(request.getQueryString() != null) {
            thisURL += "?" + request.getQueryString();
        }
        session.setAttribute("redirectAfterCaptcha", thisURL);
        response.sendRedirect("turnstile.jsp");
        return;
    }
%>
<%
    InformationDTO user = (InformationDTO) session.getAttribute("user");
    if(user == null) {
        response.sendRedirect("dormitory_board.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>기숙사 게시판 글쓰기</title>
    <style>
        * {margin: 0; padding: 0; box-sizing: border-box;}
        body {font-family: Arial, sans-serif; background-color: #f9f9f9; line-height: 1.6;}
        .top-bar {
            position: fixed; top: 0; left: 0; width: 100%; z-index: 1000;
            background-color: #f44336; color: white; padding: 10px 20px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }
        .top-bar .title img {height: 60px; width: auto;}
        .nav-links a {color: white; text-decoration: none; margin-left: 15px; font-size: 16px;}
        .nav-links a:hover {text-decoration: underline;}
        nav {
            width: 15%; float: left; background-color: #f4f4f4; padding: 15px;
            height: 90vh; margin-top: 80px;
        }
        nav h3 {font-size: 18px; margin-bottom: 10px;}
        nav ul {list-style: none; padding: 0;}
        nav ul li {margin-bottom: 10px;}
        nav ul li a {font-size: 14px; color: #333; text-decoration: none;}
        nav ul li a:hover {color: #f44336; text-decoration: underline;}
        main {width:85%; float:left; padding:20px; margin-top:80px; display:flex; justify-content:center; background:#f9f9f9; min-height:calc(100vh - 100px);}
        .write-form-container {background:#fff; width:100%; max-width:650px; padding:36px 34px 28px 34px; border:1px solid #ddd; border-radius:8px; box-shadow: 0 2px 5px rgba(0,0,0,.13);}
        .write-form-container h2 {font-size:22px; margin-bottom:26px; color:#f44336; border-bottom:2px solid #f44336; padding-bottom:10px; text-align:center;}
        .write-form label {font-size:16px; color:#333; margin-bottom:8px; display:block;}
        .write-form input[type="text"], .write-form textarea {width:100%; padding:14px; border:1px solid #ccc; border-radius:4px; font-size:15px; margin-bottom:20px;}
        .write-form textarea {min-height:180px; resize:vertical;}
        .write-form input[type="file"] {margin-bottom:20px; font-size:15px;}
        .write-form .btns {text-align:right;}
        .write-form button, .write-form a {
            display:inline-block; background:#f44336; color:#fff; border-radius:50px;
            border:none; font-size:16px; font-weight:bold; padding:10px 32px;
            margin-left:7px; text-decoration:none; cursor:pointer; transition:background .13s; box-shadow:0 2px 8px rgba(244,67,54,.09);
        }
        .write-form button:hover, .write-form a:hover {background:#d32f2f;}
        footer {clear:both; background:#333; color:white; text-align:center; padding:10px 0; margin-top:25px;}
    </style>
</head>
<body>
    <!-- 상단바 -->
    <header class="top-bar">
        <div class="title">
            <a href="index.jsp">
                <img src="img/logo.png" alt="SCNU 로고">
            </a>
        </div>
        <div class="nav-links">
            <a href="howtouse.jsp">How to use</a>
            <% if (user == null) { %>
                <a href="signup.jsp">Signup</a>
                <a href="login.jsp">Login</a>
            <% } else { %>
                <a href="mypage.jsp"><%= user.getName() %>님</a>
                <a href="logout.jsp">Logout</a>
            <% } %>
        </div>
    </header>
    <!-- 네비게이션 -->
    <nav>
        <h3>순천대학교</h3>
        <ul>
            <li><a href="announcement.jsp">공지사항</a></li>
            <li><a href="class_schedule.jsp">시간표</a></li>
            <li><a href="school_schedule.jsp">학사일정</a></li>
            <li><a href="food_menu.jsp">오늘의 학식</a></li>
            <li><a href="free_board.jsp">자유 게시판</a></li>
            <li><a href="dormitory_board.jsp">기숙사 게시판</a></li>
            <li><a href="offcampus_board.jsp">자취생 게시판</a></li>
            <li><a href="debate_board.jsp">토론 게시판</a></li>
            <li><a href="request_board.jsp">게시판 요청</a></li>
        </ul>
    </nav>
    <main>
        <div class="write-form-container">
            <h2>기숙사 게시판 글쓰기</h2>
            <form class="write-form" action="dormitory_write_process" method="post" enctype="multipart/form-data">
                <label for="title">제목</label>
                <input type="text" id="title" name="title" maxlength="150" required>
                <label for="content">내용</label>
                <textarea id="content" name="content" maxlength="2000" required></textarea>
                <label for="file">사진 업로드</label>
                <input type="file" id="file" name="file" accept="image/*">
                <div class="btns">
                    <button type="submit">등록</button>
                    <a href="dormitory_board.jsp">취소</a>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
