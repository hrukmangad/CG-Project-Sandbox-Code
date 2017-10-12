public class LH_RelatedListViewController{
      
     @AuraEnabled
    public static String fetchRelatedParties( String objectName, String recordId ,String fieldsetName, integer recordlimit)
    {
        String result = JSON.serialize( LH_SObjectWrapper.getsObjectWrapperList( objectName, fieldSetName, ' WHERE Keyword__c =\''+recordId+'\' LIMIT '+ recordlimit ));
        
        return result;
    }
    
    @AuraEnabled
    public static String delRelatedPartyRecord(string relPartyId){
        if(String.isNotBlank(relPartyId)){
            LH_Related_Party__c  relParty = new LH_Related_Party__c (Id = relPartyId);
            delete relParty;
            return LH_Keyword_Helper.SUCCESS_MSG;
        }else{
            return LH_Keyword_Helper.FAILURE_MSG;
        }
    }
}