// Trigger to handle all post insert processing via helper method
trigger LoanChargeInsertTrigger on Loan_Charge__c (after insert) {
	LoanChargeHelper.chkReleaseCharge(Trigger.New, Trigger.NewMap);
}