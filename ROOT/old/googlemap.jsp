<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List" %>
<%@ page import="model.InformationDTO" %>
<%
    // 세션에서 로그인한 사용자 정보 가져오기
    InformationDTO user = (InformationDTO) session.getAttribute("user");

    // DB 연결 설정
    String driverName = "org.mariadb.jdbc.Driver";
    String dbUrl = "jdbc:mariadb://gwedu.org:3306/team8";
    String dbUsername = "team8";
    String dbPassword = "a1234";
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    // request에서 a_name 파라미터 가져오기
    String aName = request.getParameter("a_name");
    
    // a_name에 맞는 지역명 검색 쿼리
    String sql = "SELECT latitude, longitude FROM recommendations WHERE a_name LIKE ?";
    
    double latitude = 0.0;
    double longitude = 0.0;
    
    try {
        // DB 연결
        Class.forName(driverName); // 드라이버 로드
        conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

        // 쿼리 실행 준비
        ps = conn.prepareStatement(sql);
        
        // a_name 파라미터를 쿼리에 전달
        ps.setString(1, "%" + aName + "%"); // LIKE 조건에 %를 추가하여 부분 일치를 처리
        
        // 쿼리 실행
        rs = ps.executeQuery();

        // 결과 처리
        if (rs.next()) {
            latitude = rs.getDouble("latitude");
            longitude = rs.getDouble("longitude");
        }
    } catch (Exception e) {
        e.printStackTrace();  // 예외 처리
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // latitude와 longitude 값을 JSP 페이지로 전달
    request.setAttribute("latitude", latitude);
    request.setAttribute("longitude", longitude);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Place 4 You - 구글 지도</title>
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
		.map-container {
            text-align: center;
            background-color: rgba(255, 255, 255, 0.8);
            padding: 50px;
            border-radius: 10px;
            width: 80%; /* 너비 80%로 설정 */
            height: 70vh; /* 부모 높이에 비례하는 높이 */
            box-sizing: border-box;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            display: flex; /* Flexbox로 자식 요소 정렬 */
            flex-direction: column; /* 세로로 배치 */
            justify-content: center; /* 세로 중앙 정렬 */
            min-width: 500px
        }
        .subtitle {
        	text-align: center;
            font-size: 2em;
            color: #333;
            margin-bottom: 20px; /* 위아래 간격 좁히기 */
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
        #map {
            height: 100%;
            width: 100%;
        }

    </style>
    <!-- 구글 지도 API 로드 (API 키 삽입) -->
    <% 
    	out.println("<script src='https://maps.googleapis.com/maps/api/js?key=AIzaSyCk-4ZHlSivSXRlSEReOvePIl23-ZkCx0I&loading=async&callback=initMap' async defer></script>");
	%>

    <script>
        // 지도 초기화 함수
        function initMap() {
            var latitude = <%= latitude %>; // JSP에서 전달된 위도 값
            var longitude = <%= longitude %>; // JSP에서 전달된 경도 값

            // 지도 옵션 설정
            var mapOptions = {
                center: {lat: latitude, lng: longitude}, // 동적으로 설정된 위도와 경도
                zoom: 20 // 확대 수준
            };

            // 지도 생성
            var map = new google.maps.Map(document.getElementById('map'), mapOptions);

            // 마커 추가 (동적으로 받은 위치)
            var marker = new google.maps.Marker({
                position: {lat: latitude, lng: longitude},
                map: map,
                title: "검색된 위치"
            });
        }
    </script>
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
        <div class = "map-container">  
        	<!-- 구글 지도 영역 -->
        	<h1>구글 지도</h1>
        	<div id="map"></div>
        </div>  
</body>
</html>
