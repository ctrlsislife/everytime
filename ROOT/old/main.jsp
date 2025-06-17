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
    <title>순천대생</title>
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
		.search-container {
          	text-align: center;
           	background-color: #FDF8F4;
           	opacity: 0.8;
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
        .search-label {
            font-size: 2em;
            color: black;
            margin-top: 60px;
            
        }
        .search-button {
            padding: 12px 20px;
            background-color: #333;
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 1.2em;
            cursor: pointer;
            width: 30%;
            max-width: 100%;
        }
        .search-button:hover {
            background-color: #555;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 80%;
            max-width: 100%;
            margin: 0 auto;
        }

        .form-group label {
            font-size: 1.3em;
            color: black;
            display: flex;
            justify-content: space-between; /* 양쪽 끝에 맞추기 */
            width: 100%;
            margin-bottom: 10px;
        }
        
        select {
            font-size: 1.2em;
            padding: 12px 20px;
            width: 100%;
            border-radius: 8px;
            border: 2px solid #ccc;
            margin-top: 10px;
            box-sizing: border-box;
            text-align-last: left;
            cursor: pointer;
        }

        select:focus {
            border-color: #333;
            text-align: 
        }
        .random-link {
        	text-align: center;
            margin-top: 10px; /* 위아래 간격 좁히기 */
            font-size: 1em;
            
        }
        .random-link a {
            color: #333;
            text-decoration: none;
        }
        .random-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
	<div class="background"></div>
    <div class="top-bar">
        <div class="title"><a href="main.jsp">SCNU EVERYDAY</a></div>
        <div class="nav-links">
            <a href="howtouse.jsp">How to use</a>
            <% if (user == null) { %>
                <a href="signup.jsp">Signup</a>
                <a href="login.jsp">Login</a>
            <% } else { %>
                <a href="mypage.jsp"><span><%= user.getName() %>님</span></a>
                <a href="logout.jsp">Logout</a>
            <% } %>
        </div><br><br><br><!-- nav-links -->
    </div><!-- top-bar -->
    <div class="search-container">
    	<form action="search.jsp" method="GET" onsubmit="return validateForm()">
    		<p class="search-label"><b>숨은 명소를 찾아보세요!</b></p><br>
            <div class="form-group">
                <label for="region"><b>지역 선택:</b></label>
                <select name="region_name" id="region" onchange="updateCities()">
                    <option value=""> 지역을 선택하세요 </option>
                    <option value="서울">서울</option>
                    <option value="경기">경기도</option>
                    <option value="강원">강원도</option>
                    <option value="충청">충청도</option>
                    <option value="전라">전라도</option>
                    <option value="경남">경상남도</option>
                    <option value="경북">경상북도</option>
                    <option value="제주">제주도</option>
                </select>
            </div><br><!-- form-group -->
            <div class="form-group">
                <label for="city"><b>시/구 선택:</b></label>
                <select name="city_name" id="city">
                    <option value=""> 시/구를 선택하세요. </option>
                </select>
            </div><br><!-- form-group -->
            <div class="form-group">
                <label for="hobby"><b>취미 선택:</b></label>
                <select name="hobby_name" id="hobby">
                    <option value=""> 취미를 선택하세요. </option>
                    <option value="맛집">맛집탐방</option>
                    <option value="시장">시장</option>
                    <option value="카페 / 베이커리">디저트</option>
                    <option value="스포츠">스포츠</option>
                    <option value="엔터테인먼트 / 체험">엔터테인먼트 / 체험</option>
                    <option value="역사 / 문화 / 예술">역사 / 문화 / 예술</option>
                    <option value="자연 / 힐링">자연 / 힐링</option>
                </select>
            </div><br><!-- form-group -->
            <button type="submit" class="search-button">탐색 시작</button>
        </form>
        <div class="random-link">
        <p>무엇을 할지 고민이신가요? <a href="random_suggestion.jsp">랜덤 찾기</a></p>
        </div>
    </div><!-- search-container -->
    <script>
        // 지역별 시 목록
        const cities = {
            '서울': ['강남구', '종로구', '서초구', '송파구', '마포구'],
            '경기': ['수원', '고양', '성남', '안양', '용인', '부천', '인천'],
            '강원': ['춘천', '강릉', '원주', '속초', '동해'],
            '충청': ['대전', '세종', '청주', '천안', '공주'],
            '전라': ['광주', '전주', '순천', '여수', '목포'],
            '경남': ['부산', '창원', '김해', '양산', '진주'],
            '경북': ['대구', '울산', '경산', '포항', '김천'],
            '제주': ['제주', '서귀포']
        };

        // 지역이 선택되면 해당 시 목록 업데이트
        function updateCities() {
            const region = document.getElementById("region").value;
            const citySelect = document.getElementById("city");

            // 시 선택 박스 초기화
            citySelect.innerHTML = '<option value=""> 시/구를 선택하세요 </option>';

            // 지역이 선택되지 않으면 종료
            if (!region) return;

            // 해당 지역에 맞는 시 목록 추가
            const selectedCities = cities[region] || [];
            selectedCities.forEach(function(city) {
                const option = document.createElement("option");
                option.value = city;
                option.textContent = city;
                citySelect.appendChild(option);
            });
        }
        
        function validateForm() {
            const region = document.getElementById("region").value;
            const city = document.getElementById("city").value;
            const hobby = document.getElementById("hobby").value;

            if (!region && !city && !hobby) {
                alert("지역 또는 취미를 하나 이상 선택해주세요!");
                return false;
            }else if (region && !city && hobby) {
                alert("시/구를 선택해주세요! 지역 검색을 원하지 않으시면 지역을 빈칸으로 설정하십시오.");
                return false; // 폼 제출 방지
            } else if (region && !city && !hobby) {
            	alert("지역을 검색하시려면 시/구 까지 선택해주세요!");
                return false;
            }
            return true; // 폼 제출 진행
        }
    </script>
</body>
</html>
