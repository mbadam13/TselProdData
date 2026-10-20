public with sharing class Calculation_Controller {
    
    /*
       
    Selling Target
    Selling Actual  <--
    Selling Minus  <--
    Selling Plus  <--
    
    Visit Target
    Visit Actual  <--
    Call Target
    Call Actual  <--
    
    */
    
    
    //public id calcSellingActual(String CampaignID, String salesID, Date closeDate) {
      /*
      Sales__c
      Type__c
      Amount__c
      Date__c
      */
    /*  
    string dataType = 'Selling Actual';
      
    //-- set owner
    string ownerID = salesID;
    
    //-- get date (month and year)
    Integer iedDay=0; 
    Integer iedMonth=0; 
    Integer iedYear=0; 
    double soa;
    
    Date dataDate = closeDate.addMonths(1).toStartofMonth().addDays(-1);
    iedDay = dataDate.day();
    iedMonth = dataDate.month();
    iedYear = dataDate.year();
    
    //-- get sum of amount of that month
    system.debug ('============= ownerID ' + ownerid );
    system.debug ('============= iedDay ' + iedDay );
    system.debug ('============= iedMonth ' + iedMonth );
    system.debug ('============= iedYear ' + iedYear );
    
    /*AggregateResult[] groupedResults = [select ownerid, sum(Amount) soa from opportunity 
        where ownerid = :ownerID and CALENDAR_MONTH(CloseDate) = :iedMonth 
              and CALENDAR_YEAR(CloseDate) = :iedYear
              and stageNAme = 'Closed Won'
            group by ownerid];*/
            
    /*AggregateResult[] groupedResults = [select sum(Amount__c) soa from Usage__c 
    where CALENDAR_MONTH(Date__c) = :iedMonth 
          and CALENDAR_YEAR(Date__c) = :iedYear
       ];
    
    double totAmount=0;
    for (AggregateResult ar : groupedResults)  {
        soa= (double) ar.get('soa') ;
        totAmount=totAmount + soa ;
    }
    
    //-- check availablity data on Target_and_Actual__c 
    Monthly_Sales_Target__c[] taas = [ select id from Monthly_Sales_Target__c 
        where Type__c =: dataType and 
            Sales__c = :ownerID and 
            CALENDAR_MONTH(Date__c) = :iedMonth and 
            CALENDAR_YEAR(Date__c) = :iedYear ];
    
    Monthly_Sales_Target__c tmpTaa = new Monthly_Sales_Target__c();
    Monthly_Sales_Target__c[] tmpTaas = new List<Monthly_Sales_Target__c>();
    
    try {
        if (taas.size() >0) {
            //-- exist, then update
            tmpTaa.id= taas[0].id;
            tmpTaa.Date__c = dataDate;
            tmpTaa.Number_of__c = totAmount;
            //tmpTaas.add (tmpTaa);
            update tmpTaa;
        }
        else{
            //-- no-record-data, then create
            date periode = date.newInstance(iedYear, iedMonth, iedDay);
    
            tmpTaa.Sales__c = ownerID;
            tmpTaa.Date__c= periode;
            tmpTaa.Type__c= dataType;
            
            tmpTaa.Number_of__c= totAmount;
            //tmpTaas.add (tmpTaa);
            insert tmpTaa;
        }
    }
    catch (Exception e) {
        string errMessage = e.getmessage() + ' - error line : '  + e.getLineNumber() ;
        // note::message::linenumber
        apputils.putError('error on Calculation_Controller class ( after update in Usage__c ) ' +
            ' data: ' + tmpTaas +
            '::'+ e.getmessage() + '::' + e.getLineNumber() ); 
    }
    
    return tmpTaa.id;
    }
    */
    public id calcVisitActual(String EventID,String salesID, Datetime visitDateTime) {
    string dataType = 'Visit Actual';
      
    //-- set owner
    string ownerID = salesID;
    
    //-- get date (month and year)
    Integer iedDay=0; 
    Integer iedMonth=0; 
    Integer iedYear=0; 
    double coi;
    
    Date visitDate =  date.newinstance(visitDateTime.year(), visitDateTime.month(), visitDateTime.day());
    Date dataDate = visitDate.addMonths(1).toStartofMonth().addDays(-1);
    iedDay = dataDate.day();
    iedMonth = dataDate.month();
    iedYear = dataDate.year();
    
    //-- get sum of amount of that month
    system.debug ('============= iedDay ' + iedDay );
    system.debug ('============= iedMonth ' + iedMonth );
    system.debug ('============= iedYear ' + iedYear );
    
    AggregateResult[] groupedResults = [select ownerid, count(id) coi from event 
        where ownerid = :ownerID and CALENDAR_MONTH(Activity_Date__c) = :iedMonth and 
            CALENDAR_YEAR(Activity_Date__c) = :iedYear and
            type ='Meeting'
            group by ownerid];
    
    double totCount=0;
    for (AggregateResult ar : groupedResults)  {
        coi= (double) ar.get('coi') ;
        totCount=totCount + coi ;
    }
    
    //-- check availablity data on Target_and_Actual__c 
    Monthly_Sales_Target__c[] taas = [ select id from Monthly_Sales_Target__c 
        where Type__c =: dataType and 
            Sales__c = :ownerID and 
            CALENDAR_MONTH(Date__c) = :iedMonth and 
            CALENDAR_YEAR(Date__c) = :iedYear ];
    
    Monthly_Sales_Target__c tmpTaa = new Monthly_Sales_Target__c();
    Monthly_Sales_Target__c[] tmpTaas = new List<Monthly_Sales_Target__c>();
    
    try {
        if (taas.size() >0) {
            //-- exist, then update
            tmpTaa.id= taas[0].id;
            tmpTaa.Number_of__c = totCount;
            tmpTaas.add (tmpTaa);
            update tmpTaas;
        }
        else{
            //-- no-record-data, then create
            date periode = date.newInstance(iedYear, iedMonth, iedDay);
    
            tmpTaa.Sales__c = ownerID;
            tmpTaa.Date__c= periode;
            tmpTaa.Type__c= dataType;
            
            tmpTaa.Number_of__c = totCount;
            tmpTaas.add (tmpTaa);
    
            insert tmpTaas;
        }
    }
    catch (Exception e) {
        string errMessage = e.getmessage() + ' - error line : '  + e.getLineNumber() ;
        // note::message::linenumber
        apputils.putError('error on Calculation_Controller class ( after update in Visit) ' +
            ' data: ' + tmpTaas +
            '::'+ e.getmessage() + '::' + e.getLineNumber() ); 
    }
         return tmpTaa.id;
    } 
    
    /*
    public id calcUsageActual(String CampaignID, String salesID, Date closeDate) {
    string dataType = 'Selling Actual';
      
    //-- set owner
    string ownerID = salesID;
    
    //-- get date (month and year)
    Integer iedDay=0; 
    Integer iedMonth=0; 
    Integer iedYear=0; 
    double soa;
    
    Date dataDate = closeDate.addMonths(1).toStartofMonth().addDays(-1);
    iedDay = dataDate.day();
    iedMonth = dataDate.month();
    iedYear = dataDate.year();
    
    //-- get sum of amount of that month
    system.debug ('============= ownerID ' + ownerid );
    system.debug ('============= iedDay ' + iedDay );
    system.debug ('============= iedMonth ' + iedMonth );
    system.debug ('============= iedYear ' + iedYear );
    
    AggregateResult[] groupedResults = [select  sum(Amount__c) soa,Campaign_ID__c from Usage__c 
        where CALENDAR_MONTH(Date__c) = :iedMonth 
              and CALENDAR_YEAR(Date__c) = :iedYear
              and Campaign_ID__c=:CampaignID
            group by Campaign_ID__c];
    
    double totAmount=0;
    for (AggregateResult ar : groupedResults)  {
        soa= (double) ar.get('soa') ;
        totAmount=totAmount + soa ;
    }
    
    //-- check availablity data on Target_and_Actual__c 
    OrderItem [] taas = [ select id from OrderItem 
        where Campaign_ID__c= :CampaignID];
    
    OrderItem tmpTaa = new OrderItem ();
    OrderItem [] tmpTaas = new List<OrderItem >();
    
    try {
        if (taas.size() >0) {
            //-- exist, then update
            tmpTaa.id= taas[0].id;
            //tmpTaa.Date__c = dataDate;
            tmpTaa.Usage_Actual__c= totAmount;
            //tmpTaas.add (tmpTaa);
            update tmpTaa;
        }
        else{
            //-- no-record-data, then create
            date periode = date.newInstance(iedYear, iedMonth, iedDay);
            
            tmpTaa.Usage_Actual__c= totAmount;
            //tmpTaas.add (tmpTaa);
            insert tmpTaa;
        }
    }
    catch (Exception e) {
        string errMessage = e.getmessage() + ' - error line : '  + e.getLineNumber() ;
        // note::message::linenumber
        apputils.putError('error on Calculation_Controller class ( after update in opportuntiy ) ' +
            ' data: ' + tmpTaas +
            '::'+ e.getmessage() + '::' + e.getLineNumber() ); 
    }
    
    return tmpTaa.id;
    }       
    */
}