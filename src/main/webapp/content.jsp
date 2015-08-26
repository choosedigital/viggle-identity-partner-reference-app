<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Content</title>
	<link rel="stylesheet" href="style.css" type="text/css" media="screen">
</head>
<body>

<div id="pg-container">
	
	<%@ include file="_header.jsp" %>

	<div class="row">
		<div class="small-10 small-centered medium-8 large-6 columns">

			<h1>Featured Video</h1>

			<p>Connect your Viggle account to get points after you've watched our video.</p>
		
			<a class="btn btn--viggle" style="float:right;" href="<%=application.getInitParameter("tokenEndpoint")%>?accessKey=<%=application.getInitParameter("accessKey")%>&state=someUsefulKeyNeededByYourApp">Connect Viggle</a>

			<img class="img--fluid" src="https://placeholdit.imgix.net/~text?txtsize=96&bg=000000&txtclr=555555&txt=Video&w=640&h=480&txttrack=0" alt="">

			<br><br><br>

		</div>
	</div>

</div>

<footer>
	<small><code>
	Current Time: <%  out.println(new java.util.Date().toString()); %>
	</code></small>
</footer>

</body>
</html>