public class ContentDocumentTriggerHandler {
    
    //Cannot be final as it needs to be set from unit tests.
    public static String publicGroupName = 'CG Financial';
    
    public ContentDocumentTriggerHandler(){
    }
    
    public void onAfterInsert( Map<Id, ContentDocumentLink> newDocuments ){
        createDocumentLink( newDocuments );
    }
    
    public void createDocumentLink( Map<Id, ContentDocumentLink> newDocuments ){
      
        List<ContentDocumentLink> documentLinksToInsert = new List<ContentDocumentLink>();
        List<CollaborationGroup> publicGroup = [SELECT Id, Name From CollaborationGroup WHERE CollaborationType = 'Public' AND Name = :publicGroupName];
        System.debug( '----> ' + newDocuments );
        if( !publicGroup.isEmpty() ){
            for( ContentDocumentLink aDoc : newDocuments.values() ){
                String entityId = String.valueOf( aDoc.LinkedEntityId );
                if( !entityId.startsWith( '005') && !entityId.startsWith( '0F9' ) ){
                    ContentDocumentLink docLink = new ContentDocumentLink();
                    docLink.ShareType = 'C';
                    docLink.LinkedEntityId = publicGroup[0].Id;
                    docLink.Visibility = 'AllUsers';
                    docLink.ContentDocumentId = aDoc.ContentDocumentId;
                    
                    documentLinksToInsert.add( docLink );
                }
            }    
        }
        
        insert documentLinksToInsert;
    }

}