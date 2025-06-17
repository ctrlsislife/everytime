<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter, java.sql.Connection, java.sql.DriverManager, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException, java.net.URI, java.net.http.HttpClient, java.net.http.HttpRequest, java.net.http.HttpResponse, org.w3c.dom.Document, javax.xml.parsers.DocumentBuilder, javax.xml.parsers.DocumentBuilderFactory, org.xml.sax.InputSource, java.io.StringReader, org.w3c.dom.Element, org.w3c.dom.Node" %>
<%@ page import="java.util.ArrayList, java.util.List" %>
<%@ page import="model.InformationDTO" %>
<%@ page import="org.w3c.dom.NodeList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.*, java.text.*, org.w3c.dom.*, javax.xml.parsers.*, java.io.*" %>
<%@ page import="java.net.*, java.io.*, javax.xml.parsers.*, org.w3c.dom.*, org.xml.sax.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>

<%
    // 사용자 정보를 세션에서 가져오기
    InformationDTO user = (InformationDTO) session.getAttribute("user");
%>

<%
    // URL 파라미터에서 필요한 값들을 받기
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String img = request.getParameter("img");
    String rec = request.getParameter("rec");

    // 현재 날짜를 구하고, yyyyMMdd 형식으로 포맷팅
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    String baseDate = today.format(formatter); 
    DateTimeFormatter a_formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    String a_date = today.format(formatter);
    String convTime = "";

    // 현재 시간 구하기 (HHMM 형식)
    java.util.Date now = new java.util.Date();
    SimpleDateFormat sdf = new SimpleDateFormat("HHmm");
    String baseTime = sdf.format(now);
    
    int baseTimeInt = Integer.parseInt(baseTime); // 현재 시간을 정수로 변환
    int comparisonTime = 30; // 30분과 비교하기 위해 정수로 설정
    int airTimeInt = baseTimeInt;
    
    LocalDate airtoday = LocalDate.now();
	if (airTimeInt < 500) {
		airtoday = today.minusDays(1);
		a_date = airtoday.format(a_formatter);
    }
	else {
		a_date = airtoday.format(a_formatter);
	}
 // 시간을 분리하여 비교 (HHmm에서 분만 따로 추출)
    int hour = baseTimeInt / 100; // 시 부분 (예: 0930 -> 9)
    int minute = baseTimeInt % 100; // 분 부분 (예: 0930 -> 30)



    // 30분 이전이라면 한 시간 전으로 설정
    if (minute < comparisonTime) {
        // 시간에서 1을 빼고, 분은 30으로 설정
        hour = hour - 1;
        minute = 30;
        // HHmm 형식으로 다시 계산
        convTime = String.format("%02d%02d", hour, minute); // 시와 분을 HHmm 형식으로 변환

    } else {
        // 30분 이후면 그대로 사용

        minute = 30;
        convTime = String.format("%02d%02d", hour, minute); // 시와 분을 HHmm 형식으로 변환
    }

    if (name == null || img == null || id == null) {
        out.print("필요한 데이터가 없습니다.");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Detail</title>
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
        .detail-body {
        	display: flex;
    		justify-content: center;
        	align-items: center;
			margin: 70px;
        	width: 95%;
        	height: 20%;
        	min-width: 1000px;
        }
        .detail-container {
        	display: flex;
    		justify-content: center; 
    		align-items: center; 
    		margin: auto;
    		min-width: 1000px;
    		width: 500px;
        }
        .api-body {
        	display: flex;
        	flex-direction: column;
    		justify-content: center;
        	align-items: center;
			margin: auto;
        	width: 90%;
        	height: 30%;
        }
        .api-container {
        	background-color: rgba(255, 255, 255, 0.8);
        	justify-content: center;
    		display: flex;
    		flex-wrap: wrap; /* 줄 바꿈 허용 */
    		gap: 16px; /* 박스 간격 */
    		width: 1100px;
    		height: 100%;
    		padding: 30px;
    		border-radius: 10px;
        }
        .api-box {
    		border: 1px solid #ccc;
    		border-radius: 8px;
    		padding: 16px;
    		width: 120px;
    		height: 220px; /* 박스 크기 */
    		box-shadow: 2px 2px 8px rgba(0, 0, 0, 0.1);
    		background-color: rgba(255, 255, 255, 0.8);
        }
         .api-box .datetime {
            font-weight: bold;
            margin-bottom: 0px;
            color: #333;
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
	<div class="detail-body">
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
			
			    // 첫 번째 쿼리: 추천 정보 가져오기
			    String sql = "SELECT * FROM recommendations WHERE a_name = ?";
			    
			    
			    String username = ""; // 실제 로그인한 사용자로 설정
			    if (user != null) {
			    	username = user.getUsername();
			    }
			    boolean isLiked = false;  // 좋아요 상태를 추적하는 변수
			
			    try {
			        // DB 연결
			        Class.forName(driverName);
			        conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

			        // 사용자가 해당 아이템을 좋아요했는지 확인
			        String checkQuery = "SELECT * FROM wishlist WHERE username = ? AND recommendation_id = ?";
			        ps = conn.prepareStatement(checkQuery);
			        ps.setString(1, username);
			        ps.setString(2, rec);
			        rs = ps.executeQuery();
			        
			        if (rs.next()) {
			            isLiked = true;  // 이미 좋아요한 상태
			        }
			    } catch (Exception e) {
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
			    
			    try {
			        // DB 연결
			        Class.forName(driverName);
			        conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
			
			        // 첫 번째 쿼리 실행
			        ps = conn.prepareStatement(sql);
			        ps.setString(1, name);  // 'name'은 검색하려는 추천 항목의 이름
			        rs = ps.executeQuery();
			
			        if (rs.next()) {
			            String a_name = rs.getString("a_name");
			            String a_description = rs.getString("a_desc");
			            String a_address = rs.getString("address");
			            double latitude = rs.getDouble("latitude");  // 위도 (구글 Places API 검색에 필요 없음)
			            double longitude = rs.getDouble("longitude");  // 경도 (구글 Places API 검색에 필요 없음)
			
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
			            out.println("<img src='" + img + "' alt='Image' style='float: left; margin-right: 20px; width: 40%; height: auto;' onerror=\"this.onerror=null;this.src='/team8_main/img/no_img.jpg';\">");
			            out.println("<div style='text-align: left;'>");
			            out.println("<h2>" + a_name + 
			            		"&nbsp&nbsp<form id='wishlistForm' action='toggleWishlist.jsp' method='post' style='display:inline-block;'>");
			            out.println("<input type='hidden' name='id' value='" + rec + "'>");
			            out.println("<input type='hidden' name='username' value='" + username + "'>");
			            out.println("<button type='submit' style='background: none; border: none; cursor: pointer; font-size: 25px; align-items: center;'>");
			            out.println(isLiked ? "❤️" : "🤍");
			            out.println("</button>");
			            out.println("</form>");
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
			            // 추천 정보만 출력하고, 평점과 리뷰는 생략
			            String a_name = rs.getString("a_name");
			            String a_description = rs.getString("a_desc");
			            String a_address = rs.getString("address");
			
			            out.println("<div style='text-align: center; display: inline-block;'>");
			            out.println("<div style='border: 1px solid #ccc; border-radius: 10px; padding: 20px; margin: 20px; display: inline-block; background-color: #f9f9f9; box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);'>");
			            out.println("<div style='text-align: left; display: flex; align-items: center;'>");
			            out.println("<img src='" + img + "' alt='Image' style='float: left; margin-right: 20px; width: 40%; height: auto;' onerror=\"this.onerror=null;this.src='/team8_main/img/no_img.jpg';\">");
			            out.println("<div style='text-align: left;'>");
			            out.println("<h2>" + a_name + 
			            		"&nbsp&nbsp<form id='wishlistForm' action='toggleWishlist.jsp' method='post' style='display:inline-block;'>");
			            out.println("<input type='hidden' name='id' value='" + rec + "'>");
			            out.println("<input type='hidden' name='username' value='" + username + "'>");
			            out.println("<button type='submit' style='background: none; border: none; cursor: pointer; font-size: 25px; align-items: center;'>");
			            out.println(isLiked ? "❤️" : "🤍");
			            out.println("</button>");
			            out.println("</form>");
			            out.println("<p>설명: " + a_description + "</p>");
			            out.println("<p>주소: " + a_address + "&nbsp;" + 
			                        "<a href='googlemap.jsp?a_name=" + a_name + "' style='text-decoration: none;'>" +
			                        "<button style='background-color: #333; color: white; border: none; border-radius: 5px; padding: 5px 10px; cursor: pointer;'>지도 보기</button>" +
			                        "</a></p>");
			            out.println("</div>");
			            out.println("</div>");
			            out.println("</div>");
			            out.println("</div>");
			        }
			        
			        
			        if (user != null) {
			            
			            // 중복 체크 쿼리 준비
			            String checkQuery = "SELECT COUNT(*) FROM history WHERE username = ? AND recommendation_id = ?";
			            PreparedStatement psCheck = conn.prepareStatement(checkQuery);
			            psCheck.setString(1, username);
			            psCheck.setString(2, rec);

			            // 중복 체크 실행
			            ResultSet rsCheck = psCheck.executeQuery();
			            if (rsCheck.next() && rsCheck.getInt(1) == 0) {
			                // 중복되지 않으면 history 테이블에 데이터 삽입
			                String hist = "INSERT INTO history (username, recommendation_id) VALUES (?, ?)";
			                ps = conn.prepareStatement(hist);

			                // 파라미터 설정
			                ps.setString(1, username);
			                ps.setString(2, rec);

			                // 쿼리 실행
			                ps.executeUpdate();
			            }
			            // 중복된 경우에는 아무 작업도 하지 않음
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
			<script>
    // 하트 버튼 클릭 시 폼 제출
    document.getElementById("heartButton").addEventListener("click", function(event) {
        event.preventDefault(); // 기본 폼 제출을 막음

        const form = document.getElementById("wishlistForm");
        const heartButton = document.getElementById("heartButton");

        // 하트 상태 토글 (클릭 시 하트 모양 바꾸기)
        if (heartButton.innerHTML === "♡") {
            heartButton.innerHTML = "❤️";  // 하트를 빨간색으로 변경
        } else {
            heartButton.innerHTML = "♡";  // 빈 하트로 변경
        }

        // 폼 제출
        form.submit();
    });
</script>
		</div> <!--detail-container -->
	</div> <!--detail-body-->
	<div class="api-body">
			<div class="api-container">
				<div><a href="weather_detail.jsp?name=<%= name %>&id=<%= id %> ">
					<button style='background-color: #333; position: absolute; margin-left: 200px; margin-top: 20px; color: white; border: 1px solid; 
					border-radius: 10px; width: 150px; height: 50px; font-size: 1.2em; padding: 10px 10px; cursor: pointer;'>날씨 더보기</button></a>
    			</div>
				<div class="subtitle">날씨 예보</div>
	
				<%
				    // 날씨 정보를 담을 리스트 생성
				    List<Map<String, String>> weatherDataList = new ArrayList<>();
				    StringBuilder boxBuilder = new StringBuilder();  // 박스를 위한 문자열 빌더
				
				    String targetRegion = ""; // 지역명을 저장할 변수
				    String targetGrade = "";  // 특정 지역의 예보 값
				    String informData = "";
				    String informCode = "";
				    String informGrade = "";
				    String dataTime = "";
				
				    // DB 연결 설정
				    Connection conn2 = null;
				    PreparedStatement ps2 = null;
				    ResultSet rs2 = null;
				
				    try {
				        // DB 연결
				        Class.forName(driverName);
				        conn2 = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
				
				        // 두 번째 쿼리 실행: 위도와 경도를 가져오기
				        String locationSql = "SELECT nx, ny FROM region_index r " +
				                             "JOIN recommendations rc ON r.region_id = rc.region_id " +
				                             "WHERE r.region_id LIKE ?";
				        ps2 = conn2.prepareStatement(locationSql);
				        ps2.setString(1, id);
				        rs2 = ps2.executeQuery();
				
				        if (rs2.next()) {
				            String nx = rs2.getString("nx");  // 위도
				            String ny = rs2.getString("ny");  // 경도
				
				            // API URL 생성
				            String serviceKey = "FJpfbQGQv43vMthQ%2FA73cEDP4ydRXH4ibW9ESwieKgH04Kipl7DAAXRYlvuA%2BQwgq9B36nEjDemOSVNhpX2c5w%3D%3D";
				            String apiUrl = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst?" +
				                            "serviceKey=" + serviceKey +
				                            "&pageNo=1&numOfRows=1000&dataType=XML" +
				                            "&base_date=" + baseDate +
				                            "&base_time=" + convTime +
				                            "&nx=" + nx +
				                            "&ny=" + ny;
				
				            // HTTP 요청 보내기
				            HttpClient client = HttpClient.newHttpClient();
				            HttpRequest httpRequest = HttpRequest.newBuilder().uri(new URI(apiUrl)).build();
				            HttpResponse<String> httpResponse = client.send(httpRequest, HttpResponse.BodyHandlers.ofString());
				
				            // XML 파싱
				            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
				            DocumentBuilder builder = factory.newDocumentBuilder();
				            InputSource is = new InputSource(new StringReader(httpResponse.body()));
				            Document doc = builder.parse(is);
				
				            NodeList items = doc.getElementsByTagName("item");
				
				            // 날씨 정보를 담을 리스트에 추가
				            for (int i = 0; i < items.getLength(); i++) {
				                Node itemNode = items.item(i);
				
				                if (itemNode.getNodeType() == Node.ELEMENT_NODE) {
				                    Element element = (Element) itemNode;
				                    String fcstDate = element.getElementsByTagName("fcstDate").item(0).getTextContent();
				                    String fcstTime = element.getElementsByTagName("fcstTime").item(0).getTextContent();
				                    String category = element.getElementsByTagName("category").item(0).getTextContent();
				                    String fcstValue = element.getElementsByTagName("fcstValue").item(0).getTextContent();
				
				                    // 날씨 정보를 담을 Map 객체 생성
				                    Map<String, String> weatherData = new HashMap<>();
				                    weatherData.put("fcstDate", fcstDate);
				                    weatherData.put("fcstTime", fcstTime);
				                    weatherData.put("category", category);
				                    weatherData.put("fcstValue", fcstValue);
				
				                    weatherDataList.add(weatherData);
				                }
				            }
				
				            // 리스트를 날짜와 시간으로 오름차순 정렬
				            weatherDataList.sort((a, b) -> {
				                String dateTimeA = a.get("fcstDate") + a.get("fcstTime");
				                String dateTimeB = b.get("fcstDate") + b.get("fcstTime");
				                return dateTimeA.compareTo(dateTimeB);
				            });
				
				            // 날씨 데이터를 박스에 출력
				            for (Map<String, String> weatherData : weatherDataList) {
				                String fcstDate = weatherData.get("fcstDate");
				                String fcstTime = weatherData.get("fcstTime");
				                String category = weatherData.get("category");
				                String fcstValue = weatherData.get("fcstValue");
				
				                // 시간 포맷 설정
				                String formattedDate = fcstDate.substring(4, 6) + "월" + fcstDate.substring(6, 8) + "일";
				                String formattedTime = fcstTime.substring(0, 2) + "시";
				
				                // 데이터 출력
				                if ("SKY".equals(category)) {
				                    String weather = "";
				                    switch (fcstValue) {
				                        case "1":
				                            weather = "맑음";
				                            break;
				                        case "3":
				                            weather = "구름 많음";
				                            break;
				                        case "4":
				                            weather = "흐림";
				                            break;
				                        default:
				                            weather = "알 수 없음";
				                    }
				                    boxBuilder.append("<div class='api-box'>");
				                    boxBuilder.append("<strong>" + formattedDate + " " + formattedTime + 
				                                      "<img src='/team8_main/img/" + weather + ".png' alt='Image' width=50px height=50px onerror=\"this.onerror=null;this.src='/team8_main/img/no_img.jpg';\">" + 
				                                      "</strong>");
				                    boxBuilder.append("<p>" + "하늘 : " + weather + "</p>");
				                } else if ("T1H".equals(category)) {
				                    boxBuilder.append("<p>온도 : " + fcstValue + "°C" + "</p>");
				                } else if ("REH".equals(category)) {
				                    boxBuilder.append("<p>습도 : " + fcstValue + "%" + "</p>");
				                } else if ("POP".equals(category)) {
				                    boxBuilder.append("<p>강수확률 : " + fcstValue + "%" + "</p>");
				                } else if ("WSD".equals(category)) {
				                    boxBuilder.append("<p>풍속 : " + fcstValue + "m/s" + "</p>");
				                    boxBuilder.append("</div>");
				                }
				            }
				        }
				    } catch (Exception e) {
				        e.printStackTrace();
				        out.println("<p>날씨 데이터를 가져오는 중 오류가 발생했습니다.</p>");
				    } finally {
				        try {
				            if (rs2 != null) rs2.close();
				            if (ps2 != null) ps2.close();
				            if (conn2 != null) conn2.close();
				        } catch (SQLException e) {
				            e.printStackTrace();
				        }
				    }
				
				    // 미세먼지 예보 부분
				    try {
				        // DB 연결
				        conn2 = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
				
				        // 미세먼지 예보 데이터 가져오기
				        String airSql = "SELECT region_location FROM region_index WHERE region_id LIKE ?";
				        ps2 = conn2.prepareStatement(airSql);
				        ps2.setString(1, id);
				        rs2 = ps2.executeQuery();
				
				        if (rs2.next()) {
				            targetRegion = rs2.getString("region_location"); // 예: "제주"
				        }
				
				        // API URL 구성
				        String apiUrl = "https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMinuDustFrcstDspth?" +
				                        "serviceKey=FJpfbQGQv43vMthQ%2FA73cEDP4ydRXH4ibW9ESwieKgH04Kipl7DAAXRYlvuA%2BQwgq9B36nEjDemOSVNhpX2c5w%3D%3D" +
				                        "&returnType=xml&numOfRows=100&pageNo=1&searchDate=" + a_date +
				                        "&InformCode=PM25";
				
				        // HTTP 요청
				        HttpClient client = HttpClient.newHttpClient();
				        HttpRequest httpRequest = HttpRequest.newBuilder().uri(new URI(apiUrl)).build();
				        HttpResponse<String> httpResponse = client.send(httpRequest, HttpResponse.BodyHandlers.ofString());
				
				        // XML 파싱
				        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
				        DocumentBuilder builder = factory.newDocumentBuilder();
				        InputSource is = new InputSource(new StringReader(httpResponse.body()));
				        Document doc = builder.parse(is);
				
				        // 필요한 노드 추출
				        NodeList informDataNodes = doc.getElementsByTagName("informData");
				        NodeList informCodeNodes = doc.getElementsByTagName("informCode");
				        NodeList informGradeNodes = doc.getElementsByTagName("informGrade");
				        NodeList dataTimeNodes = doc.getElementsByTagName("dataTime");
				
				        String currentDate = "";  // 현재 날짜 추적 변수
				
				        // 첫 번째 노드부터 6개까지 처리
				        for (int i = 0; i < Math.min(6, informDataNodes.getLength()); i++) {
				            informData = informDataNodes.item(i).getTextContent();
				            informCode = informCodeNodes.item(i).getTextContent();
				            informGrade = informGradeNodes.item(i).getTextContent();
				            dataTime = dataTimeNodes.item(i).getTextContent();
				
				            // informGrade에서 특정 지역 값 추출
				            if (informGrade.contains(targetRegion)) {
				                String[] regions = informGrade.split(",");
				                for (String regionData : regions) {
				                    if (regionData.contains(targetRegion)) {
				                        targetGrade = regionData.split(":")[1].trim();
				                        break;
				                    }
				                }
				            }
				
				            // 날짜가 바뀔 때마다 새로운 api-box 박스 열기
				            if (!informData.equals(currentDate)) {
				                if (!currentDate.isEmpty()) {
				                    boxBuilder.append("</div>");  // 이전 날짜의 박스 닫기
				                }
				                currentDate = informData;  // 새로운 날짜로 갱신
				                boxBuilder.append("<div class='api-box'>");  // 새로운 api-box 시작
				                boxBuilder.append("<h3>미세먼지 <br>" + informData + "</h3>");
				            }
				
				            // 해당 날짜와 시간의 예보 정보를 출력
				            boxBuilder.append("<div class='dataTime'>");
				            boxBuilder.append("<p>종류: " + informCode + "</p>");
				            boxBuilder.append("<p>" + "예보: " + targetGrade + "</p>");
				            boxBuilder.append("<p>" + dataTime + "</p>");
				            boxBuilder.append("</div>");  // 시간별 데이터 끝
				        }
				
				        // 마지막 날짜의 api-box 박스 닫기
				        if (!currentDate.isEmpty()) {
				            boxBuilder.append("</div>");
				        }
				
				        // 최종적으로 박스 빌더에 담긴 내용을 출력
				        out.println(boxBuilder.toString());
				
				    } catch (Exception e) {
				        e.printStackTrace();
				        out.println("<p>미세먼지 예보 데이터를 가져오는 중 오류가 발생했습니다.</p>");
				    } finally {
				        try {
				            if (rs2 != null) rs2.close();
				            if (ps2 != null) ps2.close();
				            if (conn2 != null) conn2.close();
				        } catch (SQLException e) {
				            e.printStackTrace();
				        }
				    }
				
				%>
			</div> <!--api-container-->
		 </div><!--api-body-->
</body>
</html>
