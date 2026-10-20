/**
 * @description       : CLASS UTILITY FOR INSERT LOG
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : RKA
**/
public without sharing class UtilLog {
    public static void createLog(String className, String methodName, String message, Double lineNumber, String trace) {
        Log_Error__c log = new Log_Error__c();
        log.Message__c = message;
        log.Line_Number__c = lineNumber;
        log.Stack_Trace__c = trace;
        log.Class_Name__c = className;
        log.Method_Name__c = methodName;
        Database.insert(log, AccessLevel.SYSTEM_MODE);
    }
    
    public static void createLogIntegration(HttpResponse res, HttpRequest req) {
        Log_API__c log = new Log_API__c();
        log.Input_Parameter__c = req.getBody();
        log.Input_url__c = req.getEndpoint();
        log.Response__c = res.getBody();
        log.Status_Code__c = res.getStatusCode();
        log.Status__c = res.getStatus();
        Database.insert(log, AccessLevel.SYSTEM_MODE);
    }
}