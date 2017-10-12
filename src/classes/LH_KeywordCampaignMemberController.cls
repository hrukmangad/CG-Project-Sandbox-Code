public with sharing class  LH_KeywordCampaignMemberController {
     
    @auraEnabled
    public static CampaignWrapper fetchCampaigns(String filterValue, String keywordId){   
        CampaignWrapper camp = new CampaignWrapper();        
        if(!String.isEmpty(keywordId))
            camp.keywordName = [Select Name from LH_Keyword__c where id=:keywordId ].Name;        
        if(!String.isEmpty(filterValue))
            camp.campaigns =  AutocompleteController.searchObject('Campaign',filterValue,'10', 'true','', '','');
        else
            camp.campaigns = Database.query('Select id, Name from Campaign order by Name limit 10'); 
        return camp;
    }   
    
    public  class CampaignWrapper{ 
        @auraEnabled
        public String keywordName;
        @auraEnabled
        public  List<Campaign> campaigns;     
    }
    
    
    @auraEnabled
    public Static String inserCampaignMember(string keywordId,String campaignId){
        set<Id> listOfContactId = new  set<Id>();
        set<Id> listOfLeadId = new  set<Id>();
        if(!String.isEmpty(keywordId) && !String.isEmpty(campaignId)){            
            try{
                List<LH_Related_Party__c> listOfRelatedParty = [SELECT Id, Name, Contact__c, Keyword__c, Lead__c,
                                                                Account_Id__c, Lead_Id__c, Contact_Id__c FROM LH_Related_Party__c WHERE Keyword__c = :keywordId];
                for(LH_Related_Party__c Relprty : listOfRelatedParty){
                    if(Relprty.Contact_Id__c != null)
                        listOfContactId.add(Relprty.Contact_Id__c);
                    else If(Relprty.Lead_Id__c != null)
                        listOfLeadId.add(Relprty.Lead_Id__c);                                      
                }
                List<CampaignMember> listOfCampainMembers = new List<CampaignMember>();
                for(id leadId :listOfLeadId){
                    CampaignMember campMember = new CampaignMember();
                    campMember.LeadId = leadId;
                    campMember.CampaignId = campaignId;
                    listOfCampainMembers.add(campMember);
                }
                for(id contactId :listOfContactId){
                    CampaignMember campMember = new CampaignMember();
                    campMember.ContactId = contactId;
                    campMember.CampaignId = campaignId;
                    listOfCampainMembers.add(campMember);
                }                
                if(!listOfCampainMembers.isEmpty())
                    Database.insert(listOfCampainMembers ,false) ; 
                return LH_Keyword_Helper.SUCCESS_MSG;
            }catch(Exception e){
                return e.getMessage();
            }
        }
        return LH_Keyword_Helper.MISSING_ID; 
    }   
}