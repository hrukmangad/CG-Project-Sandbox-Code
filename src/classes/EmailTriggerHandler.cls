/************* Email Trigger Handler ********
 @Author Himanshu Rukmangad/Liquidhub
 @Date 9/7/2017
 @Description Methods Related to Email Trigger Functionality
**********************************************/
public class EmailTriggerHandler {

    /**
     * @Description : This Function is used to Create or update Email Data on Account and Contact Object Based on sync Fields
     * @param : List of Email Web Address Records which are inserted or updated.
     * @return : null
     **/
    public static void insertEmailDataOnAccountAndContact(List<Email_Web_Address__c> listOfEmailRecord){
        Set<id> setOfAccountIDs = new  Set<id>();
        Set<id> setOfContactIDs = new  Set<id>();
        Set<id> setOfEmailIDs = new  Set<id>(); 
        Set <Email_Web_Address__c> setUpdateEmailRecordsToSetFalseAccount = new Set <Email_Web_Address__c>();
        Set <Email_Web_Address__c> setUpdateEmailRecordsToSetFalseContact = new Set <Email_Web_Address__c>();
        List<Email_Web_Address__c> listUpdateEmailRecordsToSetFalseAccount = new  List<Email_Web_Address__c>();
        List<Email_Web_Address__c> listUpdateEmailRecordsToSetFalseContact = new  List<Email_Web_Address__c>();
        Set<Account> setOfAccountDataToUpdate = new  Set<Account>();
        Set<Contact> setOfContactDataToUpdate = new  Set<Contact>();
        List<Account> listOfUpdatedAccount = new List<Account>();
        List<Contact> listOfUpdatedContact = new List<Contact>();
        Map<id,Account> mapOfAccountValues = new Map<id,Account>();
        Map<id,Contact> mapOfContactValues = new Map<id,Contact>();
        //Iterating through Trigger.New
        for(Email_Web_Address__c emailData : listOfEmailRecord){
            setOfEmailIDs.add(emailData.Id);
            if(emailData.Account__c != Null){
                if(emailData.Primary__c)
                    setOfAccountIDs.add(emailData.Account__c); 
            }
            if(emailData.Contact__c !=Null){
                if(emailData.Primary__c)
                    setOfContactIDs.add(emailData.Contact__c);
            }
        }
        
        //Query to Account Object for Populating Map
        //for(Account accountData : [select (select Id,Primary__c,Website__c from Email_Web_Addresses__r
        // where Primary__c = True and ID NOT IN :setOfEmailIDs),Id,Website from Account where Id IN : setOfAccountIDs]){
        for(Account accountData : [select (select Id,Primary__c,Website__c from Email_Web_Addresses__r),
                                   Id,Website from Account where Id IN : setOfAccountIDs]){
                                       mapOfAccountValues.put(accountData.Id,accountData);
                                       for(Email_Web_Address__c emailRecords :  accountData.Email_Web_Addresses__r){
                                           if(emailRecords.Primary__c == True && !setOfEmailIDs.contains(emailRecords.Id)){
                                               emailRecords.Primary__c = false;
                                               setUpdateEmailRecordsToSetFalseAccount.add(emailRecords);
                                           }
                                       }
                                   }
        if(!setUpdateEmailRecordsToSetFalseAccount.isEmpty())
            listUpdateEmailRecordsToSetFalseAccount.addAll(setUpdateEmailRecordsToSetFalseAccount);
        update listUpdateEmailRecordsToSetFalseAccount;
        
        //Update Account Website when Primary__c = True
        //Iterating through Email_Web_Address object to Populate the value of Email_Web_Address and Account Object
        for(Email_Web_Address__c emailData : listOfEmailRecord){
            if(emailData.Account__c != Null){
                if(emailData.Primary__c){
                    if(mapOfAccountValues.containsKey(emailData.Account__c) && mapOfAccountValues.get(emailData.Account__c)!=Null){
                        Account accountRecord = mapOfAccountValues.get(emailData.Account__c);
                        accountRecord.Website = emailData.Website__c;
                        setOfAccountDataToUpdate.add(accountRecord);
                    }
                }
            }
        }
        if(!setOfAccountDataToUpdate.isEmpty()){
            listOfUpdatedAccount.addAll(setOfAccountDataToUpdate);
            update listOfUpdatedAccount;
        }
        
        //Query to Contact Object for Populating Map
        for(Contact contactData : [select (select Id,Primary__c,Email_Type__c,Email_Address__c,
                                           Website__c from Email_Web_Addresses__r where Primary__c = True and ID NOT IN : setOfEmailIDs),
                                   Id,Email,Email_type__c from Contact where Id IN : setOfContactIDs]){
                                       mapOfContactValues.put(contactData.Id,contactData); 
                                       for(Email_Web_Address__c emailData : contactData.Email_Web_Addresses__r){
                                           
                                           emailData.Primary__c = false;
                                           setUpdateEmailRecordsToSetFalseContact.add(emailData);
                                          
                                       }
                                   }
        if(!setUpdateEmailRecordsToSetFalseContact.isEmpty())
            listUpdateEmailRecordsToSetFalseContact.addAll(setUpdateEmailRecordsToSetFalseContact);
        update listUpdateEmailRecordsToSetFalseContact;
        
        //Update Contact Email_Address__c,Email_Type__c when Primary__c = True
        //Iterating through Email_Web_Address to Populate the value of Email_Web_Address and Contact Object
        for(Email_Web_Address__c emailRecords : listOfEmailRecord){
            if(emailRecords.Contact__c != Null){
                if(emailRecords.Primary__c){
                    if(mapOfContactValues.containsKey(emailRecords.Contact__c) && mapOfContactValues.get(emailRecords.Contact__c)!= Null){
                        Contact contactData = mapOfContactValues.get(emailRecords.Contact__c);
                        contactData.Email = emailRecords.Email_Address__c;
                        contactData.Email_type__c = emailRecords.Email_Type__c;
                        setOfContactDataToUpdate.add(contactData);
                    }
                }
            }
        }
        if(!setOfContactDataToUpdate.isEmpty())
            listOfUpdatedContact.addAll(setOfContactDataToUpdate);
        update listOfUpdatedContact;
        
    }
}