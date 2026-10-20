/**
 * @description       : 
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
@IsTest
public without sharing class TestJSONLead {
    @IsTest
    static void testParse() {
        // Create a sample JSON string
        String jsonString = '{' +
            '"allOrNone": true,' +
            '"records": [' +
                '{' +
                    '"attributes": {"type": "Lead"},' +
                    '"id": "00Q1I00000XXXXXX",' +
                    '"NumberOfEmployees": 100,' +
                    '"Company": "Test Company",' +
                    '"Account_Type_Z": "Customer",' +
                    '"Legal_Name_Z": "Test Legal Name",' +
                    '"Status": "Open",' +
                    '"LeadSource": "Web",' +
                    '"Regional_Z": "North America",' +
                    '"Rating": "Hot",' +
                    '"LastName": "Doe",' +
                    '"Description": "Test Description",' +
                    '"Email": "test@example.com",' +
                    '"Phone": "123-456-7890",' +
                    '"isConverted_Z": false' +
                '}' +
            ']' +
        '}';

        // Parse the JSON string
        JSONLead lead = JSONLead.parse(jsonString);

        // Verify the parsed object
        System.assertNotEquals(null, lead);
        System.assertEquals(true, lead.allOrNone);
        System.assertNotEquals(null, lead.records);
        System.assertEquals(1, lead.records.size());

        JSONLead.Records record = lead.records[0];
        System.assertEquals('Lead', record.attributes.type);
        System.assertEquals('00Q1I00000XXXXXX', record.id);
        System.assertEquals(100, record.NumberOfEmployees);
        System.assertEquals('Test Company', record.Company);
        System.assertEquals('Customer', record.Account_Type_Z);
        System.assertEquals('Test Legal Name', record.Legal_Name_Z);
        System.assertEquals('Open', record.Status);
        System.assertEquals('Web', record.LeadSource);
        System.assertEquals('North America', record.Regional_Z);
        System.assertEquals('Hot', record.Rating);
        System.assertEquals('Doe', record.LastName);
        System.assertEquals('Test Description', record.Description);
        System.assertEquals('test@example.com', record.Email);
        System.assertEquals('123-456-7890', record.Phone);
        System.assertEquals(false, record.isConverted_Z);
    }

    @IsTest
    static void testEmptyJson() {
        // Create an empty JSON string
        String jsonString = '{}';

        // Parse the JSON string
        JSONLead lead = JSONLead.parse(jsonString);

        // Verify the parsed object
        System.assertNotEquals(null, lead);
        System.assertEquals(null, lead.allOrNone);
        System.assertEquals(null, lead.records);
    }
}