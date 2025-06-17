<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.net.*, java.io.*, org.json.JSONObject" %>
<%
    request.setCharacterEncoding("UTF-8");
    String turnstileResponse = request.getParameter("cf-turnstile-response");
    String secretKey = "0x4AAAAAABC9tyyNLHJGBLVHf0FNUl8kz7w";
    String urlStr = "https://challenges.cloudflare.com/turnstile/v0/siteverify";

    URI uri = new URI(urlStr);
    URL url = uri.toURL();

    String parameters = "secret=" + secretKey + "&response=" + turnstileResponse;

    HttpURLConnection con = (HttpURLConnection) url.openConnection();
    con.setRequestMethod("POST");
    con.setDoOutput(true);
    con.getOutputStream().write(parameters.getBytes("UTF-8"));

    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
    String inputLine;
    StringBuffer responseBuffer = new StringBuffer();

    while ((inputLine = in.readLine()) != null) {
        responseBuffer.append(inputLine);
    }
    in.close();

    JSONObject jsonResponse = new JSONObject(responseBuffer.toString());
    boolean success = jsonResponse.getBoolean("success");

    if (success) {
        session.setAttribute("turnstileValidated", true);
        // 원래 가려던 주소가 있으면 그리로 이동, 없으면 index.jsp
        String redirectURL = (String)session.getAttribute("redirectAfterCaptcha");
        if (redirectURL == null || redirectURL.equals("")) {
            redirectURL = "index.jsp";
        }
        // 사용 후 삭제!
        session.removeAttribute("redirectAfterCaptcha");
        response.sendRedirect(redirectURL);
    } else {
        out.println("<h3>Turnstile 인증에 실패했습니다. 다시 시도하세요.</h3>");
        out.println("<a href='turnstile.jsp'>돌아가기</a>");
    }
%>

