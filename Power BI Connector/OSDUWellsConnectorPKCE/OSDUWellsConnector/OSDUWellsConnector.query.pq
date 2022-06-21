// Use this file to write queries to test your data connector
let
    //result = OSDUWellsConnector.Contents("{'fulltext': '*','aggregates_count': 10,'map_aggregates' : false,'start': 0,'count': 5000,'metadata': {'ResourceType':['master-data/Well'],'WellCommonName':['AME*'], 'CurrentOperator':['*NAM:'], 'Curves.Mnemonic':['RHOB']},'facets':['ResourceType'],'full_results': true}")
    result = OSDUWellsConnector.Contents("opendes:osdu:*:0.2.0", "BGM")
in
    result