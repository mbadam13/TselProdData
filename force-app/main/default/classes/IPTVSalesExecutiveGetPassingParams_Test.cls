/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-15-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class IPTVSalesExecutiveGetPassingParams_Test {
    @isTest
    static void testPassingParameter(){
        List<String> urlValue = new List<String>{
            'https://digiads--pc1.sandbox.my.site.com/SalesExecutive/s/create-oppty?extUsername_Text={!NIK}'
        };

        List<IPTVSalesExecutiveGetPassingParameter.OutputValue> result = IPTVSalesExecutiveGetPassingParameter.checkApprovalStatus(urlValue);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }    
}