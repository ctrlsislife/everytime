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
    // 로그아웃 처리 (세션 해제)
    session.invalidate();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그아웃</title>
    <style>
        * {margin: 0; padding: 0; box-sizing: border-box;}
        body {font-family: Arial, sans-serif; background-color: #f9f9f9; line-height: 1.6;}
        .top-bar {
            position: fixed;
            top: 0; left: 0; width: 100%; z-index: 1000;
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
        main {
            width: 85%; float: left; padding: 20px; margin-top: 80px;
            min-height: calc(100vh - 100px); background: #f9f9f9; display: flex; align-items: center; justify-content: center;
        }
        .logout-message {
            background: #fff;
            padding: 40px 50px 40px 50px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.12);
            text-align: center;
            max-width: 400px;
            width: 100%;
        }
        .logout-message h2 {
            color: #f44336; margin-bottom: 16px;
        }
        .logout-message p {
            font-size: 17px; color: #222; margin-bottom: 30px;
        }
        .logout-message a {
            display: inline-block;
            background: #f44336;
            color: #fff;
            border-radius: 4px;
            padding: 10px 26px;
            text-decoration: none;
            font-size: 16px;
            font-weight: bold;
        }
        .logout-message a:hover {
            background: #d32f2f;
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
            <a href="index.jsp">
                <img src="img/logo.png" alt="SCNU 로고">
            </a>
        </div>
        <div class="nav-links">
            <a href="howtouse.jsp">How to use</a>
            <a href="signup.jsp">Signup</a>
            <a href="login.jsp">Login</a>
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
        <div class="logout-message">
            <h2>로그아웃 완료</h2>
            <p>정상적으로 로그아웃 되었습니다.<br>이용해주셔서 감사합니다!</p>
            <a href="index.jsp">메인으로 돌아가기</a>
        </div>
    </main>
</body>
</html>
