public class LH_LeadTriggerHandler {    
    
    public static void isAfterUpdate(Map<Id, Lead> oldMap, Map<Id, Lead> newMap){
        updateLeadReferenceUponConversion(oldMap,newMap);   
    }
    
    public static void updateLeadReferenceUponConversion(Map<Id, Lead> oldMap, Map<Id, Lead> newMap){
        Map<Id,Id> leadContactMap = new  Map<Id,Id>(); // map of lead and converted contact id 
        for(Lead leadObj : newMap.values()){
            if(leadObj.isConverted )
                leadContactMap.put(leadObj.Id, leadObj.convertedContactId);            
        }
        List<LH_Related_Party__c> relatedPartyList = new List<LH_Related_Party__c>();
        for(LH_Related_Party__c relatedParty :[SELECT Id, Contact__c, Lead__c,Keyword_Name__c FROM LH_Related_Party__c where Lead__c IN : leadContactMap.keySet()]){
            if(leadContactMap.containsKey(relatedParty.Lead__c)){
                relatedParty.Contact__c = leadContactMap.get(relatedParty.lead__c);
                relatedParty.lead__c = null;                
                relatedPartyList.add(relatedParty);
            }
        }
        if(!relatedPartyList.isEmpty())
            update relatedPartyList;
    }
}