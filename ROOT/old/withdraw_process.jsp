<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="model.InformationDTO" %>
<%
    String password = request.getParameter("password");  // 사용자가 입력한 비밀번호
    String username = ((InformationDTO) session.getAttribute("user")).getUsername();  // 세션에서 사용자 아이디 가져오기

    // DB 연결 정보
    String driverName = "org.mariadb.jdbc.Driver";
    String dbUrl = "jdbc:mariadb://gwedu.org:3306/team8";
    String dbUsername = "team8";
    String dbPassword = "a1234";
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        // DB 드라이버 로드 및 연결
        Class.forName(driverName);
        conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

        // 비밀번호 확인 쿼리 준비
        String pw_confirm = "SELECT passwd FROM user_index WHERE username = ?";
        ps = conn.prepareStatement(pw_confirm);
        ps.setString(1, username);
        rs = ps.executeQuery();

        // 비밀번호가 일치하는지 확인
        if (rs.next()) {
            String storedPassword = rs.getString("passwd");  // DB에서 가져온 비밀번호

            // 비밀번호 비교
            if (password.equals(storedPassword)) {
                // 비밀번호가 일치하면 삭제 쿼리 실행
                String sql = "DELETE FROM user_index WHERE username = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, username);

                int count = ps.executeUpdate();  // 쿼리 실행

                if (count == 1) {
                    response.sendRedirect("withdraw_complete.jsp");
                } else {
                    out.print("<script>alert('회원 탈퇴 실패!'); window.location.href='withdraw.jsp';</script>");
                }
            } else {
                // 비밀번호가 일치하지 않으면 실패 메시지 출력
                out.print("<script>alert('비밀번호가 일치하지 않습니다.'); window.location.href='withdraw.jsp';</script>");
            }
        } else {
            out.print("<script>alert('해당 사용자가 존재하지 않습니다.'); window.location.href='withdraw.jsp';</script>");
        }
    } catch (ClassNotFoundException e) {
        out.print("DB 드라이버 로드 실패: " + e.getMessage());
    } catch (SQLException e) {
        out.print("SQL 오류: " + e.getMessage());
    } finally {
        // 자원 정리
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
