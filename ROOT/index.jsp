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
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판 포털</title>
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
            flex-wrap: wrap; /* 게시판을 행 3개씩 배치 */
            gap: 20px; /* 박스 사이 간격 */
        }
        section {
            background: white;
            flex: 1 1 calc(33.333% - 20px); /* 가로 폭의 33.333% 차지 */
            margin-bottom: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        section h2 {
            font-size: 20px;
            margin-bottom: 15px;
            color: #333;
            border-bottom: 2px solid #f44336;
            padding-bottom: 5px;
        }
        section ul {
            list-style: none;
        }
        section ul li {
            margin-bottom: 10px;
        }
        section ul li a {
            text-decoration: none;
            color: #f44336;
            font-size: 16px;
        }
        section ul li a:hover {
            text-decoration: underline;
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
        <!-- 공지사항 -->
        <section>
		    <h2>공지사항</h2>
		    <ul>
		    <%
		        Connection conn1 = null;
		        PreparedStatement pstmt1 = null;
		        ResultSet rs1 = null;
		        try {
		            Class.forName("org.mariadb.jdbc.Driver");
		            String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
		            String dbUsername = "root";
		            String dbPassword = "a1234";
		            conn1 = DriverManager.getConnection(url, dbUsername, dbPassword);
		
		            String sql = "SELECT id, title FROM announcements ORDER BY id DESC LIMIT 3";
		            pstmt1 = conn1.prepareStatement(sql);
		            rs1 = pstmt1.executeQuery();
		
		            while (rs1.next()) {
		                int annId = rs1.getInt("id");
		                String title = rs1.getString("title");
		    %>
		        <li>
		            <a href="announcement_detail.jsp?id=<%= annId %>"><%= title %></a>
		        </li>
		    <%
		            }
		        } catch (Exception e) {
		            out.println("<li>공지사항을 불러오지 못했습니다.</li>");
		        } finally {
		            if (rs1 != null) try { rs1.close(); } catch (Exception e) {}
		            if (pstmt1 != null) try { pstmt1.close(); } catch (Exception e) {}
		            if (conn1 != null) try { conn1.close(); } catch (Exception e) {}
		        }
		    %>
		    </ul>
		    <div style="margin-top:8px; text-align:right;">
		        <a href="announcement.jsp" style="color:#f44336;font-size:15px;text-decoration:none;font-weight:bold;">
		            더보기 &nbsp;&gt;
		        </a>
		    </div>
		</section>


        <!-- 자유 게시판 -->
        <section>
            <h2>자유 게시판</h2>
            <ul>
            <%
                Connection conn2 = null;
                PreparedStatement pstmt2 = null;
                ResultSet rs2 = null;
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
                    String dbUsername = "root";
                    String dbPassword = "a1234";
                    conn2 = DriverManager.getConnection(url, dbUsername, dbPassword);

                    String sql = "SELECT id, title FROM free_board ORDER BY id DESC LIMIT 3";
                    pstmt2 = conn2.prepareStatement(sql);
                    rs2 = pstmt2.executeQuery();

                    while (rs2.next()) {
		                int freeId = rs2.getInt("id");
		                String title = rs2.getString("title");
            %>
              <li>
		            <a href="free_detail.jsp?id=<%= freeId %>"><%= title %></a>
		        </li>
		    <%
		            }
		        } catch (Exception e) {
		            out.println("<li>자유 게시판을 불러오지 못했습니다.</li>");
		        } finally {
		            if (rs2 != null) try { rs2.close(); } catch (Exception e) {}
		            if (pstmt2 != null) try { pstmt2.close(); } catch (Exception e) {}
		            if (conn2 != null) try { conn2.close(); } catch (Exception e) {}
		        }
		    %>
		    </ul>
		    <div style="margin-top:8px; text-align:right;">
		        <a href="free_board.jsp" style="color:#f44336;font-size:15px;text-decoration:none;font-weight:bold;">
		            더보기 &nbsp;&gt;
		        </a>
		    </div>
		</section>

        <!-- 기숙사 게시판 -->
        <section>
            <h2>기숙사 게시판</h2>
            <ul>
            <%
                Connection conn3 = null;
                PreparedStatement pstmt3 = null;
                ResultSet rs3 = null;
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
                    String dbUsername = "root";
                    String dbPassword = "a1234";
                    conn3 = DriverManager.getConnection(url, dbUsername, dbPassword);

                    String sql = "SELECT id, title FROM dormitory_board ORDER BY id DESC LIMIT 3";
                    pstmt3 = conn3.prepareStatement(sql);
                    rs3 = pstmt3.executeQuery();

                    while (rs3.next()) {
		                int dormId = rs3.getInt("id");
		                String title = rs3.getString("title");
            %>
              <li>
		            <a href="dormitory_detail.jsp?id=<%= dormId %>"><%= title %></a>
		        </li>
		    <%
		            }
		        } catch (Exception e) {
		            out.println("<li>기숙사 게시판을 불러오지 못했습니다.</li>");
		        } finally {
		            if (rs3 != null) try { rs3.close(); } catch (Exception e) {}
		            if (pstmt3 != null) try { pstmt3.close(); } catch (Exception e) {}
		            if (conn3 != null) try { conn3.close(); } catch (Exception e) {}
		        }
		    %>
		    </ul>
		    <div style="margin-top:8px; text-align:right;">
		        <a href="dormitory_board.jsp" style="color:#f44336;font-size:15px;text-decoration:none;font-weight:bold;">
		            더보기 &nbsp;&gt;
		        </a>
		    </div>
		</section>

        <!-- 자취생 게시판 -->
        <section>
            <h2>자취생 게시판</h2>
            <ul>
            <%
                Connection conn4 = null;
                PreparedStatement pstmt4 = null;
                ResultSet rs4 = null;
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
                    String dbUsername = "root";
                    String dbPassword = "a1234";
                    conn4 = DriverManager.getConnection(url, dbUsername, dbPassword);

                    String sql = "SELECT id, title FROM offcampus_board ORDER BY id DESC LIMIT 3";
                    pstmt4 = conn4.prepareStatement(sql);
                    rs4 = pstmt4.executeQuery();

                    while (rs4.next()) {
		                int offId = rs4.getInt("id");
		                String title = rs4.getString("title");
            %>
              <li>
		            <a href="offcampus_detail.jsp?id=<%= offId %>"><%= title %></a>
		        </li>
		    <%
		            }
		        } catch (Exception e) {
		            out.println("<li>자취생 게시판을 불러오지 못했습니다.</li>");
		        } finally {
		            if (rs4 != null) try { rs4.close(); } catch (Exception e) {}
		            if (pstmt4 != null) try { pstmt4.close(); } catch (Exception e) {}
		            if (conn4 != null) try { conn4.close(); } catch (Exception e) {}
		        }
		    %>
		    </ul>
		    <div style="margin-top:8px; text-align:right;">
		        <a href="offcampus_board.jsp" style="color:#f44336;font-size:15px;text-decoration:none;font-weight:bold;">
		            더보기 &nbsp;&gt;
		        </a>
		    </div>
		</section>

        <!-- 토론 게시판 -->
        <section>
            <h2>토론 게시판</h2>
            <ul>
            <%
                Connection conn5 = null;
                PreparedStatement pstmt5 = null;
                ResultSet rs5 = null;
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
                    String dbUsername = "root";
                    String dbPassword = "a1234";
                    conn5 = DriverManager.getConnection(url, dbUsername, dbPassword);

                    String sql = "SELECT title FROM debate_board ORDER BY id DESC LIMIT 3";
                    pstmt5 = conn5.prepareStatement(sql);
                    rs5 = pstmt5.executeQuery();

                    while (rs5.next()) {
                        String title = rs5.getString("title");
            %>
                        <li><a href="#"> <%= title %> </a></li>
            <%
                    }
                } catch (Exception e) {
                    out.println("<li>준비중입니다.</li>");
                } finally {
                    if (rs5 != null) try { rs5.close(); } catch (Exception e) {}
                    if (pstmt5 != null) try { pstmt5.close(); } catch (Exception e) {}
                    if (conn5 != null) try { conn5.close(); } catch (Exception e) {}
                }
            %>
            </ul>
        </section>

        <!-- 게시판 요청 -->
        <section>
            <h2>게시판 요청</h2>
            <ul>
            <%
                Connection conn6 = null;
                PreparedStatement pstmt6 = null;
                ResultSet rs6 = null;
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
                    String dbUsername = "root";
                    String dbPassword = "a1234";
                    conn6 = DriverManager.getConnection(url, dbUsername, dbPassword);

                    String sql = "SELECT id, title FROM request_board ORDER BY id DESC LIMIT 3";
                    pstmt6 = conn6.prepareStatement(sql);
                    rs6 = pstmt6.executeQuery();

                    while (rs6.next()) {
		                int offId = rs6.getInt("id");
		                String title = rs6.getString("title");
            %>
              <li>
		            <a href="request_detail.jsp?id=<%= offId %>"><%= title %></a>
		        </li>
		    <%
		            }
		        } catch (Exception e) {
		            out.println("<li>게시판 요청을 불러오지 못했습니다.</li>");
		        } finally {
		            if (rs6 != null) try { rs6.close(); } catch (Exception e) {}
		            if (pstmt6 != null) try { pstmt6.close(); } catch (Exception e) {}
		            if (conn6 != null) try { conn6.close(); } catch (Exception e) {}
		        }
		    %>
		    </ul>
		    <div style="margin-top:8px; text-align:right;">
		        <a href="request_board.jsp" style="color:#f44336;font-size:15px;text-decoration:none;font-weight:bold;">
		            더보기 &nbsp;&gt;
		        </a>
		    </div>
		</section>
    </main>
</body>
</html>