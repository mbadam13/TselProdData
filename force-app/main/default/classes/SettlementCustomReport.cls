/**
 * @description       : Custom Report for Settlement Team
 * @author            : M. Reza Maulana
 * @group             : 
 * @last modified on  : 07-22-2025
 * @last modified by  : M. Reza Maulana
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   22/07/2025    M. Reza Maulana  Initial Version
**/
public with sharing class SettlementCustomReport implements Schedulable {
    public void execute(SchedulableContext sc) {
        generateAndSendCSV();
    }

    public static void generateAndSendCSV() {
        // Ambil email dari Custom Label
        String emailAddressRaw = Label.Settlement_Report_Email_recipientEmail1;
        if (String.isBlank(emailAddressRaw)) {
            System.debug('Email address label is empty.');
            return;
        }

        // Split dan trim email menjadi List<String>
        List<String> emailList = new List<String>();
        for (String e : emailAddressRaw.split(',')) {
            if (!String.isBlank(e)) {
                emailList.add(e.trim());
            }
        }

        List<Monthly_Sales_Target__c> records = [
            SELECT Amount__c, Date__c, Opportunity__c, Opportunity__r.Name,
                   Usage__r.Product_Name__c, Name, Usage__c, Usage__r.Name,
                   Campaign_ID__c, Adjustment_Amount__c, usages_telkomsel_revenue__c,
                   Opportunity_Owner__c, Tipe_MST__c,
                   Usage__r.Bucket_Detail__r.OrderItemNumber,
                   Usage__r.Bucket_Detail__r.Order.Order_amount__c,
                   Usage__r.Bucket_Detail__r.ListPrice,
                   Usage__r.Bucket_Detail__r.Revenue_Sales__c,
                   Usage__r.Telkomsel_Revenue__c,
                   Usage__r.Bucket_Detail__r.Order.SOA_Quotation_No__c,
                   Usage__r.Bucket_Detail__r.Order.SOA__r.SOA_Number__c,
                   Usage__r.Bucket_Detail__r.Order.Quote.Name,
                   Usage__r.Bucket_Detail__r.Order.Name,
                   Usage__r.Bucket_Detail__r.Order.Usage_Plan__c,
                   Usage__r.Bucket_Detail__r.Order.Completion__c,
                   Usage__r.Bucket_Detail__r.Quantity,
                   Usage__r.Bucket_Detail__r.Usage_Actual__c,
                   Usage__r.Total_Amount__c, Usage__r.Sales_Price__c, 
                   Usage__r.Order_Amount__c
            FROM Monthly_Sales_Target__c
            WHERE (Date__c = LAST_MONTH OR Date__c = THIS_MONTH)
            AND Group_Type__c = 'Actual'
            AND Type__c = 'Revenue Actual'
            AND Tipe_MST__c = 'Direct Sales'
            ORDER BY Date__c DESC
        ];

        String csvBody = generateCSV(records);

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        Date today = Date.today();
        String month = today.month() < 10 ? '0' + today.month() : String.valueOf(today.month());
        String day = today.day() < 10 ? '0' + today.day() : String.valueOf(today.day());
        String formattedDate = today.year() + month + day;
        attachment.setFileName('SettlementCustomReport - ' + formattedDate + '.csv');

        attachment.setBody(Blob.valueOf(csvBody));
        attachment.setContentType('text/csv');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailList);
        mail.setSubject('Settlement Report');
        mail.setPlainTextBody('Dear Mba Mei, Please find the attached CSV report.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    // Method untuk escape karakter spesial CSV
    /*private static String escapeCsv(Object value) {
        if (value == null) return '""'; // empty quoted string
        String val = String.valueOf(value);
        // Escape double quotes di dalam value
        val = val.replaceAll('"', "\"\"");
        // Bungkus dengan double quotes
        return '"' + val + '"';
    }*/
    private static String escapeCsv(Object value) {
        if (value == null) return '""'; // empty quoted string
        String val = String.valueOf(value);
        // Escape double quotes di dalam value (ganti " dengan "")
        val = val.replaceAll('"', '""');
        // Bungkus dengan double quotes
        return '"' + val + '"';
    }


    private static String generateCSV(List<Monthly_Sales_Target__c> records) {
        List<String> header = new List<String>{
            'Amount__c','Date__c','Opportunity__c','Opportunity__r.Name',
            'Usage__r.Product_Name__c','Name','Usage__c','Usage__r.Name',
            'Campaign_ID__c','Adjustment_Amount__c','usages_telkomsel_revenue__c',
            'Opportunity_Owner__c','Tipe_MST__c','Usage__r.Bucket_Detail__r.OrderItemNumber',
            'Usage__r.Bucket_Detail__r.Order.Order_amount__c',
            'Usage__r.Bucket_Detail__r.ListPrice',
            'Usage__r.Bucket_Detail__r.Revenue_Sales__c',
            'Usage__r.Telkomsel_Revenue__c',
            'Usage__r.Bucket_Detail__r.Order.SOA_Quotation_No__c',
            'Usage__r.Bucket_Detail__r.Order.SOA__r.SOA_Number__c',
            'Usage__r.Bucket_Detail__r.Order.Quote.Name',
            'Usage__r.Bucket_Detail__r.Order.Name',
            'Usage__r.Bucket_Detail__r.Order.Usage_Plan__c',
            'Usage__r.Bucket_Detail__r.Order.Completion__c',
            'Usage__r.Bucket_Detail__r.Quantity',
            'Usage__r.Bucket_Detail__r.Usage_Actual__c',
            'Usage__r.Total_Amount__c',
            'Usage__r.Sales_Price__c',
            'Usage__r.Order_Amount__c'
        };

        String csv = String.join(header, ',') + '\n';

        for (Monthly_Sales_Target__c record : records) {
            List<String> row = new List<String>{
                escapeCsv(record.Amount__c),
                escapeCsv(record.Date__c),
                escapeCsv(record.Opportunity__c),
                escapeCsv(record.Opportunity__r?.Name),
                escapeCsv(record.Usage__r?.Product_Name__c),
                escapeCsv(record.Name),
                escapeCsv(record.Usage__c),
                escapeCsv(record.Usage__r?.Name),
                escapeCsv(record.Campaign_ID__c),
                escapeCsv(record.Adjustment_Amount__c),
                escapeCsv(record.usages_telkomsel_revenue__c),
                escapeCsv(record.Opportunity_Owner__c),
                escapeCsv(record.Tipe_MST__c),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.OrderItemNumber),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Order?.Order_amount__c),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.ListPrice),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Revenue_Sales__c),
                escapeCsv(record.Usage__r?.Telkomsel_Revenue__c),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Order?.SOA_Quotation_No__c),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Order?.SOA__r?.SOA_Number__c),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Order?.Quote?.Name),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Order?.Name),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Order?.Usage_Plan__c),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Order?.Completion__c),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Quantity),
                escapeCsv(record.Usage__r?.Bucket_Detail__r?.Usage_Actual__c),
                escapeCsv(record.Usage__r?.Total_Amount__c),
                escapeCsv(record.Usage__r?.Sales_Price__c),
                escapeCsv(record.Usage__r?.Order_Amount__c)
            };
            csv += String.join(row, ',') + '\n';
        }

        return csv;
    }
}