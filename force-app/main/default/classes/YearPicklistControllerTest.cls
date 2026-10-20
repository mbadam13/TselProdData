/**
 * @description       : Test Class Year Picklist Controller For LWC Picklist Support to Screeen Flow  
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/



@isTest
public class YearPicklistControllerTest {
    @isTest
    public static void testGetYearPicklistValues() {
        // Call the method
        List<String> yearList = YearPicklistController.getYearPicklistValues();
        
        // Verify the size of the list
        Integer expectedSize = 5;
        System.assertEquals(expectedSize, yearList.size(), 'The year list should have 5 years');

        // Verify the contents of the list
        Integer currentYear = Date.today().year();
        for (Integer i = 0; i < expectedSize; i++) {
            String expectedYear = String.valueOf(currentYear + i);
            System.assertEquals(expectedYear, yearList[i], 'Year list contains the correct year');
        }
    }

}