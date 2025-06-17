<%@ page import="model.InformationDAO" %>
<%@ page import="model.InformationDTO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Retrieve parameters from the request
    String login_id = request.getParameter("login_id");
    String login_pw = request.getParameter("login_pw");

    // Default messages and redirection
    String msg = "정보가 맞지 않습니다.";
    String successLogin = "login.jsp";

    try {
        if (login_id != null && login_pw != null && !login_id.trim().isEmpty() && !login_pw.trim().isEmpty()) {
            // Fetch user information
            InformationDTO member_info = new InformationDAO().getUserInfo(login_id);

            // Validate credentials
            if (member_info != null && member_info.getPassword().equals(login_pw)) {
                msg = "로그인 성공했습니다.";
                successLogin = "index.jsp";
                session.setAttribute("user", member_info); // Save user info to session
            }
        } else {
            msg = "아이디와 비밀번호를 모두 입력해주세요.";
        }
    } catch (Exception e) {
        // Log exception for debugging
        e.printStackTrace();
        msg = "시스템 오류가 발생했습니다. 다시 시도해주세요.";
    }
%>
<script type="text/javascript">
    // Display alert message and redirect
    alert("<%=msg%>");
    location.href = "<%=successLogin%>";
</script>
