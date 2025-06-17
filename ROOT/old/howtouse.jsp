<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List" %>
<%@ page import="model.InformationDTO" %>
<%
    InformationDTO user = (InformationDTO) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Place 4 You - 도움말</title>
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
        .help-container {
        	align-items: center;
            text-align: center;
            background-color: rgba(255, 255, 255, 0.8);
            padding: 50px;
            border-radius: 10px;
            width: 60%;
            box-sizing: border-box;
            position: absolute;
            top: 10%;
            left: 50%;
            transform: translate(-50%, 0);
            min-width: 500px;
        }
        .message {
            font-size: 1.5em;
            color: #666;
            margin-top: 60px;
        }

        .button {
            padding: 12px 20px;
            background-color: #333;
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 1.2em;
            cursor: pointer;
        }
        .button:hover {
            background-color: #555;
        }
    </style>
</head>
<body>
	<div class="background"></div>
    <div class="top-bar">
        <div class="title"><a href="index.jsp">PLACE 4 YOU</a></div>
        <div class="nav-links">
            <a href="howtouse.jsp">How to use</a>
            <% if (user == null) { %>
                <a href="signup.jsp">Signup</a>
                <a href="login.jsp">Login</a>
            <% } else { %>
                <a href="mypage.jsp"><span><%= user.getName() %>님</span></a>
                <a href="logout.jsp">Logout</a>
            <% } %>
        </div><br><br><br>
	</div>
	<div class="help-container">
        <p style="font-size: 3.5em; position-center: absolute; top: 10px;"><b> PLACE 4 YOU </b></p>
        <p style="font-size: 1.5em; position-center: absolute; top: 250px;">당신의 여행을 더 다채롭게 채워보세요.</p><br>
        <p style="font-size: 1.3em; position-center: absolute; top: 300px;">PLACE 4 YOU는 당신이 놓친 숨겨진 관광지를 추천해주는 기능을 가지고 있습니다.</p><br>
        <p style="font-size: 1.6em; position-center: absolute; margin-top: 30%;"><b>원하는 관광지를 검색하기</b></p><br>
        <p style="font-size: 1.6em; position-center: absolute; "><b>원하는 지역을 선택</b></p><br>
        <img src="/team8_main/img/howtouse2.jpg" alt="검색" style="position-center: absolute; border: 1px solid; border-radius: 5px;"><br>
        <p style="font-size: 1.6em; position-center: absolute; "><b>원하는 시/구를 선택</b></p><br>
        <img src="/team8_main/img/howtouse3.jpg" alt="검색" style="position-center: absolute; border: 1px solid; border-radius: 5px;"><br>
        <p style="font-size: 1.6em; position-center: absolute;"><b>원하는 취미를 선택</b></p><br>
        <img src="/team8_main/img/howtouse4.jpg" alt="검색" style="position-center: absolute; border: 1px solid; border-radius: 5px;"><br>
        <p style="font-size: 1.6em; position-center: absolute; margin-top: 50%;"><b>검색된 결과 중 원하는 관광지를 선택</b></p><br>
        <img src="/team8_main/img/howtouse5.jpg" alt="검색" style="position-center: absolute; border: 1px solid; border-radius: 5px; width: 600px;"><br>
        <p style="font-size: 1.6em; position-center: absolute;"><b>위치와 날씨등을 확인</b></p><br>
        <img src="/team8_main/img/howtouse6.jpg" alt="검색" style="position-center: absolute; border: 1px solid; border-radius: 5px; width: 700px;"><br>
		<a href="index.jsp"><button style="background-color: #333; color: white; border: none; border-radius: 5px; padding: 10px 10px; font-size: 1.5em; width: 250px; height: 50px; margin-top: 50px; cursor: pointer;">탐색 하러가기</button></a>
    	
    </div>

</body>
</html>
