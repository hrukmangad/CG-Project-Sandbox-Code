@isTest
public class RevenueTriggerHandlerTest {
    @isTest
    static void createCommissionSplitRecordsTestMethod(){
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert new TriggersConfiguration__c(name = 'RevenueTrigger',active__c=true);
        Account accountObject = new Account();
        accountObject.Name = 'Test Account';
        accountObject.RecordTypeId = RecordTypeIdAccount; 
        insert accountObject;
                
        Contact contactObject = new Contact();
        contactObject.LastName = 'Test Contact';
        insert contactObject;
               
        FinancialAccountRole__C faccountRecord = new FinancialAccountRole__C();
        faccountRecord.Name = 'Old – Primary Advisor';
        insert faccountRecord;
        
        FinServ__FinancialAccount__c financialAccountData = new FinServ__FinancialAccount__c();
        financialAccountData.name='Test Financial Account Data';
        financialAccountData.FinServ__PrimaryOwner__c = accountObject.id;
        insert  financialAccountData;
        
        FinServ__FinancialAccountRole__c financialAccountRoleRecord = new FinServ__FinancialAccountRole__c();
        financialAccountRoleRecord.FinServ__FinancialAccount__c = financialAccountData.id;
        financialAccountRoleRecord.FinServ__RelatedContact__c = contactObject.id;
        financialAccountRoleRecord.FinServ__Role__c = 'Old – Primary Advisor';
        financialAccountRoleRecord.Split_Percent__c = 80;
        financialAccountRoleRecord.FinServ__RelatedAccount__c = accountObject.id;
        insert financialAccountRoleRecord;
        
        FinServ__FinancialAccountRole__c financialAccountRoleRecord1 = new FinServ__FinancialAccountRole__c();
        financialAccountRoleRecord1.FinServ__FinancialAccount__c = financialAccountData.id;
        financialAccountRoleRecord1.FinServ__RelatedContact__c = contactObject.id;
        financialAccountRoleRecord1.FinServ__Role__c = 'Old – Primary Advisor';
        financialAccountRoleRecord1.Split_Percent__c = 80;
        financialAccountRoleRecord1.FinServ__RelatedAccount__c = accountObject.id;
        insert financialAccountRoleRecord1;
        
        FinServ__Revenue__c revenueRecord = new FinServ__Revenue__c();
        revenueRecord.FinServ__Date__c = System.today();
        revenueRecord.FinServ__Amount__c = 1000;
        revenueRecord.FinServ__FinancialAccount__c = financialAccountData.id;
        revenueRecord.FinServ__SubType__c='Transaction';
        insert revenueRecord;

		FinServ__Revenue__c revenueRecord1 = new FinServ__Revenue__c();
        revenueRecord1.FinServ__Date__c = System.today();
        revenueRecord1.FinServ__Amount__c = 1000;
        revenueRecord1.FinServ__FinancialAccount__c = financialAccountData.id;
        revenueRecord1.FinServ__SubType__c='Transaction';
        insert revenueRecord1;       
        
		Commission_Split__c commissionRecord = new Commission_Split__c();
        commissionRecord.Commission__c = revenueRecord.id;
        commissionRecord.Policy__c = financialAccountData.id;
        commissionRecord.Advisor__c = contactObject.id;
        insert commissionRecord;        
        
     }
   
}