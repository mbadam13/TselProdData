/**
 * @description       : 
 * Test Class         : YearPicklistControllerTest
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-01-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class YearPicklistController {
    @AuraEnabled(cacheable=true)
    public static List<String> getYearPicklistValues() {
        List<String> yearList = new List<String>();
        Integer currentYear = Date.today().year();
        for (Integer i = 0; i <= 4; i++) {
            yearList.add(String.valueOf(currentYear + i));
        }
        return yearList;
    }
}