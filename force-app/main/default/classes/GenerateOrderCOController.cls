public with sharing class GenerateOrderCOController {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
 
    public String OrderID {get;set;}

    public List<Campaign_Order__c> coRec {get;set;}
    public List<OrderItem> orderitemRec {get;set;}
    public List<Order> orderRec {get;set;}

    public GenerateOrderCOController (ApexPages.StandardController controller) {
 
        con = controller;

        OrderID= con.getRecord().id;
        
        coRec= [select id, Name,Channel__c,Impression_Click__c,Masking_Sender_Brand__c,Order_Product__c,OwnerId,Placement__c,Profiling_Lokasi__c,SMS_Per_Day_Location__c,WORDING_PICTURE_VIDEO__c,Start_Campaign__c,End_Campaign__c
                              from Campaign_Order__c where Order_ID__c =:OrderID];
                              
        orderitemRec= [select id, Telephone__c,Advertiser_Name__c,Brand_Product__c from OrderItem where OrderId=:OrderID];
        orderRec= [select id,Telephone__c,Advertiser_Name__c,Brand_Product__c,Address__c,Fax__c,Email__c,PIC__c,Quotation_Number__c,Order_Owner__c,Owner_Manager__c,Whitelist_and_UAT__c from Order where id=:OrderID];
                              
    }
    
}