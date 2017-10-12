@isTest
private class LH_LeadTrigger_Test {
    
    static Lead leadObj;
    static Account acc;
    
    public static testMethod void setupData(){
        acc = new Account();
        acc.Name = 'Test Account';
        if(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual')!=null){
            Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();     
            acc.put('recordTypeId', individualRecordTypeId); 
        }
        insert acc;
        
        Contact con = new contact();
        con.LastName = 'TestContact';
        insert con;
        
        leadObj = new Lead();
        leadObj.Company= 'Test Lead';
        leadObj.LastName = 'Test Lead';
        insert leadObj;
        
        LH_Keyword__c key= new LH_Keyword__c();
        key.Type__c = 'Text';
        key.Name = 'Test Keyword';
        insert key;
        
        LH_Related_Party__c relParty = new LH_Related_Party__c();
        relParty.Contact__c = con.id;
        relParty.Keyword__c = key.id;
        insert relParty;
        
        LH_Related_Party__c relParty_lead = new LH_Related_Party__c();
        relParty_lead.Lead__c = leadObj.id;
        relParty_lead.Keyword__c = key.id;
        insert relParty_lead;
        
        Campaign cmpg = new Campaign();
        cmpg.Name = 'Test Campaign';
        insert cmpg;
    }
    
    public static testMethod void LeadTriggerTest(){
        setupData();
        Test.startTest();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadObj.id);
            lc.setAccountId(acc.id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);        
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();
    }
}