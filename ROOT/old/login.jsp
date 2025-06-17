<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PLACE 4 YOU - 로그인</title>
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
        .subtitle {
        	text-align: center;
            font-size: 2em;
            color: #333;
            margin-bottom: 20px;
        }
        .login-container {
            text-align: left;
            background-color: rgba(255, 255, 255, 0.8);
            padding: 50px;
            border-radius: 10px;
            width: 20%;
            box-sizing: border-box;
            position: absolute;
            top: 10%;
            left: 50%;
            transform: translate(-50%, 0);
            min-width: 500px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 95%;
            max-width: 100%;
            margin: 0 auto;
        }

        .form-group label {
            font-size: 1.3em;
            color: #333;
            display: flex;
            justify-content: space-between; /* 양쪽 끝에 맞추기 */
            width: 100%;
            margin-bottom: 10px;
        }
        .form-group input {
            width: 100%;
            padding: 3%;
            margin-top: 30px;
            border-radius: 5px;
            border: 1px solid #ccc;
            font-size: 1em;
            text-align: left; /* 입력 글씨 왼쪽 정렬 */
        }
        .form-group input::placeholder {
            text-align: center; /* placeholder 텍스트 가운데 정렬 */
        }
        .login-button {
            display: block;
            margin: 5px auto;
            padding: 10px 20px;
            background-color: #333;
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 1.1em;
            cursor: pointer;
            width: 40%;
        }
        .login-button:hover {
            background-color: #555;
        }
        .error-message {
            color: red;
            font-size: 1em;
            margin-top: 10px;
        }
        .signup-link {
        	text-align: center;
            margin-top: 10px; /* 위아래 간격 좁히기 */
            font-size: 1em;
        }
        .signup-link a {
            color: #333;
            text-decoration: none;
        }
        .signup-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="background"></div>
    <div class="top-bar">
        <div class="title"><a href="index.jsp">PLACE 4 YOU</a></div>
        <div class="nav-links">
            <a href="howtouse.jsp">How to use</a>
            <a href="signup.jsp">Signup</a>
            <a href="login.jsp">Login</a>
        </div><br><br><br><br><br>
    </div>
  <div class="login-container">
    <div class="subtitle">로그인</div>
        <!-- 로그인 폼 -->
        <form action="login_process.jsp" method="POST">
            <!-- 아이디 입력 -->
            <div class="form-group">
                <label for="username"><b>아이디</b></label>
                <input type="text" id="username" name="login_id" required placeholder="아이디를 입력하세요">
            </div><br>

            <!-- 비밀번호 입력 -->
            <div class="form-group">
                <label for="password"><b>비밀번호</b></label>
                <input type="password" id="password" name="login_pw" required placeholder="비밀번호를 입력하세요">
            </div><br><br>

            <!-- 로그인 버튼 -->
            <button type="submit" class="login-button">로그인</button>
        </form>

        <c:if test="${not empty errorMessage}">
            <div class="error-message">${errorMessage}</div>
        </c:if>

        <div class="signup-link">
            <p>회원이 아니신가요? <a href="signup.jsp">회원가입</a></p>
        </div>
      </div>
</body>
</html>
