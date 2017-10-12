@isTest
private class LH_ManageKeywordController_Test {
    
    public static testMethod void ManageKeywordControllertest(){
        
        Account acc = new Account();
        //acc.RecordTypeId = '012410000005wOy';
        acc.Name = 'Test Account';
        insert acc;
        
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
            LH_ManageKeywordController.fetchKeywords('Tes');
            LH_ManageKeywordController.fetchRelatedPartyDetails(con.id);
            LH_ManageKeywordController.insertKeyword(key.id,'Test',con.id, 'Text','Text','','Test');
            LH_ManageKeywordController.insertKeyword('','Test',acc.id, 'Text','Text','Test','');
            LH_ManageKeywordController.getContactWrapper('Contact' ,con.id);
            LH_ManageKeywordController.getContactWrapper('Contact' ,'');
            //LH_ManageKeywordController.getIndividualContactId(con.id);
            LH_ManageKeywordController.findObjectNameFromRecordIdPrefix('');
            LH_ManageKeywordController.hasSObjectField('Type__c');
        Test.stopTest();
        
    } 
}