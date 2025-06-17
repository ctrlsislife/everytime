<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Cloudflare Turnstile 예제</title>
    <!-- Cloudflare Turnstile 라이브러리 -->
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
    <style>
        body {
            height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            background: #f7f7f7;
        }
        .center-box {
            background: #fff;
            padding: 48px 40px 40px 40px;
            border-radius: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.10);
            display: flex;
            flex-direction: column;
            align-items: center;
            min-width: 380px;
        }
        .logo-wrap {
            width: 100%;
            display: flex;
            justify-content: center; /* 로고 가로 중앙정렬 */
            align-items: center;
        }
        .logo {
            width: 300px;
            height: auto;
            margin-bottom: 32px;
            display: block;
        }
        form {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .cf-turnstile {
            margin-bottom: 24px;
        }
        button[type="submit"] {
            padding: 14px 32px;
            border: none;
            border-radius: 5px;
            background: #f44336;
            color: #fff;
            font-size: 1.10rem;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s;
        }
        button[type="submit"]:hover {
        	font-size: 1.20rem;
        }
    </style>
</head>
<body>
    <div class="center-box">
        <div class="logo-wrap">
            <img src="img/logo.png" alt="로고" class="logo">
        </div>
        <form action="turnstile_process.jsp" method="POST">
            <!-- Cloudflare Turnstile 위젯 -->
            <div class="cf-turnstile" data-sitekey="0x4AAAAAABC9t-Pt2eIkhwGc"></div>
            <button type="submit">제출</button>
        </form>
    </div>
</body>
</html>
