<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="org.json.*,javax.crypto.Mac,javax.crypto.spec.SecretKeySpec,java.security.SignatureException,java.io.*,java.net.*,javax.net.ssl.*,java.util.*,java.text.*"%>

<%@ include file="base64-util.jsp" %>

<%!
public String getToken(String endpoint, String accessKey, String secret) throws Exception {
	String token = null;

	//prepare endpoint URL
	URL obj = new URL(endpoint + "/token" );
	HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();

	//add method and basic request headers
	con.setRequestMethod("GET");
	con.setRequestProperty("Accept", "application/json");
	con.setRequestProperty("Content-Type", "application/json");

	//add auth headers after sha1 calculation on date
	TimeZone tz = TimeZone.getTimeZone("UTC");
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); //iso 8601 format utc  example) 2015-07-05T22:16:18Z
	df.setTimeZone(tz);
	String nowAsISO = df.format(new Date());

	String authorizationHeader;
	try {
		// get an hmac_sha1 key from the raw key bytes
		SecretKeySpec signingKey = new SecretKeySpec(secret.getBytes(), "HmacSHA1");

		// get an hmac_sha1 Mac instance and initialize with the signing key
		Mac mac = Mac.getInstance("HmacSHA1");
		mac.init(signingKey);

		// compute the hmac on input data bytes
		byte[] rawHmacHeader = mac.doFinal(nowAsISO.getBytes());

		// base64-encode the hmac
		authorizationHeader = new String(Base64.encodeBytes(rawHmacHeader));
	} catch (Exception e) {
		throw new SignatureException("Failed to generate HMAC : " + e.getMessage());
	}
	con.setRequestProperty("x-access-key", accessKey);
	con.setRequestProperty("x-authorization-date", nowAsISO);
	con.setRequestProperty("x-authorization", authorizationHeader);
	
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
	JSONObject json = new JSONObject(b.toString());
	return json.getString("token");
}
%>
