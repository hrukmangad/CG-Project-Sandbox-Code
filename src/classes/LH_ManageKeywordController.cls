public with sharing class LH_ManageKeywordController {
    
    @auraEnabled
    public static List<Object> fetchKeywords(String filterValue){
        return AutocompleteController.searchObject('lH_Keyword__c',filterValue,'10', 'true','', '','');
    }
    
    @auraEnabled
    public static RelatedPartyWrapper fetchRelatedPartyDetails(String recordId){
        String objectName;
        if(!String.isEmpty(recordId)){ 
            objectName = findObjectNameFromRecordIdPrefix(recordId) ;       
            if(objectName == LH_Keyword_Helper.ACCOUNT){                
                if(hasSObjectField(LH_Keyword_Helper.FINANCIAL_SERVICE_ACCOUNT)){
                    String contactId = getIndividualContactId(recordId) ;
                    if(contactId != null){
                        recordId = contactId;
                        objectName = LH_Keyword_Helper.CONTACT;
                    }
                }
            }
        }
        return getContactWrapper(objectName,recordId);
    }
    
    @auraEnabled
    public static RelatedPartyWrapper insertKeyword(String keywordId,String keywordValue, String recordId, String keywordType, String data_type, String value, String comments){
        String objectName;
        if(!String.isEmpty(keywordValue)){
            keywordValue = keywordValue.trim();
            LH_Keyword__c key = new LH_Keyword__c();
            if(String.isEmpty(keywordId) ){
                Boolean isKeywordValueExist = false; 
                // SOQL to cross check if keyword value exist in database to avoid duplicate keyword entry in database
                for(LH_Keyword__c keywrdObj : [Select id, Name from LH_Keyword__c where Name =: keywordValue limit 1]){
                    keywordId = keywrdObj.Id;
                    isKeywordValueExist  = true;
                }
                if(!isKeywordValueExist){
                    key.Name = keywordValue;
                    key.Type__c = keywordType;
                    insert key;
                }
                keywordId = key.Id;
            }                       
            LH_Related_Party__c conKeyword = new LH_Related_Party__c();
            conKeyword.keyword__c = keywordId;
            objectName = findObjectNameFromRecordIdPrefix(recordId) ;
            if(objectName == LH_Keyword_Helper.LEAD)
                conKeyword.Lead__c = recordId;            
            else if (objectName == LH_Keyword_Helper.CONTACT)
                conKeyword.Contact__c = recordId;                     
            else if (objectName == LH_Keyword_Helper.ACCOUNT){
                conKeyword.Account__c = recordId; 
                if(hasSObjectField(LH_Keyword_Helper.FINANCIAL_SERVICE_ACCOUNT)){
                    String contactId = getIndividualContactId(recordId) ;
                    if(contactId!=null){
                        conKeyword.Contact__c = contactId;	
                        recordId = contactId;
                        objectName = LH_Keyword_Helper.CONTACT;
                        conKeyword.Account__c = null;
                    }                                           
                }             
            }
            conKeyword.Comments__c = comments;    
            conKeyword.Value__c = String.valueOf(value);         
            if(!String.isBlank(value)){
                if (keywordType== LH_Keyword_Helper.CURRENCY_TYPE)
                    conKeyword.Value_Currency__c  = Decimal.valueof(value);
                else if (keywordType == LH_Keyword_Helper.DATE_TYPE)
                    conKeyword.Value_Date__c  = Date.valueOf(value);
                else if (keywordType == LH_Keyword_Helper.NUMBER_TYPE)
                    conKeyword.Value_Number__c =  Decimal.valueof(value);
                else if (keywordType == LH_Keyword_Helper.TEXT_TYPE)
                    conKeyword.Value_Text__c = String.valueOf(value);
            }
            insert conKeyword;
        }
        return getContactWrapper(objectName,recordId);
    }
    
    public static  RelatedPartyWrapper getContactWrapper(String objectName, String recordId){       
        if(!String.isBlank(objectName) && !String.isBlank(recordId)){
            RelatedPartyWrapper conWrapper = new RelatedPartyWrapper();
            String query = 'Select id, Name, (Select id, Name, Keyword__r.Id, Keyword__r.Name, CreatedBy.Name, CreatedDate, Value__c, Comments__c from Related_Parties__r) from '+objectName+ ' where id =: recordId Limit 1' ;           
            for(sObject sObj : Database.query(query)){
                conWrapper.sObj = sObj;
                conWrapper.conKeywords = (List<LH_Related_Party__c>)sObj.getSObjects('Related_Parties__r');         
            }  
            return conWrapper;            
        }
        return null;
    }
    
    public  class RelatedPartyWrapper{ 
        @auraEnabled
        public sObject sObj;
        @auraEnabled
        public  List<LH_Related_Party__c> conKeywords;
        RelatedPartyWrapper(){            
            conKeywords = new List<LH_Related_Party__c> ();
        }
    }
    
    
    public static String getIndividualContactId( String recordId){
        Id contactId ;
        String query = 'Select id,FinServ__IndividualId__c,(Select id, FinServ__IndividualId__c from Contacts) from Account where id=:recordId Limit 1';
        for(Account acc : Database.query(query)){
            for(Contact con : acc.Contacts){
                if(acc.get('FinServ__IndividualId__c') == con.get('FinServ__IndividualId__c')){
                    contactId = con.Id;     
                    break;
                }
            }
        } 
        return contactId;
    }
    
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);            
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();               
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
    
    public static boolean hasSObjectField(String fieldName){       
        return Schema.SObjectType.Account.fields.getMap().keySet().contains(fieldName.toLowerCase());
    }
    @auraEnabled
    public static RelatedPartyWrapper delKeywordRecord(String relatedPartyId, String keyRecId){        
        LH_Related_Party__c relParty = new LH_Related_Party__c(Id=relatedPartyId);
        delete relParty;
        return fetchRelatedPartyDetails(keyRecId);
        
    }
}