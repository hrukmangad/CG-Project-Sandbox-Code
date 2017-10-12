@isTest
public class EmailTriggerHandlerTest {
    @isTest
    static void insertEmailDataOnAccountAndContact_Test(){        // Test trigger handler for insert on Account and Contact email
        insert new TriggersConfiguration__c(name = 'EmailTrigger',active__c=true);
        Account accountObject = new Account();
        accountObject.Name = 'Test Account';
        insert accountObject;
        
        Contact contactObject = new Contact();
        contactObject.Description = 'Test Contact';
        contactObject.LastName='Test';
        contactObject.Email='abc@gmail.com';
        insert contactObject;
        
        Email_Web_Address__c emailWebObject =  new Email_Web_Address__c();
        //emailWebObject.Account__c = accountObject.Id;
        emailWebObject.Contact__c = contactObject.Id;
        emailWebObject.Primary__c = True;
        emailWebObject.Email_Address__c='Test@gmail.com';
        insert emailWebObject;
        
        Email_Web_Address__c emailWebObject1 =  new Email_Web_Address__c();
        emailWebObject1.Account__c = accountObject.Id;
        //emailWebObject1.Contact__c = contactObject.Id;
        emailWebObject1.Primary__c = True;
        emailWebObject1.Website__c = 'www.google.com';
        insert emailWebObject1;
        
        Email_Web_Address__c emailWebObject2 =  new Email_Web_Address__c();
        emailWebObject2.Account__c = accountObject.Id;
        emailWebObject2.Contact__c = contactObject.Id;
        emailWebObject2.Primary__c = True;
        emailWebObject2.Website__c = 'www.google.com';
        insert emailWebObject2;
        
        Email_Web_Address__c  emailData = [select id,Account__c,Contact__c,Primary__c from Email_Web_Address__c where Primary__c = True];
        emailData.Account__c = accountObject.Id;
        emailData.Contact__c = contactObject.Id;
        emailData.Primary__c = False;
        //update emailData;
        
        Test.startTest();
        /*insert emailWebObject;
        insert emailWebObject1;*/
       
        update emailData;
        Test.stopTest();
    }
  
}