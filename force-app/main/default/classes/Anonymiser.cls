public class Anonymiser {
    
    public static void anonymiseComplianceFieldsOnRecordObject(List<sObject> records)
    {
        // Loop through passed in records to see what object types we are dealing with...        
        Set<Schema.SObjectType> objects = new Set<Schema.SObjectType>();
        Set<string> objectNames = new Set<String>();
        for(sObject o : records)
        {
            Schema.SObjectType oType = o.getSObjectType();
            objects.add(oType);
            objectNames.add(oType.getDescribe().getName());
        }
        
        List<FieldDefinition> fieldDefs = [SELECT EntityDefinitionId, DeveloperName, ComplianceGroup 
                                           FROM FieldDefinition 
                                           WHERE EntityDefinitionId IN :objectNames AND ComplianceGroup!= NULL];
        
        Map<String, Set<String>> complianceFields = new Map<String, Set<String>>();
        
        for(FieldDefinition fieldDef : fieldDefs)
        {
            if(complianceFields.containsKey(fieldDef.EntityDefinitionId))
            {
                complianceFields.get(fieldDef.EntityDefinitionId).add(fieldDef.DeveloperName);
            }
            else
            {
                complianceFields.put(fieldDef.EntityDefinitionId, new Set<String>{fieldDef.DeveloperName});
            }
        }
        
        
        Map<Schema.SObjectType, List<Schema.DescribeFieldResult>> objectFields = new Map<Schema.SObjectType, List<Schema.DescribeFieldResult>>();
        // Loop through all the objects types we have in our list, then get the fields from the object. 
        // Important that we do not get fields like ID's that are references to other objects, as want to maintain relationships.
        
        for(Schema.SObjectType o : objects)
        {
            List<Schema.DescribeFieldResult> fields = new list<Schema.DescribeFieldResult>();
            Map<String, Schema.SObjectField> fieldMap = o.getDescribe().fields.getMap();
            for(string fieldName : fieldMap.keyset())
            {
                Schema.SObjectField field = fieldMap.get(fieldName);
                if( complianceFields.get(o.getDescribe().getName()).contains(fieldName))
                {
                    Schema.DescribeFieldResult fieldDetails = field.getDescribe();                
                    if(fieldDetails.isUpdateable() && !fieldDetails.isCalculated() 
                       && !fieldDetails.isRestrictedPicklist()
                       && !fieldDetails.isRestrictedDelete()
                       && fieldDetails.getType() != Schema.DisplayType.ID 
                       && fieldDetails.getType() != Schema.DisplayType.Reference)
                    {
                        fields.add(fieldDetails);
                    }
                }
            }
            
            if(fields.size() > 0)
            {
                objectFields.put(o, fields); 
            }
        }
        
        
        for(sObject record : records)
        {
            // Get list of fields for sObject
            
            List<Schema.DescribeFieldResult> ofields = objectFields.get(record.getSObjectType());
            
            for(Schema.DescribeFieldResult ofield : ofields)
            {
                string fieldName = ofield.getName(); 
                
                Schema.DisplayType fieldType = ofield.getType();
                
                switch on fieldType {
                    when ADDRESS{}
                    when ANYTYPE{
                        
                    }
                    when BASE64{
                        
                    }
                    when BOOLEAN{
                        
                    }
                    when COMBOBOX{
                        
                    }
                    when CURRENCY{
                        
                    }
                    when DATACATEGORYGROUPREFERENCE{
                        
                    }
                    when DATE{
                        
                    }
                    WHEN DATETIME{
                        
                    }
                    WHEN DOUBLE{
                        
                    }
                    WHEN EMAIL{
                        
                    }
                    WHEN ENCRYPTEDSTRING{
                        
                    }
                    WHEN ID {
                        
                    }
                    WHEN INTEGER{
                        
                    }
                    WHEN LONG{
                        
                    }
                    WHEN MULTIPICKLIST{
                        
                    }
                    WHEN PERCENT{
                        
                    }
                    WHEN PHONE{
                        
                    }
                    WHEN PICKLIST{
                        
                    }
                    WHEN REFERENCE{
                        
                    }
                    WHEN STRING{
                        
                    }
                    WHEN TEXTAREA{
                        
                    }
                    WHEN TIME{
                        
                    }
                    WHEN URL{
                        
                    }
                }
                
                
                Object recordField = record.get(fieldName); 
                if(recordField != NULL)
                {
                    record.put(fieldName, anonymise(recordField)); 
                }
            }
        }
        
        
        // Need to bypass features here...
        update records;
    }
    

    private static object anonymise(object o)
    {
        if(o instanceof string)
        {
            integer existingLength = String.valueof(o).length();
            
            o = (String) generateRandomString(existingLength);
        }
        if(o instanceof integer)
        {
            o = 1234;
        }
        
        
        
        return o;
    }
    
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    
}