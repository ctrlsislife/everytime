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
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            line-height: 1.6;
        }
        .top-bar {
            position: fixed; /* 상단 고정 */
            top: 0;
            left: 0;
            width: 100%; /* 화면 전체 너비 */
            z-index: 1000; /* 다른 요소 위로 배치 */
            background-color: #f44336; /* 빨간색 상단 바 */
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2); /* 약간의 음영 효과 */
        }
        .top-bar .title img {
            height: 60px; /* 이미지 높이 확대 */
            width: auto;  /* 비율 유지 */
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            margin-left: 15px;
            font-size: 16px;
        }
        .nav-links a:hover {
            text-decoration: underline;
        }
        nav {
            width: 15%; /* 네비게이션 폭 */
            float: left;
            background-color: #f4f4f4; /* 배경색 */
            padding: 15px;
            height: 90vh; /* 전체 화면 높이 */
            margin-top: 80px; /* 상단 바 높이 */
        }
        nav h3 {
            font-size: 18px;
            margin-bottom: 10px;
        }
        nav ul {
            list-style: none;
            padding: 0;
        }
        nav ul li {
            margin-bottom: 10px;
        }
        nav ul li a {
            font-size: 14px;
            color: #333; /* 글씨색 */
            text-decoration: none;
        }
        nav ul li a:hover {
            color: #f44336; /* 글씨 빨간색 (호버시) */
            text-decoration: underline;
        }
        main {
            width: 85%; /* 메인 컨텐츠 폭 */
            float: left;
            padding: 20px;
            margin-top: 80px; /* 상단 바 높이만큼 여백 */
            display: flex;
            justify-content: center; /* 중앙 정렬 */
            align-items: center; /* 수직 중앙 정렬 */
            min-height: calc(100vh - 120px); /* 화면 높이에서 상단 바와 푸터 높이 제외 */
        }
        .login-form {
            background: white;
            width: 100%;
            max-width: 400px; /* 폼 최대 너비 */
            padding: 30px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        .login-form h2 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
            border-bottom: 2px solid #f44336;
            padding-bottom: 10px;
            text-align: center;
        }
        .login-form label {
            display: block;
            margin-bottom: 10px;
            font-size: 16px;
            color: #333;
        }
        .login-form input[type="text"],
        .login-form input[type="password"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
        }
        .login-form input[type="submit"] {
            width: 100%;
            padding: 10px;
            background-color: #f44336;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
        }
        .login-form input[type="submit"]:hover {
            background-color: #d32f2f;
        }
        .login-form .error {
            color: #f44336;
            font-size: 14px;
            margin-top: -10px;
            margin-bottom: 15px;
            display: none; /* 기본적으로 숨김 */
        }
        .login-form .register-link {
            text-align: center;
            margin-top: 20px;
        }
        .login-form .register-link a {
            color: #f44336;
            text-decoration: none;
        }
        .login-form .register-link a:hover {
            text-decoration: underline;
        }
        footer {
            clear: both;
            background: #333;
            color: white;
            text-align: center;
            padding: 10px 0;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <!-- 상단 바 -->
    <header class="top-bar">
        <div class="title">
            <!-- 로컬 이미지 경로 -->
            <a href="index.jsp">
                <img src="img/logo.png" alt="SCNU 로고"> <!-- 이미지 파일 경로 -->
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
    <!-- 메인 컨텐츠 -->
    <main>
        <div class="login-form">
            <h2>로그인</h2>
            <form action="login_process.jsp" method="post">
                <label for="username">아이디</label>
                <input type="text" id="username" name="username" required>
                <div class="error" id="usernameError">아이디를 입력해주세요.</div>
                
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" required>
                <div class="error" id="passwordError">비밀번호를 입력해주세요.</div>
                
                <input type="submit" value="로그인">
            </form>
            <div class="register-link">
                <p>계정이 없으신가요? <a href="signup.jsp">회원가입</a></p>
            </div>
        </div>
    </main>
</body>
</html>
