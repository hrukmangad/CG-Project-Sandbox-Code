@isTest
private class LH_KeywordCampaignMemberController_Test {
    
    public static testMethod void KeywordCampaignMember(){   
        
        Contact con = new contact();
        con.LastName = 'TestContact';
        insert con;
        
        Lead ld = new Lead();
        ld.Company= 'Test Lead';
        ld.LastName = 'Test Lead';
        insert ld;
        
        LH_Keyword__c key= new LH_Keyword__c();
        key.Type__c = 'Text';
        key.Name = 'Test Keyword';
        insert key;
        
        LH_Related_Party__c relParty = new LH_Related_Party__c();
        relParty.Contact__c = con.id;
        relParty.Keyword__c = key.id;
        insert relParty;
        
        LH_Related_Party__c relParty_lead = new LH_Related_Party__c();
        relParty_lead.Lead__c = ld.id;
        relParty_lead.Keyword__c = key.id;
        insert relParty_lead;
        
        Campaign cmpg = new Campaign();
        cmpg.Name = 'Test Campaign';
        insert cmpg;
        
        Test.startTest();
            String res = LH_KeywordCampaignMemberController.inserCampaignMember(key.id,cmpg.id);
            System.assertEquals(LH_Keyword_Helper.SUCCESS_MSG ,res);
            LH_KeywordCampaignMemberController.fetchCampaigns('est',key.Id);
            LH_KeywordCampaignMemberController.fetchCampaigns(null,key.Id);
        Test.stopTest();
    }
}