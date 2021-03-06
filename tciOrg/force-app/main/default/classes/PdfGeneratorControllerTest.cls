@isTest
private class PdfGeneratorControllerTest {

  static Account account;

  static {

    account = new Account();
    account.Name = 'Test Account';
    insert account;

  }

  static testMethod void testPdfGenerator() {

    PageReference pref = Page.PdfGenerator;
    pref.getParameters().put('id',account.id);
    Test.setCurrentPage(pref);

    PdfGeneratorController con = new PdfGeneratorController();    

    Test.startTest();

    // populate the field with values
    con.parentId = account.id;
    con.pdfName = 'My Test PDF';

    // submit the record
    pref = con.savePdf();

    // assert that they were sent to the correct page
    System.assertEquals(pref.getUrl(),'/'+account.id);

    // assert that an attachment exists for the record
    System.assertEquals(1,[select count() from attachment where parentId = :account.id]);

    Test.stopTest(); 

  }
}