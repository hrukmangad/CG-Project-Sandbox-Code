global class CreateContentNoteBatch implements Database.Batchable<sObject> {
	
	private Id publicGroupId; 
	
	global CreateContentNoteBatch(){
		List<CollaborationGroup> publicGroup = [SELECT Id, Name From CollaborationGroup WHERE CollaborationType = 'Public' AND Name = 'CG Financial'];
		if( !publicGroup.isEmpty() ){
			publicGroupId = publicGroup[0].Id;
		}

	}
	
	global Database.QueryLocator start( Database.BatchableContext BC ) {
		String queryStr = 'SELECT Title__c, ShareType__c, Visibility__c, Content__c, LinkedTo__c FROM Note_Shadow__c' ;
		return Database.getQueryLocator( queryStr );
	}

	global void execute( Database.BatchableContext BC, List<sObject> scope ){
		List<ContentNote> notesToInsert = new List<ContentNote>();
		List<ContentDocumentLink> attachNoteToClient = new List<ContentDocumentLink>();
		List<ContentDocumentLink> notesToShare = new List<ContentDocumentLink>();
		List<Note_Shadow__c> shadowsToUpdate = new List<Note_Shadow__c>();
		List<Note_Shadow__c> shadowsToDelete = new List<Note_Shadow__c>();

		for( Note_Shadow__c shadow : (List<Note_Shadow__c>)scope ){
			ContentNote aNote = new ContentNote();
			String title = String.isNotEmpty( shadow.Title__c ) ? shadow.Title__c : 'Title is Empty';
			String noteContent = shadow.Content__c;
			noteContent = noteContent.escapeXML().replace('\r\n', '<br>').replace('\r', '<br>').replace('\n', '<br>').replace('&apos;', '&#39;');
			
			aNote.Content = Blob.valueOf( noteContent );
			aNote.Title = title;
			notesToInsert.add( aNote );

			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.LinkedEntityId = shadow.LinkedTo__c;
			cdl.Visibility = shadow.Visibility__c;
			cdl.ShareType = shadow.ShareType__c;
			attachNoteToClient.add( cdl );

			if( String.isNotEmpty( publicGroupId ) ){
				ContentDocumentLink docLinkForSharing = new ContentDocumentLink();
				docLinkForSharing.ShareType = 'C';
				docLinkForSharing.LinkedEntityId = publicGroupId;
				docLinkForSharing.Visibility = 'AllUsers';
				notesToShare.add( docLinkForSharing );
			}
		}
		
		List<Database.SaveResult> results = Database.insert( notesToInsert, false );
		List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
		for( Integer i = 0; i < results.size(); i++ ){
			Note_Shadow__c shadow = (Note_Shadow__c) scope[i];
			Database.SaveResult currResult = results[i];
			if( currResult.isSuccess() ){
				ContentDocumentLink aLink = attachNoteToClient[i];
				ContentDocumentLink shareLink = notesToShare[i];
				aLink.ContentDocumentId = currResult.getId();
				shareLink.ContentDocumentId = currResult.getId();

				linksToInsert.add( aLink );
				linksToInsert.add( shareLink );

				shadowsToDelete.add( shadow );
			}else{
				shadow.Imported__c = false;
				Database.Error error = currResult.getErrors()[0];
				shadow.Error__c = error.getMessage();
			}

			shadowsToUpdate.add( shadow );
		}

		Database.insert( linksToInsert,  false );
		update shadowsToUpdate;
		delete shadowsToDelete;
	}
	
	global void finish( Database.BatchableContext BC ){
		
	}
	
}