<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Home</title>
	<link rel="stylesheet" href="style.css" type="text/css" media="screen">
</head>
<body>

<div id="pg-container">
	
	<%@ include file="_header.jsp" %>

	<div class="row">
		<div class="small-10 small-centered medium-8 columns">

			<h1>Partner Homepage</h1>

			<p>A Viggle Partner can offer their members Viggle Points as an incentive for any kind of engagement. Existing Viggle Members can sign into their account or easily create a new one. </p>
			<h2>Simple example: </h2>
			<p><a class="btn" href="content.jsp">Watch Our Movie for 25 Viggle Points! ⟶</a></p>

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