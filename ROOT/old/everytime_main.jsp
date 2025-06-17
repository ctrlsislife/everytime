<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List" %>
<%@ page import="model.InformationDTO" %>
<%@ page import="model.BoardDTO" %>
<%
    // 세션에서 사용자 정보 가져오기
    InformationDTO user = (InformationDTO) session.getAttribute("user");

    // 각 게시판 리스트 가져오기
    List<BoardDTO> boardList1 = (List<BoardDTO>) request.getAttribute("boardList1");
    List<BoardDTO> boardList2 = (List<BoardDTO>) request.getAttribute("boardList2");
    List<BoardDTO> boardList3 = (List<BoardDTO>) request.getAttribute("boardList3");
    List<BoardDTO> boardList4 = (List<BoardDTO>) request.getAttribute("boardList4");

    // 게시글이 없으면 빈 리스트 초기화
    if (boardList1 == null) boardList1 = new ArrayList<>();
    if (boardList2 == null) boardList2 = new ArrayList<>();
    if (boardList3 == null) boardList3 = new ArrayList<>();
    if (boardList4 == null) boardList4 = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>대학생 커뮤니티</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        .background {
            position: fixed;
            top: 0;
            left: 0;
            margin-top: 70px;
            width: 100%;
            height: 100%;
            background-image: url('/team8_main/img/background1.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            opacity: 0.8;
            z-index: -1; /* 다른 요소 뒤로 배치 */
        }
        .top-bar {
            z-index: 1;
            background-color: rgba(255, 255, 255, 0.9);
            max-width: 100%; /* 최대 너비 제한 */
            width: 100%; /* 패딩을 제외한 너비 */
            height: 70px; /* 자동 높이 */
            margin: auto; /* 화면 중앙 정렬 */
            overflow: hidden; /* 스크롤 숨김 */
            margin-bottom: 100px;
            position: fixed;
            top: 0;
            left: 0;
        }
        .title {
            position: absolute;
            top: 20px;
            left: 20px;
            font-size: 2em;
            color: #333;
        }
        .title a {
            color: #333;
            text-decoration: none;
            margin-left: 10px;
        }
        .nav-links {
            position: absolute;
            top: 10px;
            right: 20px;
            font-size: 1em;
            color: #333;
        }
        .nav-links a {
            color: #333;
            text-decoration: none;
            margin-left: 10px;
        }
        .search-container {
            text-align: center;
            background-color: #FDF8F4;
            opacity: 0.8;
            padding: 50px;
            border-radius: 10px;
            width: 80%;
            max-width: 1100px;
            height: auto;
            box-sizing: border-box;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            min-width: 500px;
        }
        .board-header {
            font-size: 2em;
            color: black;
            margin-bottom: 20px;
        }

        /* 게시판 컨테이너 스타일 */
        .board-container {
            display: flex;
            justify-content: space-between;
            margin-bottom: 40px; /* 게시판 간 간격 */
        }

        /* 각 게시판 스타일 */
        .board-box {
            width: 48%; /* 각 게시판 너비를 50%로 설정 */
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        /* 게시글 목록 그리드 설정 */
        .board-list {
            list-style: none;
            padding: 0;
            display: grid;
            grid-template-columns: repeat(2, 1fr); /* 한 줄에 2개씩 표시 */
            gap: 20px;
        }

        .board-item {
            background-color: #f4f4f4;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .board-item .title {
            font-size: 1.2em;
            margin-bottom: 10px;
            color: #333;
        }

        .board-item .author {
            font-size: 0.9em;
            color: #777;
        }

        .board-item .content {
            font-size: 1em;
            margin-top: 10px;
            color: #555;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .post-form {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            margin-top: 30px;
        }

        .post-form input, .post-form textarea {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border-radius: 8px;
            border: 1px solid #ccc;
        }

        .post-form button {
            padding: 10px 15px;
            background-color: #007BFF;
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 1.2em;
            cursor: pointer;
        }

        .post-form button:hover {
            background-color: #0056b3;
        }

    </style>
</head>
<body>
    <div class="background"></div>
    <div class="top-bar">
        <div class="title"><a href="main.jsp">SCNU EVERYDAY</a></div>
        <div class="nav-links">
            <a href="howtouse.jsp">How to use</a>
            <% if (user == null) { %>
                <a href="signup.jsp">Signup</a>
                <a href="login.jsp">Login</a>
            <% } else { %>
                <a href="mypage.jsp"><span><%= user.getName() %>님</span></a>
                <a href="logout.jsp">Logout</a>
            <% } %>
        </div><br><br><br><!-- nav-links -->
    </div><!-- top-bar -->

    <div class="search-container">
        <!-- 게시판 1 -->
        <div class="board-container">
            <div class="board-box">
                <div class="board-header">게시판 1</div>
                <ul class="board-list">
                    <% for (BoardDTO post : boardList1) { %>
                        <li class="board-item">
                            <div class="title"><%= post.getTitle() %></div>
                            <div class="author">작성자: <%= post.getAuthor() %> | 작성일: <%= post.getDate() %></div>
                            <div class="content"><%= post.getContent() %></div>
                        </li>
                    <% } %>
                </ul>
            </div>

            <!-- 게시판 2 -->
            <div class="board-box">
                <div class="board-header">게시판 2</div>
                <ul class="board-list">
                    <% for (BoardDTO post : boardList2) { %>
                        <li class="board-item">
                            <div class="title"><%= post.getTitle() %></div>
                            <div class="author">작성자: <%= post.getAuthor() %> | 작성일: <%= post.getDate() %></div>
                            <div class="content"><%= post.getContent() %></div>
                        </li>
                    <% } %>
                </ul>
            </div>
        </div>

        <div class="board-container">
            <!-- 게시판 3 -->
            <div class="board-box">
                <div class="board-header">게시판 3</div>
                <ul class="board-list">
                    <% for (BoardDTO post : boardList3) { %>
                        <li class="board-item">
                            <div class="title"><%= post.getTitle() %></div>
                            <div class="author">작성자: <%= post.getAuthor() %> | 작성일: <%= post.getDate() %></div>
                            <div class="content"><%= post.getContent() %></div>
                        </li>
                    <% } %>
                </ul>
            </div>

            <!-- 게시판 4 -->
            <div class="board-box">
                <div class="board-header">게시판 4</div>
                <ul class="board-list">
                    <% for (BoardDTO post : boardList4) { %>
                        <li class="board-item">
                            <div class="title"><%= post.getTitle() %></div>
                            <div class="author">작성자: <%= post.getAuthor() %> | 작성일: <%= post.getDate() %></div>
                            <div class="content"><%= post.getContent() %></div>
                        </li>
                    <% } %>
                </ul>
            </div>
        </div>

        <!-- 글 작성 폼 -->
        <% if (user != null) { %>
        <div class="post-form">
            <h3>새 글 작성</h3>
            <form action="create_post.jsp" method="POST">
                <input type="text" name="title" placeholder="글 제목" required>
                <textarea name="content" rows="5" placeholder="글 내용을 입력하세요" required></textarea>
                <button type="submit">글 작성</button>
            </form>
        </div>
        <% } else { %>
        <div class="post-form">
            <p>로그인 후 글을 작성하실 수 있습니다.</p>
        </div>
        <% } %>
    </div>
</body>
</html>
