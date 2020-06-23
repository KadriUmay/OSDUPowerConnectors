// This file contains your Data Connector logic
section OSDUWellsConnector;

config = Json.Document(Text.FromBinary(Extension.Contents("config.json")));
client_id = config[client_id];
client_secret = config[client_secret];
tenant_id = config[tenant_id];
osduindexsearchendpoint = config[osduindexsearchendpoint];
redirect_uri = config[auth_callback_url];
authorize_uri = config[auth_authorize_url];
token_uri = config[auth_token_url];
logout_uri = "https://login.microsoftonline.com/logout.srf";
data_partition_id = config[data_partition_id];

windowWidth = 720;
windowHeight = 1024;

scope_prefix = "";

scopes = config[scopes];

[DataSource.Kind="OSDUWellsConnector", Publish="OSDUWellsConnector.Publish"]
shared OSDUWellsConnector.Contents = (kind as text, query as text) =>
    let
            body = GetQueryString(kind as text, query as text),
            Source = Json.Document(Web.Contents(osduindexsearchendpoint,[
                Headers = [#"Content-Type"="application/json", #"data-partition-id"=data_partition_id],
                Content = Text.ToBinary(body) 
             ]   
           ))
    in
        Source;

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


// Helper functions for OAuth2: StartLogin, FinishLogin, Refresh, Logout
StartLogin = (resourceUrl, state, display) =>
    let
        authorizeUrl = authorize_uri & "?" & Uri.BuildQueryString([
            response_type = "code",
            client_id = client_id,  
            redirect_uri = redirect_uri,
            state = state,
            scope = scopes
        ])
    in
        [
            LoginUri = authorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = 720,
            WindowWidth = 1024,
            Context = null
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        // parse the full callbackUri, and extract the Query string
        parts = Uri.Parts(callbackUri)[Query],
        // if the query string contains an "error" field, raise an error
        // otherwise call TokenMethod to exchange our code for an access_token
        result = if (Record.HasFields(parts, {"error", "error_description"})) then 
                    error Error.Record(parts[error], parts[error_description], parts)
                 else
                    TokenMethod("authorization_code", "code", parts[code])
    in
        result;

Refresh = (resourceUrl, refresh_token) => TokenMethod("refresh_token", "refresh_token", refresh_token);

Logout = (token) => logout_uri;

// see "Exchange code for access token: POST /oauth/token" at https://cloud.ouraring.com/docs/authentication for details
TokenMethod = (grantType, tokenField, code) =>
    let
        queryString = [
            grant_type = grantType,
            redirect_uri = redirect_uri,
            client_id = client_id,
            client_secret = client_secret
        ],
        queryWithCode = Record.AddField(queryString, tokenField, code),

        tokenResponse = Web.Contents(token_uri, [
            Content = Text.ToBinary(Uri.BuildQueryString(queryWithCode)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"
            ],
            ManualStatusHandling = {400} 
        ]),
        body = Json.Document(tokenResponse),
        result = if (Record.HasFields(body, {"error", "error_description"})) then 
                    error Error.Record(body[error], body[error_description], body)
                 else
                    body
    in
        result;


GetQueryString = (kind as text, query as text) as text =>
    let
        queryText = "{""kind"": """ & kind & """,""query"": """ & query & """}"
    in
        queryText;

OSDUWellsConnector.Icons = [
    Icon16 = { Extension.Contents("OSDUWellsConnector16.png"), Extension.Contents("OSDUWellsConnector20.png"), Extension.Contents("OSDUWellsConnector24.png"), Extension.Contents("OSDUWellsConnector32.png") },
    Icon32 = { Extension.Contents("OSDUWellsConnector32.png"), Extension.Contents("OSDUWellsConnector40.png"), Extension.Contents("OSDUWellsConnector48.png"), Extension.Contents("OSDUWellsConnector64.png") }
];
