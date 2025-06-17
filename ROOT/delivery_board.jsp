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
    int currentPage = 1, recordsPerPage = 10;
    if(request.getParameter("page") != null){
        currentPage = Integer.parseInt(request.getParameter("page"));
    }
    int totalRecords = 0, totalPages = 0;
    Connection conn = null; PreparedStatement pstmt = null, countStmt = null;
    ResultSet rs = null, countRs = null;
    List<Map<String, Object>> boardList = new ArrayList<>();
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
        String dbUsername = "root", dbPassword = "a1234";
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        String countSql = "SELECT COUNT(*) FROM delivery_board";
        countStmt = conn.prepareStatement(countSql);
        countRs = countStmt.executeQuery();
        if(countRs.next()) totalRecords = countRs.getInt(1);
        totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
        int start = (currentPage - 1) * recordsPerPage;
        String sql = "SELECT b.*, u.u_name FROM delivery_board b JOIN user_index u ON b.user_id = u.id ORDER BY b.id DESC LIMIT ?, ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, start);
        pstmt.setInt(2, recordsPerPage);
        rs = pstmt.executeQuery();
        while(rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", rs.getInt("id"));
            row.put("user_id", rs.getInt("user_id"));
            row.put("title", rs.getString("title"));
            row.put("u_name", rs.getString("u_name"));
            row.put("is_complete", rs.getInt("is_complete"));
            row.put("created_at", rs.getTimestamp("created_at"));
            boardList.add(row);
        }
    } catch(Exception e) { out.println("<li>불러오기 오류: "+e.getMessage()+"</li>"); }
    finally {
        try { if(countRs!=null) countRs.close(); }catch(Exception e){}
        try { if(countStmt!=null) countStmt.close(); }catch(Exception e){}
        try { if(rs!=null) rs.close(); }catch(Exception e){}
        try { if(pstmt!=null) pstmt.close(); }catch(Exception e){}
        try { if(conn!=null) conn.close(); }catch(Exception e){}
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>배달 게시판</title>
    <style>
        * {margin:0; padding:0; box-sizing:border-box;}
        body {font-family: Arial,sans-serif; background:#f9f9f9;}
        .top-bar {position:fixed; top:0; left:0; width:100%; z-index:1000; background:#f44336; color:white; padding:10px 20px; display:flex; justify-content:space-between; align-items:center; box-shadow:0 2px 5px rgba(0,0,0,.2);}
        .top-bar .title img {height:60px; width:auto;}
        .nav-links a {color:white; text-decoration:none; margin-left:15px; font-size:16px;}
        .nav-links a:hover {text-decoration:underline;}
        nav {width:15%; float:left; background-color:#f4f4f4; padding:15px; height:90vh; margin-top:80px;}
        nav h3 {font-size:18px; margin-bottom:10px;}
        nav ul {list-style:none; padding:0;}
        nav ul li {margin-bottom:10px;}
        nav ul li a {font-size:14px; color:#333; text-decoration:none;}
        nav ul li a:hover {color:#f44336; text-decoration:underline;}
        main {width:85%; float:left; padding:24px; margin-top:80px;}
        .container {max-width:900px; margin:0 auto; background:#fff; border-radius:8px; box-shadow:0 2px 5px rgba(0,0,0,.09); padding:40px 30px 32px 30px;}
        h1 {color:#f44336; border-bottom:2px solid #f44336; margin-bottom:34px; padding-bottom:10px; text-align:center; position:relative;}
        .write-btn {
            font-size:15px; background:#f44336; color:#fff; border-radius:50px; 
            padding:10px 32px; text-decoration:none; font-weight:bold; 
            position:absolute; right:10px; top:10px; 
        }
        .write-btn:hover {background:#d73122;}
        table {width:100%; border-collapse:collapse; margin-top:20px;}
        th,td {text-align:center; border-bottom:1px solid #eee; padding:14px 0;}
        th {background:#faf5f5; color:#f44336;}
        .board-title {text-align:center;}
        .board-title a {color:#f44336; font-size:16px; text-decoration:none; font-weight:600;}
        .board-title a:hover {text-decoration:underline;}
        .writer {color:#444; font-size:15px;}
        .stat-done {color:#f44336; font-size:15px; font-weight:700;}
        .pagination {margin-top:30px; text-align:center;}
        .pagination a, .pagination span {color:#f44336; display:inline-block; padding:5px 10px; margin:0 2px; font-weight:bold;}
        .pagination .current {background:#f44336; color:#fff; border-radius:5px;}
        .pagination .arrow {font-size:15px; font-weight:100;}
    </style>
</head>
<body>
    <header class="top-bar">
        <div class="title">
            <a href="main.jsp"><img src="img/logo.png" alt="SCNU 로고"></a>
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
            <h1>
                배달 모집 게시판
                <% if(user != null){ %>
                    <a href="delivery_write.jsp" class="write-btn">글쓰기</a>
                <% } %>
            </h1>
            <table>
                <thead>
                    <tr>
                        <th style="width:60px;">번호</th>
                        <th>제목</th>
                        <th>모집자</th>
                        <th style="width:140px;">작성일시</th>
                        <th style="width:90px;">상태</th>
                    </tr>
                </thead>
                <tbody>
<%
    int rowNumber = 1 + (currentPage-1)*recordsPerPage;
    for(Map<String,Object> row: boardList){
%>
                    <tr>
                        <td><%= rowNumber++ %></td>
                        <td class="board-title">
                            <a href="delivery_detail.jsp?id=<%= row.get("id") %>"><%= row.get("title") %></a>
                        </td>
                        <td class="writer"><%= row.get("u_name") %></td>
                        <td><%= timeAgo((java.sql.Timestamp)row.get("created_at")) %></td>
                        <td>
                            <% if(((int)row.get("is_complete"))==1){ %>
                               <span class="stat-done">완료</span>
                            <% } else { %>
                               모집중
                            <% } %>
                        </td>
                    </tr>
<% } %>
<% if (boardList.size() == 0) { %>
                    <tr>
                        <td colspan="5" style="text-align:center;">등록된 배달 글이 없습니다.</td>
                    </tr>
<% } %>
                </tbody>
            </table>
            <div class="pagination">
                <% if(currentPage > 1){ %>
                    <a class="arrow" href="delivery_board.jsp?page=<%= currentPage-1 %>">&laquo;</a>
                <% } else { %>
                    <span class="arrow" style="color:#ccc;">&laquo;</span>
                <% } %>
                <% for(int i=1;i<=totalPages;i++) { 
                        if(i == currentPage) { %>
                    <span class="current"><%=i%></span>
                <%  } else { %>
                    <a href="delivery_board.jsp?page=<%=i%>"><%=i%></a>
                <% }} %>
                <% if(currentPage < totalPages){ %>
                    <a class="arrow" href="delivery_board.jsp?page=<%= currentPage+1 %>">&raquo;</a>
                <% } else { %>
                    <span class="arrow" style="color:#ccc;">&raquo;</span>
                <% } %>
            </div>
        </div>
    </main>
</body>
</html>
