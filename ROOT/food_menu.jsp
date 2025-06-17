<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="model.InformationDTO" %>
<%@ page import="java.io.*" %>
<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="org.jsoup.nodes.Element" %>
<%@ page import="org.jsoup.select.Elements" %>
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
    // 사용자 정보를 세션에서 가져오기
    InformationDTO user = (InformationDTO) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>식단표</title>
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
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            background-color: #f44336;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 1000;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }
        .top-bar .title img {
            height: 60px;
            width: auto;
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
            width: 15%;
            float: left;
            background-color: #f4f4f4;
            padding: 15px;
            height: 90vh;
            margin-top: 80px;
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
            color: #333;
            text-decoration: none;
        }
        nav ul li a:hover {
            color: #f44336;
            text-decoration: underline;
        }
        main {
            width: 85%;
            float: left;
            padding: 20px;
            margin-top: 80px;
        }
        .dormitory {
            margin-bottom: 30px;
        }
        .dormitory h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 24px;
            padding-bottom: 5px;
            border-bottom: 3px solid #f44336;
        }
        .meal-container {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }
        .meal-card {
            flex: 1;
            margin: 0 10px;
            padding: 15px;
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        .meal-card h2 {
            font-size: 18px;
            margin-bottom: 10px;
            color: #f44336;
        }
        .meal-card p {
            font-size: 15px;
            color: #555;
            line-height: 1.8;
            white-space: pre-line;
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
            <% if (user == null) { %>
                <a href="signup.jsp">Signup</a>
                <a href="login.jsp">Login</a>
            <% } else { %>
                <a href="mypage.jsp"><%= user.getName() %>님</a>
                <a href="logout.jsp">Logout</a>
            <% } %>
        </div>
    </header>
    <!-- 왼쪽 네비게이션 -->
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
        <h1>오늘의 식단</h1><br>
        <%
            String url = "https://www.scnu.ac.kr/dorm/main.do";
            String hyanglimBreakfast = "";
            String hyanglimLunch = "";
            String hyanglimDinner = "";

            String jinriBreakfast = "";
            String jinriLunch = "";
            String jinriDinner = "";

            try {
                // Jsoup으로 HTML 가져오기
                Document doc = Jsoup.connect(url).get();

                // 향림관·청운관·웅지관
                Element dietTy1 = doc.getElementById("dietTy1");
                if (dietTy1 != null) {
                    Element breakfast1 = dietTy1.getElementById("meal1_1");
                    Element lunch1 = dietTy1.getElementById("meal1_2");
                    Element dinner1 = dietTy1.getElementById("meal1_3");

                    if (breakfast1 != null) {
                        Elements items = breakfast1.getElementsByTag("li");
                        for (Element item : items) {
                            hyanglimBreakfast += item.text() + "<br>";
                        }
                    }

                    if (lunch1 != null) {
                        Elements items = lunch1.getElementsByTag("li");
                        for (Element item : items) {
                            hyanglimLunch += item.text() + "<br>";
                        }
                    }

                    if (dinner1 != null) {
                        Elements items = dinner1.getElementsByTag("li");
                        for (Element item : items) {
                            hyanglimDinner += item.text() + "<br>";
                        }
                    }
                }

                // 진리관·창조관
                Element dietTy2 = doc.getElementById("dietTy2");
                if (dietTy2 != null) {
                    Element breakfast2 = dietTy2.getElementById("meal2_1");
                    Element lunch2 = dietTy2.getElementById("meal2_2");
                    Element dinner2 = dietTy2.getElementById("meal2_3");

                    if (breakfast2 != null) {
                        Elements items = breakfast2.getElementsByTag("li");
                        for (Element item : items) {
                            jinriBreakfast += item.text() + "<br>";
                        }
                    }

                    if (lunch2 != null) {
                        Elements items = lunch2.getElementsByTag("li");
                        for (Element item : items) {
                            jinriLunch += item.text() + "<br>";
                        }
                    }

                    if (dinner2 != null) {
                        Elements items = dinner2.getElementsByTag("li");
                        for (Element item : items) {
                            jinriDinner += item.text() + "<br>";
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        <!-- 향림관·청운관·웅지관 -->
        <div class="dormitory">
            <h1>향림관·청운관·웅지관</h1>
            <div class="meal-container">
                <div class="meal-card">
                    <h2>아침</h2>
                    <p><%= hyanglimBreakfast %></p>
                </div>
                <div class="meal-card">
                    <h2>점심</h2>
                    <p><%= hyanglimLunch %></p>
                </div>
                <div class="meal-card">
                    <h2>저녁</h2>
                    <p><%= hyanglimDinner %></p>
                </div>
            </div>
        </div>
        <!-- 진리관·창조관 -->
        <div class="dormitory">
            <h1>진리관·창조관</h1>
            <div class="meal-container">
                <div class="meal-card">
                    <h2>아침</h2>
                    <p><%= jinriBreakfast %></p>
                </div>
                <div class="meal-card">
                    <h2>점심</h2>
                    <p><%= jinriLunch %></p>
                </div>
                <div class="meal-card">
                    <h2>저녁</h2>
                    <p><%= jinriDinner %></p>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
