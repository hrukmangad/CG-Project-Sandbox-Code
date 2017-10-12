/************* Revenue Trigger Handler ********
 @Author Himanshu Rukmangad/Liquidhub
 @Date 9/7/2017
 @Description Methods Related to Revenue Trigger
**********************************************/
public class RevenueTriggerHandler {
    /**
     * @Description : This Function is used to create CommissionSplit records based on Financial Account Role Data.
     * @param : List of Revenues which are inserted.
     * @return : null
     **/
    public static void createCommissionSplitRecords(List<FinServ__Revenue__c> listOfRevenue){
        List<Commission_Split__c> listOfCommissionSplitRecordsForCreate = new List<Commission_Split__c>();
        Map<id,list<FinServ__FinancialAccountRole__c>> mapOfFinancialAccountIdAndRoles = new Map<id,list<FinServ__FinancialAccountRole__c>>();
        Set<id> setOfFinancialAccountID = new  Set<id>();
        list<String> listOfAccountRoleNames = new  list<String>();
        //Iterating over List of revenue and creating set of financial account id.
        for(FinServ__Revenue__c revenueRecord : listOfRevenue){
            setOfFinancialAccountID.add(revenueRecord.FinServ__FinancialAccount__c);
        }
        //Creating list of account role name for where condition from financial account role custom setting
        for(FinancialAccountRole__C accountRoleCustomSettingData : [select name from FinancialAccountRole__C]){
            listOfAccountRoleNames.add(accountRoleCustomSettingData.name);
        }
        //Quering Financial Account Role for the Finanical Account related to Revenue and based on virous criteria
        for(FinServ__FinancialAccountRole__c financialAccountRole
            : [select  Split_Percent__c,FinServ__RelatedContact__c,FinServ__FinancialAccount__c,FinServ__Role__c  from FinServ__FinancialAccountRole__c
               where FinServ__FinancialAccount__c in:setOfFinancialAccountID
               AND Split_Percent__c>0
               AND FinServ__Role__c in:listOfAccountRoleNames]){
                   //Populating mapOfFinancialAccountIdAndRoles map when the key in the iteration is already added.
                   if(mapOfFinancialAccountIdAndRoles.containsKey(financialAccountRole.FinServ__FinancialAccount__c)){
                       list<FinServ__FinancialAccountRole__c> listOfFinancialAccountData = mapOfFinancialAccountIdAndRoles.get(
                           financialAccountRole.FinServ__FinancialAccount__c);
                       listOfFinancialAccountData.add(financialAccountRole);
                       mapOfFinancialAccountIdAndRoles.put(financialAccountRole.FinServ__FinancialAccount__c, listOfFinancialAccountData);
                   }
                   //Populating mapOfFinancialAccountIdAndRoles map when the key in the iteration is still not added.
                   else{
                       list<FinServ__FinancialAccountRole__c> listOfFinancialAccountData = new list<FinServ__FinancialAccountRole__c>();
                       listOfFinancialAccountData.add(financialAccountRole);
                       mapOfFinancialAccountIdAndRoles.put(financialAccountRole.FinServ__FinancialAccount__c, listOfFinancialAccountData);
                   }
               }
        //Iterating through the List Of Revenue and creating Commision Split based on Financial Account role coming from map.
        for(FinServ__Revenue__c revenueRecord : listOfRevenue){
            if(mapOfFinancialAccountIdAndRoles.containsKey(revenueRecord.FinServ__FinancialAccount__c)){
                for(FinServ__FinancialAccountRole__c financialAccountRoleData : mapOfFinancialAccountIdAndRoles.get(
                    revenueRecord.FinServ__FinancialAccount__c)){
                        Commission_Split__c  commissionSplitRecord = new  Commission_Split__c();                        
                        commissionSplitRecord.Commission__c = revenueRecord.id;                        
                        commissionSplitRecord.Paid_On__c = revenueRecord.FinServ__Date__c;                        
                        commissionSplitRecord.Commission_Type__c  = revenueRecord.FinServ__SubType__c;                        
                        commissionSplitRecord.Policy__c = revenueRecord.FinServ__FinancialAccount__c;                        
                        commissionSplitRecord.Role__c = financialAccountRoleData.FinServ__Role__c;
                        if(financialAccountRoleData.Split_Percent__c!=null){
                            commissionSplitRecord.Split_Percentage__c = financialAccountRoleData.Split_Percent__c;
                            if(revenueRecord.FinServ__Amount__c!=null)
                            commissionSplitRecord.Paid_Amount__c = revenueRecord.FinServ__Amount__c*(financialAccountRoleData.Split_Percent__c/100);  
                        }
                        
                        commissionSplitRecord.Advisor__c = financialAccountRoleData.FinServ__RelatedContact__c;
                        listOfCommissionSplitRecordsForCreate.add(commissionSplitRecord);
                    } 
            }
        }
        if(!listOfCommissionSplitRecordsForCreate.isEmpty())
        insert listOfCommissionSplitRecordsForCreate;
    }
}