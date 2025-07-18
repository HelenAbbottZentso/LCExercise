// Helpers to handle loan charge constraint and date propagation
public class LoanChargeHelper {
    public class RelException extends Exception {}
    
    // Method to cover all restrictions and actions relating to existing Release Charges
    public static void chkReleaseCharge (List<Loan_Charge__c> insLcs, Map<Id,Loan_Charge__c>insLcMap) {
        
        // For excluding uncommitted records on initial insert
		Set<Id>insIds = insLcMap.keyset();
        
        // Fetch all the existing Release Charge record for both types of new Loan Charge cases
        Map<ID, Loan_Charge__c> lcRelMap = new Map<ID, Loan_Charge__c>{};
        List<Loan_Charge__c> lcRels = [SELECT Id, Loan__c, Loan__r.Loan_Name__c, Date__c, Amount__c
                                       from Loan_Charge__c
                                       WHERE Charge_Type__c = 'Release Charge'
                                       and (NOT Id in :insIds)];
        // Loan Charge records to update
        List<Loan_Charge__c>updRels = new List<Loan_Charge__c>();
        
        for (Loan_Charge__c lcRel : lcRels) {
            lcRelMap.put (lcRel.Loan__c, lcRel);
        }
 
        // Enforce constraint of one Release Charge
        for (Loan_Charge__c lc :insLcs) {
            if (lc.Charge_Type__c == 'Release Charge') {
            	if (lcRelMap.containsKey(lc.Loan__c)) {
                    Loan_Charge__c lcRel = lcRelMap.get(lc.Loan__c);
                    throw new RelException('Attempt to insert duplicate Release Charge for loan ' + lcRel.Loan__r.Loan_Name__c); 
                }
            }
            
			// For other types apply date extension if needed
            else {
                if (lcRelMap.containsKey(lc.Loan__c)) { // could have been deleted
                	Loan_Charge__c lcRel = lcRelMap.get(lc.Loan__c);  
                    if (lc.Date__c > lcRel.Date__c ) {
                        lcRel.Date__c = LcRel.Date__c.addMonths(1);
                        updRels.add(lcRel);
                    }
                }
                // Balance is updated by formula
            }
        }
        // Run all the updates in bulk
        update updRels;
    }
}