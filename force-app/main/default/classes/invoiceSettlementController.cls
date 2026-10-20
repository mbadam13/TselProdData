/**
 *  Author      :   Yusuf Ramadhan (yusuf.ramadhan@saasten.com)
 *  Purposes    :   Controller for LWC Invoice Settlement
 *  Test Class  :   invoiceSettlementControllerTEST,invoiceSettlementController2ndTEST
 * 
 * 
 *  Date        PIC         Ref         Brief of changes
 *  01/03/24    Yusuf       TSEL-2312   Initial Create
 *  04/03/24    Yusuf       TSEL-2312   Combine records for SOAs and quotes
 *  24/04/24    Yusuf       TSEL-2312   Implement Exporting Error Logs
 *  02/05/24    Yusuf       TSEL-2312   Fix Column for Insert Data
 *  06/05/24    Yusuf       TSEL-2312   custom validation and error for some column
 *  08/05/24    Yusuf       TSEL-2312   custom validation for invoicing process
 *  10/05/24    Yusuf       TSEL-2323   Penagihan = Prepaid Only for Quotation
 *  15/05/24    Yusuf       TSEL-2312   Fix Queries records
 *  30/05/24    Yusuf       TSEL-2312   SOA has Invoice_Settlement_App__c
    07/06/24    Yusuf       id=515      Prepaid and Postpaid will be shown
    24/06/24    Yusuf       TSEL-2402   New Column 'Business Product' will be shown on Invoice Settlement
    08/08/24    Yusuf       TSEL-2404   Adjusment column import as 'Business product'
    13/08/24    Yusuf       TSEL-2404   Fahrul asked Yusuf to adjust criteria: only SOA Postpaid and Quote Prepaid
 * 
 * 
 */
