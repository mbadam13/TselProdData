trigger ValidationSalesPrice on OpportunityLineItem (before insert, before update) {
    /*
    Opportunity myOpportunity = new Opportunity();
    pricebookentry myPricebookentry = new pricebookentry();
    Product2 myProduct = new product2();
    for(OpportunityLineItem myItem:trigger.new) {
        myOpportunity = [SELECT Pricebook2Id FROM Opportunity WHERE id = :myItem.OpportunityId];
        List<pricebookentry> myPricebookentry = new List<pricebookentry>();
        myPricebookentry = [SELECT UnitPrice FROM pricebookentry WHERE Pricebook2Id = :myOpportunity.Pricebook2Id AND Product2Id = :myItem.Product2Id LIMIT 1];
        myProduct = [SELECT Id,Name,Buying_Method__c FROM Product2 where Id=:myItem.Product2Id];
        
        if(myProduct.Buying_Method__c=='Performance'){
            if(myItem.UnitPrice > myPricebookentry[0].UnitPrice ){
            myItem.UnitPrice.addError('Lebih dari');
            } else if(myItem.UnitPrice < myPricebookentry[0].UnitPrice){
                myItem.UnitPrice.addError('Kurang dari'); 
            }
        }
        
    }
    */
}