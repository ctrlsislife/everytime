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
    request.setCharacterEncoding("UTF-8");
    String idStr = request.getParameter("id");
    String pageParam = request.getParameter("page");
    String pageBack = (pageParam == null || pageParam.equals("")) ? "1" : pageParam;
    int id = 0;
    if (idStr == null) {
        out.println("<script>alert('잘못된 접근입니다.');location.href='offcampus_board.jsp?page="+pageBack+"';</script>");
        return;
    }
    try { id = Integer.parseInt(idStr); }
    catch(Exception e) {
        out.println("<script>alert('잘못된 접근입니다.');location.href='offcampus_board.jsp?page="+pageBack+"';</script>");
        return;
    }
    String title = "", content = "", writer = "", image = "", createdAt = "", updatedAt = "";
    Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
    List<Map<String, Object>> commentList = new ArrayList<>();
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
        String dbUsername = "root"; String dbPassword = "a1234";
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        // 게시글 정보
        String sql = "SELECT * FROM offcampus_board WHERE id=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        rs = pstmt.executeQuery();
        if(rs.next()) {
            title = rs.getString("title");
            content = rs.getString("content").replaceAll("\r\n|\r|\n", "<br>");
            writer = rs.getString("writer"); // 게시물 작성자
            image  = rs.getString("image");
            createdAt = rs.getTimestamp("created_at").toString();
            updatedAt = rs.getTimestamp("updated_at").toString();
        }
        rs.close();
        pstmt.close();

        String cSql = 
            "SELECT c.*, u.username, u.u_name, u.admin "
          + "FROM offcampus_comments c "
          + "JOIN user_index u ON c.user_id = u.id "
          + "WHERE c.board_id = ? "
          + "ORDER BY c.parent_comment_id ASC, c.created_at ASC";
        PreparedStatement cStmt = conn.prepareStatement(cSql);
        cStmt.setInt(1, id);
        ResultSet cRs = cStmt.executeQuery();
        while (cRs.next()) {
            Map<String, Object> cmt = new HashMap<>();
            cmt.put("comment_id", cRs.getInt("comment_id"));
            cmt.put("user_id", cRs.getInt("user_id"));
            cmt.put("parent_comment_id", cRs.getObject("parent_comment_id"));
            cmt.put("content", cRs.getString("content"));
            cmt.put("created_at", cRs.getTimestamp("created_at"));
            cmt.put("username", cRs.getString("username"));
            cmt.put("u_name", cRs.getString("u_name"));
            cmt.put("admin", cRs.getInt("admin"));
            commentList.add(cmt);
        }
        cRs.close();
        cStmt.close();
    } catch(Exception e) {
        out.println("<script>alert('DB 오류 발생');location.href='offcampus_board.jsp?page="+pageBack+"';</script>");
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
    <title>자취생 게시판 상세보기</title>
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
        main {width: 85%; float: left; padding: 20px; margin-top: 80px;
            min-height: calc(100vh - 100px); background: #f9f9f9; display: block;}
        .container {width:85%; max-width:860px; margin:0 auto; background:#fff; border-radius:8px; box-shadow:0 2px 5px rgba(0,0,0,.09); padding:44px 50px 50px 50px;}
        h1 {color:#f44336; border-bottom:2px solid #f44336; margin-bottom:24px; padding-bottom:10px;}
        .info {font-size:15px; color:#888; margin-bottom:21px;}
        .info span {margin-right:18px;}
        .detail-img-area {text-align:center; margin-bottom:30px;}
        .detail-img-area img {max-width:420px; max-height:420px; border-radius:12px; border:1px solid #eee; box-shadow:0 2px 10px rgba(0,0,0,.07);}
        .content {font-size:17px; color:#222; min-height:120px; margin-bottom:30px; word-break:break-all;}
        .button-box {text-align:right;}
        .button-box a {display:inline-block; background:#f44336; color:#fff; border-radius:4px; padding:9px 24px; text-decoration:none; font-weight:bold;}
        .button-box a:hover {background:#d73122;}
        .comment-section {max-width:720px; margin:35px auto 0 auto;}
        .comment-form textarea {width:100%; height:64px; resize:vertical; border:1px solid #aaa; border-radius:7px; margin-bottom:5px;}
        .comment-form button {margin-top:7px; background:#f44336; color:#fff; border:none; border-radius:5px; padding:6px 22px; font-weight:bold;}
        .comment {margin-bottom:13px; border-bottom:1px solid #eee; padding-bottom:8px; position:relative;}
        .comment-author {font-weight:bold; color:#444;}
        .comment-admin {color:#f44336; font-size:13px; margin-left:4px;}
        .comment-writer {color:#448cff; font-size:13px; margin-left:4px;}
        .comment-time {margin-left:12px;font-size:13px;color:#999;}
        .comment-content {margin:5px 0 4px 0;}
        .comment-reply {font-size:13px;background:#eee;border:none;border-radius:3px;padding:3px 10px;cursor:pointer; margin-left:7px;}
        .reply-form textarea {width:80%;height:36px;resize:vertical;margin-bottom:2px;border:1px solid #aaa;}
        .reply-form .subbtn {background:#f44336; color:#fff; border:none; border-radius:5px; padding:4px 18px; font-weight:bold;}
        .reply-form .cancbtn {background:#eee; border-radius:4px; padding:4px 15px; border:none; margin-left:8px;}
        .reply-list.depth2 {margin-left:34px;}
    </style>
</head>
<body>
    <!-- 상단바/네비 -->
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
            <h1><%= title %></h1>
            <div class="info">
                <span>작성자: <%= writer %></span>
                <span>작성일: <%= createdAt %></span>
            </div>
            <% if(image != null && !image.trim().isEmpty()) { %>
            <div class="detail-img-area">
                <img src="img/<%= image %>" alt="첨부 이미지">
            </div>
            <% } %>
            <div class="content"><%= content %></div>
            <div class="button-box">
                <a href="offcampus_board.jsp?page=<%= pageBack %>">목록으로</a>
            </div>
        </div>

        <!-- 댓글/대댓글 (2중 for문, 답글엔 답글버튼X, '작성자'는 글쓴이=댓글쓴이 일때만)-->
        <div class="comment-section">
            <% if (user != null) { %>
                <form action="offcampus_comment_process" method="post" class="comment-form">
                    <input type="hidden" name="board_id" value="<%= id %>">
                    <input type="hidden" name="parent_comment_id" value="">
                    <textarea name="content" maxlength="500" required placeholder="댓글을 입력하세요"></textarea><br>
                    <button type="submit">댓글 작성</button>
                </form>
            <% } %>
            <div class="reply-list">
<%
    List<Map<String, Object>> roots = new ArrayList<>();
    Map<Integer, List<Map<String, Object>>> childMap = new HashMap<>();
    for (Map<String,Object> cmt : commentList) {
        Integer parentId = (Integer)cmt.get("parent_comment_id");
        if(parentId == null) roots.add(cmt);
        else childMap.computeIfAbsent(parentId,(k)->new ArrayList<>()).add(cmt);
    }
    for(Map<String,Object> cmt : roots){ %>
        <div class="comment">
            <span class="comment-author"><%= cmt.get("u_name") %></span>
            <% if(writer != null && writer.equals(cmt.get("u_name"))) { %>
                <span class="comment-writer">(작성자)</span>
            <% } %>
            <% if(((int)cmt.get("admin"))==1) { %>
                <span class="comment-admin">[관리자]</span>
            <% } %>
            <span class="comment-time"><%= timeAgo((Timestamp)cmt.get("created_at")) %></span>
            <div class="comment-content"><%= cmt.get("content") %></div>
            <%
            // 루트댓글만 답글버튼/폼 노출
            if(user != null) { %>
                <button type="button" class="comment-reply" onclick="showReplyForm(<%= cmt.get("comment_id") %>);">답글</button>
                <form action="offcampus_comment_process" method="post" id="replyForm_<%= cmt.get("comment_id") %>" class="reply-form" style="display:none;">
                    <input type="hidden" name="board_id" value="<%= id %>">
                    <input type="hidden" name="parent_comment_id" value="<%= cmt.get("comment_id") %>">
                    <textarea name="content" maxlength="400" required placeholder="대댓글을 입력하세요"></textarea>
                    <button type="submit" class="subbtn">등록</button>
                    <button type="button" class="cancbtn" onclick="hideReplyForm(<%= cmt.get("comment_id") %>);">취소</button>
                </form>
            <% } %>
        </div>
        <%
        // 대댓글 출력(이제 답글버튼 없음)
        List<Map<String, Object>> replies = childMap.get((Integer)cmt.get("comment_id"));
        if(replies != null){
            for(Map<String,Object> rep : replies){ %>
                <div class="comment reply-list depth2">
                    <span class="comment-author"><%= rep.get("u_name") %></span>
                    <% if(writer != null && writer.equals(rep.get("u_name"))) { %>
                        <span class="comment-writer">(작성자)</span>
                    <% } %>
                    <% if(((int)rep.get("admin"))==1) { %>
                        <span class="comment-admin">[관리자]</span>
                    <% } %>
                    <span class="comment-time"><%= timeAgo((Timestamp)rep.get("created_at")) %></span>
                    <div class="comment-content"><%= rep.get("content") %></div>
                    <%-- 대댓글에는 답글버튼X --%>
                </div>
            <% }
        }
    } %>
            </div>
        </div>
        <script>
        function showReplyForm(id) {
            document.getElementById('replyForm_' + id).style.display = 'block';
        }
        function hideReplyForm(id) {
            document.getElementById('replyForm_' + id).style.display = 'none';
        }
        </script>
    </main>
</body>
</html>
