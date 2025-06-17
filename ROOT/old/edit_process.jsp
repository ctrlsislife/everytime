<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="model.InformationDTO" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String username = ((InformationDTO) session.getAttribute("user")).getUsername();
    String passwordConfirm = request.getParameter("passwordConfirm");

    // 비밀번호 확인
    if (!password.equals(passwordConfirm)) {
        out.print("<script>alert('비밀번호가 일치하지 않습니다.'); window.location.href='editProfile.jsp';</script>");
        return;
    }

    String driverName = "org.mariadb.jdbc.Driver";
    String dbUrl = "jdbc:mariadb://gwedu.org:3306/team8";
    String dbUsername = "team8";
    String dbPassword = "a1234";
    Connection conn = null;
    PreparedStatement ps = null;
    
    // SQL 쿼리
    String sql;
    if (email.isEmpty()) {
        // 이메일이 비어있으면 비밀번호만 업데이트
        sql = "UPDATE user_index SET passwd = ? WHERE username = ?";
    } else {
        // 이메일과 비밀번호 모두 업데이트
        sql = "UPDATE user_index SET email = ?, passwd = ? WHERE username = ?";
    }

    try {
        Class.forName(driverName);
        conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
        
        ps = conn.prepareStatement(sql);
        
        if (email.isEmpty()) {
            // 이메일이 비어 있으면 비밀번호만 설정
            ps.setString(1, password);
            ps.setString(2, username);
        } else {
            // 이메일과 비밀번호 모두 설정
            ps.setString(1, email);
            ps.setString(2, password);
            ps.setString(3, username);
        }

        // 쿼리 실행
        int result = ps.executeUpdate();

        if (result > 0) {
            InformationDTO user = (InformationDTO) session.getAttribute("user");
            // 세션에 저장된 정보도 갱신
            if (!email.isEmpty()) {
                user.setEmail(email);
            }
            user.setPassword(password);
            session.setAttribute("user", user);
            
            out.print("<script>alert('회원정보가 수정되었습니다. 다시 로그인 해주세요.'); window.location.href='logout.jsp';</script>");
        } else {
            out.print("<script>alert('회원정보 수정에 실패했습니다.'); window.location.href='editProfile.jsp';</script>");
        }
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        out.print("<script>alert('오류가 발생했습니다.'); window.location.href='editProfile.jsp';</script>");
    } finally {
        try {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
