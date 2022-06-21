// This file contains your Data Connector logic

section OSDUWellsConnector;

config = Json.Document(Text.FromBinary(Extension.Contents("config.json")));
client_id = "<Client ID here>";
redirect_uri = "<Redirect URL here>"; // Must be a SPA Application Redirect URI
origin_uri = "http://localhost";
logout_uri = "https://login.microsoftonline.com/logout.srf";
scopes = "openid profile offline_access <Client ID here>/.default";
OAuthBaseUrl = "https://login.microsoftonline.com/<Tenant Here>/oauth2/v2.0";

windowWidth = 720;
windowHeight = 1024;

[DataSource.Kind="OSDUWellsConnector", Publish="OSDUWellsConnector.Publish"]
shared OSDUWellsConnector.Contents = (kind as text, query as text, optional limit as number, optional offset as number, optional returnedFields as text) =>
    let
        kind = "Hello world"
    in
        kind;
 
// Data Source Kind description
OSDUWellsConnector = [
    TestConnection = (dataSourcePath) => {"OSDUWellsConnector.Contents", dataSourcePath },
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
 
StartLogin = (resourceUrl, state, display) =>
    let
        // We'll generate our code verifier using Guids
        codeVerifier = Text.NewGuid() & Text.NewGuid(),
        AuthorizeUrl = OAuthBaseUrl & "/authorize?" & Uri.BuildQueryString([
            client_id = client_id,
            response_type = "code",
            code_challenge_method = "plain",
            code_challenge = codeVerifier,
            state = state,
            scope = scopes,
            redirect_uri = redirect_uri])
    in
        [
            LoginUri = AuthorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = windowHeight,
            WindowWidth = windowWidth,
            Context = codeVerifier
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        Parts = Uri.Parts(callbackUri)[Query]
    in
        TokenMethod(Parts[code], "authorization_code", context);
 
Refresh = (resourceUrl, refresh_token) => TokenMethod(refresh_token, "refresh_token");

Logout = (token) => logout_uri;
 
// Verifier is optional to support both the original FinishLogin call
// (which has a verifier) and the Refresh call (which does not).
TokenMethod = (code, grant_type, optional verifier) =>
    let
        codeVerifier = if (verifier <> null) then [code_verifier = verifier] else [],
        codeParameter = if (grant_type = "authorization_code") then [ code = code ] else [ refresh_token = code ],
        query = codeVerifier & codeParameter & [
            client_id = client_id,
            grant_type = grant_type,
            redirect_uri = redirect_uri
        ],
 
        // Set this if your API returns a non-2xx status for login failures
        // ManualHandlingStatusCodes = {400, 403}
        ManualHandlingStatusCodes= {},
        
        Response = Web.Contents(OAuthBaseUrl & "/token", [
            Content = Text.ToBinary(Uri.BuildQueryString(query)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json",
                #"Origin" = origin_uri
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
