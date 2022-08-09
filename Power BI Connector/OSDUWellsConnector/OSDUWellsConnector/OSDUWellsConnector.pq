// V2 - Now using PKCE authentication. Client secrets are no longer needed.
[Version="2.0.0"]
section OSDUWellsConnector;

config = Json.Document(Text.FromBinary(Extension.Contents("config.json")));
clientId = config[client_id];
redirectUri = config[redirect_uri]; // Must be a platform that supports PKCE
oAuthBaseUrl = config[oauth_base_url];
osduSearchEndpointUrl = config[osduindexsearchendpoint];
dataParitionId = config[data_partition_id];

logoutUri = "https://login.microsoftonline.com/logout.srf";

[DataSource.Kind="OSDUWellsConnector", Publish="OSDUWellsConnector.Publish"]
shared OSDUWellsConnector.Contents = (kind as text, query as text, optional limit as number, optional offset as number, optional returnedFields as text) =>
    let
            body = GetQueryString(kind, query, limit, offset, returnedFields),
            Source = Json.Document(Web.Contents(osduSearchEndpointUrl,[
                Headers = [#"Content-Type"="application/json", #"data-partition-id"=dataParitionId],
                Content = Text.ToBinary(body)
             ]  
           ))
    in
        Source;
 
// Data Source Kind description
OSDUWellsConnector = [
     TestConnection = (dataSourcePath) =>
        let
            json = Json.Document(dataSourcePath),
            kind = json[kind],
            query = json[query]
        in
            { "OSDUWellsConnector.Contents", kind, query },
    Authentication = [
        OAuth = [
            StartLogin=StartLogin,
            FinishLogin=FinishLogin,
            Refresh=Refresh,
            Logout=Logout
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];
 
// Data Source UI publishing description
OSDUWellsConnector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = OSDUWellsConnector.Icons,
    SourceTypeImage = OSDUWellsConnector.Icons
];

 Base64UrlEncode = (toConvert as binary) =>
	let
		encodedText = Binary.ToText(toConvert, BinaryEncoding.Base64)
	in
		Text.Remove(Text.Replace(Text.Replace(encodedText, "+", "-"), "/", "_"), "=");

CreateCodeChallenge = (codeVerifier as text) => 
    let 
        encodedText = Text.ToBinary(codeVerifier, TextEncoding.Ascii),
        challenge = Base64UrlEncode(Crypto.CreateHash(CryptoAlgorithm.SHA256, encodedText))
    in
        challenge;

GetScopes = () =>
    let
        scopes = "openid profile offline_access " & clientId & "/.default"
    in 
        scopes;

StartLogin = (resourceUrl, state, display) =>
    let
        codeVerifier = Text.NewGuid() & Text.NewGuid(),
        AuthorizeUrl = oAuthBaseUrl & "/authorize?" & Uri.BuildQueryString([
            client_id = clientId,
            response_type = "code",
            code_challenge_method = "S256",
            code_challenge = CreateCodeChallenge(codeVerifier),
            state = state,
            scope = GetScopes(),
            redirect_uri = redirectUri])
    in
        [
            LoginUri = AuthorizeUrl,
            CallbackUri = redirectUri,
            WindowHeight = 720,
            WindowWidth = 1024,
            Context = codeVerifier
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        Parts = Uri.Parts(callbackUri)[Query]
    in
        TokenMethod(Parts[code], "authorization_code", context);
 
Refresh = (resourceUrl, refresh_token) => TokenMethod(refresh_token, "refresh_token");

Logout = (token) => logoutUri;
 
// Verifier is optional to support both the original FinishLogin call
// (which has a verifier) and the Refresh call (which does not).
TokenMethod = (code, grant_type, optional verifier) =>
    let
        codeVerifier = if (verifier <> null) then [code_verifier = verifier] else [],
        codeParameter = if (grant_type = "authorization_code") then [ code = code ] else [ refresh_token = code ],
        query = codeVerifier & codeParameter & [
            client_id = clientId,
            grant_type = grant_type,
            redirect_uri = redirectUri
        ],
 
        // Set this if your API returns a non-2xx status for login failures
        // ManualHandlingStatusCodes = {400, 403}
        ManualHandlingStatusCodes= {400},
        
        Response = Web.Contents(oAuthBaseUrl & "/token", [
            Content = Text.ToBinary(Uri.BuildQueryString(query)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json",
                #"Origin" = ""
            ],
            ManualStatusHandling = ManualHandlingStatusCodes
        ]),
        Parts = Json.Document(Response)
    in
        // check for error in response
        if (Parts[error]? <> null) then 
            error Error.Record(Parts[error], Parts[message]?)
        else
            Parts;
 
ValueNumber.IfNull = (a, b, fieldname) => if a <> null then ",""" & fieldname & """: " & Number.ToText(a) else b;
ValueText.IfNullOrEmpty = (a, b, fieldname) => if (a <> null and a <> "") then  ",""" & fieldname & """: [" & a & "]" else b;
 
GetQueryString = (kind as text, query as text, optional limit as number, optional offset as number, optional returnedFields as text) as text =>
    let
        queryText = "{""kind"": """ & kind & """,""query"": """ & query & """" & ValueNumber.IfNull(limit, "", "limit") & ValueNumber.IfNull(offset, "", "offset") & ValueText.IfNullOrEmpty(returnedFields, "", "returnedFields") & "}"
    in
        queryText;
 
OSDUWellsConnector.Icons =[
    Icon16 = { Extension.Contents("OSDUWellsConnector16.png"), Extension.Contents("OSDUWellsConnector20.png"), Extension.Contents("OSDUWellsConnector24.png"), Extension.Contents("OSDUWellsConnector32.png") },
    Icon32 = { Extension.Contents("OSDUWellsConnector32.png"), Extension.Contents("OSDUWellsConnector40.png"), Extension.Contents("OSDUWellsConnector48.png"), Extension.Contents("OSDUWellsConnector64.png") }
];
