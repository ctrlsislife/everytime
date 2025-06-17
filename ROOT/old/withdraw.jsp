<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.InformationDTO" %>
<%@ page import="java.sql.*" %>
<%
    InformationDTO user = (InformationDTO) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Place 4 You - 회원 탈퇴</title>
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
    		width: 100%;
    		height: 100%;
    		background-image: url('/team8_main/img/background1.jpg');
    		background-size: cover;
    		background-position: center;
    		background-repeat: no-repeat;
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
        .withdraw-container {
        	align-items: center;
            text-align: center;
            background-color: rgba(255, 255, 255, 0.8);
            padding: 50px;
            border-radius: 10px;
            width: 30%;
            box-sizing: border-box;
            position: absolute;
            top: 10%;
            left: 50%;
            transform: translate(-50%, 0);
            min-width: 500px;
        }
        .form-group {
            margin-bottom: 5px; /* 위아래 간격 좁히기 */
            text-align: left;
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100%;
        }
        .form-group label {
        	position: absolute;
    		font-size: 1.2em;
    		color: #333;
    		text-align: left;   /* 텍스트 왼쪽 정렬 */
    		width: 100%;        /* 부모 요소 너비에 맞추기 */
    		display: inline-block; /* 블록 요소처럼 동작하도록 설정 */
            margin-left: 25%
		}
        .form-group input {
            width: 100%;
            padding: 10px;
            margin-top: 30px;
            border-radius: 5px;
            border: 1px solid #ccc;
            font-size: 1em;
            text-align: left;
        }
        .form-group input::placeholder {
            text-align: left; /* placeholder 텍스트 가운데 정렬 */
        }
        .form-group-readonly{
            margin-bottom: 15px; /* 위아래 간격 좁히기 */
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100%;
        }
        .form-group-readonly label {
            position: absolute;
    		font-size: 1.2em;
    		text-align: center;   /* 텍스트 왼쪽 정렬 */
    		width: 100%;        /* 부모 요소 너비에 맞추기 */
    		display: inline-block; /* 블록 요소처럼 동작하도록 설정 */
            margin-bottom: 20px;
        }
        .submit-button {
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
        
        .submit-button:hover {
            background-color: #555;
        }
    </style>
</head>
<body>
	<div class="background"></div>
    <div class="top-bar">
        <div class="title"><a href="index.jsp">PLACE 4 YOU</a></div><br><br>
        <div class="nav-links">
            <a href="howtouse.jsp">How to use</a>
            <a href="mypage.jsp"><span><%= user.getName() %>님</span></a>
            <a href="logout.jsp">Logout</a>
        </div><br><br><br>
	</div>
	<div class="withdraw-container">
		<div class="subtitle"><b>회원 탈퇴</b></div>
        <form action="withdraw_process.jsp" method="POST">
            <!-- 읽기 전용 -->
            <div class="form-group-readonly">
                <label for="name"><b>아이디 "<%= user.getUsername() %>" 에 대한 탈퇴</b></label><br><br>
                <div>
                	<strong>**탈퇴하시면 아이디는 복구하실 수 없습니다**</strong><br>
                	<strong>동의하시면 비밀번호를 입력해주세요.</strong>
                </div>
                
            </div><br>
            
            <div class="form-group">
                <input type="password" id="password" name="password" required placeholder="비밀번호를 입력하세요">
            </div><br>


            <button type="submit" class="submit-button">회원 탈퇴</button>
        </form>
    </div>
</body>
</html>
