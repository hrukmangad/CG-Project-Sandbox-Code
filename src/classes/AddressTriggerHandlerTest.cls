@isTest
public class AddressTriggerHandlerTest {
	@isTest
  static void updateAddressDataOnAccountAndContactTest(){     //test trigger handler for insert on Account and Contact Address
      insert new TriggersConfiguration__c(name = 'AddressTrigger',active__c=true);
      Account accountObject = new Account();
      accountObject.Name = 'Test Account';
      insert accountObject;

      Contact contactObject = new Contact();
      contactObject.LastName = 'Test Contact';
      insert contactObject;

      Address__c addressObject = new Address__c();
      //addressObject.Account__c = accountObject.Id;
      addressObject.Contact__c = contactObject.Id;
      addressObject.Primary__c = True;
      addressObject.Sync_to_Mailing_Address__c = True;
      addressObject.Sync_to_Other_Address__c = True;

      Address__c addressObject1 = new Address__c();
      addressObject1.Account__c = accountObject.Id;
      //addressObject1.Contact__c = contactObject.Id;
      addressObject1.Primary__c = True;
      addressObject1.Sync_to_Mailing_Address__c = True;
      addressObject1.Sync_to_Other_Address__c = True;

   	Address__c addressObject2 = new Address__c();
      addressObject2.Account__c = accountObject.Id;
      addressObject2.Contact__c = contactObject.Id;
      addressObject2.Primary__c = True;
      addressObject2.Sync_to_Mailing_Address__c = True;
      addressObject2.Sync_to_Other_Address__c = True;

      Test.startTest();
      insert addressObject;
      insert addressObject1;
      insert addressObject2;
      Test.stopTest();
  }
	@isTest
  static void updateAddressDataOnAccountAndContactTest1(){
      //test trigger handler for update on Account and Contact Address
      insert new TriggersConfiguration__c(name = 'AddressTrigger',active__c=true);
      Account accountObject = new Account();
      accountObject.Name = 'Test Account';
      insert accountObject;

      Contact contactObject = new Contact();
      contactObject.LastName = 'Test Contact';
      insert contactObject;

      Address__c addressObject1 = new Address__c();
      addressObject1.Primary__c = True;
      addressObject1.Account__c = accountObject.Id;
      addressObject1.Contact__c = contactObject.Id;
      addressObject1.Sync_to_Mailing_Address__c = True;
      addressObject1.Sync_to_Other_Address__c = True;
      insert addressObject1;

      Address__c addressUpdate = [select Id,Account__c,Contact__c,Sync_to_Mailing_Address__c,Sync_to_Other_Address__c from Address__c
                                  where Sync_to_Mailing_Address__c = True or Sync_to_Other_Address__c = True];
      addressUpdate.Account__c = accountObject.Id;
      addressUpdate.Contact__c = contactObject.Id;
      addressUpdate.Sync_to_Mailing_Address__c = False;
      addressUpdate.Sync_to_Other_Address__c = False;
      //update addressUpdate;

      Test.startTest();
      //insert addressObject1;
      update addressUpdate;
      Test.stopTest();

  }
}
