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
    int boardId = 0, writerId = 0, isComplete = 0;
    String title="", content="", postImg="", orderImg="", completeImg="", writerName="", createdAt="", feeShare="Y", together="Y", errMsg=null;
    List<Integer> participantIds = new ArrayList<>();
    String userPaidImg = null;
    List<Map<String,Object>> commentList = new ArrayList<>();
    List<Map<String,String>> participantList = new ArrayList<>();
    try {
        boardId = Integer.parseInt(request.getParameter("id"));
        Class.forName("org.mariadb.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:7778/Sw_Engineering", "root", "a1234");

        PreparedStatement pstmt = conn.prepareStatement("SELECT b.*, u.u_name FROM delivery_board b JOIN user_index u ON b.user_id=u.id WHERE b.id=?");
        pstmt.setInt(1, boardId);
        ResultSet rs = pstmt.executeQuery();
        if(rs.next()){
            writerId = rs.getInt("user_id");
            title = rs.getString("title");
            content = rs.getString("content").replaceAll("\r\n|\r|\n", "<br>");
            feeShare = rs.getString("delivery_fee_share");
            together = rs.getString("together");
            postImg = rs.getString("image_post");
            orderImg = rs.getString("image_order");
            completeImg = rs.getString("image_complete");
            writerName = rs.getString("u_name");
            createdAt = rs.getString("created_at");
            isComplete = rs.getInt("is_complete");
        }
        rs.close(); pstmt.close();
        // (1) 참여자 목록
        pstmt = conn.prepareStatement(
            "SELECT u.u_name, p.joined_at, p.image_paid, p.user_id FROM delivery_participants p JOIN user_index u ON p.user_id=u.id WHERE p.board_id=?");
        pstmt.setInt(1, boardId);
        rs = pstmt.executeQuery();
        while(rs.next()){
            Map<String,String> part = new HashMap<>();
            part.put("u_name", rs.getString("u_name"));
            part.put("joined_at", rs.getString("joined_at"));
            part.put("image_paid", rs.getString("image_paid"));
            participantList.add(part);
            int pid = rs.getInt("user_id");
            participantIds.add(pid);
            if(user!=null && user.getUserId()==pid)
                userPaidImg = rs.getString("image_paid");
        }
        rs.close(); pstmt.close();
        // (2) 댓글/대댓글
        pstmt = conn.prepareStatement(
            "SELECT c.*, u.username, u.u_name, u.admin FROM delivery_comments c JOIN user_index u ON c.user_id = u.id WHERE c.board_id = ? ORDER BY c.parent_comment_id ASC, c.created_at ASC"
        );
        pstmt.setInt(1, boardId);
        rs = pstmt.executeQuery();
        while(rs.next()){
            Map<String,Object> cmt = new HashMap<>();
            cmt.put("comment_id", rs.getInt("comment_id"));
            cmt.put("parent_comment_id", rs.getObject("parent_comment_id"));
            cmt.put("content", rs.getString("content"));
            cmt.put("user_id", rs.getInt("user_id"));
            cmt.put("u_name", rs.getString("u_name"));
            cmt.put("admin", rs.getInt("admin"));
            cmt.put("created_at", rs.getTimestamp("created_at"));
            commentList.add(cmt);
        }
        rs.close(); pstmt.close(); conn.close();
    } catch(Exception e){errMsg="DB 오류: "+e.getMessage();}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>배달 게시판 상세</title>
    <style>
        * {margin:0;padding:0;box-sizing:border-box;}
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
        main {width:85%; float:left; padding:44px 0 0 0; margin-top:80px;}
        .container {max-width:900px; margin:0 auto; background:#fff; border-radius:8px; box-shadow:0 2px 5px rgba(0,0,0,.09); padding:42px 50px 40px 50px;}
        h1 {color:#f44336; border-bottom:2px solid #f44336; margin-bottom:16px; padding-bottom:10px;}
        .info {font-size:15px; color:#888; margin-bottom:8px;}
        .badge  {font-size:15px; padding:2px 12px; border-radius:13px; color:#fff; background:#f44336; margin-right:10px;}
        .badge.b {background:#4A99E9;} .badge.g {background:#58B36C;}
        .img-area {text-align:center; margin:18px 0 25px 0;}
        .img-area img {width:50vw; max-width:620px; height:auto; border-radius:13px; border:1px solid #eee; margin-bottom:2px;}
        .content {font-size:17px; color:#222; min-height:80px; margin-bottom:18px; word-break:break-all;}
        .btns-line {margin:18px 0 5px 0; text-align:center;}
        .btns-line button, .btns-line form button {
            display:inline-block; background:#f44336; color:#fff; border-radius:50px;
            border:none; font-size:16px; font-weight:bold; padding:10px 32px; margin:0 7px; text-decoration:none; cursor:pointer; transition:background .13s; box-shadow:0 2px 8px rgba(244,67,54,.09);
        }
        .btns-line button:hover {background:#d43228;}
        .detail-date {font-size:14px; color:#aaa; text-align:left; margin-bottom:4px;}
        .paid-img {margin:24px auto 24px auto; text-align:center;}
        .paid-img img{width:36vw; max-width:340px; border-radius:12px; border:1px solid #ccc;}
        .notice-done {color:#f44336; font-weight:bold; text-align:center; margin-top:18px;}
        .comment-section {max-width:660px; margin:35px auto 0 auto;}
        .comment-form textarea {width:100%; height:64px; resize:vertical; border:1px solid #aaa; border-radius:7px; margin-bottom:5px;}
        .comment-form button {margin-top:7px; background:#f44336; color:#fff; border:none; border-radius:50px; padding:6px 22px; font-weight:bold;}
        .comment {margin-bottom:13px; border-bottom:1px solid #eee; padding-bottom:8px; position:relative;}
        .comment-author {font-weight:bold; color:#444;}
        .comment-admin {color:#f44336; font-size:13px; margin-left:4px;}
        .comment-writer {color:#448cff; font-size:13px; margin-left:4px;}
        .comment-time {margin-left:12px;font-size:13px;color:#999;}
        .comment-content {margin:6px 0 4px 0;}
        .comment-reply {font-size:13px;background:#eee;border:none;border-radius:3px;padding:3px 10px;cursor:pointer; margin-left:7px;}
        .reply-form textarea {width:80%;height:36px;resize:vertical;margin-bottom:2px;border:1px solid #aaa;}
        .reply-form button {margin:2px 2px;}
        .reply-list.depth2 {margin-left:34px;}
        .participants-area {margin:38px 0 24px 0; background:#f8eded; border-radius:8px; padding:16px 25px; box-shadow:0 2px 5px rgba(244,67,54,.06);}
        .participants-area table {width:100%; margin-top:8px;}
        .participants-area th, .participants-area td {text-align:left; font-size:15px; padding:6px 4px;}
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
    <% if(errMsg != null) { %>
        <div style="color:red;font-weight:bold;text-align:center;margin-top:24px;"><%= errMsg %></div>
    <% } %>
    <h1><%= title %></h1>
    <div class="info">
        모집자: <%= writerName %> &nbsp;&nbsp; <span class="detail-date">작성일: <%= createdAt %></span>
    </div>
    <div>
        <% if("Y".equals(feeShare)) { %> <span class="badge b">배달비 1/n</span> <% } %>
        <% if("Y".equals(together)) { %> <span class="badge g">함께 먹어요</span> <% } %>
        <% if(isComplete==1){ %><span class="badge">배달 완료</span><% } %>
    </div>
    <% if(postImg!=null && !postImg.trim().isEmpty()) { %>
    <div class="img-area"><img src="img/<%= postImg %>" alt="게시글 사진"></div>
    <% } %>
    <div class="content"><%= content %></div>
    <% if(orderImg!=null && !orderImg.trim().isEmpty()) { %>
    <div class="img-area"><b>배달 내역</b><br><img src="img/<%= orderImg %>" alt="배달 내역 사진"></div>
    <% } %>

    <% if(user != null && user.getUserId()==writerId && !participantList.isEmpty()) { %>
        <div class="participants-area">
            <h3 style="color:#f44336; margin-bottom:12px; font-size:18px;">참여자 목록</h3>
            <table>
                <thead>
                    <tr>
                        <th>이름</th>
                        <th>입금완료</th>
                        <th>참여시각</th>
                    </tr>
                </thead>
                <tbody>
                <% for(Map<String,String> part : participantList){ %>
                    <tr>
                        <td><%= part.get("u_name") %></td>
                        <td>
                            <% if(part.get("image_paid")!=null && !part.get("image_paid").isEmpty()){ %>
                                <span style="color:#33b046; font-weight:bold;">O</span>
                            <% } else { %>
                                <span style="color:#aaa;">X</span>
                            <% } %>
                        </td>
                        <td><%= part.get("joined_at") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    <% } %>

    <div class="btns-line">
        <% if(user != null && user.getUserId()!=writerId && !participantIds.contains(user.getUserId())) { %>
            <form action="delivery_participate" method="post" style="display:inline-block;">
                <input type="hidden" name="id" value="<%= boardId %>">
                <button type="submit">참여하기</button>
            </form>
        <% } %>
    </div>
    <% if(user!=null && user.getUserId() == writerId && isComplete==0) { %>
        <form action="delivery_complete_upload" method="post" enctype="multipart/form-data" style="text-align:center; margin:30px auto;">
            <input type="hidden" name="board_id" value="<%= boardId %>">
            <input type="file" name="complete_img" accept="image/*" required>
            <button type="submit" class="badge" style="font-size:17px;">배달 완료 사진 업로드</button>
        </form>
    <% } %>
    <% if(isComplete==1 && completeImg!=null && !completeImg.isEmpty()) { %>
    <div class="paid-img">
        <b>배달 완료 사진</b><br>
        <img src="img/<%= completeImg %>">
    </div>
    <div class="notice-done">✔️ 배달이 완료되었습니다.</div>
    <% } %>

    <div class="comment-section">
        <% if (user != null) { %>
            <form action="delivery_comment_process" method="post" class="comment-form">
                <input type="hidden" name="board_id" value="<%= boardId %>">
                <input type="hidden" name="parent_comment_id" value="">
                <textarea name="content" maxlength="400" required placeholder="댓글을 입력하세요"></textarea>
                <button type="submit">댓글 작성</button>
            </form>
        <% } %>
        <div class="reply-list">
        <%
        List<Map<String, Object>> roots = new ArrayList<>();
        Map<Integer, List<Map<String, Object>>> childMap = new HashMap<>();
        for(Map<String, Object> cmt : commentList){
            Integer parent = (Integer)cmt.get("parent_comment_id");
            if(parent == null) roots.add(cmt);
            else childMap.computeIfAbsent(parent,k->new ArrayList<>()).add(cmt);
        }
        for(Map<String,Object> cmt: roots){ %>
            <div class="comment">
                <span class="comment-author"><%= cmt.get("u_name") %></span>
                <% if(writerName != null && writerName.equals(cmt.get("u_name"))) { %>
                    <span class="comment-writer">(작성자)</span>
                <% } %>
                <% if(((int)cmt.get("admin"))==1) { %>
                    <span class="comment-admin">[관리자]</span>
                <% } %>
                <span class="comment-time"><%= timeAgo((Timestamp)cmt.get("created_at")) %></span>
                <div class="comment-content"><%= cmt.get("content") %></div>
                <% if(user != null) { %>
                    <button type="button" class="comment-reply" onclick="showReplyForm(<%= cmt.get("comment_id") %>);">답글</button>
                    <form action="delivery_comment_process" method="post" id="replyForm_<%= cmt.get("comment_id") %>" class="reply-form" style="display:none;">
                        <input type="hidden" name="board_id" value="<%= boardId %>">
                        <input type="hidden" name="parent_comment_id" value="<%= cmt.get("comment_id") %>">
                        <textarea name="content" maxlength="400" required placeholder="대댓글을 입력하세요"></textarea>
                        <button type="submit">등록</button>
                        <button type="button" class="cancbtn" onclick="hideReplyForm(<%= cmt.get("comment_id") %>);">취소</button>
                    </form>
                <% } %>
            </div>
            <% List<Map<String,Object>> replies = childMap.get((Integer)cmt.get("comment_id"));
               if(replies != null){
                   for(Map<String,Object> rep : replies){ %>
                <div class="comment reply-list depth2" style="margin-left:34px;">
                    <span class="comment-author"><%= rep.get("u_name") %></span>
                    <% if(writerName != null && writerName.equals(rep.get("u_name"))) { %>
                        <span class="comment-writer">(작성자)</span>
                    <% } %>
                    <% if(((int)rep.get("admin"))==1) { %>
                        <span class="comment-admin">[관리자]</span>
                    <% } %>
                    <span class="comment-time"><%= timeAgo((Timestamp)rep.get("created_at")) %></span>
                    <div class="comment-content"><%= rep.get("content") %></div>
                </div>
            <% }
         }
        }
        %>
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
    <div style="text-align:right; margin-top:23px;">
        <a href="delivery_board.jsp" style="color:#f44336;font-size:15px;text-decoration:none;font-weight:bold;">목록으로</a>
    </div>
</div>
</main>
</body>
</html>
