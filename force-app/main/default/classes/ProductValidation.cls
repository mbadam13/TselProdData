global with sharing class ProductValidation {
 
    @RemoteAction    
    global static List<Product2> ProductValidation(string Name) {      
       List<Product2> ProductList;
       ProductList = [SELECT Id,Name FROM Product2 where Name=:Name];
       return ProductList;        
    }    
}