public without sharing class invoiceSettlementController {

    public static Boolean isValidSalesforceId(String id) {
        return (id != null) && (id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]{15,18}$', id);
    }    

    // Validates if the input string can be converted to a date
    public static Boolean isValidDate(String dateString) {
        if (String.isEmpty(dateString)) {
            return false;
        }
        try {
            Date tempDate = Date.valueOf(dateString);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    // Validates if the input string can be converted to a decimal
    public static Boolean isValidDecimal(String decimalString) {
        if (String.isEmpty(decimalString)) {
            return false;
        }
        try {
            Decimal tempDecimal = Decimal.valueOf(decimalString);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    

    @AuraEnabled
    public static String importDataFromCSV(String base64Data) {
        String content = EncodingUtil.base64Decode(base64Data).toString();
        Boolean recordUpdated = false;
        List<String> rows = content.split('\n');
        
        List<Quote> quotesToUpdate = new List<Quote>();
        List<SOA__c> soasToUpdate = new List<SOA__c>();
        Map<Id, InvoiceWrapper> recIdWInvoiceUpdate = new Map<Id, InvoiceWrapper>();
        List<String> errors = new List<String>();
        String errorsCsv = 'Record ID,Error Message\n'; // CSV header
        Boolean errorOccured = false;


        // Assuming the first row contains headers
        for (Integer i = 1; i < rows.size(); i++) {
            String[] data;
            if (rows[i].contains(',')) {
                data = rows[i].split(',');
            } else if (rows[i].contains(';')) {
                data = rows[i].split(';');
            }

            System.debug('the data are: '+data);

            for (Integer j = 0; j < data.size(); j++) {
                data[j] = data[j].trim().replace('"', '');
                data[j] = String.valueOf(data[j]); // Convert as string so that able to use in DML
            }
        
            // Check if data array size matches CSV structure and validate Salesforce ID
            if ((data.size() == 10 || data.size() == 11 || data.size() == 12) && isValidSalesforceId(data[0])) {    
                Id recordId = Id.valueOf(data[0].trim());
                Schema.SObjectType objectType = recordId.getSObjectType();
                String sObjectType = objectType.getDescribe().getName();

                // Custom Validation Date
                if(
                    isValidDate(data[4]) == false ||
                    isValidDate(data[5]) == false
                    ){
                    errorOccured = true;
                    String sRecId = data[0];
                    String ErrorMsg = 'Invalid Date: Please make sure the format date is YYYY-MM-DD';
                    errorsCsv += sRecId + ',' + ErrorMsg + '\n'; 
                    continue; 
                }

                // Custom Validation Date
                if(isValidDecimal(data[6]) == false){
                    errorOccured = true;
                    String sRecId = data[0];
                    String ErrorMsg = 'Invalid Decimal: Please make sure the currency is numeric and dot (.) if you want to use comma';
                    errorsCsv += sRecId + ',' + ErrorMsg + '\n'; 
                    continue;
                }
        
                // Now use sObjectType to differentiate handling for 'Quote' and 'SOA__c'
                if (sObjectType.equals('Quote') && !errorOccured) { // Use equals for string comparison

                    // Initialization for 'Quote'
                    Quote quote = new Quote(
                        Id = recordId,
                        Name = data[1],
                        Start_Date__c = Date.valueOf(data[4]),
                        End_Date__c = Date.valueOf(data[5]),
                        Final_Sum_Revenue_Telkomsel__c = (data[6] != null ? Decimal.valueOf(data[6]) : 0),
                        Invoice_Settlement_App__c = true
                    );
                    quotesToUpdate.add(quote);

                } else if (sObjectType.equals('SOA__c') && !errorOccured) {
                    // Initialization for 'SOA__c'
                    SOA__c soa = new SOA__c(
                        Id = recordId,
                        // SOA_invoice__c = data[1], // Formula field
                        SOA_Start_Date__c = Date.valueOf(data[4]),
                        SOA_End_Date__c = Date.valueOf(data[5]),
                        Final_Sum_Revenue_Telkomsel__c = (data[6] != null ? Decimal.valueOf(data[6]) : 0),
                        Invoice_Settlement_App__c = true 
                    );
                    soasToUpdate.add(soa);
                }

                // Invoicing Upsert process
                if(String.isNotBlank(data[9]) && !errorOccured){
                    String invoiceId = (data.size() == 12 && data[11] != null) ? data[11] : 'NEW';
                    recIdWInvoiceUpdate.put(recordId, new InvoiceWrapper(
                        data[7], // Hak telkomsel
                        data[9], // Tanggal Invoice
                        data[10], // No Invoice
                        invoiceId
                    ));
                }
            }
        }

        if(errorOccured){
            return 'Error: ' + errorsCsv;
        }

        Savepoint sp = Database.setSavepoint();

        try {
            if(!recIdWInvoiceUpdate.isEmpty() && errorOccured == false){
                String errorOnInvoicing = UpsertingInvoice(recIdWInvoiceUpdate, errorsCsv);
                if(String.isNotBlank(errorOnInvoicing) && errorOnInvoicing.contains('Error:')){
                    Database.rollback(sp);
                    return errorOnInvoicing; // break the process
                }
            }
            if (!quotesToUpdate.isEmpty() && errorOccured == false){
                try {
                    update quotesToUpdate;
                    recordUpdated = true;
                }
                catch (DmlException dml) {
                    System.debug(dml);
                    Database.rollback(sp);
                    return errorToExport(dml);
                }  
            } 
            if (!soasToUpdate.isEmpty() && errorOccured == false) {
                try {
                    update soasToUpdate;
                    recordUpdated = true;
                }
                catch (DmlException dml) {
                    System.debug(dml);
                    Database.rollback(sp);
                    return errorToExport(dml);
                }                
            }
            
            if(recordUpdated){
                return 'Success';
            }else{
                return 'Warning';
            }

        } catch (Exception e) {
            system.debug(e.getCause());
            system.debug(e.getLineNumber());
            Database.rollback(sp);
            return 'General Error: ' + e.getMessage();
        }
    }

    public static String errorToExport(DmlException dml) {
        List<String> errors = new List<String>();
        String errorsCsv = 'Record ID,Error Message\n'; // CSV header
        for (Integer rec = 0; rec < dml.getNumDml(); rec++) {
            errors.add('Error on ' + dml.getDmlType(rec) + ' for ID ' + dml.getDmlId(rec) + ': ' + dml.getDmlMessage(rec));
            String sRecId = String.valueOf(dml.getDmlId(rec));
            String ErrorMsg = 'Error on ' + dml.getDmlType(rec) + ' for ID ' + dml.getDmlId(rec) + ': ' + dml.getDmlMessage(rec);
            errorsCsv += sRecId + ',' + ErrorMsg + '\n';             
        }
        return 'Error: ' + errorsCsv; // Prefix to indicate an error for LWC to handle
    }

    public class InvoiceWrapper {
        public String sHakTsel;
        public String sTanggalInvoice;
        public String sNoInvoice;
        public String sInvoiceId;

        public InvoiceWrapper(String sHakTsel, String sTanggalInvoice, String sNoInvoice, String sInvoiceId){
            this.sHakTsel = sHakTsel;
            this.sTanggalInvoice = sTanggalInvoice;
            this.sNoInvoice = sNoInvoice;
            this.sInvoiceId = sInvoiceId;
        }
    }

    private static String UpsertingInvoice(Map<Id, InvoiceWrapper> recIdWInvoiceUpdate, String existErrorCsv) {
        Map<Id, Invoice__c> recWInvoiceUpdate = new Map<Id, Invoice__c>();
        Map<Id, Invoice__c> recWInvoiceInsert = new Map<Id, Invoice__c>();
        List<String> errors = new List<String>();
        Map<Id, Id> invoiceWLookup = new Map<Id, Id>();
        List<Quote> quotesToUpdate = new List<Quote>();
        List<SOA__c> soasToUpdate = new List<SOA__c>();
        Map<String, String> processedInvoiceNumber = new Map<String, String>();
        String errorCsv = existErrorCsv; //Default
        Boolean duplicateInvoice = false;
        Boolean customValidationOccured = false;
        Set<Id> recIds = new Set<Id>();

        for (Id aRecordId : recIdWInvoiceUpdate.keySet()) {
            InvoiceWrapper anEditedInvoice = recIdWInvoiceUpdate.get(aRecordId);

            // custom validation date
            if(
                String.isNotBlank(anEditedInvoice.sTanggalInvoice) && 
                isValidDate(anEditedInvoice.sTanggalInvoice) == false
                ){
                    // Log Error 
                    customValidationOccured = true;
                    String sRecId = anEditedInvoice.sNoInvoice;
                    String ErrorMsg = 'Invalid Date: Please make sure the format date is YYYY-MM-DD';
                    errorCsv += sRecId + ',' + ErrorMsg + '\n'; 
                    continue;
            }

            if(
                String.isNotBlank(anEditedInvoice.sHakTsel) &&
                isValidDecimal(anEditedInvoice.sHakTsel) == false
                ){
                    // Log Error
                    customValidationOccured = true;
                    String sRecId = anEditedInvoice.sNoInvoice;
                    String ErrorMsg = 'Invalid Decimal: Please make sure the currency is numeric and dot (.) if you want to use comma';
                    errorCsv += sRecId + ',' + ErrorMsg + '\n'; 
                    continue;
            }

            Invoice__c anInvoiceUpserted = new Invoice__c();
            if(String.isNotBlank(anEditedInvoice.sInvoiceId) && anEditedInvoice.sInvoiceId != 'NEW'){ anInvoiceUpserted.Id = Id.valueOf(anEditedInvoice.sInvoiceId); }
            anInvoiceUpserted.Hak_Telkomsel__c = (String.isNotBlank(anEditedInvoice.sHakTsel) ? Decimal.valueOf(anEditedInvoice.sHakTsel) : 0);
            anInvoiceUpserted.Tanggal_Invoice__c = (String.isNotBlank(anEditedInvoice.sTanggalInvoice) ? Date.valueOf(anEditedInvoice.sTanggalInvoice) : null);
            anInvoiceUpserted.No_Invoice__c = anEditedInvoice.sNoInvoice;           
            
            
            if(processedInvoiceNumber.containsKey(anEditedInvoice.sNoInvoice)){
                // already have
                duplicateInvoice = true;
                String sRecId = String.valueOf(anEditedInvoice.sNoInvoice);
                String errorMsg = 'Duplicate Invoice Number : '+anEditedInvoice.sNoInvoice+'\n';
                errorCsv += sRecId+','+errorMsg;
                continue;
            }else{
                // haven't procces yet
                processedInvoiceNumber.put(anEditedInvoice.sNoInvoice, anEditedInvoice.sNoInvoice);
               // Check and handle new invoice entries
                if (anEditedInvoice.sInvoiceId == 'NEW' || String.isBlank(anEditedInvoice.sInvoiceId)) {
                    recWInvoiceInsert.put(aRecordId, anInvoiceUpserted);
                } else if (String.isNotBlank(anEditedInvoice.sInvoiceId)) {
                    anInvoiceUpserted.Id = Id.valueOf(anEditedInvoice.sInvoiceId);
                    recWInvoiceUpdate.put(aRecordId, anInvoiceUpserted);
                }

            }
        }

        // Check Error So Far:
        if(String.isNotBlank(errorCsv) && (duplicateInvoice || customValidationOccured)){
            return 'Error: '+errorCsv;
        }else{
            errorCsv = '';
        }
        
        if(!recWInvoiceUpdate.isEmpty() || !recWInvoiceInsert.isEmpty()){
            try {                
                if(!recWInvoiceUpdate.isEmpty()){
                    recIds.addAll(recIdWInvoiceUpdate.keySet());
                    update recWInvoiceUpdate.values();
                }

                if(!recWInvoiceInsert.isEmpty()){
                    recIds.addAll(recWInvoiceInsert.keySet());
                    insert recWInvoiceInsert.values();
                }
                
                // link it quote/soa
                for(Id recordIdUpsert : recIds){ // Interate InvoiceUpserted
                    Schema.SObjectType objectType = recordIdUpsert.getSObjectType();
                    String sObjectType = objectType.getDescribe().getName();

                    if(sObjectType.equals('Quote')){
                        Quote aQuoteUpdate = new Quote();
                        aQuoteUpdate.Id = recordIdUpsert;
                        aQuoteUpdate.Invoice_Settlement_App__c = true;
                        aQuoteUpdate.Invoice__c = (recWInvoiceUpdate.containsKey(recordIdUpsert) ? recWInvoiceUpdate.get(recordIdUpsert).Id : recWInvoiceInsert.get(recordIdUpsert).Id);
                        quotesToUpdate.add(aQuoteUpdate);
                        
                    }else if (sObjectType.equals('SOA__c')) {
                        SOA__c aSoaUpdate = new SOA__c();
                        aSoaUpdate.Id = recordIdUpsert;
                        aSoaUpdate.Invoice_Settlement_App__c = true;
                        aSoaUpdate.Invoice__c = (recWInvoiceUpdate.containsKey(recordIdUpsert) ? recWInvoiceUpdate.get(recordIdUpsert).Id : recWInvoiceInsert.get(recordIdUpsert).Id);
                        soasToUpdate.add(aSoaUpdate);
                        
                    }
                }

                if (!quotesToUpdate.isEmpty()){
                    update quotesToUpdate;
                }

                if (!soasToUpdate.isEmpty()){
                    update soasToUpdate;
                }
            }
            catch (DmlException dml) {
                errorCsv = errorToExport(dml);
            }
        }

        return errorCsv;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean canUserAccessButtons() {
        // Retrieve the name of the current user's profile
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        // Set of profiles that are not allowed to see the buttons
        Set<String> restrictedProfiles = new Set<String>{'Sales', 'Sales Manager'};
        
        // Return true if the user's profile is not in the restricted set
        return !restrictedProfiles.contains(profileName);
    }



    @AuraEnabled(cacheable=true)
    public static List<InvoiceInSOAorQuoteRecord> getCombinedRecords(Date startDate, Date endDate) {
        List<InvoiceInSOAorQuoteRecord> InvoiceInSOAorQuoteRecords = new List<InvoiceInSOAorQuoteRecord>();

        // Query SOA__c records
        List<SOA__c> soaRecords = [SELECT Id, SOA_invoice__c, Opportunity__r.AccountId, Opportunity__r.Account.Name, 
                                    Invoice__r.PKS__c, Invoice__r.Jangka_Waktu_PKS__c, SOA_Start_Date__c,
                                    SOA_End_Date__c, Final_Sum_Revenue_Telkomsel__c, Selisih_Revenue__c, Business_Product__c,
                                    Invoice__r.Tanggal_Invoice__c, Invoice__r.No_Master__c, Invoice__r.No_Individual__c,
                                    Invoice__r.Region__c, Invoice__r.No_Invoice__c, Invoice__r.Hak_Telkomsel__c,
                                    Opportunity__r.Penagihan_based_on__c  
                                    FROM SOA__c 
                                    WHERE SOA_Start_Date__c >= :startDate 
                                    AND SOA_Start_Date__c <= :endDate];

        // Query Quote records
        List<Quote> quoteRecords = [SELECT Id, Name, Opportunity.AccountId, Opportunity.Account.Name, 
                                    Invoice__r.PKS__c, Invoice__r.Jangka_Waktu_PKS__c, Start_Date__c,
                                    End_Date__c, Final_Sum_Revenue_Telkomsel__c, Selisih_Revenue__c, 
                                    Invoice__r.Tanggal_Invoice__c, Business_Product__c, Penagihan__c,
                                    Invoice__r.No_Master__c, Invoice__r.No_Individual__c, Invoice__r.Region__c,
                                    Invoice__r.No_Invoice__c, Invoice__r.Hak_Telkomsel__c,
                                    Opportunity.Penagihan_based_on__c  
                                    FROM Quote 
                                    WHERE Start_Date__c >= :startDate 
                                    AND Start_Date__c <= :endDate];

        // Query related Order records for SOA__c
        Set<Id> soaIds = new Set<Id>();
        for (SOA__c soa : soaRecords) {
        soaIds.add(soa.Id);
        }

        Map<Id, Order> soaOrderMap = new Map<Id, Order>();
        List<Order> soaOrders = [SELECT Id, SOA__c, Penagihan__c FROM Order WHERE SOA__c IN :soaIds 
                                    AND Penagihan__c = 'Postpaid'
                                ];
        for (Order ord : soaOrders) {
            soaOrderMap.put(ord.SOA__c, ord);
        }

        // Query related Order records for Quote
        Set<Id> quoteIds = new Set<Id>();
        for (Quote quote : quoteRecords) {
            quoteIds.add(quote.Id);
        }

        Map<Id, Order> quoteOrderMap = new Map<Id, Order>();
        List<Order> quoteOrders = [SELECT Id, QuoteId, Penagihan__c FROM Order WHERE QuoteId IN :quoteIds 
                                    AND Penagihan__c = 'Prepaid'
                                ];
        for (Order ord : quoteOrders) {
            quoteOrderMap.put(ord.QuoteId, ord);
        }
        
        // Combine records
        for (SOA__c soa : soaRecords) {
            if (soaOrderMap.containsKey(soa.Id)) {
                InvoiceInSOAorQuoteRecords.add(new InvoiceInSOAorQuoteRecord(
                soa.Id, 
                soa.SOA_invoice__c, 
                soa.Opportunity__r.AccountId,
                removeUnintendedComma(soa.Opportunity__r.Account.Name), 
                soa.Invoice__r.PKS__c,
                soa.Invoice__r.Jangka_Waktu_PKS__c,
                soa.SOA_Start_Date__c,
                soa.SOA_End_Date__c,
                soa.Final_Sum_Revenue_Telkomsel__c,
                soa.Invoice__r.Hak_Telkomsel__c,
                soa.Selisih_Revenue__c,
                soa.Invoice__r.Tanggal_Invoice__c,
                soa.Opportunity__r.Penagihan_based_on__c,
                soa.Invoice__r.No_Master__c,
                soa.Invoice__r.No_Individual__c,
                soa.Invoice__r.Region__c,
                soa.Invoice__r.No_Invoice__c,
                soa.Invoice__c,
                soa.Business_Product__c
                ));
            }            
        }
        for (Quote quote : quoteRecords) {
            if (quoteOrderMap.containsKey(quote.Id)) {
                InvoiceInSOAorQuoteRecords.add(new InvoiceInSOAorQuoteRecord(
                quote.Id,
                quote.Name,
                quote.Opportunity.AccountId,
                removeUnintendedComma(quote.Opportunity.Account.Name),
                quote.Invoice__r.PKS__c,
                quote.Invoice__r.Jangka_Waktu_PKS__c,
                quote.Start_Date__c,
                quote.End_Date__c,
                quote.Final_Sum_Revenue_Telkomsel__c,
                quote.Invoice__r.Hak_Telkomsel__c,
                quote.Selisih_Revenue__c,
                quote.Invoice__r.Tanggal_Invoice__c,
                quote.Penagihan__c,
                quote.Invoice__r.No_Master__c,
                quote.Invoice__r.No_Individual__c,
                quote.Invoice__r.Region__c,
                quote.Invoice__r.No_Invoice__c,
                quote.Invoice__c,
                quote.Business_Product__c
                ));
            }
        }
        
        return InvoiceInSOAorQuoteRecords;
    }

    private static String removeUnintendedComma(String text) {
        if(String.isNotBlank(text)){
            return text.replace(',', '.');
        }else{
            return text;
        }
        
    }
    

    public class InvoiceInSOAorQuoteRecord {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String RecordName;
        @AuraEnabled public Id MitraId;
        @AuraEnabled public String MitraName;
        @AuraEnabled public String Pks;
        @AuraEnabled public String JangkaWaktuPks;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public Double FinalTselRevenue;
        @AuraEnabled public Double FinalHakTsel;
        @AuraEnabled public Double SelisihFinalRevenue;
        @AuraEnabled public Date tanggalInvoice;
        @AuraEnabled public String typeBisnis;
        @AuraEnabled public String noMaster;
        @AuraEnabled public String noIndividual;
        @AuraEnabled public String region;
        @AuraEnabled public String invoiceName;
        @AuraEnabled public Id invoiceId;
        @AuraEnabled public String businessProduct;        

        
        public InvoiceInSOAorQuoteRecord(Id recordId, 
                                            String RecordName,
                                            Id MitraId,
                                            String MitraName,
                                            String Pks,
                                            String JangkaWaktuPks,
                                            Date startDate,
                                            Date endDate,
                                            Decimal FinalTselRevenue,
                                            Decimal FinalHakTsel,
                                            Decimal SelisihFinalRevenue,
                                            Date tanggalInvoice,
                                            String typeBisnis,
                                            String noMaster,
                                            String noIndividual,
                                            String region,
                                            String invoiceName,
                                            Id invoiceId,
                                            String businessProduct) {
            this.recordId = recordId;
            this.RecordName = RecordName;
            this.MitraId = MitraId;
            this.MitraName = MitraName;
            this.Pks = Pks;
            this.JangkaWaktuPks = JangkaWaktuPks;
            this.startDate = startDate;
            this.endDate = endDate;
            this.FinalTselRevenue = (FinalTselRevenue == null ? 0 : FinalTselRevenue);
            this.FinalHakTsel = (FinalHakTsel == null ? 0 : FinalHakTsel);
            this.SelisihFinalRevenue = SelisihFinalRevenue;
            this.tanggalInvoice = tanggalInvoice;
            this.typeBisnis = typeBisnis;
            this.noMaster = noMaster;
            this.noIndividual = noIndividual;
            this.region = region;
            this.invoiceName = invoiceName;
            this.invoiceId = invoiceId;
            this.businessProduct = businessProduct;
        }
    }
    
}