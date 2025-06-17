<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter, java.sql.Connection, java.sql.DriverManager, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException, java.net.URI, java.net.http.HttpClient, java.net.http.HttpRequest, java.net.http.HttpResponse, org.w3c.dom.Document, javax.xml.parsers.DocumentBuilder, javax.xml.parsers.DocumentBuilderFactory, org.xml.sax.InputSource, java.io.StringReader, org.w3c.dom.Element, org.w3c.dom.Node" %>
<%@ page import="java.util.ArrayList, java.util.List" %>
<%@ page import="model.InformationDTO" %>
<%@ page import="org.w3c.dom.NodeList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
    // 사용자 정보를 세션에서 가져오기
    InformationDTO user = (InformationDTO) session.getAttribute("user");
%>

<%
    // URL 파라미터에서 필요한 값들을 받기
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String img = request.getParameter("img");

    // 현재 날짜를 구하고, yyyyMMdd 형식으로 포맷팅
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    String baseDate = today.format(formatter); 
    String convDate = baseDate;

    // 현재 시간 구하기 (HH00 형식)
    java.util.Date now = new java.util.Date();
    SimpleDateFormat sdf = new SimpleDateFormat("HH00");
    String baseTime = sdf.format(now);  // 시간 (예: 0400)

    // baseTime이 0500 미만일 경우, baseDate를 하루 전으로 설정
    if (Integer.parseInt(baseTime) < 500) {
        today = today.minusDays(1);  // 하루 빼기
        convDate = today.format(formatter);  // 새로운 baseDate
    }

    if (id == null) {
        out.print("필요한 데이터가 없습니다.");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Place 4 You - 상세 날씨</title>
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
        	margin-top: 5%;
        	background-color: rgba(255, 255, 255, 0.8);
        	justify-content: center;
    		display: flex;
    		flex-wrap: wrap; /* 줄 바꿈 허용 */
    		gap: 16px; /* 박스 간격 */
    		width: 70%;
    		height: 100%;
    		padding: 30px;
    		border-radius: 10px;
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
        .weather-container {
            border: 2px solid #333;
            border-radius: 10px;
            padding: 20px;
            margin: 20px auto;
            background-color: lightblue;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 50%;
        }
        .weather-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            justify-content: center;
        }
        .box {
            border: 1px solid #ccc;
            padding: 10px;
            margin: 10px;
            border-radius: 5px;
            background-color: #f9f9f9;
            width: 200px;
            text-align: center;
        }
        .box .datetime {
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .item {
            margin: 5px 0;
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

        <div class="api-body">
            <div class="api-container">
            <div class="subtitle">상세 날씨</div>
                <%
                String driverName = "org.mariadb.jdbc.Driver";
			    String dbUrl = "jdbc:mariadb://gwedu.org:3306/team8";
			    String dbUsername = "team8";
			    String dbPassword = "a1234";
			    Connection conn = null;
			    PreparedStatement ps = null;
			    ResultSet rs = null;
                String currentDateTime = baseDate + baseTime;
    // 두 번째 쿼리: 위도, 경도 가져오기
    String locationSql = "SELECT nx, ny FROM region_index r " +
                         "JOIN recommendations rc ON r.region_id = rc.region_id " +
                         "WHERE r.region_id LIKE ?";

    // DB 연결 다시 설정
    Connection conn2 = null;
    PreparedStatement ps2 = null;
    ResultSet rs2 = null;

    try {
        // DB 연결
        Class.forName(driverName);
        conn2 = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

        // 두 번째 쿼리 실행
        ps2 = conn2.prepareStatement(locationSql);
        ps2.setString(1, id);
        rs2 = ps2.executeQuery();

        if (rs2.next()) {
            String nx = rs2.getString("nx");  // 위도
            String ny = rs2.getString("ny");  // 경도

            // API URL 생성
            String serviceKey = "FJpfbQGQv43vMthQ%2FA73cEDP4ydRXH4ibW9ESwieKgH04Kipl7DAAXRYlvuA%2BQwgq9B36nEjDemOSVNhpX2c5w%3D%3D";
            String apiUrl = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?" +
                            "serviceKey=" + serviceKey +
                            "&pageNo=1&numOfRows=1000&dataType=XML" +
                            "&base_date=" + convDate +
                            "&base_time=0500" +
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

            List<String> weatherBlocks = new ArrayList<>();
            StringBuilder currentBlock = new StringBuilder();
            String lastDateTime = "";

            for (int i = 0; i < items.getLength(); i++) {
                Node itemNode = items.item(i);

                if (itemNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element element = (Element) itemNode;
                    String fcstDate = element.getElementsByTagName("fcstDate").item(0).getTextContent();
                    String fcstTime = element.getElementsByTagName("fcstTime").item(0).getTextContent();
                    String category = element.getElementsByTagName("category").item(0).getTextContent();
                    String fcstValue = element.getElementsByTagName("fcstValue").item(0).getTextContent();
                    String forecastDateTime = fcstDate + fcstTime;

                    if (forecastDateTime.compareTo(currentDateTime) >= 0) {
                        if (!forecastDateTime.equals(lastDateTime) && currentBlock.length() > 0) {
                            weatherBlocks.add(currentBlock.toString());
                            currentBlock = new StringBuilder();
                        }

                        if (!forecastDateTime.equals(lastDateTime)) {
                            String formattedDate = fcstDate.substring(0, 4) + "년 " + fcstDate.substring(4, 6) + "월 " + fcstDate.substring(6, 8) + "일";
                            String formattedTime = fcstTime.substring(0, 2) + "시";
                            currentBlock.append("<div class='datetime'>" + formattedDate + " " + formattedTime + "</div>");
                            lastDateTime = forecastDateTime;
                        }

                        if ("TMP".equals(category)) {
                            currentBlock.append("<div class='item'><strong>온도:</strong> ").append(fcstValue).append(" °C</div>");
                        } else if ("REH".equals(category)) {
                            currentBlock.append("<div class='item'><strong>습도:</strong> ").append(fcstValue).append(" %</div>");
                        } else if ("SKY".equals(category)) {
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
                            currentBlock.append("<img src='/team8_main/img/" + weather + ".png' alt='Image' width=50px height=50px onerror=\"this.onerror=null;this.src='/team8_main/img/no_img.jpg';\">" + 
                                    "</strong>");
                        } else if ("POP".equals(category)) {
                            currentBlock.append("<div class='item'><strong>강수 확률:</strong> ").append(fcstValue).append(" %</div>");
                        } else if ("WSD".equals(category)) {
                            currentBlock.append("<div class='item'><strong>풍속:</strong> ").append(fcstValue).append(" m/s</div>");
                        }
                    }
                }
            }

            if (currentBlock.length() > 0) {
                weatherBlocks.add(currentBlock.toString());
            }

            for (String block : weatherBlocks) {
                out.println("<div class='box'>" + block + "</div>");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>데이터를 가져오는 중 오류가 발생했습니다.</p>");
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
            </div>
    </div>
</body>
</html>
