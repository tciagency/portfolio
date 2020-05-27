public class BulkPolicyUpdates {

  // Constructor
 public BulkPolicyUpdates(ApexPages.StandardController controller) {
  this.con = (Contact)controller.getSubject();

     this.policies = [ SELECT 
                        p.id,
                        p.name,
                        p.Insured__c,
                        p.Insurance_Company__c,
                        p.Policy_Status__c,
                        p.Policy_Type__c,
                        p.Policy_Active__c,
                        p.Completion_Date__c,
                        p.Product_Issued__c
                      FROM 
                        Policy__c p 
                      WHERE 
                        p.Insured__c = :con.id 
                        and (p.Policy_Status__c IN ('Active','Reinstated','Pending'))];

 }
 // Action Method called from page button
 public pagereference saveChanges() {
  
  update this.policies;
  list<Policy__c> lstToUpdate= new list<Policy__c>();
  for(Integer i=0; i<this.policies.size();i++)
  {
    lstToUpdate.add(this.policies[i]);
  }
  if(lstToUpdate.size() > 0)
     update lstToUpdate;
     return null;
  }
    
 // public getter to provide table headers
 public string[] getheaders() { return new string [] {
 'Policy No.', 'Carrier', 'Policy Issued', 'Status', 'Name' } ; }
 
  // public getter to list contacts policies
 public policy__c[] getpolicies() {
 return this.policies;
 }
 
 // class variables
 Contact con;
 Policy__c[] policies;
 
 }