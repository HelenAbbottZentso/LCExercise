//  Helper class for servicing Loan triggers
public class LoanHelper {
 
 // Charge Amounts
    public static final Decimal INIT_REL_AMT = 500.00;
    public static final Decimal ADMIN_AMT = 300.00;
    
    // Create Release Charge for new Loan
    public static void createReleaseCharge (List<Loan__c> insLoans) {

        List<Loan_Charge__c>insLcs = new List<Loan_Charge__c>();
        for (Loan__c ln :insLoans) {
            Loan_Charge__c insLc = new Loan_Charge__c (
                Loan__c = ln.Id,
                Charge_Type__c = 'Release Charge',
                Amount__c = INIT_REL_AMT,
                Date__c = ln.Date_Loan_Issued__c.addMonths((integer)ln.Term__c)
            );
          insLcs.add(insLc);
        }
  	 	insert insLcs;
    }
    // Process Loan Term change on update
    public static void procTermChange (Map<Id,Loan__c> oldLoanMap, List<Loan__c>newLoans) {
        
        Date curDt = Date.Today();
        
        // Find existing Release Charge for all Loans
        Map<ID, Loan_Charge__c> lcRelMap = new Map<ID, Loan_Charge__c>{};
        List<Loan_Charge__c> lcRels = [SELECT Id, Loan__c, Loan__r.Loan_Name__c, Date__c, Amount__c
                                       from Loan_Charge__c
                                       WHERE Charge_Type__c = 'Release Charge'];
         for (Loan_Charge__c lcRelIter : lcRels) {
            lcRelMap.put (lcRelIter.Loan__c, lcRelIter);
        }     
        
        // Find existing Interest Charge for all Loans (ASSUPTION: Only one interest charge per loan per day)
        Map<ID, Loan_Charge__c> lcInMap = new Map<ID, Loan_Charge__c>{};
        List<Loan_Charge__c> lcIns = [SELECT Id, Loan__c, Loan__r.Loan_Name__c, Date__c, Amount__c
                                       from Loan_Charge__c
                                       WHERE Charge_Type__c = 'Interest Charge'
                                       and Date__c = :curDt];
         for (Loan_Charge__c lcInIter : lcIns) {
            lcInMap.put (lcInIter.Loan__c, lcInIter);
        } 
        
        // Loan Charge records to update
        List<Loan_Charge__c>updLcs = new List<Loan_Charge__c>();
        
        // Loan Charge records to insert
        List<Loan_Charge__c>insLcs = new List<Loan_Charge__c>();
        
        for (Loan__c ln : newLoans) {
            Loan__c oldln = oldLoanMap.get(ln.Id);
            if (ln.Term__c <> oldln.Term__c) {
                
               // Update date of linked Release Charge
               if (lcRelMap.containsKey(ln.Id)) { // could have been deleted
                	Loan_Charge__c lcRel = lcRelMap.get(ln.Id);  
                    lcRel.Date__c = ln.Date_Loan_Issued__c.addMonths((integer)ln.Term__c);
                    updLcs.add(lcRel);
                }
                // Create new Loan Charge
                Loan_Charge__c insLc = new Loan_Charge__c (
              	    Charge_Type__c = 'Admin Fee',
                    Loan__c = ln.Id,
                	Amount__c = ADMIN_AMT,
                	Date__c = curDt);
                insLcs.add(insLc);
                
                // Advance interest charge date if found in set for today
                if (lcInMap.containsKey(ln.Id)) {
                   	Loan_Charge__c lcIn = lcInMap.get(ln.Id);  
                   	lcIn.Date__c = curDt + 1;
                   	updLcs.add(lcIn);                 
                }
            }
        }
        update updLcs;  
        insert insLcs;
    }
}