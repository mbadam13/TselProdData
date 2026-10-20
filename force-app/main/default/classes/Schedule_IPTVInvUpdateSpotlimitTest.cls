@isTest 
public class Schedule_IPTVInvUpdateSpotlimitTest {
    @isTest
    static void testExecute() {
        Schedule_IPTVInvUpdateSpotlimit schedulableInstance = new Schedule_IPTVInvUpdateSpotlimit();
        Test.startTest();
        schedulableInstance.execute(null);
        Test.stopTest();
    }

}