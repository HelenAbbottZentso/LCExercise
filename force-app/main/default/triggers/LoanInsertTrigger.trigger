// Trigger to handle all post insert processing via helper method
trigger LoanInsertTrigger on Loan__c (after insert) {
	LoanHelper.createReleaseCharge(Trigger.New);
}