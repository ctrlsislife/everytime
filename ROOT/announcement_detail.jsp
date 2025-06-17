<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.InformationDTO" %>
<%@ page import="java.sql.*" %>
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

    request.setCharacterEncoding("UTF-8");
    String idStr = request.getParameter("id");
    int id = 0;
    String pageParam = request.getParameter("page");
    String pageBack = (pageParam==null||pageParam.equals("")) ? "1" : pageParam;

    if (idStr == null) {
        out.println("<script>alert('잘못된 접근입니다.');location.href='announcement.jsp?page="+pageBack+"';</script>");
        return;
    }
    try {
        id = Integer.parseInt(idStr);
    } catch(Exception e) {
        out.println("<script>alert('잘못된 접근입니다.');location.href='announcement.jsp?page="+pageBack+"';</script>");
        return;
    }

    String title = "";
    String content = "";
    String createdAt = "";
    String updatedAt = "";
    String image = "";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
        String dbUsername = "root";
        String dbPassword = "a1234";
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);

        String sql = "SELECT * FROM announcements WHERE id=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);

        rs = pstmt.executeQuery();

        if(rs.next()) {
            title = rs.getString("title");
            content = rs.getString("content").replaceAll("\r\n|\r|\n", "<br>");
            createdAt = rs.getTimestamp("created_at").toString();
            updatedAt = rs.getTimestamp("updated_at").toString();
            image = rs.getString("image");
        } else {
            out.println("<script>alert('존재하지 않는 공지입니다.');location.href='announcement.jsp?page="+pageBack+"';</script>");
            return;
        }
    } catch(Exception e) {
        out.println("<script>alert('DB 오류 발생');location.href='announcement.jsp?page="+pageBack+"';</script>");
        return;
    } finally {
        try { if(rs != null) rs.close(); } catch(Exception e) {}
        try { if(pstmt != null) pstmt.close(); } catch(Exception e) {}
        try { if(conn != null) conn.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 상세보기</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background-color: #f9f9f9; line-height: 1.6;}
        .top-bar {
            position: fixed; top: 0; left: 0; width: 100%; z-index: 1000;
            background-color: #f44336; color: white; padding: 10px 20px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }
        .top-bar .title img { height: 60px; width: auto; }
        .nav-links a { color: white; text-decoration: none; margin-left: 15px; font-size: 16px; }
        .nav-links a:hover { text-decoration: underline; }
        nav {
            width: 15%; float: left; background-color: #f4f4f4; padding: 15px;
            height: 90vh; margin-top: 80px;
        }
        nav h3 { font-size: 18px; margin-bottom: 10px; }
        nav ul { list-style: none; padding: 0; }
        nav ul li { margin-bottom: 10px; }
        nav ul li a { font-size: 14px; color: #333; text-decoration: none; }
        nav ul li a:hover { color: #f44336; text-decoration: underline; }
        main {
            width: 85%; float: left; padding: 20px; margin-top: 80px;
            min-height: calc(100vh - 100px); background: #f9f9f9; display: block;
        }
        .notice-detail-section {
            background: white; border: 1px solid #ddd; border-radius: 5px;
            padding: 35px 40px 35px 40px; margin-bottom: 30px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.09); width: 93%;
        }
        .notice-detail-section h2 {
            font-size: 26px; color: #f44336; border-bottom: 2px solid #f44336;
            padding-bottom: 10px; margin-bottom: 18px;
        }
        .info { font-size: 15px; color: #888; margin-bottom: 24px; }
        .content {
            font-size: 17px; color: #222; min-height: 120px; margin-bottom: 30px;
            word-break: break-all;
        }
        .notice-img-area { text-align: center; margin-bottom: 24px; }
        .notice-img-area img {
            max-width: 350px; max-height: 400px; border-radius: 10px; border: 1px solid #eee;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
        }
        .button-box { text-align: right; }
        .button-box a {
            display: inline-block; background: #f44336; color: #fff; border-radius: 4px;
            padding: 8px 18px; text-decoration: none; margin-left: 6px; font-weight: bold;
        }
        .button-box a:hover { background: #d73122; }
        footer {
            clear: both; background: #333; color: white;
            text-align: center; padding: 10px 0; margin-top: 20px;
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
        <section class="notice-detail-section">
            <h2><%= title %></h2>
            <div class="info">
                작성일: <%= createdAt %>
                <% if(!createdAt.equals(updatedAt)) { %>
                   | 수정일: <%= updatedAt %>
                <% } %>
            </div>
            <% if(image != null && !image.trim().isEmpty()) { %>
            <div class="notice-img-area">
                <img src="img/<%= image %>" alt="첨부 이미지">
            </div>
            <% } %>
            <div class="content">
                <%= content %>
            </div>
            <div class="button-box">
                <a href="announcement.jsp?page=<%= pageBack %>">목록으로</a>
            </div>
        </section>
    </main>
</body>
</html>
