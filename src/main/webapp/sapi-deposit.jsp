<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="org.json.*,javax.crypto.Mac,javax.crypto.spec.SecretKeySpec,java.security.SignatureException,java.io.*,java.net.*,javax.net.ssl.*,java.util.*,java.text.*"%>

<%@ include file="sapi-get-token.jsp" %>

<%
	String proxyId = request.getParameter("proxyId");
	
	//get env variables
	String endpoint = application.getInitParameter("sapiEndpoint");
	String accessKey = application.getInitParameter("accessKey");
	String secret = application.getInitParameter("secret");
	
	String token = null;
	try {
		token = getToken(endpoint, accessKey, secret);
	} catch(Throwable t) {
		t.printStackTrace();	
	}
	
	//variables for deposit
	String partnerMemberId = "foobar91";
	int pointsToDeposit = 25;
	String partnerTransactionId = UUID.randomUUID().toString();
	String campaign = "27394e96-4fd7-4505-86f0-268cda040822";
	String transactionType = "ContentEngagement";
	String actionType = "video";
	String contextId = "sports";
	String contextMessage = "You watched some really great sports analysis";

	//prepare deposit endpoint URL
	URL obj = new URL(endpoint + "/deposit" );
	HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();

	//add method and basic request headers
	con.setRequestMethod("POST");
	con.setRequestProperty("Accept", "application/json");
	con.setRequestProperty("Content-Type", "application/json");

	//add auth headers after sha1 calculation on date
	TimeZone tz = TimeZone.getTimeZone("UTC");
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); //iso 8601 format utc  example) 2015-07-05T22:16:18Z
	df.setTimeZone(tz);
	String nowAsISO = df.format(new Date());

	String authorizationHeader;
	String authorizationBody;
	try {
		// get an hmac_sha1 key from the raw key bytes
		SecretKeySpec signingKey = new SecretKeySpec(secret.getBytes(), "HmacSHA1");

		// get an hmac_sha1 Mac instance and initialize with the signing key
		Mac mac = Mac.getInstance("HmacSHA1");
		mac.init(signingKey);

		// compute the hmac on input data bytes
		byte[] rawHmacHeader = mac.doFinal(nowAsISO.getBytes());
		byte[] rawHmacBody = mac.doFinal((token + proxyId + pointsToDeposit + partnerTransactionId + campaign + transactionType + actionType).getBytes());

		// base64-encode the hmac
		authorizationHeader = new String(Base64.encodeBytes(rawHmacHeader));
		authorizationBody = new String(Base64.encodeBytes(rawHmacBody));
	} catch (Exception e) {
		throw new SignatureException("Failed to generate HMAC : " + e.getMessage());
	}
	con.setRequestProperty("x-access-key", accessKey);
	con.setRequestProperty("x-authorization-date", nowAsISO);
	con.setRequestProperty("x-authorization", authorizationHeader);
	
	JSONObject json = new JSONObject();
	json.put("token", token);
	json.put("viggleMemberId", proxyId);
	json.put("partnerMemberId", partnerMemberId);
	json.put("pointsToDeposit", pointsToDeposit);
	json.put("partnerTransactionId", partnerTransactionId);
	json.put("campaign", campaign);
	json.put("transactionType", transactionType);
	json.put("actionType", actionType);
	json.put("contextId", contextId);
	json.put("contextMessage", contextMessage);
	json.put("authentication", authorizationBody);

	// Send post request
	con.setDoOutput(true);
	DataOutputStream wr = new DataOutputStream(con.getOutputStream());
	wr.writeBytes(json.toString());
	wr.flush();
	wr.close();
	
	int responseCode = con.getResponseCode();
	
	InputStream is = null;
	if (responseCode == 200) {
		is = con.getInputStream();
	} else {
		is = con.getErrorStream();
	}
	
	String inputLine;
	StringBuffer b = new StringBuffer();
	if (is != null) {
		BufferedReader in = new BufferedReader(new InputStreamReader(is));

		while ((inputLine = in.readLine()) != null) {
			b.append(inputLine);
		}
		in.close();
	}
	String resultText = b.toString();
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>SAPI - Deposit</title>
</head>
<body>

	<h1>SAPI - Deposit</h1>
	
	<p>Response Code: <%=responseCode %></p>
	
	<p>
		 Response:
		<%= resultText %>
	</p>


</body>
</html>