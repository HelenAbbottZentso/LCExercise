// Trigger to handle all post update processing via helper method
trigger LoanUpdateTrigger on Loan__c (after update) {
	LoanHelper.procTermChange(Trigger.oldMap, Trigger.New);
}