/**
 * @description       : SERVICES CLASS FOR OBJECT LEAD
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : RKA
**/
public class LeadServices {
    
    /**
    * @description DELETE LEAD IN CSSM
    * @author RKA | 07-05-2024 
    * @param leadCSSMId 
    **/
    @future(callout = true)
    public static void deleteLeadCSSM(String leadCSSMId) {
        Map<String,String> mapHeader = new Map<String,String>();

        List<String> leadIds = new List<String>();
        leadIds.add(leadCSSMId);

        String strLeadIds = '';
        if (leadIds.size() > 1) {
            strLeadIds = String.join(leadIds, '\',\'');
        } else if (leadIds.size() == 1) {
            strLeadIds = leadCSSMId;
        }

        try {
            mapHeader.put('Content-Type', 'application/json');

            UtilIntegration.deleteLead('SFCSSM_Delete_Lead', strLeadIds+'&allOrNone=true', mapHeader);
        } catch (Exception ex) {
            UtilLog.createLog('LeadServices', 'deleteLeadCSSM', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
    }

    /**
    * @description UPDATE LEAD DETAILS IN CSSM
    * @author RKA | 07-05-2024 
    * @param leadIds 
    **/
    @future(callout = true)
    public static void patchLead(Set<String> leadIds) {
        Map<String,String> header = new Map<String,String>();
        header.put('Content-Type', 'application/json');
        
        List<String> leadIds2 = new List<String>();
        leadIds2.addAll(leadIds);
        
        JSONLead jsonLead = new JSONLead();
        jsonLead.allOrNone = true;
        
        List<JSONLead.Records> records = new List<JSONLead.Records>();
        List<Object> responses = new List<Object>();
        
        JSONLead.Attributes attributes = new JSONLead.Attributes();
        attributes.type = 'Lead';
        
        String condition = 'Id IN (\'' + String.join(leadIds2, '\', \'') + '\')';
        try {
            List<Lead> leads = UtilSOQL.sobjects('', 'Lead', condition, '', '', '');
            if (leads.size() > 0) {
                for (Lead ld : leads) {
                    JSONLead.Records record = populateJSONLead(ld, false, attributes);
                    records.add(record);
                }
                jsonLead.records = records;
                
                String reqBody = JSON.serialize(jsonLead);
                if (reqBody.contains('_Z')) {
                    reqBody = reqBody.replace('_Z', '__c');
                }
                reqBody = UtilJSON.removeNullsAndEmptyValues(reqBody);
                HttpResponse res = UtilIntegration.postLead('SFCSSM_Patch_Lead', reqBody, header);
            }
        } catch (Exception ex) {
            UtilLog.createLog('LeadServices', 'patchLead', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
    }

    /**
    * @description CONVERT LEAD IN CSSM 
    * @author RKA | 07-05-2024 
    * @param leadIds 
    **/
    @future(callout = true)
    public static void convertLead(Set<String> leadIds) {
        Map<String,String> header = new Map<String,String>();
        header.put('Content-Type', 'application/json');

        List<String> leadDataIds = new List<String>();
        leadDataIds.addAll(leadIds);

        String condition = 'Id IN (\'' + String.join(leadIds, '\', \'') + '\')';
        String addFields = ', ConvertedAccount.Id, ConvertedContact.Id, ConvertedAccount.Name, ConvertedAccount.Account_Type__c, '+
                'ConvertedAccount.Website, ConvertedAccount.Phone, ConvertedAccount.Email__c, ConvertedAccount.Telephone_2__c, ConvertedAccount.Fax, '+
                'ConvertedAccount.Fax_Number_2__c, ConvertedAccount.BP_Number__c, ConvertedAccount.LOB__c, ConvertedAccount.User_ID__c, '+
                'ConvertedAccount.Kategori_Bisnis__c, ConvertedAccount.Account_Category__c, ConvertedAccount.Registrasi_Status__c, ConvertedAccount.No_PKS__c, '+
                'ConvertedAccount.Active_Contract_Start_Date__c, ConvertedAccount.Active_Contract_End_Date__c, ConvertedAccount.ContractId__c, ConvertedAccount.Ext_Partner_Id__c, '+
                'ConvertedAccount.Merchant_Id__c, ConvertedAccount.Description, ConvertedAccount.Legal_Name__c, ConvertedAccount.NPWP__c, ConvertedAccount.NPWP_Address__c, ConvertedAccount.Email_Address_Tax__c, '+
                'ConvertedAccount.Email_Address_Payment__c, ConvertedAccount.Email_Address_Finance_or_A_P__c, ConvertedAccount.Email_Address_Marketing__c, ConvertedAccount.Balance_Top_Up_Voucher__c, '+
                'ConvertedAccount.Balance_Top_Up_Invoice__c, ConvertedAccount.Total_Balance__c, ConvertedAccount.Balance_Terpakai__c, ConvertedAccount.Balance_Remaining__c, ConvertedAccount.Total_Revenue__c, ConvertedAccount.Tanggal_Approval__c, '+
                'ConvertedAccount.Tanggal_Daftar__c, ConvertedContact.FirstName, ConvertedContact.LastName, ConvertedContact.AccountId, '+
                'ConvertedContact.Title, ConvertedContact.Email, ConvertedContact.Phone, ConvertedContact.MobilePhone, ConvertedContact.ReportsToId, ConvertedContact.Department, ConvertedContact.Fax';
        String reqBody = '';

        JSONAccount jsonAcc = new JSONAccount();
        jsonAcc.allOrNone = true;

        JSONAccount.Attributes attributes = new JSONAccount.Attributes();
        attributes.type = 'Account';

        List<JSONAccount.Records> records = new List<JSONAccount.Records>();
        List<Object> responses = new List<Object>();

        try {
            List<Lead> leads = (List<Lead>) UtilSOQL.sobjects(addFields, 'Lead', condition, '', '', '');
            if (leads.size() > 0) {
                for (Lead ld : leads) {
                    System.debug('attributes = '+attributes);
                    JSONAccount.Records record = populateJSONAccount(ld, attributes);
                    records.add(record);
                }
                jsonAcc.records = records;
                reqBody = JSON.serialize(jsonAcc);
                if (reqBody.contains('_Z')) {
                    reqBody = reqBody.replace('_Z', '__c');
                }
                reqBody = UtilJSON.removeNullsAndEmptyValues(reqBody);
                HttpResponse resAcc = UtilIntegration.postAccount('SFCSSM_Post_Account', reqBody, header);
                if (resAcc != null) {
                    if (String.valueOf(resAcc.getStatusCode()).startsWith('2')) {
                        responses = (List<Object>) JSON.deserializeUntyped(resAcc.getBody());
                        if (responses.size() > 0) {
                            for (Object resObj : responses) {
                                Map<String,Object> mapAcc = (Map<String,Object>) resObj;
                                if (mapAcc.containsKey('id')) {
                                    populateCSSMContact(leads, (String) mapAcc.get('id'));
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            UtilLog.createLog('LeadServices', 'convertLead', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
    }

    private static void populateCSSMContact(List<Lead> leads, String accId) {
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('Content-Type', 'application/json');

        List<JSONContact.Records> conRecords = new List<JSONContact.Records>();
        List<Object> responses = new List<Object>();

        JSONContact jsonCon = new JSONContact();
        JSONContact.Attributes attributes = new JSONContact.Attributes();

        String reqBody = '';
        
        jsonCon.allOrNone = true;
        attributes.type = 'Contact';

        try {
            if (leads.size() > 0) {
                for (Lead ld : leads) {
                    JSONContact.Records record = populateJSONContact(ld, attributes, accId);
                    conRecords.add(record);
                }
                jsonCon.records = conRecords;
                reqBody = JSON.serialize(jsonCon);
                if (reqBody.contains('_Z')) {
                    reqBody = reqBody.replace('_Z', '__c');
                }
                reqBody = UtilJSON.removeNullsAndEmptyValues(reqBody);
                HttpResponse resCon = UtilIntegration.postContact('SFCSSM_Post_Contact', reqBody, mapHeader);
                if (resCon != null) {
                    if (String.valueOf(resCon.getStatusCode()).startsWith('2')) {
                        responses = (List<Object>) JSON.deserializeUntyped(resCon.getBody());
                        if (responses.size() > 0) {
                            for (Object resObj : responses) {
                                Map<String,Object> mapAcc = (Map<String,Object>) resObj;
                                if (mapAcc.containsKey('errors')) {
                                    List<Object> errors = (List<Object>) mapAcc.get('errors');
                                    if (errors.size() == 0) {
                                        populateLeadCSSMIsConverted(leads);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            UtilLog.createLog('LeadServices', 'populateCSSMContact', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
    }

    private static void populateLeadCSSMIsConverted(List<Lead> leads) {
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('Content-Type', 'application/json');
        
        List<JSONLead.Records> ledRecords = new List<JSONLead.Records>();

        JSONLead jsonLead = new JSONLead();
        JSONLead.Attributes attributes = new JSONLead.Attributes();

        jsonLead.allOrNone = true;
        attributes.type = 'Lead';

        String reqBody = '';
        try {
            for (Lead ld : leads) {
                JSONLead.Records record = populateJSONLead(ld, true, attributes);
                ledRecords.add(record);
            }
            jsonLead.records = ledRecords;
            reqBody = '';
            reqBody = JSON.serialize(jsonLead);
            if (reqBody.contains('_Z')) {
                reqBody = reqBody.replace('_Z', '__c');
            }
            reqBody = UtilJSON.removeNullsAndEmptyValues(reqBody);
            HttpResponse resLead = UtilIntegration.postLead('SFCSSM_Patch_Lead', reqBody, mapHeader);

        } catch (Exception ex) {
            UtilLog.createLog('LeadServices', 'populateLeadCSSMConverted', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
    }
    
    /**
    * @description POPULATE JSON LEAD
    * @author RKA | 07-05-2024 
    * @param ld 
    * @param attributes 
    * @return JSONLead.Records 
    **/
    private static JSONLead.Records populateJSONLead(Lead ld, Boolean isConverted, JSONLead.Attributes attributes) {
        JSONLead.Records record = new JSONLead.Records();
        record.attributes = attributes;
        record.id = ld.CSSM_Record_Id_DigiAds__c;
        record.Company = ld.Company;
        record.Account_Type_Z = ld.Account_Type__c;
        record.Legal_Name_Z = ld.Legal_Name__c;
        String status = ld.Status;
        if (ld.Status == 'Follow_Up') {
            status = 'Follow Up';
        }
        record.Status = status;
        String lsource= ld.LeadSource;
        if (ld.LeadSource == 'Contact Us Form') {
            lsource = 'Web-to-lead';
        }
        record.LeadSource = lsource;
        record.Rating = ld.Rating;
        record.LastName = ld.LastName;
        record.Email = ld.Email;
        record.Description = ld.Description;
        record.Phone = ld.Phone;
        record.isConverted_Z = isConverted;
        return record;
    }

    /**
    * @description POPULATE JSON CONTACT
    * @author RKA | 07-05-2024 
    * @param ld 
    * @param attributes 
    * @param accountId 
    * @return JSONContact.Records 
    **/
    private static JSONContact.Records populateJSONContact(Lead ld, JSONContact.Attributes attributes, String accountId) {
        JSONContact.Records record = new JSONContact.Records();
        record.attributes = attributes;
        record.RecordTypeId = System.Label.RT_CSSM_CONTACT;
        record.External_Id_Z = ld.ConvertedContact.Id;
        record.FirstName = ld.ConvertedContact.FirstName;
        record.LastName = ld.ConvertedContact.LastName;
        record.AccountId = accountId;
        record.Title = ld.ConvertedContact.Title;
        record.Email = ld.ConvertedContact.Email;
        record.Phone = ld.ConvertedContact.Phone;
        record.MobilePhone = ld.ConvertedContact.MobilePhone;
        record.Originally_Reports_to_Z = ld.ConvertedContact.ReportsToId;
        record.Department = ld.ConvertedContact.Department;
        record.Fax = ld.ConvertedContact.Fax;
        return record;
    }

    /**
    * @description POPULATE JSON ACCOUNT
    * @author RKA | 07-05-2024 
    * @param ld 
    * @param attributes 
    * @return JSONAccount.Records 
    **/
    private static JSONAccount.Records populateJSONAccount(Lead ld, JSONAccount.Attributes attributes) {
        JSONAccount.Records record = new JSONAccount.Records();
        record.attributes = attributes;
        record.RecordTypeId = System.Label.RT_CSSM_Account;
        record.Name = ld.ConvertedAccount.Name;
        record.External_Id_Z = ld.ConvertedAccount.Id;
        record.Account_Type_Z = ld.ConvertedAccount.Account_Type__c;
        record.Website = ld.ConvertedAccount.Website;
        record.Phone = ld.ConvertedAccount.Phone;
        record.Email_Z = ld.ConvertedAccount.Email__c;
        record.Telephone_2_Z = ld.ConvertedAccount.Telephone_2__c;
        record.Fax = ld.ConvertedAccount.Fax;
        record.Fax_Number_2_Z = ld.ConvertedAccount.Fax_Number_2__c;
        record.BP_Number_Z = ld.ConvertedAccount.BP_Number__c;
        record.LOB_Z = ld.ConvertedAccount.LOB__c;
        record.User_ID_Z = ld.ConvertedAccount.User_ID__c;
        record.Kategori_Bisnis_Z = ld.ConvertedAccount.Kategori_Bisnis__c;
        record.Account_Category_Z = ld.ConvertedAccount.Account_Category__c;
        record.Registrasi_Status_Z = ld.ConvertedAccount.Registrasi_Status__c;
        record.No_PKS_Z = ld.ConvertedAccount.No_PKS__c;
        record.Active_Contract_Start_Date_Z = ld.ConvertedAccount.Active_Contract_Start_Date__c;
        record.Active_Contract_End_Date_Z = ld.ConvertedAccount.Active_Contract_End_Date__c;
        record.ContractId_Z = ld.ConvertedAccount.ContractId__c;
        record.Ext_Partner_Id_Z = ld.ConvertedAccount.Ext_Partner_Id__c;
        record.Merchant_Id_Z = ld.ConvertedAccount.Merchant_Id__c;
        record.Description = ld.ConvertedAccount.Description;
        record.Legal_Name_Z = ld.ConvertedAccount.Legal_Name__c;
        record.NPWP_Z = ld.ConvertedAccount.NPWP__c;
        record.NPWP_Address_Z = ld.ConvertedAccount.NPWP_Address__c;
        record.Email_Address_Tax_Z = ld.ConvertedAccount.Email_Address_Tax__c;
        record.Email_Address_Payment_Z = ld.ConvertedAccount.Email_Address_Payment__c;
        record.Email_Address_Finance_or_A_P_Z = ld.ConvertedAccount.Email_Address_Finance_or_A_P__c;
        record.Email_Address_Marketing_Z = ld.ConvertedAccount.Email_Address_Marketing__c;
        record.Balance_Top_Up_Voucher_Z = ld.ConvertedAccount.Balance_Top_Up_Voucher__c;
        record.Balance_Top_Up_Invoice_z = ld.ConvertedAccount.Balance_Top_Up_Invoice__c;
        record.Total_Balance_Z = ld.ConvertedAccount.Total_Balance__c;
        record.Balance_Terpakai_Z = ld.ConvertedAccount.Balance_Terpakai__c;
        record.Balance_Remaining_Z = ld.ConvertedAccount.Balance_Remaining__c;
        record.Total_Revenue_Z = ld.ConvertedAccount.Total_Revenue__c;
        record.Tanggal_Approval_Z = ld.ConvertedAccount.Tanggal_Approval__c;
        record.Tanggal_Daftar_Z = ld.ConvertedAccount.Tanggal_Daftar__c;
        return record;
    }
}