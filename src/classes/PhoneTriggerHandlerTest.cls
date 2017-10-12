@isTest
public class PhoneTriggerHandlerTest {
    @isTest
    static void insertPhoneDataOnAccountAndContact_Test(){         // Test trigger handler for insert on Account and Contact Phone
        insert new TriggersConfiguration__c(name = 'PhoneTrigger',active__c=true);
        Account accountObject =  new Account();
        accountObject.Name = 'Test Account';
        insert accountObject;
        
        //List<RecordType> listRecordType = [select id from RecordType where name = 'individual' and SobjectType = 'contact'];
        
        //Schema.DescribeSObjectResult schemaObject = Schema.SObjectType.Contact; 
        //Map<String,Schema.RecordTypeInfo> contactRecordTypeInfo = schemaObject.getRecordTypeInfosByName(); 
        //Id recordId = contactRecordTypeInfo .get('Individual').getRecordTypeId(); 
        Id recordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        System.debug('Record Id:'+recordId);
        
        Contact contactObject = new Contact();
        contactObject.LastName = 'Test Contact';
        contactObject.RecordTypeId = recordId;       
        insert contactObject;
        
        Phone_Number__c phoneNumberObject = new Phone_Number__c();
        //phoneNumberObject.Account__c = accountObject.Id;
        phoneNumberObject.Contact__c = contactObject.Id;
        phoneNumberObject.Primary__c = True;
        phoneNumberObject.Sync_to_Home__c = True;
        phoneNumberObject.Sync_to_Mobile__c = True;
        phoneNumberObject.Sync_to_Other__c = True;
        
        
        Phone_Number__c phoneNumberObject1 = new Phone_Number__c();
        phoneNumberObject1.Account__c = accountObject.Id;
        //phoneNumberObject1.Contact__c = contactObject.Id;
        phoneNumberObject1.Primary__c = True;
        phoneNumberObject1.Sync_to_Home__c = True;
        phoneNumberObject1.Sync_to_Mobile__c = True;
        phoneNumberObject1.Sync_to_Other__c = True;
        
        Phone_Number__c phoneNumberObject2 = new Phone_Number__c();
        phoneNumberObject2.Account__c = accountObject.Id;
        phoneNumberObject2.Contact__c = contactObject.Id;
        phoneNumberObject2.Primary__c = True;
        phoneNumberObject2.Sync_to_Home__c = True;
        phoneNumberObject2.Sync_to_Mobile__c = True;
        phoneNumberObject2.Sync_to_Other__c = True;
        
        Test.startTest();
        insert phoneNumberObject;
        insert phoneNumberObject1;
        insert phoneNumberObject2;       
        Test.stopTest();
        
    }
    /*@isTest
    static void insertPhoneDataOnAccountAndContact_Test1(){			//Test trigger handler for update on Account and Contact Phone
        insert new TriggersConfiguration__c(name = 'PhoneTrigger',active__c=true);
        Account accountObject =  new Account();
        accountObject.Name = 'Test Account';
        insert accountObject;
        
        List<RecordType> listRecordType = [select id from RecordType where name = 'individual' and SobjectType = 'contact'];
        Contact contactObject = new Contact();
        contactObject.RecordTypeId = listRecordType[0].id; 
        contactObject.LastName = 'Test Contact';
        insert contactObject;
        
        Phone_Number__c phoneNumberObject = new Phone_Number__c();
        phoneNumberObject.Primary__c = True;
        //phoneNumberObject.Account__c = accountObject.Id;
        phoneNumberObject.Contact__c = contactObject.Id;
        phoneNumberObject.Sync_to_Home__c = True;
        phoneNumberObject.Sync_to_Mobile__c = True;
        phoneNumberObject.Sync_to_Other__c = True;
        insert phoneNumberObject;
        
        Phone_Number__c phoneData = [select Account__c,Contact__c,Sync_to_Home__c
                                     ,Sync_to_Mobile__c,Sync_to_Other__c from Phone_Number__c where Primary__c = True];
        phoneData.Primary__c = False;
        
        //phoneData.Account__c = accountObject.Id;
        phoneData.Contact__c = contactObject.Id;     
        
        Test.startTest();
        update phoneData;
        Test.stopTest();
        
    }*/
}