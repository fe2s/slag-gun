<%@ page import="java.net.InetAddress" %>
<%@ page import="java.util.Date" %>
<html>
<head><title>Start page</title></head>
<body>
<%
    String host = null;


     response.setHeader("Expires", "Tue, 03 Jul 2001 06:00:00 GMT");
     response.setHeader("Last-Modified", new Date().toString());
     response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0, post-check=0, pre-check=0");
     response.setHeader("Pragma", "no-cache");

    try{
        host = request.getRemoteHost();
    }catch(RuntimeException e){
        e.printStackTrace();
    }

    if(host == null){
        try{
            InetAddress addr = InetAddress.getLocalHost();
            host = addr.getHostAddress();
        }catch(RuntimeException e){
            e.printStackTrace();
        }
    }

    if(host == null){
        host = "127.0.0.1";
    }
%>
<a href="Launcher.swf?host=<%=host%>&autojoin=true&nocache=<%=Math.random()%>">Run</a>
</body>
</html> 