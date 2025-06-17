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

    String myImage = null, imageId = null, createdAt = null;
    boolean hasMyImage = false;
    if(user != null) {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering", "root", "a1234");
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT * FROM class_schedule WHERE user_id = ? ORDER BY created_at DESC LIMIT 1");
            pstmt.setInt(1, user.getUserId());
            ResultSet rs = pstmt.executeQuery();
            if(rs.next()) {
                hasMyImage = true;
                imageId = String.valueOf(rs.getInt("id"));
                myImage = rs.getString("image");
                createdAt = rs.getString("created_at");
            }
            rs.close(); pstmt.close(); conn.close();
        } catch(Exception e){e.printStackTrace();}
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>SCNU 시간표</title>
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
        main {
            width: 85%; float: left; padding: 20px; margin-top: 80px;
            min-height: calc(100vh - 100px); background: #f9f9f9; display: block;
        }
        h1 {color:#f44336; border-bottom:2px solid #f44336; margin-bottom:34px; padding-bottom:10px; text-align:center;}
        .class-img {display:flex; flex-direction:column; align-items:center; margin:35px 0 20px 0;}
        .class-img img {
            width:50vw; max-width:640px; height:auto;
            border-radius:16px; border:1px solid #eee; box-shadow:0 1px 8px rgba(0,0,0,0.09);
        }
        .class-date {font-size:14px; color:#888; text-align:center; margin-top:12px;}
        .owner-area {margin:38px 0 24px 0; text-align:center;}
        .owner-area form {display:inline-block;}
        .owner-area input[type="file"] {margin-bottom:19px;font-size:15px;}
        .owner-area button, .owner-area a {background:#f44336; color:#fff; border:none; border-radius:5px; padding:8px 20px; font-size:15px; font-weight:bold; margin:5px 5px 0 5px; cursor:pointer;}
        .owner-area button:hover, .owner-area a:hover {background:#d73228;}
        .editbtn {padding:8px 22px !important; font-size:15px; background:#f44336; color:#fff;}
        .hidden {display:none;}
    </style>
</head>
<body>
<header class="top-bar">
    <div class="title">
        <a href="index.jsp"><img src="img/logo.png" alt="SCNU 로고"></a>
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
    <div class="container">
        <h1>나의 시간표</h1>
    <% if(user != null) { %>
        <div class="owner-area">
            <% if(!hasMyImage) { %>
            <form action="class_schedule_upload" method="post" enctype="multipart/form-data">
                <input type="file" name="image" accept="image/*" required>
                <button type="submit">등록</button>
            </form>
            <% } %>
        </div>
    <% } %>
        <% if(hasMyImage && user != null) { %>
        <div class="class-img">
            <img src="img/<%= myImage %>" alt="내 시간표">
            <div class="class-date" style="margin-bottom:0;">
                등록일: <%= createdAt %>
            </div>
            <!-- 등록일 아래 바로! -->
            <div id="editBtnWrapper" style="margin-bottom:12px;">
                <button type="button" id="editBtn" class="editbtn" onclick="showEditForm();">수정</button>
            </div>
            <form id="editForm" class="hidden" action="class_schedule_edit" method="post" enctype="multipart/form-data" style="margin-top:0;">
                <input type="hidden" name="id" value="<%= imageId %>">
                <input type="file" name="image" accept="image/*" required>
                <button type="submit" class="editbtn">저장</button>
                <button type="button" class="editbtn" onclick="hideEditForm();">취소</button>
            </form>
        </div>
        <% } else if(user != null) { %>
        <div style="text-align:center;">등록된 시간표가 없습니다.</div>
        <% } else { %>
        <div style="text-align:center;">로그인 후 본인 시간표를 등록·확인할 수 있습니다.</div>
        <% } %>
    </div>
</main>
<script>
function showEditForm() {
    document.getElementById("editBtn").style.display = "none";
    document.getElementById("editForm").classList.remove("hidden");
}
function hideEditForm() {
    document.getElementById("editBtn").style.display = "";
    document.getElementById("editForm").classList.add("hidden");
}
</script>
</body>
</html>
