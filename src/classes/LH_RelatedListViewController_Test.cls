@isTest
private class LH_RelatedListViewController_Test {
    
    public static testmethod void test1(){
        
        LH_Keyword__c key= new LH_Keyword__c();
        key.Type__c = 'Text';
        key.Name = 'Test';
        insert key;
        System.assertEquals('Test',Key.Name);
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;      
        System.assertEquals('Test',acc.Name);
        
        Contact con = new Contact();
        con.LastName ='Test';
        insert con;
        System.assertEquals('Test',con.LastName);
        
        LH_Related_Party__c relParty = new LH_Related_Party__c();
        relParty.Contact__c = con.id;
        relParty.Account__c = acc.id;
        relParty.Keyword__c = key.id;
        insert relParty;
        
        test.startTest();
        LH_RelatedListViewController.fetchRelatedParties('LH_Related_Party__c', key.Id, 'RelatedPartyListView', 5);
        LH_RelatedListViewController.delRelatedPartyRecord(relParty.Id);
        LH_RelatedListViewController.delRelatedPartyRecord('');
        test.stopTest();
    }
}