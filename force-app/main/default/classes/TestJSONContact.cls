/**
 * @description       : 
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
@IsTest
public without sharing class TestJSONContact {
    @isTest
    static void testParse() {
        // Create a sample JSON string
        String jsonString = '{' +
            '"allOrNone": true,' +
            '"records": [' +
                '{' +
                    '"attributes": {"type": "Contact"},' +
                    '"RecordTypeId": "0123I000000XXXX",' +
                    '"External_Id_Z": "EXT123",' +
                    '"FirstName": "John",' +
                    '"LastName": "Doe",' +
                    '"AccountId": "0013I00000XXXXXX",' +
                    '"Title": "Manager",' +
                    '"Email": "john.doe@example.com",' +
                    '"Phone": "123-456-7890",' +
                    '"MobilePhone": "098-765-4321",' +
                    '"Originally_Reports_to_Z": "0013I00000YYYYYY",' +
                    '"Department": "Sales",' +
                    '"Fax": "123-456-7891"' +
                '}' +
            ']' +
        '}';

        // Parse the JSON string
        JSONContact contact = JSONContact.parse(jsonString);

        // Verify the parsed object
        System.assertNotEquals(null, contact);
        System.assertEquals(true, contact.allOrNone);
        System.assertNotEquals(null, contact.records);
        System.assertEquals(1, contact.records.size());

        JSONContact.Records record = contact.records[0];
        System.assertEquals('Contact', record.attributes.type);
        System.assertEquals('0123I000000XXXX', record.RecordTypeId);
        System.assertEquals('EXT123', record.External_Id_Z);
        System.assertEquals('John', record.FirstName);
        System.assertEquals('Doe', record.LastName);
        System.assertEquals('0013I00000XXXXXX', record.AccountId);
        System.assertEquals('Manager', record.Title);
        System.assertEquals('john.doe@example.com', record.Email);
        System.assertEquals('123-456-7890', record.Phone);
        System.assertEquals('098-765-4321', record.MobilePhone);
        System.assertEquals('0013I00000YYYYYY', record.Originally_Reports_to_Z);
        System.assertEquals('Sales', record.Department);
        System.assertEquals('123-456-7891', record.Fax);
    }

    @isTest
    static void testEmptyJson() {
        // Create an empty JSON string
        String jsonString = '{}';

        // Parse the JSON string
        JSONContact contact = JSONContact.parse(jsonString);

        // Verify the parsed object
        System.assertNotEquals(null, contact);
        System.assertEquals(null, contact.allOrNone);
        System.assertEquals(null, contact.records);
    }
}