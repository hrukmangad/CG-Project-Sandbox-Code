/************* Address Trigger Handler ********
 @Author Himanshu Rukmangad/Liquidhub
 @Date 9/7/2017
 @Description Methods Related to Address Trigger Functionality
**********************************************/
public class AddressTriggerHandler {
    public static Boolean isRecursiveTriggerOn = true;
     /**
     * @Description : This Function is used to Create or update Address Data on Account and Contact Object Based on sync Fields
     * @param : List of Address which are inserted or updated.
     * @return : null
     **/
    public static void updateAddressDataOnAccountAndContact(List<Address__c> listOfAddress){
        Set<id> setOfAccountIDs = new  Set<id>();
        Set<id> setOfContactIDs = new  Set<id>();
        Set<id> setOfAddressIDs = new  Set<id>();
        Boolean syncAccountAddress =false;
        Boolean syncAccountOtherAddress =false;
        Boolean syncContactAddress =false;
        Boolean syncContactOtherAddress =false;
        Set<Address__c> setUpdateAddressRecordsToSetFalseContact = new  Set<Address__c>();
        Set<Address__c> setUpdateAddressRecordsToSetFalseAccount = new  Set<Address__c>();
        List<Address__c> listUpdateAddressRecordsToSetFalseAccount = new  List<Address__c>();
        List<Address__c> listUpdateAddressRecordsToSetFalseContact = new  List<Address__c>();
        Set<Account> setOfAccountDataToUpdate = new  Set<Account>();
        Set<ID> setOfAccountDataIDToUpdate = new  Set<ID>();
        List<Account> listOfAccountDataToUpdate = new  List<Account>();
        Set<Contact> setOfContactDataToUpdate = new  Set<Contact>();
        Set<id> setOfContactDataIDToUpdate = new  Set<Id>();
        List<Contact> listOfContactDataToUpdate = new  List<Contact>();
        Map<id,Account> mapOfAccountValues = new Map<id,Account>();
        Map<id,Contact> mapOfContactValues = new Map<id,Contact>();        
        Map<Id,Boolean> mapOfAddressMailingContact = new Map<Id,Boolean>();
        Map<Id,Boolean> mapOfAddressOtherContact = new Map<Id,Boolean>();
        
        //Iterating through Trigger.New and creating required maps
        for(Address__c addressData : listOfAddress){
            setOfAddressIDs.add(addressData.id);
            
            if(addressData.Account__c!=null){
                if(addressData.Sync_to_Mailing_Address__c||addressData.Sync_to_Other_Address__c)
                    setOfAccountIDs.add(addressData.Account__c); 
                
            }            
            if(addressData.Contact__c!=null){
                if(addressData.Sync_to_Mailing_Address__c||addressData.Sync_to_Other_Address__c)
                    setOfContactIDs.add(addressData.Contact__c); 
                
                mapOfAddressMailingContact.put(addressData.Contact__c,addressData.Sync_to_Mailing_Address__c);
                mapOfAddressOtherContact.put(addressData.Contact__c,addressData.Sync_to_Other_Address__c);
            }               
        }
        //Query to Account Object for Populating Map and setting sync values for already existing data
        for(Account accountData : [select (select Sync_to_Mailing_Address__c,Sync_to_Other_Address__c from Addresses__r
                                           where Sync_to_Mailing_Address__c=true OR Sync_to_Other_Address__c=true),BillingStreet,BillingCity,
                                   BillingState,BillingPostalCode,Address_Type_Mailing__c,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,
                                   Address_Type_Other__c from Account where id in:setOfAccountIDs]){
                                       mapOfAccountValues.put(accountData.id, accountData);
                                       for(Address__c addressRecords :accountData.Addresses__r){
                                           
                                           if(setOfAddressIDs.contains(addressRecords.id)){
                                               system.debug('in if for current data For Account ==>'+addressRecords.id);
                                               if(addressRecords.Sync_to_Mailing_Address__c)
                                                   syncAccountAddress=true;
                                               if(addressRecords.Sync_to_Other_Address__c)
                                                   syncAccountOtherAddress=true;
                                           }else{
                                               system.debug('in else for other data For Account==>'+addressRecords.id);
                                               Address__c addressData = addressRecords;
                                               if(addressRecords.Sync_to_Mailing_Address__c==true && syncAccountAddress){                        
                                                   addressData.Sync_to_Mailing_Address__c=false;                        
                                               }
                                               if(addressRecords.Sync_to_Other_Address__c==true && syncAccountOtherAddress){
                                                   addressData.Sync_to_Other_Address__c=false;                        
                                               } 
                                               setUpdateAddressRecordsToSetFalseAccount.add(addressData); 
                                           }
                                           
                                           
                                       }
                                   }
        //Query to Contact Object for Populating Map and setting sync values for already existing data
        for(Contact contactData : [select (select Sync_to_Mailing_Address__c,Sync_to_Other_Address__c from Addresses__r where 
                                           (Sync_to_Mailing_Address__c=true OR Sync_to_Other_Address__c=true) AND ID NOT IN:setOfAddressIds),
                                   MailingStreet,MailingCity,MailingState,MailingPostalCode,Address_Type_Mailing__c,OtherStreet,OtherCity,OtherState,
                                   OtherPostalCode,Address_Type_Other__c  from Contact where id in:setOfContactIDs]){
                                       mapOfContactValues.put(contactData.id, contactData);
                                       for(Address__c addressRecords :contactData.Addresses__r){
                                           
                                           Address__c addressData = addressRecords;
                                           system.debug('in else for other data For Contact==>'+addressRecords.id);
                                           if(addressRecords.Sync_to_Mailing_Address__c==true && mapOfAddressMailingContact.get(contactData.Id)){
                                               system.debug('in sync to mailing for id===>'+addressRecords.id);
                                               addressData.Sync_to_Mailing_Address__c=false;
                                               
                                           }
                                           if(addressRecords.Sync_to_Other_Address__c==true && mapOfAddressOtherContact.get(contactData.Id)){
                                               system.debug('in sync to other address for id===>'+addressRecords.id);
                                               addressData.Sync_to_Other_Address__c=false;
                                               
                                           }
                                           setUpdateAddressRecordsToSetFalseContact.add(addressData);
                                           system.debug('====>setUpdateAddressRecordsToSetFalseContact'+setUpdateAddressRecordsToSetFalseContact);
                                           
                                       }
                                   }
        system.debug('setUpdateAddressRecordsToSetFalseAccount==>'+setUpdateAddressRecordsToSetFalseAccount);
        system.debug('setUpdateAddressRecordsToSetFalseContact==>'+setUpdateAddressRecordsToSetFalseContact);
        if(!setUpdateAddressRecordsToSetFalseAccount.isEmpty()){
            listUpdateAddressRecordsToSetFalseAccount.addAll(setUpdateAddressRecordsToSetFalseAccount);
            isRecursiveTriggerOn = false;            
            update listUpdateAddressRecordsToSetFalseAccount;
        }
        if(!setUpdateAddressRecordsToSetFalseContact.isEmpty()){
            isRecursiveTriggerOn = false;
            listUpdateAddressRecordsToSetFalseContact.addAll(setUpdateAddressRecordsToSetFalseContact);
            update listUpdateAddressRecordsToSetFalseContact;
        }   
        
        //Iterating through Address__c Object to Populate the value of Address__c , Account and Contact Object
        for(Address__c addressData : listOfAddress){
            if(addressData.Account__c!=null){                
                if(mapOfAccountValues.containsKey(addressData.Account__c) && mapOfAccountValues.get(addressData.Account__c)!=null){
                    Account accountRecord = mapOfAccountValues.get(addressData.Account__c);
                    if(addressData.Sync_to_Mailing_Address__c){                        
                        accountRecord.BillingStreet = addressData.Address__c;
                        accountRecord.BillingCity = addressData.City__c;
                        accountRecord.BillingState = addressData.State__c;
                        accountRecord.BillingPostalCode = addressData.Zip_Code__c;
                        accountRecord.Address_Type_Mailing__c = addressData.Address_Type__c;                          
                    }
                    if(addressData.Sync_to_Other_Address__c){                                                
                        accountRecord.ShippingStreet = addressData.Address__c;
                        accountRecord.ShippingCity = addressData.City__c;
                        accountRecord.ShippingState = addressData.State__c;
                        accountRecord.ShippingPostalCode = addressData.Zip_Code__c;
                        accountRecord.Address_Type_Other__c = addressData.Address_Type__c;                          
                    }
                    if(!setOfAccountDataIDToUpdate.contains(accountRecord.id)){
                       setOfAccountDataIDToUpdate.add(accountRecord.id);
                    setOfAccountDataToUpdate.add(accountRecord); 
                    }
                    
                }
                
            }
            
            if(addressData.Contact__c!=null){
                if(mapOfContactValues.containsKey(addressData.Contact__c) && mapOfContactValues.get(addressData.Contact__c)!=null){
                    Contact contactRecord = mapOfContactValues.get(addressData.Contact__c);
                    if(addressData.Sync_to_Mailing_Address__c){
                        contactRecord.MailingStreet = addressData.Address__c;
                        contactRecord.MailingCity = addressData.City__c;
                        contactRecord.MailingState = addressData.State__c;
                        contactRecord.MailingPostalCode = addressData.Zip_Code__c;
                        contactRecord.Address_Type_Mailing__c  = addressData.Address_Type__c;                        
                    }                                        
                    if(addressData.Sync_to_Other_Address__c){
                        contactRecord.OtherStreet = addressData.Address__c;
                        contactRecord.OtherCity = addressData.City__c;
                        contactRecord.OtherState = addressData.State__c;
                        contactRecord.OtherPostalCode = addressData.Zip_Code__c;
                        contactRecord.Address_Type_Other__c  = addressData.Address_Type__c;                        
                    }
                     if(!setOfContactDataIDToUpdate.contains(contactRecord.id)){
                       setOfContactDataIDToUpdate.add(contactRecord.id);
                    setOfContactDataToUpdate.add(contactRecord);
                     }
                } 
            }
        }
        
        if(!setOfAccountDataToUpdate.isEmpty()){
            listOfAccountDataToUpdate.addAll(setOfAccountDataToUpdate);
            update listOfAccountDataToUpdate; 
        }
        
        if(!setOfContactDataToUpdate.isEmpty()){
            listOfContactDataToUpdate.addAll(setOfContactDataToUpdate);
            update listOfContactDataToUpdate;  
        }
        
    }
}