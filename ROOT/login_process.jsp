<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.Base64" %>
<%@ page import="model.InformationDTO" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String msg = "";
    String nextPage = "login.jsp";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // 패스워드 암호화
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(password.getBytes("UTF-8"));
            String encryptedPassword = Base64.getEncoder().encodeToString(md.digest());

            Class.forName("org.mariadb.jdbc.Driver");
            String url = "jdbc:mariadb://127.0.0.1:7778/Sw_Engineering";
            String dbUser = "root";
            String dbPassword = "a1234";
            conn = DriverManager.getConnection(url, dbUser, dbPassword);

            // ★ admin 컬럼 포함하여 전체 컬럼 select!
            String sql = "SELECT * FROM user_index WHERE username = ? AND passwd = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, encryptedPassword);

            rs = pstmt.executeQuery();
            if (rs.next()) {
                // 로그인 성공, user 객체 생성 및 세션 저장
                InformationDTO user = new InformationDTO();
                user.setUserId(rs.getInt("id"));
                user.setName(rs.getString("u_name"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("passwd"));
                user.setEmail(rs.getString("email"));
                user.setSignin(rs.getString("created_at"));
                user.setUpdate(rs.getString("updated_at"));
                user.setAdmin(rs.getInt("admin"));   // << ★ 반드시 추가!

                session.setAttribute("user", user);

                msg = "로그인 성공했습니다.";
                nextPage = "index.jsp"; // 혹은 메인 페이지 등
            } else {
                msg = "아이디 또는 비밀번호가 올바르지 않습니다.";
            }
        } catch(Exception e) {
            e.printStackTrace();
            msg = "로그인 과정에서 오류가 발생했습니다.";
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception ex) {}
            try { if (pstmt != null) pstmt.close(); } catch(Exception ex) {}
            try { if (conn != null) conn.close(); } catch(Exception ex) {}
        }
    }
%>
<script type="text/javascript">
    alert("<%= msg %>");
    location.href = "<%= nextPage %>";
</script>
