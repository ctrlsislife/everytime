<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, jakarta.servlet.*, jakarta.servlet.http.*" %>
<%@ page import="model.InformationDTO" %>
<%
    // 세션에서 로그인된 사용자 정보 가져오기
    InformationDTO user = (InformationDTO) session.getAttribute("user");
    
    // 사용자가 로그인되어 있지 않으면 로그인 페이지로 리다이렉션
    if (user == null) {
        response.sendRedirect("login.jsp"); // 로그인 페이지로 리다이렉션
        return; // 더 이상 코드를 실행하지 않음
    }

    // 세션에서 로그인된 사용자의 이름 가져오기
    String username = user.getUsername();  // 실제 로그인한 사용자로 설정
    String recommendationId = request.getParameter("id");  // 추천 아이템 ID

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        // DB 연결
        String dbUrl = "jdbc:mariadb://gwedu.org:3306/team8";
        String dbUsername = "team8";
        String dbPassword = "a1234";
        conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

        // 사용자가 해당 아이템을 이미 좋아요했는지 확인
        String checkQuery = "SELECT * FROM wishlist WHERE username = ? AND recommendation_id = ?";
        ps = conn.prepareStatement(checkQuery);
        ps.setString(1, username);
        ps.setString(2, recommendationId);
        rs = ps.executeQuery();

        if (rs.next()) {
            // 이미 좋아요한 경우, 삭제
            String deleteQuery = "DELETE FROM wishlist WHERE username = ? AND recommendation_id = ?";
            ps = conn.prepareStatement(deleteQuery);
            ps.setString(1, username);
            ps.setString(2, recommendationId);
            ps.executeUpdate();
        } else {
            // 좋아요하지 않은 경우, 추가
            String insertQuery = "INSERT INTO wishlist (username, recommendation_id) VALUES (?, ?)";
            ps = conn.prepareStatement(insertQuery);
            ps.setString(1, username);
            ps.setString(2, recommendationId);
            ps.executeUpdate();
        }

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<div class='error-message'>SQL 오류가 발생했습니다.</div>");
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 처리 후 원래 페이지로 리다이렉트
    String referer = request.getHeader("Referer");
    if (referer != null) {
        response.sendRedirect(referer);  // 원래 페이지로 리다이렉트
    } else {
        response.sendRedirect("index.jsp");  // 기본 페이지로 리다이렉트
    }
%>
