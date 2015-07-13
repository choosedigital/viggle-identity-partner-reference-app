<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="org.json.*,javax.crypto.Mac,javax.crypto.spec.SecretKeySpec,java.security.SignatureException,java.io.*,java.net.*,javax.net.ssl.*,java.util.*,java.text.*"%>

<%@ include file="base64-util.jsp" %>

<%
	String proxyId = request.getParameter("proxyId");

	//get env variables
	String endpoint = application.getInitParameter("sapiEndpoint") + "/user";
	String accessKey = application.getInitParameter("accessKey");
	String secret = application.getInitParameter("secret");

	//prepare endpoint URL
	URL obj = new URL(endpoint + "/" + proxyId);
	HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();

	//add method and basic request headers
	con.setRequestMethod("GET");
	con.setRequestProperty("Accept", "application/json");

	//add auth headers after sha1 calculation on date
	TimeZone tz = TimeZone.getTimeZone("UTC");
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); //iso 8601 format utc  example) 2015-07-05T22:16:18Z
	df.setTimeZone(tz);
	String nowAsISO = df.format(new Date());

	String authorization;
	try {
		// get an hmac_sha1 key from the raw key bytes
		SecretKeySpec signingKey = new SecretKeySpec(secret.getBytes(),
				"HmacSHA1");

		// get an hmac_sha1 Mac instance and initialize with the signing key
		Mac mac = Mac.getInstance("HmacSHA1");
		mac.init(signingKey);

		// compute the hmac on input data bytes
		byte[] rawHmac = mac.doFinal(nowAsISO.getBytes());

		// base64-encode the hmac
		authorization = new String(Base64.encodeBytes(rawHmac));
	} catch (Exception e) {
		throw new SignatureException("Failed to generate HMAC : "
				+ e.getMessage());
	}
	con.setRequestProperty("x-access-key", accessKey);
	con.setRequestProperty("x-authorization-date", nowAsISO);
	con.setRequestProperty("x-authorization", authorization);

	// Send get request
	int responseCode = con.getResponseCode();

	BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
	String inputLine;
	StringBuffer b = new StringBuffer();

	while ((inputLine = in.readLine()) != null) {
		b.append(inputLine);
	}
	in.close();

	String resultText = b.toString();
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>SAPI - Get User</title>
</head>
<body>

	<h1>SAPI - Get User</h1>
	
	<p>
		proxyId: <%=proxyId %>
	</p>
	
	<p>
		<%= resultText %>
	</p>


</body>
</html>