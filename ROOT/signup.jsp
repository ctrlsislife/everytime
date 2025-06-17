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
    InformationDTO user = (InformationDTO) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
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
            z-index: 1000;
            background-color: #f44336;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
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
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: calc(100vh - 120px);
        }
        .signup-form {
            background: white;
            width: 100%;
            max-width: 500px;
            padding: 30px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        .signup-form h2 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
            border-bottom: 2px solid #f44336;
            padding-bottom: 10px;
            text-align: center;
        }
        .signup-form label {
            display: block;
            margin-bottom: 10px;
            font-size: 16px;
            color: #333;
        }
        .signup-form input[type="text"],
        .signup-form input[type="password"],
        .signup-form input[type="email"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
        }
        .signup-form input[type="submit"] {
            width: 100%;
            padding: 10px;
            background-color: #f44336;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
        }
        .signup-form input[type="submit"]:hover {
            background-color: #d32f2f;
        }
        .signup-form .error {
            color: #f44336;
            font-size: 14px;
            margin-top: -10px;
            margin-bottom: 15px;
            display: none;
        }
        .signup-form .login-link {
            text-align: center;
            margin-top: 20px;
        }
        .signup-form .login-link a {
            color: #f44336;
            text-decoration: none;
        }
        .signup-form .login-link a:hover {
            text-decoration: underline;
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
        <div class="signup-form">
            <h2>회원가입</h2>
            <form action="signup_process.jsp" method="post" id="signupForm">
                <label for="username">아이디</label>
                <input type="text" id="username" name="username" required>
                <div class="error" id="usernameError">아이디를 입력해주세요.</div>
                
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" required>
                <div class="error" id="passwordError">비밀번호를 입력해주세요.</div>
                
                <label for="passwordConfirm">비밀번호 확인</label>
                <input type="password" id="passwordConfirm" name="passwordConfirm" required>
                <div class="error" id="confirmPasswordError">비밀번호가 일치하지 않습니다.</div>
                
                <label for="name">이름</label>
                <input type="text" id="name" name="name" required>
                <div class="error" id="nameError">이름을 입력해주세요.</div>
                
                <label for="email">이메일</label>
                <input type="email" id="email" name="email" required>
                <div class="error" id="emailError">유효한 이메일을 입력해주세요.</div>
                
                <input type="submit" value="회원가입">
            </form>
            <div class="login-link">
                <p>이미 계정이 있으신가요? <a href="login.jsp">로그인</a></p>
            </div>
        </div>
    </main>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.getElementById("signupForm");
        const username = document.getElementById("username");
        const password = document.getElementById("password");
        const passwordConfirm = document.getElementById("passwordConfirm");
        const nameField = document.getElementById("name");
        const email = document.getElementById("email");

        const usernameError = document.getElementById("usernameError");
        const passwordError = document.getElementById("passwordError");
        const confirmPasswordError = document.getElementById("confirmPasswordError");
        const nameError = document.getElementById("nameError");
        const emailError = document.getElementById("emailError");

        form.addEventListener("submit", function(e) {
            let isValid = true;

            if (!username.value.trim()) {
                usernameError.style.display = "block";
                isValid = false;
            } else { usernameError.style.display = "none"; }

            if (!password.value) {
                passwordError.style.display = "block";
                isValid = false;
            } else { passwordError.style.display = "none"; }

            if (password.value !== passwordConfirm.value) {
                confirmPasswordError.style.display = "block";
                isValid = false;
            } else { confirmPasswordError.style.display = "none"; }

            if (!nameField.value.trim()) {
                nameError.style.display = "block";
                isValid = false;
            } else { nameError.style.display = "none"; }

            if (!email.value.trim() || !email.value.includes("@")) {
                emailError.style.display = "block";
                isValid = false;
            } else { emailError.style.display = "none"; }

            if (!isValid) e.preventDefault();
        });

        passwordConfirm.addEventListener("input", function() {
            if (password.value !== passwordConfirm.value) {
                confirmPasswordError.style.display = "block";
            } else {
                confirmPasswordError.style.display = "none";
            }
        });
        password.addEventListener("input", function() {
            if (passwordConfirm.value && password.value !== passwordConfirm.value) {
                confirmPasswordError.style.display = "block";
            } else {
                confirmPasswordError.style.display = "none";
            }
        });
    });
    </script>
</body>
</html>
