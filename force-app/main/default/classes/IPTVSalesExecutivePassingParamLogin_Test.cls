/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-15-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class IPTVSalesExecutivePassingParamLogin_Test {
    @isTest
    static void testPassingParams(){
        List<String> urlValue = new List<String>{
            'https://digiads--pc1.sandbox.my.site.com/SalesExecutive/s/view-oppty-records?NIK={!NIK}'
        };
        
        List<IPTVSalesExecutivePassingParamsLogin.OutputValue> result = IPTVSalesExecutivePassingParamsLogin.checkApprovalStatus(urlValue);
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
   }
}