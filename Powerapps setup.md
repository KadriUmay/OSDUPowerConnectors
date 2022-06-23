
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

The Power Automate Connector Postman collection could be downloaded from here.
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
select Apps -\> Import Canvas App, it upload and select zip file located here.

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

# Creating the Power Apps Flow – Step by Step

In the previous section we’ve imported the solution for the Power Apps Flow, in
this section we’ll show the step by instruction to build it from scratch

Open the newly created application and select edit

![](media/34b106b56c1bb9f3f43606e1760bb158.png)

Select the Button and select the Action ribbon item and Select Power Automate

![](media/1132fc4ee5aaf5abe920f4bd855b93ec.png)

Select Create a new flow

![](media/efa85172e8c1368637c131d771567d2c.png)

Select the first template called PowerApps button

![](media/2edd2f6d7cca2d4f6f4816f24436d6f9.png)

Add a New Step

![](media/bd56631f22d3f945682370662844c655.png)

Search for Initialize variable and add to the Canvas, repeat this step to add a
second Initialize variable.

![](media/61e493e68e319014ac8d48c590559d2e.png)

Add the following to the two initialize variable boxes:

-   Name: query

-   Type: String

-   Value: data.UWI:

-   Name: kind

-   Type: String

-   Value: opendes:osdu:well-master:0.2.1

For the “query” box, put the cursor after the data:UWI: and select the Ask in
PowerApps from the Dynamic content

![](media/e42100a0398b29e2fbeb60aaa65f2947.png)

It will create a variable to read the UWI value put in the TextBox in the Power
App. Your flow should like this

![](media/c24e90d0a57b0dc2423b42137acfdf8f.png)

Add a new step, Select Custom and add the custom connector you’ve created
previously as mentioned in this document

![](media/78f2c1431bc1292dbfade2043e56256b.png)

Drag – Drop the kind and query fields from Dynamic content. Note: When you
select the kind or query field the Dynamic content tab pops out.

![](media/2717923aee43e4ce9dee256eeafb716e.png)

Add a new Parse JSON step

![](media/c2bf86c3ed8675c2f79913126b26864e.png)

For the content, select Dynamic content and pick the Body from the customer
connector

![](media/9008ff707497c271307214807f7b7e32.png)

Schema could be generated from sample, you can find a sample file from the OSDU
search query under Power Automate Connector Postman
Collection/Sampleresponse.json. Copy the contents of this file, click Generate
from sample, and paste and click done, the schema for parser is generated
automatically.

![](media/eefee4d11bd562375e11aca9ca9a4471.png)

Create new Select step

![](media/74d5cb3918a92c647b7b199b9c0c8d87.png)

Select the From field, and select results from Parse JSON step from the Dynamic
content selector

![](media/75be3e7023581d7578a87a72c8457e01.png)

Add the following to Map variables

![](media/8694d3dba62c631d034e337b44dcbbe8.png)

Add a new Http Response step by clicking the Add an action within the Apply to
each block.

![](media/b9568b81d4242a114dc9f8b94dcc7431.png)

Add the following parameter as output.

![](media/6a4c7398d19d1091234ef10ab1d97b1a.png)

Click Show advanced options. Schema could be generated from sample, you can find
a sample file from the OSDU search query under Power Automate Connector Postman
Collection/ SampleoutputtoPowerApps.json. Copy the contents of this file, click
Generate from sample, and paste and click done, the schema for parser is
generated automatically.

![](media/669610df763e0e51a7fdf4d74b80b2e8.png)

Save the Power Automate Flow and go back to the Power App and select the newly
created Power Automate Flow (PowerApps button in this case)

![](media/ef9efcc3d43390086f547ce51c45cd16.png)

Add the following code to the Button OnSelect, this will call the new Power
Automate Flow and search for the specific well with the UWI.

*ClearCollect(response, PowerAppsbutton.Run(TextInput1.Text))*

Hit Run and you should see below screen for a sample search
