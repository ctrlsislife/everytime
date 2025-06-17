<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String msg = "NULL";  // 기본 메시지 설정
    String successSignup = "signup.jsp";  // 기본 성공 페이지

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String u_name = request.getParameter("name");
        String u_username = request.getParameter("username");
        String u_passwd = request.getParameter("password");
        String u_email = request.getParameter("email");
        
        // 필수 입력 값 체크
        if (u_name == null || u_name.isEmpty()) {
            msg = "이름을 입력해 주세요.";
        } else if (u_username == null || u_username.isEmpty()) {
            msg = "아이디를 입력해 주세요.";
        } else if (u_passwd == null || u_passwd.isEmpty()) {
            msg = "비밀번호를 입력해 주세요.";
        } else if (u_email == null || u_email.isEmpty()) {
            msg = "이메일을 입력해 주세요.";
        } else {
            String u_passwdConfirm = request.getParameter("passwordConfirm");
            if (!u_passwd.equals(u_passwdConfirm)) {
                msg = "비밀번호가 일치하지 않습니다.";
                successSignup = "pw_verify_fail.jsp?name=" + u_name + "username=" + u_username + "&email=" + u_email;
            } else {
                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;

                try {
                    // JDBC 연결
                    Class.forName("org.mariadb.jdbc.Driver");
                    String url = "jdbc:mariadb://gwedu.org:3306/team8";
                    String username = "team8";
                    String password = "a1234";

                    conn = DriverManager.getConnection(url, username, password);

                    // 아이디 중복 체크
                    String checkSql = "SELECT 1 FROM user_index WHERE username = ?";
                    stmt = conn.prepareStatement(checkSql);
                    stmt.setString(1, u_username);
                    rs = stmt.executeQuery();

                    if (rs.next()) {
                        // 아이디가 중복될 경우
                        msg = "이미 사용 중인 아이디입니다.";
                        successSignup = "duplicate_id.jsp?name=" + u_name + "&email=" + u_email;  // name과 email을 쿼리 파라미터로 전달
                    } else {
                        // 아이디 중복이 없으면 회원가입 처리
                        String sql = "INSERT INTO user_index (u_name, username, passwd, email) VALUES (?, ?, ?, ?)";
                        stmt = conn.prepareStatement(sql);
                        stmt.setString(1, u_name);
                        stmt.setString(2, u_username);
                        stmt.setString(3, u_passwd);
                        stmt.setString(4, u_email);

                        int result = stmt.executeUpdate();
                        
                        if (result > 0) {
                            msg = "회원가입 성공했습니다.";
                            successSignup = "login.jsp";  // 성공 후 리디렉션 URL 변경
                        } else {
                            msg = "회원가입 실패했습니다.";
                        }
                    }
                    
                } catch (SQLException e) {
                    msg = "오류가 발생했습니다: " + e.getMessage();
                    e.printStackTrace();
                } catch (ClassNotFoundException e) {
                    msg = "JDBC 드라이버를 찾을 수 없습니다: " + e.getMessage();
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (stmt != null) stmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
%>

<script type="text/javascript">
    // 메시지 출력
    alert("<%= msg %>");
    // 성공 시 리디렉션
    location.href = "<%= successSignup %>";
</script>
