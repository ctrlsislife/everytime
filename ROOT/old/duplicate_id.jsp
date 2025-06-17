<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<%
	String u_name = request.getParameter("name");

	String u_email = request.getParameter("email");
%>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PLACE 4 YOU - 아이디 중복</title>
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
            margin-bottom: 20px; /* 위아래 간격 좁히기 */
        }
        .signup-container {
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
            margin-bottom: 5px;
        }
        .form-group duplicate {
            width: 100%;
            padding: 3%;
            margin-top: 30px;
            border-radius: 5px;
            border: 1px solid red;
            font-size: 1em;
            text-align: left; /* 입력 글씨 왼쪽 정렬 */
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
            text-align: left; /* placeholder 텍스트 가운데 정렬 */
        }
        .signup-button {
            display: block;
            margin: 20px auto;
            padding: 10px 20px;
            background-color: #333;
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 1.1em;
            cursor: pointer;
            width: 40%;
        }
        .signup-button:hover {
            background-color: #555;
        }
        .error-message {
            color: red;
            font-size: 1em;
            margin-top: 10px;
        }
        .login-link {
            margin-top: 20px;
            font-size: 1em;
            text-align: center;
        }
        .login-link a {
            color: #333;
            text-decoration: none;
        }
        .login-link a:hover {
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
        </div><br><br><br><!--nav-links-->
    </div><!-- top-bar -->
   	<div class="signup-container">
        <div class="subtitle"><b>회원가입</b></div>
        
        <form action="signup_process.jsp" method="POST">
        <div class="form-group">
            <label for="name"><b>이름</b></label>
            <!-- 쿼리 파라미터로 전달된 name을 input 필드에 채워넣기 -->
            <input type="text" id="name" name="name" required placeholder="이름을 입력하세요" value="${param.name}">
        </div><br>
        
        <div class="form-group">
            <label for="username"><b>아이디</b><span style="font-size: 14px; color: red;">중복된 아이디입니다.</span></label>
            <input type="text" id="username" name="username" style="border: 1px solid red;" required placeholder="아이디를 입력하세요" value="${param.username}">
        </div><br>
        
        <div class="form-group">
            <label for="password"><b>비밀번호</b></label>
            <input type="password" id="password" name="password" required placeholder="비밀번호를 입력하세요">
        </div><br>

        <div class="form-group">
            <label for="passwordConfirm"><b>비밀번호 확인</b></label>
            <input type="password" id="passwordConfirm" name="passwordConfirm" required placeholder="비밀번호를 다시 입력하세요">
        </div><br>
        
        <div class="form-group">
            <label for="email"><b>이메일</b></label>
            <!-- 쿼리 파라미터로 전달된 email을 input 필드에 채워넣기 -->
            <input type="text" id="email" name="email" required placeholder="이메일을 입력하세요" value="${param.email}">
        </div><br>

        <button type="submit" class="signup-button">회원가입</button>
    </form>

    <div class="login-link">
        <p><a href="login.jsp">아이디가 있으신가요?</a></p>
    </div>
    </div>
</body>
</html>
