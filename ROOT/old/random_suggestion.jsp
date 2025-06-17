<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter, java.sql.Connection, java.sql.DriverManager, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException, java.net.URI, java.net.http.HttpClient, java.net.http.HttpRequest, java.net.http.HttpResponse, org.w3c.dom.Document, javax.xml.parsers.DocumentBuilder, javax.xml.parsers.DocumentBuilderFactory, org.xml.sax.InputSource, java.io.StringReader, org.w3c.dom.Element, org.w3c.dom.Node" %>
<%@ page import="java.util.ArrayList, java.util.List" %>
<%@ page import="model.InformationDTO" %>
<%@ page import="org.w3c.dom.NodeList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.*, java.text.*, org.w3c.dom.*, javax.xml.parsers.*, java.io.*" %>
<%@ page import="java.net.*, java.io.*, javax.xml.parsers.*, org.w3c.dom.*, org.xml.sax.*" %>
<%@ page import="org.json.JSONObject, org.json.JSONArray" %>

<%
    // 사용자 정보를 세션에서 가져오기
    InformationDTO user = (InformationDTO) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PLACE 4 YOU - 랜덤 추천</title>
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
        .detail-container {
        	display: flex;
        	flex-direction: row;
    		text-align: center;
    		height: 50%;
           	opacity: 0.8;
            padding: 10px;
            border-radius: 10px;
            box-sizing: border-box;
            position: absolute;
            top: 40%;
            left: 50%;
            transform: translate(-50%, -50%);
        }
        .button-container {
    		text-align: center;
           	background-color: #FDF8F4;
           	opacity: 0.8;
            padding: 5px;
            border-radius: 10px;
            box-sizing: border-box;
            position: absolute;
            top: 120px;
            left: 50%;
            transform: translate(-50%, -50%);
        }
        .button-container:hover{
        	background-color: #B5B5B5;
        }
        .subtitle {
        	width: 100%;
        	text-align: center;
    		font-size: 2.5em; /* 글자 크기를 조정 */
    		font-weight: bold; /* 볼드 처리 */
    		color: #333; /* 글자 색상 */
    		margin-bottom: 20px; /* 아래쪽 여백 */
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
        </div><br><br><br><!--nav-links-->
    </div> <!--top-bar-->
	<div class="detail-container">
    	      
			<%
			
			    // DB 연결을 위한 기본 설정
			    String driverName = "org.mariadb.jdbc.Driver";
			    String dbUrl = "jdbc:mariadb://gwedu.org:3306/team8";
			    String dbUsername = "team8";
			    String dbPassword = "a1234";
			    Connection conn = null;
			    PreparedStatement ps = null;
			    ResultSet rs = null;
			
			    // API 키 (구글 Places API)
			    String apiKey = "AIzaSyDJ7b4LTwx3aeJOTxEHE8iVylaG15xe9Sg";  // 구글 API 키
			
			    // 첫 번째 쿼리: 추천 정보 가져오기 (랜덤 항목)
			    String sql = "SELECT * FROM recommendations ORDER BY RAND() LIMIT 1";  // 랜덤으로 한 항목 가져오기
			
			    try {
			        // DB 연결
			        Class.forName(driverName);
			        conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
			
			        // 첫 번째 쿼리 실행
			        ps = conn.prepareStatement(sql);
			        rs = ps.executeQuery();
			
			        if (rs.next()) {
			            String a_name = rs.getString("a_name");
			            String a_description = rs.getString("a_desc");
			            String a_address = rs.getString("address");
			            String a_img = rs.getString("img_url");
			
			            // 구글 Places API 요청 URL (장소 이름을 기반으로 검색)
			            String searchUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" + URLEncoder.encode(a_name, "UTF-8") + "&key=" + apiKey;
			
			            // Places API에 요청 보내기
			            HttpURLConnection searchConnection = (HttpURLConnection) new URL(searchUrl).openConnection();
			            searchConnection.setRequestMethod("GET");
			            BufferedReader searchReader = new BufferedReader(new InputStreamReader(searchConnection.getInputStream()));
			            StringBuilder placesApiResponse = new StringBuilder();
			            String searchLine;
			            while ((searchLine = searchReader.readLine()) != null) {
			                placesApiResponse.append(searchLine);
			            }
			
			            // JSON 응답 파싱
			            JSONObject searchJsonResponse = new JSONObject(placesApiResponse.toString());
			            JSONArray searchResults = searchJsonResponse.getJSONArray("results");
			
			            // 구글 Places API에서 결과가 있으면 평점과 리뷰를 출력
			            double rating = 0;
			            StringBuilder reviewsHtml = new StringBuilder();
			            if (searchResults.length() > 0) {
			                // 첫 번째 검색 결과에서 장소 정보 가져오기
			                JSONObject matchedPlace = searchResults.getJSONObject(0);  // 첫 번째 결과 사용
			                String googlePlaceId = matchedPlace.getString("place_id");
			
			                // 평점, 리뷰 등 세부 정보 가져오기 위해 Place Details API 요청
			                String detailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=" + googlePlaceId + "&key=" + apiKey + "&language=ko";
			
			                // Place Details API에 요청 보내기
			                HttpURLConnection detailsConnection = (HttpURLConnection) new URL(detailsUrl).openConnection();
			                detailsConnection.setRequestMethod("GET");
			                BufferedReader detailsReader = new BufferedReader(new InputStreamReader(detailsConnection.getInputStream()));
			                StringBuilder placeDetailsResponse = new StringBuilder();
			                String detailsLine;
			                while ((detailsLine = detailsReader.readLine()) != null) {
			                    placeDetailsResponse.append(detailsLine);
			                }
			
			                // JSON 응답 파싱 (리뷰, 평점 등)
			                JSONObject detailsJsonResponse = new JSONObject(placeDetailsResponse.toString());
			                JSONObject result = detailsJsonResponse.getJSONObject("result");
			
			                // 평점 추출
			                rating = result.optDouble("rating", 0);  // 평점 (없으면 0)
			
			                // 리뷰 출력 (설명 아래에 리뷰 추가) - 최신 리뷰 1개만 출력
			                JSONArray reviews = result.optJSONArray("reviews");  // reviews 필드가 없을 수 있음
			
			                if (reviews != null && reviews.length() > 0) {
			                    reviewsHtml.append("<h3>최신 리뷰</h3>");
			                    // 최신 리뷰는 배열의 첫 번째 요소
			                    JSONObject latestReview = reviews.getJSONObject(0);
			                    String reviewerName = latestReview.getString("author_name");
			                    String reviewText = latestReview.getString("text");
			                    int reviewRating = latestReview.getInt("rating");
			
			                    // 한글 리뷰만 출력
			                    if (latestReview.has("language") && latestReview.getString("language").equals("ko")) {
			                        reviewsHtml.append("<div style='border: 1px solid #ddd; padding: 10px; margin-bottom: 10px; background-color: #f9f9f9;'>");
			                        reviewsHtml.append("<strong>" + reviewerName + " (" + reviewRating + " / 5)</strong>");
			                        reviewsHtml.append("<p>" + reviewText + "</p>");
			                        reviewsHtml.append("</div>");
			                    }
			                } else {
			                    reviewsHtml.append("<p>리뷰가 없습니다.</p>");
			                }
			            }
			
			            // HTML 출력
			            out.println("<div style='text-align: center; display: inline-block;'>");
			            out.println("<div style='border: 1px solid #ccc; border-radius: 10px; padding: 20px; margin: 20px; display: inline-block; background-color: #f9f9f9; box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);'>");
			            out.println("<div style='text-align: left; display: flex; align-items: center;'>");
			            out.println("<img src='" + a_img + "' alt='Image' style='float: left; margin-right: 20px; width: 40%; height: auto;' onerror=\"this.onerror=null;this.src='/team8_main/img/no_img.jpg';\">");
			            out.println("<div style='text-align: left;'>");
			            out.println("<h2>" + a_name + "</h2>");
			            out.println("<p>설명: " + a_description + "</p>");
			            out.println("<p>주소: " + a_address + "&nbsp;" + 
			                        "<a href='googlemap.jsp?a_name=" + a_name + "' style='text-decoration: none;'>" +
			                        "<button style='background-color: #333; color: white; border: none; border-radius: 5px; padding: 5px 10px; cursor: pointer;'>지도 보기</button>" +
			                        "</a></p>");
			
			            // 평점 출력
			            out.println("<p>평점: " + (rating == 0 ? "평가 없음" : rating) + "</p>");
			
			            // 최신 리뷰 출력 (평점 바로 아래)
			            out.println(reviewsHtml.toString());
			
			            out.println("</div>");
			            out.println("</div>");
			            
			            out.println("</div>");
			            
			            out.println("</div>");
			        } else {
			            // 추천 정보를 찾을 수 없으면 메시지 출력
			            out.println("<p>추천 정보를 찾을 수 없습니다.</p>");
			        }
			    } catch (Exception e) {
			        out.println("<p>데이터를 가져오는 중 오류가 발생했습니다.</p>");
			        e.printStackTrace();
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
			</div>
			<div class="button-container">
			<a href='random_suggestion.jsp' style='text-decoration: none;'><button style='background-color: #333; color: white; border: none; border-radius: 5px; padding: 10px 10px; font-size: 1.5em; width: 250px; height: 50px; margin-top: 0px; cursor: pointer;'>랜덤 돌리기</button></a>
		</div> <!--button-container -->
</body>
</html>
