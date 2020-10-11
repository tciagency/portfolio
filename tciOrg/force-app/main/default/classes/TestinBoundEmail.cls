/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-11-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-08-2020   Calvin Bates Jr.                     Initial Version
**/
@isTest
private class TestinBoundEmail{

    static testMethod void TestinBoundEmail()
    {
       // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       // setup the data for the email
      email.subject = 'Create Contact';
      email.fromAddress = 'someaddress@email.com';
      email.plainTextBody = 'email body\n2225256325\nTitle';
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
      
      // add Binary attachment content to Files object
      Messaging.inboundEmail.BinaryAttachment binAttach = new Messaging.inboundEmail.BinaryAttachment();
      ContentVersion cv = new ContentVersion();
      cv.VersionData = binAttach.body;
      cv.Title = binAttach.fileName;
      cv.PathOnClient = binAttach.fileName;
      //cv.FirstPublishLocationId = account.id; (optional);
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {binAttach};

      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.LinkedEntityId = cv.id;
      cdl.ContentDocumentId = cv.ContentDocumentId;
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {binAttach};
  
      // add an Text atatchment  
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };      
      
      // call the email service class and test it with the data in the testMethod
      inBoundEmail  testInbound=new inBoundEmail ();
      testInbound.handleInboundEmail(email, env);   
    }
}
