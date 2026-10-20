@isTest(seealldata=true)
private class Test_Calculation_Controller {
 
    static testMethod void CalculationController() {
        Account A=new Account();
        A.Name='ABC Account';
        insert A;

        Monthly_Sales_Target__c tmpTaa = new Monthly_Sales_Target__c();
        Calculation_Controller calc=new Calculation_Controller();
        
      //Calc.calcSellingEstimation(LP.Id,O.Ownerid,O.Service_Type__c,system.today());
      //Calc.calcUnitIn('5', O.ownerid,O.Service_Type__c,O.CloseDate);
      Calc.calcVisitActual('5',A.id,system.now());
    }
       
}