/**
 * @description       : 
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
@isTest
public without sharing class TestJSONAccount {
    @isTest
    static void testParse() {
        // Create a sample JSON string
        String jsonString = '{' +
            '"allOrNone": true,' +
            '"records": [' +
                '{' +
                    '"attributes": {"type": "Account"},' +
                    '"RecordTypeId": "0123I000000XXXX",' +
                    '"External_Id_Z": "EXT123",' +
                    '"Name": "Test Account",' +
                    '"Account_Type_Z": "Customer",' +
                    '"Website": "http://example.com",' +
                    '"Phone": "123-456-7890",' +
                    '"Email_Z": "contact@example.com",' +
                    '"Telephone_2_Z": "098-765-4321",' +
                    '"Fax": "123-456-7891",' +
                    '"Fax_Number_2_Z": "098-765-4322",' +
                    '"BP_Number_Z": "BP123",' +
                    '"LOB_Z": "Retail",' +
                    '"User_ID_Z": "User123",' +
                    '"Kategori_Bisnis_Z": "TypeA",' +
                    '"Account_Category_Z": "CategoryA",' +
                    '"Registrasi_Status_Z": "Registered",' +
                    '"No_PKS_Z": "PKS123",' +
                    '"Active_Contract_Start_Date_Z": "2024-01-01",' +
                    '"Active_Contract_End_Date_Z": "2024-12-31",' +
                    '"ContractId_Z": "Contract123",' +
                    '"Ext_Partner_Id_Z": "Partner123",' +
                    '"Merchant_Id_Z": "Merchant123",' +
                    '"Description": "Test Description",' +
                    '"Legal_Name_Z": "Legal Name",' +
                    '"NPWP_Z": "NPWP123",' +
                    '"NPWP_Address_Z": "NPWP Address",' +
                    '"Email_Address_Tax_Z": "tax@example.com",' +
                    '"Email_Address_Payment_Z": "payment@example.com",' +
                    '"Email_Address_Finance_or_A_P_Z": "finance@example.com",' +
                    '"Email_Address_Marketing_Z": "marketing@example.com",' +
                    '"Balance_Top_Up_Voucher_Z": 100.50,' +
                    '"Balance_Top_Up_Invoice_Z": 200.75,' +
                    '"Total_Balance_Z": 300.25,' +
                    '"Balance_Terpakai_Z": 150.00,' +
                    '"Balance_Remaining_Z": 150.25,' +
                    '"Total_Revenue_Z": 1000.00,' +
                    '"Tanggal_Approval_Z": "2024-07-01",' +
                    '"Tanggal_Daftar_Z": "2024-01-01"' +
                '}' +
            ']' +
        '}';

        // Parse the JSON string
        JSONAccount account = JSONAccount.parse(jsonString);

        // Verify the parsed object
        System.assertNotEquals(null, account);
        System.assertEquals(true, account.allOrNone);
        System.assertNotEquals(null, account.records);
        System.assertEquals(1, account.records.size());

        JSONAccount.Records record = account.records[0];
        System.assertEquals('Account', record.attributes.type);
        System.assertEquals('0123I000000XXXX', record.RecordTypeId);
        System.assertEquals('EXT123', record.External_Id_Z);
        System.assertEquals('Test Account', record.Name);
        System.assertEquals('Customer', record.Account_Type_Z);
        System.assertEquals('http://example.com', record.Website);
        System.assertEquals('123-456-7890', record.Phone);
        System.assertEquals('contact@example.com', record.Email_Z);
        System.assertEquals('098-765-4321', record.Telephone_2_Z);
        System.assertEquals('123-456-7891', record.Fax);
        System.assertEquals('098-765-4322', record.Fax_Number_2_Z);
        System.assertEquals('BP123', record.BP_Number_Z);
        System.assertEquals('Retail', record.LOB_Z);
        System.assertEquals('User123', record.User_ID_Z);
        System.assertEquals('TypeA', record.Kategori_Bisnis_Z);
        System.assertEquals('CategoryA', record.Account_Category_Z);
        System.assertEquals('Registered', record.Registrasi_Status_Z);
        System.assertEquals('PKS123', record.No_PKS_Z);
        System.assertEquals(Date.newInstance(2024, 1, 1), record.Active_Contract_Start_Date_Z);
        System.assertEquals(Date.newInstance(2024, 12, 31), record.Active_Contract_End_Date_Z);
        System.assertEquals('Contract123', record.ContractId_Z);
        System.assertEquals('Partner123', record.Ext_Partner_Id_Z);
        System.assertEquals('Merchant123', record.Merchant_Id_Z);
        System.assertEquals('Test Description', record.Description);
        System.assertEquals('Legal Name', record.Legal_Name_Z);
        System.assertEquals('NPWP123', record.NPWP_Z);
        System.assertEquals('NPWP Address', record.NPWP_Address_Z);
        System.assertEquals('tax@example.com', record.Email_Address_Tax_Z);
        System.assertEquals('payment@example.com', record.Email_Address_Payment_Z);
        System.assertEquals('finance@example.com', record.Email_Address_Finance_or_A_P_Z);
        System.assertEquals('marketing@example.com', record.Email_Address_Marketing_Z);
        System.assertEquals(100.50, record.Balance_Top_Up_Voucher_Z);
        System.assertEquals(200.75, record.Balance_Top_Up_Invoice_Z);
        System.assertEquals(300.25, record.Total_Balance_Z);
        System.assertEquals(150.00, record.Balance_Terpakai_Z);
        System.assertEquals(150.25, record.Balance_Remaining_Z);
        System.assertEquals(1000.00, record.Total_Revenue_Z);
        System.assertEquals(Date.newInstance(2024, 7, 1), record.Tanggal_Approval_Z);
        System.assertEquals(Date.newInstance(2024, 1, 1), record.Tanggal_Daftar_Z);
    }

    @isTest
    static void testEmptyJson() {
        // Create an empty JSON string
        String jsonString = '{}';

        // Parse the JSON string
        JSONAccount account = JSONAccount.parse(jsonString);

        // Verify the parsed object
        System.assertNotEquals(null, account);
        System.assertEquals(null, account.allOrNone);
        System.assertEquals(null, account.records);
    }
}