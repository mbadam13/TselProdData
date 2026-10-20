/* @description       : 
* @author            : Ahmat Zulkifli Murad
* @group             : 
* test class         : dataTableSettlementWeekly_ControllerTest
* @last modified on  : 08-12-2024
* @last modified by  : Yusuf Ramadhan
**/
public with sharing class dataTableSettlementWeekly_Controller {
    @AuraEnabled(cacheable=false)
    public static list<orderitem>  getOrderItem(){
        try {
            list<orderItem> orderItemList = [
                SELECT id,
                ServiceDate,
                //No_FBO__c,
                Pencatatan_Keuangan__c,
                Tanggal_Invoice__c,
                EndDate,
                penagihan__c,
                Kirim_Nodin_Submit_To_Finance__c,
                No_Invoice_Tsel__c,
                OrderItemNumber,
                Payment_Date_ke_Telkomsel__c,
                Product_Category__c,
                Invoice_Finance__c,
                Status_Invoice__c,
                Account_Name__c,
                Agency_Name__c,
                Brand_Product__c,
                Campaign_Name__c,
                Sales__c,
                Sales__r.Name,
                order.SOA_Invoice__c,
                order.sales_team__c,
                Source_SME__c,
                Grouping_Layanan__c,
                Grouping_DS__c,
                Product2id,
                Product2.name,
                Quantity,
                UnitPrice,
                Total_Gross__c,
                Total_Gross_Inventory__c,
                Sub_Total_FBO__c,
                Disc_Adv_FBO__c,
                Total_Diskon_FBO__c,
                Discount__c,
                Telkomsel_Revenue__c,
                VAT__c,
                Setelah_PPn_FBO__c,
                Usage_Actual__c,
                Usage_After_Disc__c,
                Sisa_Usage__c,
                Sisa_Usage_After_Disc__c,
                Order_Item_Status__c,
                Order.Account.Id, 
                Order.status,
                Order.Account.Name,
                Order.Brand__c,
                Order.Brand__r.Id,
                Order.Brand__r.Name,
                Opportunity__r.Brand__c,
                Opportunity__r.Brand__r.Id,
                Opportunity__r.Brand__r.Name,
                Opportunity__r.Agency_Name__c,
                Opportunity__r.Agency_Name__r.Name,
                Opportunity__c,
                Business_Product__c,
                Source__c
            FROM OrderItem
            WHERE orderid != null
                AND ServiceDate >= LAST_N_DAYS:730 
                WITH SECURITY_ENFORCED
            LIMIT 50000
            ];

            return orderItemList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static String getSobjectpicklistValues(String sobjectApiName, String fieldName) {
        String fieldLabel = '';
        String fieldNameValue = '';
        String bodyJson = '';

        JSONGenerator bodyJsonMessage = JSON.createGenerator(true);
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sobjectApiName).getDescribe().fields.getMap();
        List<Schema.PickListEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getpicklistValues(); 
        
        bodyJsonMessage.writeStartArray();
        for (Schema.PickListEntry picklistValue : picklistValues) { //for all values in the pickList List
            fieldLabel = (String) picklistValue.getLabel();
            fieldNameValue = (String) picklistValue.getValue();
            System.debug('fieldLabel: ' + fieldLabel);
            System.debug('fieldNameValue: ' + fieldNameValue);
            
                bodyJsonMessage.writeStartObject();
                if(fieldLabel != null){                 
                    bodyJsonMessage.writeStringField('label', fieldLabel );
                }else {
                    bodyJsonMessage.writeNullField('label');
                }

                if(fieldName != null){
                    bodyJsonMessage.writeStringField('value',  fieldNameValue);
                }else {
                    bodyJsonMessage.writeNullField('value');
                }
                
                bodyJsonMessage.writeEndObject();
        }

        bodyJsonMessage.writeEndArray();                                
        bodyJson = bodyJsonMessage.getAsString();
        System.debug('bodyJson: ' + bodyJson);
      
        return bodyJson; //return the List
    }
}