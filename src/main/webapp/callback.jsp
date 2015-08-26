<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.*,javax.crypto.Mac,javax.crypto.spec.SecretKeySpec,java.security.SignatureException,java.io.*,java.net.*,javax.net.ssl.*,java.util.*,java.text.*" %>

<%@ include file="base64-util.jsp" %>

<%
	//get URL param named 'token'
	String token = request.getParameter("token");

	String state = request.getParameter("state");
	
	//get env variables
	String endpoint = application.getInitParameter("proxyIdEndpoint");
	String accessKey = application.getInitParameter("accessKey");
	String secret = application.getInitParameter("secret");
	
	//prepare endpoint URL
	URL obj = new URL(endpoint);
	HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();

	//add method and basic request headers
	con.setRequestMethod("POST");
	con.setRequestProperty("Content-Type", "application/json");
	con.setRequestProperty("Accept", "application/json");
	
	//add auth headers after sha1 calculation on date
	TimeZone tz = TimeZone.getTimeZone("UTC");
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); //iso 8601 format utc  example) 2015-07-05T22:16:18Z
    df.setTimeZone(tz);
    String nowAsISO = df.format(new Date());
    
    String authorization;
    try {
        // get an hmac_sha1 key from the raw key bytes
        SecretKeySpec signingKey = new SecretKeySpec(secret.getBytes(), "HmacSHA1");

        // get an hmac_sha1 Mac instance and initialize with the signing key
        Mac mac = Mac.getInstance("HmacSHA1");
        mac.init(signingKey);

        // compute the hmac on input data bytes
        byte[] rawHmac = mac.doFinal(nowAsISO.getBytes());

        // base64-encode the hmac
        authorization = new String(Base64.encodeBytes(rawHmac));
    } catch (Exception e) {
        throw new SignatureException("Failed to generate HMAC : " + e.getMessage());
    }
	con.setRequestProperty("x-access-key", accessKey);
	con.setRequestProperty("x-authorization-date", nowAsISO);
	con.setRequestProperty("x-authorization", authorization);

	JSONObject postBody = new JSONObject();
	postBody.put("token", token);

	// Send post request
	con.setDoOutput(true);
	DataOutputStream wr = new DataOutputStream(con.getOutputStream());
	wr.writeBytes(postBody.toString());
	wr.flush();
	wr.close();

	int responseCode = con.getResponseCode();
	String inputLine;
	StringBuffer b = new StringBuffer();
	BufferedReader in = null;
	
	InputStream is = null;
	if (responseCode == 500) {
		is = con.getErrorStream();
		in = new BufferedReader(new InputStreamReader(is));
	} else {
		in = new BufferedReader(new InputStreamReader(con.getInputStream()));
	}
	while ((inputLine = in.readLine()) != null) {
		b.append(inputLine);
	}
	in.close();
	
	String resultText = b.toString();
	
	//parse proxyId from json string
	JSONObject json = new JSONObject(resultText);
	String proxyId = json.getString("proxyId");
%>

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
		<div class="small-10 small-centered medium-8 columns">

			<h1>Your Viggle Account is Connected!</h1>

			<div class="callout">
		
				<h3>What just happened:</h3>
				<p>The Viggle member has authorized this Viggle Partner to use the Viggle API to get member information and deposit points. But isn't allowed to withdraw any points.</p>
	
				<ul>
					<li><a href="sapi-user.jsp?proxyId=<%=proxyId %>">Get User Info</a></li>
					<li><a href="sapi-deposit.jsp?proxyId=<%=proxyId %>">Deposit</a></li>
				</ul>
	
				<p>The Viggle member can de-authorize this partner from their profile page at <a href="https://identity-stage.viggle.com">Viggle</a>.</p>

			</div>

		</div>

	</div>

</div>

<footer>
	<small><code>
	Current Time: <%  out.println(new java.util.Date().toString()); %>
	</code></small>

<!-- <p><a href="sapi-withdrawal.jsp?proxyId=<%=proxyId %>">Withdrawal</a></p> -->

</footer>

<script>
	console.log('Token: <%=token %>');
	console.log('proxyId: <%=proxyId %>');
	console.log('state: <%=state %>');
</script>


</body>
</html>
