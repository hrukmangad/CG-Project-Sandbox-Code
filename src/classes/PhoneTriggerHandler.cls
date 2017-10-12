/************* Phone Trigger Handler ********
@Author Himanshu Rukmangad/Liquidhub
@Date 9/7/2017
@Description Methods Related to Phone Trigger Functionality
**********************************************/
public class PhoneTriggerHandler {
     /**
* @Description : This Function is used to update Individual Account On the Phone Data
* @param : List of Phones numbers which are inserted or updated.
* @return : null
**/   
    public static void updateAccountOnPhoneForIndividualContact(List<Phone_Number__c> listOfPhoneData,Map<Id,Phone_Number__c> newMap){
        Set<id> setOfContactIDs = new  Set<id>();
        Map<String,Id> mapOfIndividualIdAndContactId = new Map<String,Id>();
        Map<Id,Id> mapOfIndividualContactIdAndAccountId = new Map<Id,Id>();
        for(Phone_Number__c phoneData : listOfPhoneData ){           
            if(phoneData.Contact__c != Null){
				setOfContactIDs.add(phoneData.Contact__c);
            }            
        }
        for(Contact contactRecord : [select FinServ__IndividualId__c,id from Contact where RecordType.name = 'Individual' AND id in:setOfContactIDs]){
           mapOfIndividualIdAndContactId.put(contactRecord.FinServ__IndividualId__c, contactRecord.id); 
        }
        for(Account accountRecord : [select id,FinServ__IndividualId__c from Account where FinServ__IndividualId__c in:mapOfIndividualIdAndContactId.keySet()]){
            mapOfIndividualContactIdAndAccountId.put(mapOfIndividualIdAndContactId.get(accountRecord.FinServ__IndividualId__c),accountRecord.id);
        }
        for(Phone_Number__c phoneData : listOfPhoneData ){           
            if(phoneData.Contact__c != Null && mapOfIndividualContactIdAndAccountId.containsKey(phoneData.Contact__c)){
				if(phoneData.Account__c==NULL)
                phoneData.Account__c = mapOfIndividualContactIdAndAccountId.get(phoneData.Contact__c);
            }            
        }  
    }
    /**
* @Description : This Function is used to Create or update Phone Data on Account and Contact Object Based on sync Fields
* @param : List of Phones numbers which are inserted or updated.
* @return : null
**/
    public static void insertPhoneDataOnAccountAndContact(List<Phone_Number__c> listOfPhoneData,Map<Id,Phone_Number__c> newMap){
        Set<id> setOfAccountIDs = new  Set<id>();
        Set<id> setOfContactIDs = new  Set<id>();
        Set<id> setOfPhoneIDs = newMap.keySet();
        Set <Phone_Number__c> setUpdatePhoneRecordsToSetFalseAccount = new Set <Phone_Number__c>();
        Set <Phone_Number__c> setUpdatePhoneRecordsToSetFalseContact = new Set <Phone_Number__c>();
        List<Phone_Number__c> listUpdatePhoneRecordsToSetFalseAccount = new  List<Phone_Number__c>();
        List<Phone_Number__c> listUpdatePhoneRecordsToSetFalseContact = new  List<Phone_Number__c>();
        Set<Account> setOfAccountDataToUpdate = new  Set<Account>();
        Set<id> setOfAccountDataIDToUpdate = new  Set<id>();
        Set<Contact> setOfContactDataToUpdate = new  Set<Contact>();
        Set<id> setOfContactDataIDToUpdate = new  Set<id>();
        List<Account> listOfUpdatedAccount = new List<Account>();
        List<Contact> listOfUpdatedContact = new List<Contact>();
        Map<id,Account> mapOfAccountValues = new Map<id,Account>();
        Map<id,Contact> mapOfContactValues = new Map<id,Contact>();
        Map<Id,Boolean> mapOfPrimaryContactMap = new Map<Id,Boolean>();
        Map<Id,Boolean> mapOfHomeContactMap = new Map<Id,Boolean>();
        Map<Id,Boolean> mapOfOtherContactMap = new Map<Id,Boolean>();
        Map<Id,Boolean> mapOfMobileContactMap = new Map<Id,Boolean>();
        
        //Iterating through Trigger.New 
        for(Phone_Number__c phoneData : listOfPhoneData ){
            //setOfPhoneIDs.add(phoneData.Id);
            if(phoneData.Account__c != Null){
                if(phoneData.Primary__c)
                    setOfAccountIDs.add(phoneData.Account__c);                
            }
            
            if(phoneData.Contact__c != Null){
                if(phoneData.Primary__c ||  phoneData.Sync_to_Home__c ||  phoneData.Sync_to_Mobile__c || phoneData.Sync_to_Other__c)
                    setOfContactIDs.add(phoneData.Contact__c);
                
                mapOfPrimaryContactMap.put(phoneData.Contact__c,phoneData.Primary__c);
                mapOfHomeContactMap.put(phoneData.Contact__c,phoneData.Sync_to_Home__c);
                mapOfMobileContactMap.put(phoneData.Contact__c,phoneData.Sync_to_Mobile__c);
                mapOfOtherContactMap.put(phoneData.Contact__c,phoneData.Sync_to_Other__c);
            }
            
        }
        //Query to Account Object for Populating Map
        for(Account accountData : [select (select Id,Primary__c,Phone_Number__c from Phone_Numbers__r where Primary__c = true AND ID NOT IN : setOfPhoneIDs)
                                   ,Id,Phone from Account where Id IN:setOfAccountIDs]){
                                       mapOfAccountValues.put(accountData.Id, accountData);
                                       for(Phone_Number__c phoneRecords : accountData.Phone_Numbers__r){
                                           //if(phoneRecords.Primary__c == True && !setOfPhoneIDs.contains(phoneRecords.Id)){
                                           phoneRecords.Primary__c = false;
                                           setUpdatePhoneRecordsToSetFalseAccount.add(phoneRecords);
                                           //}                    
                                       }                    
                                   }
        
        if(!setUpdatePhoneRecordsToSetFalseAccount.isEmpty()){
            listUpdatePhoneRecordsToSetFalseAccount.addAll(setUpdatePhoneRecordsToSetFalseAccount);
            PhoneTriggerUtility.runAgain = false;
            
            update listUpdatePhoneRecordsToSetFalseAccount;
            
        }
        //Iterating through Phone_Number Object to Populate the value of Phone_Number and Account Object
        // Update Account Phone when Primary__c = True
        for(Phone_Number__c phoneData : listOfPhoneData){
            if(phoneData.Account__c != Null){
                if(phoneData.Primary__c){
                    if(mapOfAccountValues.containsKey(phoneData.Account__c) && mapOfAccountValues.get(phoneData.Account__c)!=Null){
                        Account accountRecord = mapOfAccountValues.get(phoneData.Account__c);
                        accountRecord.Phone = phoneData.Phone_Number__c;
                        if(!setOfAccountDataIDToUpdate.contains(accountRecord.id)){
                            setOfAccountDataIDToUpdate.add(accountRecord.id);
                            setOfAccountDataToUpdate.add(accountRecord); 
                        }
                        
                    }
                }
            }
        }
        if(!setOfAccountDataToUpdate.isEmpty()){
            listOfUpdatedAccount.addAll(setOfAccountDataToUpdate);
            update listOfUpdatedAccount;
            
        }
        
        //Query to Contact Object to Populate Map
        for(Contact contactData : [select (select Id,Primary__c, Sync_to_Home__c, Sync_to_Mobile__c, Sync_to_Other__c,
                                           Phone_Number__c from Phone_Numbers__r where ID NOT IN : setOfPhoneIDs)
                                   ,Id,Phone,HomePhone,MobilePhone,OtherPhone from Contact where Id IN:setOfContactIDs]){
                                       mapOfContactValues.put(contactData.Id, contactData);
                                       for(Phone_Number__c phoneRecords : contactData.Phone_Numbers__r){
                                           if(phoneRecords.Primary__c == True && mapOfPrimaryContactMap.get(contactData.Id)){
                                               phoneRecords.Primary__c = false;
                                           }
                                           if(phoneRecords.Sync_to_Home__c == True && mapOfHomeContactMap.get(contactData.Id)){
                                               phoneRecords.Sync_to_Home__c = false;
                                           }
                                           if(phoneRecords.Sync_to_Mobile__c == True && mapOfMobileContactMap.get(contactData.Id)){
                                               phoneRecords.Sync_to_Mobile__c = false;
                                           }
                                           if(phoneRecords.Sync_to_Other__c == True && mapOfOtherContactMap.get(contactData.Id)){
                                               phoneRecords.Sync_to_Other__c = false;
                                           }
                                           setUpdatePhoneRecordsToSetFalseContact.add(phoneRecords);
                                       }
                                   }
        if(!setUpdatePhoneRecordsToSetFalseContact.isEmpty()){
            listUpdatePhoneRecordsToSetFalseContact.addAll(setUpdatePhoneRecordsToSetFalseContact);
            PhoneTriggerUtility.runAgain = false;
            update listUpdatePhoneRecordsToSetFalseContact;
            
        }
        //Iterating through Phone_Number Object to Populate the value of Phone_Number and Contact Object
        // Update Contact Phone,HomePhone,MobilePhone,OtherPhone when Primary__c = True && Sync_to_Home__c = True && Sync_to_Mobile__c = True && Sync_to_Other__c = True
        for(Phone_Number__c phoneData : listOfPhoneData){
            if(phoneData.Contact__c!=Null){
                if(mapOfContactValues.containsKey(phoneData.Contact__c) && mapOfContactValues.get(phoneData.Contact__c)!=Null){
                    Contact contactRecord = mapOfContactValues.get(phoneData.Contact__c);
                    if(phoneData.Primary__c){
                        contactRecord.Phone = phoneData.Phone_Number__c;
                        System.debug('****Testing Primary****'+ contactRecord.Phone +'****Phone Primary****'+phoneData.Phone_Number__c);
                    }
                    
                    if(phoneData.Sync_to_Home__c){
                        contactRecord.HomePhone = phoneData.Phone_Number__c;
                        System.debug('****Testing Sync_to_Home__c****'+contactRecord.HomePhone +'****Phone Sync_to_Home__c****'+phoneData.Phone_Number__c);
                    }
                    
                    if(phoneData.Sync_to_Mobile__c){
                        contactRecord.MobilePhone = phoneData.Phone_Number__c;
                        System.debug('****Testing Sync_to_Mobile__c****'+contactRecord.MobilePhone + '****Phone Sync_to_Mobile__c****'+phoneData.Phone_Number__c);
                    }
                    
                    if(phoneData.Sync_to_Other__c){
                        contactRecord.OtherPhone = phoneData.Phone_Number__c;
                        System.debug('****Testing Sync_to_Other__c****'+contactRecord.OtherPhone +'****Phone Sync_to_Other__c****'+phoneData.Phone_Number__c);
                    }
                    if(!setOfContactDataIDToUpdate.contains(contactRecord.id)){
                        setOfContactDataIDToUpdate.add(contactRecord.id);
                        setOfContactDataToUpdate.add(contactRecord);
                    }
                }
            }
        }
        if(!setOfContactDataToUpdate.isEmpty()){
            listOfUpdatedContact.addAll(setOfContactDataToUpdate);
            update listOfUpdatedContact;
        }
    }
    
}