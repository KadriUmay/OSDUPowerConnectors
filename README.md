# Connection Parameters

Demo environment parameters will be provided by Microsoft. Current parameters as
of 6/22/2020 for R2 QA environment is provided below. For customer tenant custom
deployments the location to get the parameter is also provided.

**client_id &ltYour Client ID Here&gt**

![](media/a326745be1ced2e16f0191ff077197c2.png)

Select App Registrations if you have an existing application then select it
otherwise select New Registration.

![](media/89a8d6ce2e25d639571a2df998160fb2.png)

Client ID can be obtained from the Overview tab under Application (client) ID
value. Copy this for Client_Id parameter.

![](media/692a2774bd05414a9cf518ec408f3bd4.png)

**client_secret Your client secret here**

Select Certificates and secrets tab, hit New client secret and copy the Value
for client_secret. Note that once you create and save the client secret, you
will not have access to the secret value. Be sure to copy it as soon as you
create before navigating to a new tab.

![](media/08bb4a32da19c52014e592a314591c12.png)

**scopes openid profile offline_access Your Client ID Here/.default**

The last parameter of the scopes parameter contains a GUID, replace it with the
client_id parameter above if you’re accessing a custom application

In the following parameters, you will need the replace the GUID with the tenant
ID for custom deployments.

**tenant_id Your Tenant ID Here**

**auth_authorize_url**
<https://login.microsoftonline.com/Your Tenant ID Here/oauth2/v2.0/authorize>

**auth_token_url**
<https://login.microsoftonline.com/Your Tenant ID Here/oauth2/v2.0/token>

![](media/692a2774bd05414a9cf518ec408f3bd4.png)

**auth_callback_url** <http://localhost:8080/auth/callback>

Callback URL needs to be added to the Authentication tab as a Web Redirect URI

![](media/443d34af68fbefb99fe4cd332ed9b3e4.png)

**search_api_url
https://YourOSDUHost/api/search/v2/query**

**data-partition-id opendes**

These parameters need to be provided by the deployment team for deployments in
customer tenants

# PowerBI Connectivity

## Building a Connector to OSDU R2 supporting OAuth2 and OpenID

To be able to connect to OSDU R2 we need to support OAuth2 and OpenID protocol
with Code Grant Workflow. This needs development of a very simple Power BI
connector in M Language. Most of the code is boilerplate and the core part of
the code could also be augmented with other M Language constructors to clean up
the results. For illustrative purposes we will provide a very simple connector
which could be used to send a full text query and get the returned results as a
hierarchical JSON object which is re-shaped in Power BI Desktop.

First we’ll need to open Visual Studio and load M-Language extensions. Select
Extensions and install Power Query SDK as shown below.

![](media/10465c4cc2c5291d391f20f7c2dfcc6f.png)

Once installed open the M Language Project under Power BI Connector.

Solution has 3 main files and set of resources. Config.json stores the
connection parameters, it has been pre-populated with the demo environment
values. For custom tenants, replace the parameters with the customer values as
explained in the first section of this document.

OSDUWellsConnector.pg is the main code with the connector logic.
OSDUWellsConnector.query.pg has the test code which enabled the connector to be
run and tested within Visual Studio, hit F5 or the green run button, first you
will prompted to authenticate and get token, once the token is acquired hit the
Store Credentials, close the window and re-rerun the query.

![](media/2568a89548d876e89400f762e18d5555.png)

Code for the connector consists of several sections, mostly boilerplate code to
acquire and store tokens via OAuth2 and OpenID code grant workflow.

The main section that call’s OSDU R2 is below, the variables defined here shown
up in the connector surface when getting data in the Power BI Desktop. You can
also put the keyword optional in front of the variables you define. For the
purposes of the demo we are defining a kind attribute and query which form the
body of the search query in Lucene syntax sent to the OSDU R2 search engine.

[DataSource.Kind="OSDUWellsConnector", Publish="OSDUWellsConnector.Publish"]

shared OSDUWellsConnector.Contents = (kind as text, query as text) =\>

let

body = GetQueryString(kind as text, query as text),

