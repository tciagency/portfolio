global class EmailtoLeadService implements Messaging.InboundEmailHandler {
	
    private static String OWNER_QUEUE_NAME = 'Agent Queue';
    
    private static String RECORDTYPE_NAME = 'Personal_Lines';	
    private boolean isError;
    private String errorMessage;
    private void cathcException(String err, Exception e){
        isError = true;
        errorMessage = (errorMessage == null ? '' : errorMessage) + err 
            + '\n\n Error Message : ' + e.getMessage() 
            + '\n\n Root Cause : ' + e.getStackTraceString();
    }
    
    private void handelException(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        if(isError || Test.isRunningTest()){
            String errorMailBody = errorMessage + '\n\n----- Orignal Mail Text -----\n\n'+email.PlainTextBody;
            Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage(); 
            em.setSubject( email.Subject );
            em.setToAddresses( new String[] { envelope.fromAddress } );
            em.setPlainTextBody( errorMessage );
            if(!Test.isRunningTest())   Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {em});
        }
    }
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    isError = false;errorMessage='';
    System.debug('-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ PROCESS EMAIL SERVICE [EmailToLeadService] ');
    try{
        String ownerId, recordTypeId;
        for(Group q : [Select Id, Name From Group where Type = 'Queue' and Name = :OWNER_QUEUE_NAME]){
            ownerId = q.Id;
        }
        for(RecordType rt : [Select Id From RecordType where sObjectType = 'Lead' and DeveloperName = :RECORDTYPE_NAME]){
            recordTypeId = rt.Id;
        }
        Lead lead = new Lead();
      
        if(email.fromname != null && email.fromname != ''){
            if(email.fromname.contains(' ')){
                lead.FirstName = email.fromname.substring(0,email.fromname.indexOf(' '));
                lead.LastName = email.fromname.substring(email.fromname.indexOf(' '));   
            }
            else{
                lead.LastName = email.fromname;
            }
        }
        else{
        	lead.FirstName = '';
            
            lead.LastName = envelope.fromAddress;
            
        }
        
        lead.Email = envelope.fromAddress;
        lead.Subject__c = email.Subject;

        lead.Description = email.plainTextBody;
        lead.LeadSource = 'Email';
        
        String emailDomain = envelope.fromAddress.substring(envelope.fromAddress.indexOf('@')+1);
        
        lead.Company = emailDomain.substring(0,emailDomain.indexOf('.'));
        lead.OwnerId = ownerId;

        lead.isEmailtoLead__c = true;
        lead.RecordTypeId   = recordTypeId;
        System.debug('-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ LEAD TO CREATE :: '+lead);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        
        lead.setOptions(dmo);
        
        insert lead;
        System.debug('-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ LEAD CREATED :: ['+lead.Id+']');
            
        System.debug('-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ PROCESS ATTACHMENTS ');
            
        if (email.binaryAttachments != null){
            for (Messaging.InboundEmail.binaryAttachment binAttach :email.binaryAttachments){
                ContentVersion cv = new ContentVersion();
                cv.VersionData = binAttach.body;
                cv.Title = binAttach.fileName;
                cv.PathOnClient = binAttach.fileName;
                //cv.FirstPublishLocationId = account.id;
                insert cv;
	     
		        cv = [select ContentDocumentId from ContentVersion where id = :cv.id limit 1];

                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = lead.id;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.ShareType = 'V';
                insert cdl;
                
                result.success = true;
                result.message = (email.subject + ' matched');
            }
        }
    }
    catch (Exception e) {
    result.success = false;
    result.message = 'Awe. Sorry. Failed to create lead and attach any files if any. Error : '+e.getMessage();
    }
   
    return result;
    }
}