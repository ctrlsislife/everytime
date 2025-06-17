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
    <title>PLACE 4 YOU - 검색 결과</title>
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
    		opacity: 0.7;
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
        .search-container {
            text-align: center;
            background-color: rgba(255, 255, 255, 0.3);
            padding: 50px;
            border-radius: 10px;
            width: 65%;
            box-sizing: border-box;
            position: absolute;
            top: 10%;
            left: 50%;
            transform: translate(-50%, 0);
            min-width: 500px;
        }
        .subtitle {
            font-size: 2.5em;
            color: #333;
            margin-bottom: 20px;
        }
        .results-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center; /* 가로로 정렬 */
            gap: 30px;
        }
        .result-item {
            width: calc(25% - 20px);
            min-width: 200px;
            max-width: 300px;
            background-color: #FFF6DF;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
        }
        .result-item img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 5px;
        }
        .result-item:hover {
           background: #627A82;
           opacity: 1;
           -webkit-transition: .3s ease-in-out;
           transition: .3s ease-in-out;
        }
        .result-item a {
            text-decoration: none;
            color: black;
        }
        .result-item a:visited {
            color: black;
        }
        .result-item a:hover {
            color: white;
            opacity: 1;
           -webkit-transition: .3s ease-in-out;
           transition: .3s ease-in-out;
        }
        .result-item a:active {
            color: black;
        }
        .error-message {
            color: red;
            font-size: 1.2em;
            margin-top: 20px;
            text-align: center;
        }
        }
        .return-button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #d9534f;
            color: #fff;
            border-radius: 5px;
            text-decoration: none;
            margin-top: 20px;
        }
        .return-button:hover {
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
            <% if (user == null) { %>
                <a href="signup.jsp">Signup</a>
                <a href="login.jsp">Login</a>
            <% } else { %>
                <a href="mypage.jsp"><span><%= user.getName() %>님</span></a>
                <a href="logout.jsp">Logout</a>
            <% } %>
        </div><br><br><br><!--nav-links-->
    </div> <!--top-bar-->
    <div class="search-container">
		<div class="subtitle"><b>검색 결과</b></div>
		
		<%
			String regionQuery = request.getParameter("city_name");
            String hobbyQuery = request.getParameter("hobby_name");

            String driverName = "org.mariadb.jdbc.Driver";
            String dbUrl = "jdbc:mariadb://gwedu.org:3306/team8";
            String dbUsername = "team8";
            String dbPassword = "a1234";
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

                String sql;
                if (regionQuery != null && !regionQuery.trim().isEmpty() && hobbyQuery != null && !hobbyQuery.trim().isEmpty()) {
                    sql = "SELECT r.* FROM recommendations r " +
                          "JOIN region_index rg ON r.region_id = rg.region_id " +
                          "JOIN category c ON r.category_id = c.category_id " +
                          "WHERE rg.region_name LIKE ? AND c.category_name LIKE ?";
                    stmt = conn.prepareStatement(sql);
                    stmt.setString(1, "%" + regionQuery.trim() + "%");
                    stmt.setString(2, "%" + hobbyQuery.trim() + "%");
                } else if (regionQuery != null && !regionQuery.trim().isEmpty()) {
                    sql = "SELECT r.* FROM recommendations r " +
                          "JOIN region_index rg ON r.region_id = rg.region_id " +
                          "WHERE rg.region_name LIKE ?";
                    stmt = conn.prepareStatement(sql);
                    stmt.setString(1, "%" + regionQuery.trim() + "%");
                } else if (hobbyQuery != null && !hobbyQuery.trim().isEmpty()) {
                    sql = "SELECT r.* FROM recommendations r " +
                          "JOIN category c ON r.category_id = c.category_id " +
                          "WHERE c.category_name LIKE ?";
                    stmt = conn.prepareStatement(sql);
                    stmt.setString(1, "%" + hobbyQuery.trim() + "%");
                } else {
                    out.println("<div class='error-message'>검색어를 입력해주세요.</div>");
                    return;
                }

                rs = stmt.executeQuery();

                if (!rs.isBeforeFirst()) {
                    out.println("<div class='error-message'>검색 결과가 없습니다.</div>");
                    out.println("<br>" + "<a href='index.jsp' class='return-button'>돌아가기</a>");
                } else {
                    out.println("<div class='results-container'>");
                    while (rs.next()) {
                        String r_img = rs.getString("img_url");
                        String r_name = rs.getString("a_name");
                        String r_id = rs.getString("region_id");
                        String rec = rs.getString("recommendation_id");
                        out.println("<div class='result-item'>");
                        out.println("<a href='search_detail.jsp?name=" + r_name + "&id=" + r_id + "&rec=" + rec +"&img=" + r_img + "'>");
                        out.println("<img src='" + r_img + "' alt='Image' onerror=\"this.onerror=null;this.src='/team8_main/img/no_img.jpg';\">");
                        out.println("<br><b>" + r_name + "</b><br></a>");
                        out.println("</div>");
                    }
                    out.println("</div>");
                }
            } catch (SQLException e) {
                out.println("<div class='error-message'>검색 중 오류가 발생했습니다.</div>");
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
        %>
	</div><!-- search-container -->
</body>
</html>
