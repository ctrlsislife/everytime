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
    <title>Place 4 You - 마이 페이지</title>
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
		.info-container {
          	text-align: center;
           	background-color: rgba(255, 255, 255, 0.8);
            padding: 50px;
            border-radius: 10px;
            width: 40%;
            height: auto;
            box-sizing: border-box;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            min-width: 500px;
        }
        .subtitle {
            font-size: 2em;
            color: #333;
            margin-bottom: 20px;
        }
        .user-info {
            margin-top: 30px;
            font-size: 1.2em;
            color: #666;
        }
        .user-info p {
            margin: 10px 0;
        }
        .user-info a {
            display: inline-block;
            padding: 10px 20px;
            background-color: #333;
            color: #fff;
            border-radius: 5px;
            text-decoration: none;
            margin-top: 20px;
        }
        .user-info a:hover {
            background-color: #555;
        }
        .logout-button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #d9534f;
            color: #fff;
            border-radius: 5px;
            text-decoration: none;
            margin-top: 20px;
        }
        .logout-button:hover {
            background-color: #c9302c;
        }
    </style>
</head>
<body>
	<div class="background"></div>
    <div class="top-bar">
        <div class="title"><a href="index.jsp">PLACE 4 YOU</a></div>
        <div class="nav-links">
		<a href="howtouse.jsp">How to use</a>
		<a href="mypage.jsp"><span><%= user.getName() %>님</span></a>
		<a href="logout.jsp">Logout</a>
        </div><br><br><br><!-- nav-links -->
    </div><!-- top-bar -->
    <div class="info-container">
    	<div class="subtitle">마이페이지</div>
		<div class="user-info">
			<%
        		String username = user.getUsername();
        		String email = "";
        
	        	// DB 연결 설정
	        	String driverName = "org.mariadb.jdbc.Driver";
	        	String dbUrl = "jdbc:mariadb://gwedu.org:3306/team8";
	        	String dbUsername = "team8";
	        	String dbPassword = "a1234";
	        	Connection conn = null;
	        	PreparedStatement ps = null;
	        	ResultSet rs = null;
	        	String sql = "SELECT * FROM user_index WHERE username = ?";
	
	        	try {
	            	Class.forName(driverName);
	
	            	conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
	
	            	ps = conn.prepareStatement(sql);
	            	ps.setString(1, username);
	
	            	rs = ps.executeQuery();
	
	            	if (rs.next()) {
	                	email = rs.getString("email");
	            	} else {
	                	email = "이메일을 찾을 수 없습니다.";
	            	}
	        	} catch (SQLException e) {
	            	e.printStackTrace();
	            	email = "오류 발생";
	        	} catch (ClassNotFoundException e) {
	            	e.printStackTrace();
	            	email = "드라이버를 찾을 수 없습니다.";
	        	} finally {
	            	try {
	                	if (rs != null) rs.close();
	                	if (ps != null) ps.close();
	                	if (conn != null) conn.close();
	            	} catch (SQLException e) {
	                	e.printStackTrace();
	            	}
	        	}
	        %>
        	<p><strong>이름:</strong> <%= user.getName() %></p>
            <p><strong>아이디:</strong> <%= user.getUsername() %></p>
            <p><strong>이메일:</strong> <%= user.getEmail() %></p>
            <p><strong>가입일:</strong> <%= user.getSignin() %></p>
            <p><strong>최종 수정일:</strong> <%= user.getUpdate() %></p>
            <a href="wishlist.jsp">찜 목록</a>
            <a href="history.jsp">방문 기록</a><br>

            <a href="editProfile.jsp">프로필 수정</a>
            <a href="logout.jsp" class="logout-button">로그아웃</a>
            <a href="withdraw.jsp">회원 탈퇴</a>
        </div>
    </div>
</body>
</html>
