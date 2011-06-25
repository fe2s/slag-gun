<%@ page import="java.net.InetAddress" %>
<html>
<head><title>Start page</title></head>
<body>
<%
    String host = "127.0.0.1";
	try{
	    InetAddress addr = InetAddress.getLocalHost();
        host = addr.getHostAddress();
	}catch(RuntimeException e){
	    e.printStackTrace();
	}
%>
<a href="Launcher.swf?host=<%=host%>">Run</a>
</body>
</html> 