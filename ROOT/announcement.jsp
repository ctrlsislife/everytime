<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.InformationDTO" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
<%! 
    // 작성일시를 '방금 전', 'n분 전', 'n시간 전', 'n일 전'으로 표시하는 함수
    public String timeAgo(java.sql.Timestamp time) {
        long diffMillis = System.currentTimeMillis() - time.getTime();
        long min = diffMillis / 60000;
        if (min < 1) return "방금 전";
        if (min < 60) return min + "분 전";
        long hour = min / 60;
        if (hour < 24) return hour + "시간 전";
        long day = hour / 24;
        return day + "일 전";
    }
%>
<%
    InformationDTO user = (InformationDTO) session.getAttribute("user");

    request.setCharacterEncoding("UTF-8");
    int currentPage = 1;
    int recordsPerPage = 10;
    if(request.getParameter("page") != null){
        currentPage = Integer.parseInt(request.getParameter("page"));
    }

    int totalRecords = 0;
    int totalPages = 0;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    PreparedStatement countStmt = null;
    ResultSet countRs = null;

    List<Map<String, Object>> announcementList = new ArrayList<>();

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
        String dbUsername = "root";
        String dbPassword = "a1234";
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);

        // 전체 공지 수 구하기
        String countSql = "SELECT COUNT(*) FROM announcements";
        countStmt = conn.prepareStatement(countSql);
        countRs = countStmt.executeQuery();
        if(countRs.next()) {
            totalRecords = countRs.getInt(1);
        }

        totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);

        int start = (currentPage - 1) * recordsPerPage;

        String sql = "SELECT id, title, created_at FROM announcements ORDER BY id DESC LIMIT ?, ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, start);
        pstmt.setInt(2, recordsPerPage);

        rs = pstmt.executeQuery();

        while(rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", rs.getInt("id"));
            row.put("title", rs.getString("title"));
            row.put("created_at", rs.getTimestamp("created_at"));
            announcementList.add(row);
        }

    } catch(Exception e) {
        out.println("<li>공지사항을 불러오지 못했습니다. (" + e.getMessage() + ")</li>");
    } finally {
        try { if (countRs != null) countRs.close(); } catch(Exception e) {}
        try { if (countStmt != null) countStmt.close(); } catch(Exception e) {}
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch(Exception e) {}
        try { if (conn != null) conn.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항</title>
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
        section.notice-section {
            background: white; border: 1px solid #ddd; border-radius: 5px;
            padding: 25px 20px 35px 20px; margin-bottom: 30px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.09); width: 95%;
        }
        section h2 {font-size: 24px; margin-bottom: 18px; color: #f44336;
            border-bottom: 2px solid #f44336; padding-bottom: 10px;}
        .notice-section h2 {
            display: flex; justify-content: space-between; align-items: center;
        }
        .write-btn {
            font-size: 15px; background: #f44336; color: #fff; border-radius: 5px;
            padding: 6px 15px; text-decoration: none; margin-left: 15px;
        }
        .write-btn:hover {
            background: #d73122;
        }
        table.notice-table {
            width: 100%; border-collapse: collapse; margin-top: 5px;
        }
        table.notice-table th, table.notice-table td {
            text-align: center; border-bottom: 1px solid #eee; padding: 12px 0;
        }
        table.notice-table th {background-color: #faf5f5; color: #f44336;}
        table.notice-table td a {
            color: #f44336; text-decoration: none; font-size: 16px;
        }
        table.notice-table td a:hover {text-decoration: underline;}
        .pagination {
            margin-top: 25px; text-align: center;
        }
        .pagination a, .pagination span {
            color: #f44336; display: inline-block; padding: 5px 10px;
            margin: 0 3px; font-weight: bold; font-size: 17px;
        }
        .pagination .current {
            background: #f44336; color: #fff; border-radius: 5px;
        }
        .pagination .arrow {font-size: 15px; font-weight: 100;}
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
        <section class="notice-section">
            <h2>
                공지사항
                <% if(user != null && user.isAdmin()) { %>
                    <a href="announcement_write.jsp" class="write-btn">공지사항 쓰기</a>
                <% } %>
            </h2>
            <table class="notice-table">
                <thead>
                    <tr>
                        <th>번호</th>
                        <th>제목</th>
                        <th>작성일시</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        int rowNumber = 1 + (currentPage-1)*recordsPerPage;
                        for(Map<String,Object> row: announcementList){
                    %>
                    <tr>
                        <td><%= rowNumber++ %></td>
                        <td>
                            <a href="announcement_detail.jsp?id=<%= row.get("id") %>&page=<%= currentPage %>">
                                <%= row.get("title") %>
                            </a>
                        </td>
                        <td>
                            <%= timeAgo((java.sql.Timestamp)row.get("created_at")) %>
                        </td>
                    </tr>
                    <% } %>
                    <% if (announcementList.size() == 0) { %>
                    <tr>
                        <td colspan="3" style="text-align:center;">등록된 공지사항이 없습니다.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <!-- 페이지네이션 -->
            <div class="pagination">
                <% if(currentPage > 1){ %>
                    <a class="arrow" href="announcement.jsp?page=<%= currentPage-1 %>">&laquo;</a>
                <% } else { %>
                    <span class="arrow" style="color:#ccc;">&laquo;</span>
                <% } %>
                <% for(int i=1;i<=totalPages;i++) { 
                        if(i == currentPage) { %>
                    <span class="current"><%=i%></span>
                <%  } else { %>
                    <a href="announcement.jsp?page=<%=i%>"><%=i%></a>
                <% }} %>
                <% if(currentPage < totalPages){ %>
                    <a class="arrow" href="announcement.jsp?page=<%= currentPage+1 %>">&raquo;</a>
                <% } else { %>
                    <span class="arrow" style="color:#ccc;">&raquo;</span>
                <% } %>
            </div>
        </section>
    </main>
</body>
</html>