Source = **Json.Document**(**Web.Contents**(osduindexsearchendpoint,[

Headers = [\#"Content-Type"="application/json",
\#"data-partition-id"=data_partition_id],

Content = **Text.ToBinary**(body)

]

))

in

Source;

GetQueryString function forms the query from the input parameters. The rest of
code doesn’t need to be changed, it is boilerplate code to get the id_token and
authorization tokens.

Build the application, it generates OSDUWellsConnector.mez located under
\<Project Directory\>/bin/Debug or Release.

Copy the .mez file and the config.json file in the project directory to the
following directory. Create the directory if it doesn’t exist. If Power BI
Desktop is open, close and reopen.

C:\\Users\\\<username\>\\Documents\\Power BI Desktop\\Custom Connectors

![](media/4193c87a024cbfd6497abe51001e2601.png)

Open Power BI Desktop (not the PowerBI Windows Application). You can download
Power BI Desktop from <https://powerbi.microsoft.com/en-us/desktop/>, login with
your corporate credentials. Dismiss the data window.

From the menu select File -\> Options and setting and select Options

![](media/13b609fd423a3aa02e52cf8858b29c34.png)

Select Security Options and under Data Extension click the second option,
re-start Power BI Desktop.

![](media/0ac68263deebeef88cc0e01de6519437.png)

Select Get data on the Splash window. Note that if you dismissed this window,
you can access Get data from the top menu.

![](media/cf24f2e34af1569a2b751206446d2172.png)

Select Other and OSDUWellsConnector (Beta). If you don’t see the connector after
copying mez file most probably there’s an issue with the connector code.

![](media/973dda0391c86bceb17ea5be53b0ee1a.png)

Fill in the kind and query fields with the OSDU syntax and hit OK.

![](media/da2eceaf0506167432abbdd15b9c4982.png)

On the first run you will be prompted to login with your credentials and get the
token. Make sure that the credentials are either enabled on the demo tenant or
in your own tenant if you’re using a custom deployment. Hit Sign, fill in
account details and hit connect.

You will get a query results window where the data from OSDU R2 is pulled as a
hierarchical json file. For a sample file see the PBIX file under Power BI Sample Dashboard.

![](media/a1f98588255d99df3982e1768a64396b.png)

![](media/c809cf612f6589f202610125cb4d9fa9.png)

# Connecting Power Apps and Power Automate to OSDU R2

Connecting to OSDU R2 thru Power Apps will use Power Automate and connector
framework. It will enable a zero code client to read data from OSDU. In this
example we will first create an Power Automate Custom Connector to implement the
OAuth2 and OpenID code grant workflow to get access token and search for data in
OSDU given a kind and query using Lucene syntax.

Connection Parameters are provided for the demo environment, see the first
section to get parameters for your environment. We will need to add a return url
parameter to the Application in Azure Active Directory hence you will need
someone with administrative privileges to make the necessary changes on the
application definitions.

## Creating the Custom Connector for OSDU R2 to support OAuth2/OpenID

To support the code grant workflow we first need to create a custom connector in
Power Automate. Open up the Power Automate designer by navigating to
<https://make.preview.powerapps.com/> , Open data section and select Custom
Connectors, select Import a Postman Collection. In this demo we are using a
simple Postman Collection with a single query to search for wells in OSDU R2.

![](media/f844c77bc02830464f6e52020c74c4ab.png)

The Power Automate Connector Postman collection could be downloaded from Power Automate Connector Postman Collection.
Note that the query doesn’t run as you need to provide a bearer token.

![](media/6c4acf1043e880dafcb19b083959a83e.png)

Note that the Postman collection should be exported as v1. Select the Postman
Collection and give the connector a name.

![](media/a1b7f1ac87c1f411045f5e91c7390d5f.png)

You can upload a logo if needed, select Security to define OAuth 2 parameters

![](media/0529bc04eb78405feca5344beea0c5a0.png)

Select OAuth2 as the authentication type and provide the parameters provided in
first section of this document.

![](media/1e74f65ba9f63fb517290f175ff863ef.png)

Hit Create connector, make a note of the Redirect URL generated, you should
provide this to your Azure Active Directory Administrator to add it as a
redirect URL in the Application Settings as outlined in the first section of
this document.

![](media/db7035cfed48861ed148d06576c1d35d.png)

![](media/a3d8e9a17ec2eb57ed2e1d30b99d140b.png)

Hit Definition, you should see Validation Succeeded at the bottom of the page.

![](media/b991ac1223bef7be860ef2638b80ae06.png)

Make sure to change the operation ID to OSDUR2_FulltextSearch for the Power Apps
demos to import.

![](media/9b6cb5d561e4c54db696389c6d7c0b87.png)

Hit test, first create a connection by selecting new +Connection. Hit Create to
select a new instance of the connector. Select your account. (Make sure that you
have access to the demo environment, or your system admin has provided you
access if you are using a custom tenant).

![](media/241b1b56631db977c29a4f955f255642.png)

You have created a connector

![](media/1b80e4a9091412f46b885382256b7c02.png)

Go back to Custom Connectors and search for the connector you are working on and
select edit (Pencil Icon) to go back and test the connector.

![](media/1e10d092066e345132f76584dbaa4601.png)

Select the Test tab, fill in the parameters with values and select Test
Operation. Note that the connector instance you’ve created before shows up in
the connections combo on top of the page.

![](media/84dddc81ff7a4d232c33043fb7eb7fa9.png)

You will see the successful response on the bottom of the page

![](media/97d0dd068b3750e94f221237a89cb48a.png)

## Creating the Power Automate Application

Now that you have created a custom connector, you can create a Power Automate
flow using the designer. Navigate to <https://make.preview.powerapps.com/> ,
select Apps -\> Import Canvas App, it upload and select zip file located at Power Automate Package.

![](media/9023e3f8cf3a480254ef3ee695202b4a.png)

Upload process begins.

![](media/6a99a8efcbedb44a98e38cd7b928b102.png)

Select the Action Icon and do the following changes

![](media/59db81baac4f0791797abc87461b9e55.png)

![](media/07ec308f00c2e53935cc8d6facba1a7f.png)

![](media/80223b91babb6422f7cf673afa6b7fe8.png)

![](media/2e0659b8e949a752aa7cef8df25c51b7.png)

![](media/9ad3150e2b09fe5f2003b4994dfac2fb.png)

![](media/54cbe3b11461ee3da2871c44a1e3672f.png)

![](media/8e07e98993e2130b6bdd2931a86d77de.png)

Hit Import to create the Power Apps and Power Automate Flows in your tenant

![](media/eacb9d4d10b8985ae45691c47cdec7fc.png)

Open Flows and select the Query Wells in OSDU R2, Click the edit icon (Pencil)

![](media/f650f681eceb1b0a59f3b0838d827558.png)

First box gets the UWI from the Power Apps Application

![](media/fe8956f17601e9d8ce55932a154cfc99.png)

Second and third boxes set the kind and query text. Note that the UWI value read
from Power Apps is used to generate a query data.UWI: \<UWI Value\>.

![](media/f2db8702d4c4fd4b9e38537c14c945b9.png)

Third box is the custom connector we’ve built, the kind and query parameters are
sent as calculated. Header parameters are also provided.

![](media/a3661613e383ea80b865c791dc636f40.png)

We do parse the Json returned from OSDU R2 search query and the information is
extracted using a second block based on the schema. In the first block we
provide a sample OSDU R2 schema which generates the parsing logic.

![](media/088cf081ec17b09e49486c5a27b8f80b.png)

Finally the result is returned back to Power App.

![](media/bf320a37496d31cfd4c4f318b7bb6e7c.png)

## Create the Power App UI

In the Power Apps design page select + Create and select Canvas app from blank
to create a Power App.

![](media/0e207b0deea7e3b5661907bc76b86123.png)

Select Phone Format and provide an application name

![](media/b1716b656d0393378c913ebfdbf1059c.png)

Add the following controls to the gallery:

-   Text - Text Input

-   Button

-   Gallery – Vertical, select the Title, subtitle, and body template

-   Medi - Image

![](media/3bd7dfd4b660e1f893f32d3046a59a83.png)

Select Button control, select Action tab on the ribbon above, click Power
Automate on the dynamic ribbon. Select Query Wells in OSDU R2 in the Data panel.
Add following code to OnSelect on top.

ClearCollect(response, QueryWellsinOSDUR2.Run(TextInput1.Text))

Note: Default name for text input is TextInput1, you might need to change above
if the name is different.

![](media/9cee253619954ffb318f65898669ed81.png)

Select the Gallery Control and set the data source as response collection which
you’ve just created with the above code.

![](media/f5bff6608b38586ddc1c2abfd87d3c62.png)

Hit run on the Ribbon to test the application, search a UWI, for instance 1016.

![](media/9c53794c1ab809fdc7d1c8b9a30b712d.png)

![](media/7f8a44dd7ce4115535a9e048a68e5068.png)

Optional:

Select image control and add the following code. Power App doesn’t provide a map
visualization control, in this example we are using an image control and using
Bing Maps static image generator, providing the lat – long we are receiving from
OSDU R2. You can use a similar service that generates images or get a free Bing
Maps key at <https://www.microsoft.com/en-us/maps/create-a-bing-maps-key>.

"https://dev.virtualearth.net/REST/V1/Imagery/Map/Aerial/" &
Gallery1.Selected.Latitude & "%2C" & Gallery1.Selected.Longitude &
"/13?mapSize=300,300&format=png&pushpin="& Gallery1.Selected.Latitude & "," &
Gallery1.Selected.Longitude & ";;"& Gallery1.Selected.UWI & "&key=\<Your Key\>"

![](media/5cbfdb11bc7210d824dc598eac2d4672.png)

Run the application and enter a UWI

![](media/46e4ac173e8574a12fe6f6a4f2b7caaa.png)

You have to Save and Publish your application, select File on the ribbon and
select the option to save your application on the cloud

![](media/e2c297336af761120b953ee70f2229e3.png)

Select Share

![](media/5cd7f04825bf0d93705827985210d3ae.png)

You can share your application with other people in your organization

![](media/9c49a26b425c386b9a321543e1c46157.png)

Install Power Apps on your iOS or Android device and login with your
credentials.

![](media/fabb38f51763e72b03b93a63d3013a80.png)

Select All Apps from the Power Apps Drop Down if you don’t see the newly created
application in the list.

Select the Application and test from your phone.

![](media/4afe0e94c671b30f675efdafb361a5c2.png)

![](media/99f50412ea3b13fcd08c7b08315bc49b.png)

Congratulations, you’ve built your first OSDU R2 mobile application.
