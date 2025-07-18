// Test class for Loan and Loan Charge processing
@isTest
private class LoanHelperTest {
    
    @isTest 
    private static void newLoanTest () {
 	
    	// Create Person Account with record type
		Account tstAcc = creAcc();
    
    	Date curDt = Date.Today();
    	Integer LnTerm = 24;
    	Date endDt = curDt.addMonths(lnTerm);
    
    	Loan__c tstLn = new Loan__c (
            Loan_Name__c = 'Test Loan',
    		Account__c = tstAcc.Id,
        	Gross_Loan_Amount__c = 300000,
        	Date_Loan_Issued__c = curDt,
        	Term__c = lnTerm
    	);
        Test.startTest();
        insert tstLn;
    	Test.stopTest();
    
    	List<Loan_Charge__c> tstLcs = [SELECT Id from Loan_Charge__c 
                                       where Loan__c = :tstLn.Id 
                                       and Charge_Type__c = 'Release Charge' 
                                       and Date__c = :endDt];
    	Assert.areEqual(1, tstLcs.Size(), 'Must be 1 Release Charge with calculated charge date');
    }      
    @isTest 
    private static void updChargeTest () {
        Account tstAcc = creAcc();
        
      	Date curDt = Date.Today();
    	Integer LnTerm = 24;
        Integer modTerm = 36;
    	Date modDt = curDt.addMonths(modTerm);
    
    	Loan__c tstLn = new Loan__c (
            Loan_Name__c = 'Test Loan',
    		Account__c = tstAcc.Id,
        	Gross_Loan_Amount__c = 300000,
        	Date_Loan_Issued__c = curDt,
        	Term__c = lnTerm
    	);
        insert tstLn;
        
        // Test the case where there is an Interest Charge
        Loan_Charge__c insLc = new Loan_Charge__c (
                Loan__c = tstLn.Id,
                Charge_Type__c = 'Interest Charge',
                Amount__c = 200,
                Date__c = curDt
        );
        insert insLc;    

        Date intDt = curDt + 1;
        Test.startTest();
        tstLn.Term__c = modTerm;
        update tstLn;
    	Test.stopTest();

        // Check for updated Release Charge
     	List<Loan_Charge__c> tstRelLcs = [SELECT Id from Loan_Charge__c 
                                       where Loan__c = :tstLn.Id 
                                       and Charge_Type__c = 'Release Charge' 
                                       and Date__c = :modDt];
    	Assert.areEqual(1, tstRelLcs.Size(), 'Must be 1 Release Charge with revised date for Term' );
        
        // Check for Admin charge
     	List<Loan_Charge__c> tstAdmLcs = [SELECT Id from Loan_Charge__c 
                                       where Loan__c = :tstLn.Id 
                                       and Charge_Type__c = 'Admin Fee' 
                                       and Date__c = :curDt];
    	Assert.areEqual(1, tstAdmLcs.Size(), 'Must be 1 Admin Charge for today');

       // Check for Interest charge
     	List<Loan_Charge__c> tstIntLcs = [SELECT Id from Loan_Charge__c 
                                       where Loan__c = :tstLn.Id 
                                       and Charge_Type__c = 'Interest Charge' 
                                       and Date__c = :intDt];
    	Assert.areEqual(1, tstIntLcs.Size(), 'Must be 1 Interest Charge for incremented day');
    }
    @isTest 
             
 // Test the case where there is an duplicate Release Charge
    private static void dupRelTest () {
         Account tstAcc = creAcc();
        
         Date curDt = Date.Today();
    	 Integer LnTerm = 24;
        
         Loan__c tstLn = new Loan__c (
            Loan_Name__c = 'Test Loan',
    		Account__c = tstAcc.Id,
        	Gross_Loan_Amount__c = 300000,
        	Date_Loan_Issued__c = curDt,
        	Term__c = lnTerm
    	);
        insert tstLn;
 
        Loan_Charge__c insLc = new Loan_Charge__c (
                Loan__c = tstLn.Id,
                Charge_Type__c = 'Release Charge',
                Amount__c = 500,
                Date__c = curDt.addMonths(LnTerm)
        );
		Boolean hasException = false;
        Test.startTest();
		// Try-catch gives coverage of the thrown exception but Database.SaveResult does not.
        try {
            insert insLc;
        }
        catch (Exception e) {
            hasException = true; 
        	System.debug('Caught exception ' + e.getMessage());
        }
		Test.stopTest();
        
        Assert.isTrue (hasException, 'Exception should be generated');
    }
    
     // Test the case where the date has to be extended
    @isTest
    private static void lateDateTest () {
         Account tstAcc = creAcc();
        
         Date curDt = Date.Today();
    	 Integer LnTerm = 24;
         Date lateDt = curDt.addMonths(lnTerm) + 7;
         Date extendedDt = curDt.addMonths(lnTerm).addMonths(1);
        
         Loan__c tstLn = new Loan__c (
            Loan_Name__c = 'Test Loan',
    		Account__c = tstAcc.Id,
        	Gross_Loan_Amount__c = 300000,
        	Date_Loan_Issued__c = curDt,
        	Term__c = lnTerm
    	);
        insert tstLn;
        
        Loan_Charge__c insLc = new Loan_Charge__c (
                Loan__c = tstLn.Id,
                Charge_Type__c = 'Legal Fee',
                Amount__c = 500,
                Date__c = lateDt
        );
        Test.startTest();
        insert insLc;
        Test.stopTest();

        // Check for updated Release Charge
     	List<Loan_Charge__c> tstRelLcs = [SELECT Id from Loan_Charge__c 
                                       where Loan__c = :tstLn.Id 
                                       and Charge_Type__c = 'Release Charge' 
                                       and Date__c = :extendedDt];
    	Assert.areEqual(1, tstRelLcs.Size(), 'Must be 1 Release Charge with extended date for late Charge' );
       
    }
     
    // Method to set up a Person Account
    private static Account creAcc() {

        // Create Person Account with record type
	  	Id PAccRecId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
 		Account tstAcc = new Account(
	 		FirstName = 'Loan',
 			LastName = 'Loaner',
 			RecordTypeId = PAccRecId
    	);
 		insert tstAcc;
        return tstAcc;
    }
}