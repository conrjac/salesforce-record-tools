public class RecordMatcher {
    
    public static List<Map<String, String>> testData()
    {
        List<Map<String, String>> testData = new List<Map<String, String>>();
        
        testData.add(new Map<String,String>{'Forname' => 'Connor','Surname' => 'Jackson'});
        testData.add(new Map<String,String>{'Forname' => 'Rob','Surname' => 'Johnson'}); 
        testData.add(new Map<String,String>{'Forname' => 'Steve','Surname' => 'Smith'}); 
        return testData;
    }
    
    
    public static List<Map<String, String>> matchRecords(List<Map<string, string>> input, Id algorithm)
    {
        // Get algorithm
        
        // Get algorithm setup
        List<Matching_Algorithm_Field_Rule__mdt> matchingFieldRules = [SELECT Id, Matching_Algorithm__c, Input_Field__c, Object__c, Field__c, Match_Type__c, First_Characters__c 
                                                                       FROM Matching_Algorithm_Field_Rule__mdt WHERE Matching_Algorithm__c = :algorithm];

        //	Define local storage maps
        Map<String, Map<String, Set<String>>> objectFieldValues = new Map<String, Map<String, Set<String>>>();
        Map<String, inputObjectMapping> objectFieldMapping = new Map<String, inputObjectMapping>();
        
        final string mainObject = '';
        
        // Build Config to local maps
        for(Matching_Algorithm_Field_Rule__mdt matchingFieldRule : matchingFieldRules)
        {
            inputObjectMapping iOM = new inputObjectMapping();
            iOM.objectName = matchingFieldRule.Object__c;
            iOM.fieldName =  matchingFieldRule.Field__c;
            objectFieldMapping.put(matchingFieldRule.Input_Field__c, iOM);
        }
        
        // Interate over input
        
        for(Map<string, string> inputData : input)
        {
    
            for(string inputKey : inputData.keySet())
            {
                inputObjectMapping iOM = objectFieldMapping.get(inputKey);
                string inputValue = inputData.get(inputKey);
                
                if(objectFieldValues.containskey(iOM.objectName))
                {
                    if(objectFieldValues.get(iOM.objectName).containskey(iOM.fieldName))
                    {
                        objectFieldValues.get(iOM.objectName).get(iOM.fieldName).add(inputValue);
                    }
                    else
                    {
                        objectFieldValues.get(iOM.objectName).put(iOM.fieldName, new Set<String>{inputValue});   
                    }
                }
                else
                {
                    objectFieldValues.put(iOM.objectName, new Map<String, Set<String>>{iOM.fieldName => new Set<String>{ inputValue }});
                }
            }
        }
        
        System.debug(objectFieldValues);
        
        Map<String, List<sObject>> queryResults = new Map<String, List<sObject>>();
        // Build Queries
        
        For(String objectToQuery : objectFieldValues.keySet())
        {
            Set<String> fieldNames = objectFieldValues.get(objectToQuery).keySet();
            
            String query = 'SELECT ';
            for(string fieldName : fieldNames)
            {
                query = query + fieldname +', ';
            }
            
            query = query.removeEnd(', ');
            query = query + ' FROM ' + objectToQuery + ' WHERE ';
            for(string fieldName : fieldNames)
            {
                query = query + fieldname +' IN ';
                string values = '(';
                for(string fieldValue : objectFieldValues.get(objectToQuery).get(fieldname))
                {
                    values = values + '\'' + fieldValue + '\',';
                }
                values = values.removeEnd(',');
                values = values + ') AND ';
                query = query + values;
            }
            query = query.removeEnd(' AND ');
            system.debug(query);
            queryResults.put(objectToQuery, Database.query(query));
        }
        
        system.debug(queryResults);

        // Match results
        
        List<Map<String, String>> results = new List<Map<String, String>>();

        return results;
    }    
    
    class inputObjectMapping
    {
        string objectName;
        string fieldName;
        boolean partial;
        integer numChars;
    }
    
}