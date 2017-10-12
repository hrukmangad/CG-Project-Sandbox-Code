public with sharing class LH_SObjectWrapper
{
	public List<OutputWrapper> outputWrapperList;
    public String Id;

	public static OuputResponse getsObjectWrapperList( String objectName, String fieldSetName, String whereCondition )
	{
        OuputResponse res = new OuputResponse();
		List<LH_SObjectWrapper> sObjectList = new List<LH_SObjectWrapper>();

		Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType sObjectTypeObj = globalDescribeMap.get( objectName );
		Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
		Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get( fieldsetName );
        Map<String, Schema.SObjectField> fieldMap = describeSObjectResultObj.fields.getMap();

        Map<String,String> fieldAPINameMap = new Map<String,String>();
        Map<String,String> referenceFieldAPINameMap = new Map<String,String>();
        List<String> fieldLabelList = new List<String> {'Related Party'};
       
		String query = 'SELECT ';
		for( Schema.FieldSetMember fsm : fieldSetObj.getFields() )
		{
			String fieldPath = fsm.getFieldPath();
            fieldLabelList.add(fieldMap.get(fieldPath).getDescribe().getLabel());
            String referenceField;
            if( String.valueOf( fsm.getType() ) == 'REFERENCE' ){
				referenceField =  fieldPath.replace( '__c', '__r' ) + '.Name';
                
                fieldPath = fieldPath.replace( '__c', '__r' ) + '.Id';
                fieldAPINameMap.put(fieldPath,fsm.getFieldPath());
                referenceFieldAPINameMap.put(fieldPath,referenceField);  
            }else
                fieldAPINameMap.put(fieldPath,fieldPath);
			
			query += fieldPath + ',';
            if(referenceField!=null)
                query += referenceField + ',';
            
		}
		query += 'Id,Keyword__c,Keyword__r.Name';

		query += ' FROM ' + objectName ;

		if( String.isNotBlank( whereCondition ) )
			query += whereCondition;
		System.debug('--query---> '+query);
		for( sObject sObjRec : Database.query( query ) )
		{
			LH_SObjectWrapper sObj = new LH_SObjectWrapper();
            res.keywordName = String.valueOf(sObjRec.getSObject('keyword__r').get('Name'));
			List<OutputWrapper> outList = new List<OutputWrapper>();
            Boolean isRelatedParty = false;
			for( String fieldName : fieldAPINameMap.keyset())
			{
				OutputWrapper out = new OutputWrapper();
				out.fieldAPIName = fieldName;
                System.debug('---fieldName--> '+fieldName);
				out.fieldLabel = fieldMap.get(fieldAPINameMap.get(fieldName)).getDescribe().getLabel();
				if( fieldName.contains( '.' ) )
				{
                    System.debug('---fieldName---> '+fieldName);
                    System.debug('--referenceFieldAPINameMap---> '+referenceFieldAPINameMap);
					List<String> fieldNameList  ;
                    if(referenceFieldAPINameMap.containsKey(fieldName)){
                        fieldNameList  = referenceFieldAPINameMap.get(fieldName).split( '\\.' );
                     
                        System.debug('---fieldnamelisyt--> '+sObjRec.getSObject( fieldNameList[0] ));
                        if(sObjRec.getSObject( fieldNameList[0] )!=null)
                            out.fieldValue = String.valueOf( sObjRec.getSObject( fieldNameList[0] ).get( fieldNameList[1] ) );
                    }
                    out.isLink = true;
                    fieldNameList  = fieldName.split( '\\.' );
                    if(sObjRec.getSObject( fieldNameList[0] )!=null && !isRelatedParty){
                        isRelatedParty = true;
                        out.Id = String.valueOf( sObjRec.getSObject( fieldNameList[0] ).get( fieldNameList[1] ) );
                      	outList.add(0,out);
                    }
				}
				else
					out.fieldValue = String.valueOf( sObjRec.get( fieldName ) );

				outList.add( out );
			}

			sobj.outputWrapperList = outList;
            sobj.Id = String.valueOf(sObjRec.get('Id'));
			sObjectList.add( sobj );
		}
        System.debug('--sObjectList-- > '+sObjectList);
        System.debug('--fieldLabelList--> '+fieldLabelList);
		sObjectList[0].outputWrapperList[0].fieldLabel = 'Related Party';
        res.sObjectList = sObjectList;
        res.fieldLabelList = fieldLabelList;
		return res;
	}
    
    public static OutputWrapper createRelatedParty(OutputWrapper out){
        OutputWrapper out1 = new OutputWrapper();
        //out1.fieldLabel = 'Related Party';
        out1.fieldValue = out.fieldValue;
        out1.isLink = out.isLink;
        out1.Id = out.Id;
        return out1;
    }
    public class OuputResponse{
        List<LH_SObjectWrapper> sObjectList;
        List<String> fieldLabelList;
        String keywordName;
    }

	public class OutputWrapper
	{
		String fieldAPIName;
		String fieldLabel;
		String fieldValue;
        Boolean isLink; 
        String Id;
	}
}