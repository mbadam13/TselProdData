/**
 * @description       : utility soql query syntax
 * @author            : RKA
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : RKA
**/
public without sharing class UtilSOQL {
    public static String SOQL(String Fields, String addField, String sObjectName, String condition, String order, String ascDesc, String limits){
        String sortby = 'ASC';
        if(string.isNotBlank(ascDesc)) sortby = ascDesc;
        String soql = 'SELECT '+Fields.toLowerCase();
        if(String.isNotBlank(addField)) soql = soql+addField.toLowerCase(); //addfield = ',xx___c' atau '(select id from xx__r)'
        soql = soql +' FROM '+sObjectName;
        if(String.isNotBlank(condition)) soql = soql+' where '+condition; //condition = 'xx__c = xxx and xx__c = yyyy'
        if(String.isNotBlank(order)) soql = soql+' order by '+order.toLowerCase()+' '+sortby; // order = 'order by xx__c '
        if(String.isNotBlank(limits)) soql = soql+' limit '+limits.toLowerCase(); // limits = '10'
        return soql;
    } 
    
    public static List<SObject> sobjects(String addField, String sObjectName, String condition, String order, String ascDesc,String limits){
        List<SObject> listSobj;
        String dpFields = getAllFields(sObjectName);
        
        String dpQuery = SOQL(dpFields, addField, sObjectName, condition, order,ascDesc, limits);
        listSobj = Database.query(dpQuery);
        return listSobj;
    }
    
    public static SObject singleSobject(String addField, String sObjectName, String condition, String order, String ascDesc, String limits){
        SObject sObj;
        String dpFields = getAllFields(sObjectName);
        String dpQuery = SOQL(dpFields, addField, sObjectName, condition, order,ascDesc, limits);
        sObj = Database.query(dpQuery);
        
        return sObj;
    }
    
    public static String getAllFields(String sObjectName){
        Schema.DescribeSObjectResult describeResultdpacc = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        List<String> dpaccFieldList = new List<String>(describeResultdpacc.fields.getMap().keySet());
        String dpaccFields = String.join(dpaccFieldList, ',');
        return dpaccFields;
    }
}