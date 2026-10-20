/**
 * @description       : CLASS UTILITY FOR INTEGRATION
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
public without sharing class UtilIntegration {
    /**
    * @description PATCH LEAD IN CSSM
    * @author RKA | 07-05-2024 
    * @param integrationName 
    * @param body 
    * @param header 
    * @return HttpResponse 
    **/
    public static HttpResponse postLead(String integrationName, String body, Map<String,String> header) {
        Integration__mdt integration = Integration__mdt.getInstance(integrationName);

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        
        List<Object> responses = new List<Object>();
        try {
            req.setEndpoint(integration.Base_Url__c);
            req.setMethod(integration.Method__c);
            req.setTimeout(Integer.valueOf(integration.Timeout__c));
            req.setBody(body);
            for (String key : header.keySet()) {
                req.setHeader(key, header.get(key));
            }
            res = http.send(req);
            if (res != null) {
                if (!String.valueOf(res.getStatusCode()).startsWith('2')) {
                    UtilLog.createLogIntegration(res, req);
                } else {
                    responses = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    if (responses.size() > 0) {
                        for (Object obj : responses) {
                            Map<String,Object> mapObj = (Map<String,Object>) obj;
                            if (mapObj.containsKey('errors')) {
                                List<Object> errors = (List<Object>) mapObj.get('errors');
                                if (errors.size() > 0) {
                                    UtilLog.createLogIntegration(res, req);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            UtilLog.createLog('UtilIntegration', 'postLead', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
        return res;
    }

    /**
    * @description POST ACCOUNT (CREATE ACCOUNT)
    * @author RKA | 07-05-2024 
    * @param integrationName 
    * @param body 
    * @param header 
    * @return HttpResponse 
    **/
    public static HttpResponse postAccount(String integrationName, String body, Map<String,String> header) {
        Integration__mdt integration = Integration__mdt.getInstance(integrationName);

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        
        List<Object> responses = new List<Object>();

        try {
            req.setEndpoint(integration.Base_Url__c);
            req.setMethod(integration.Method__c);
            req.setTimeout(Integer.valueOf(integration.Timeout__c));
            req.setBody(body);
            for (String key : header.keySet()) {
                req.setHeader(key, header.get(key));
            }
            res = http.send(req);
            if (res != null) {
                if (!String.valueOf(res.getStatusCode()).startsWith('2')) {
                    UtilLog.createLogIntegration(res, req);
                } else {
                    responses = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    if (responses.size() > 0) {
                        for (Object obj : responses) {
                            Map<String,Object> mapObj = (Map<String,Object>) obj;
                            if (mapObj.containsKey('errors')) {
                                List<Object> errors = (List<Object>) mapObj.get('errors');
                                if (errors.size() > 0) {
                                    UtilLog.createLogIntegration(res, req);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            UtilLog.createLog('UtilIntegration', 'postAccount', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }

        return res;
    }

    /**
    * @description 
    * @author RKA | 07-06-2024 
    * @param integrationName 
    * @param param 
    * @param header 
    * @return HttpResponse 
    **/
    /*
    public static HttpResponse getAccount(String integrationName, String param, Map<String,String> header) {
        Integration__mdt integration = Integration__mdt.getInstance(integrationName);

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        
        List<Object> responses = new List<Object>();
        try {
            req.setEndpoint(integration.Base_Url__c+EncodingUtil.urlEncode(param, 'UTF-8'));
            req.setMethod(integration.Method__c);
            req.setTimeout(Integer.valueOf(integration.Timeout__c));
            for (String key : header.keySet()) {
                req.setHeader(key, header.get(key));
            }
            res = http.send(req);
            if (res != null) {
                if (!String.valueOf(res.getStatusCode()).startsWith('2')) {
                    UtilLog.createLogIntegration(res, req);
                }
            } 
        } catch(Exception ex) {
            UtilLog.createLog('UtilIntegration', 'getAccount', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
        return res;
    }
    */

    /**
    * @description POST CONTACT (CREATE CONTACT)
    * @author RKA | 07-05-2024 
    * @param integrationName 
    * @param body 
    * @param header 
    * @return HttpResponse 
    **/
    public static HttpResponse postContact(String integrationName, String body, Map<String,String> header) {
        Integration__mdt integration = Integration__mdt.getInstance(integrationName);

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse res = new HttpResponse();

        List<Object> responses = new List<Object>();

        try {
            req.setEndpoint(integration.Base_Url__c);
            req.setMethod(integration.Method__c);
            req.setTimeout(Integer.valueOf(integration.Timeout__c));
            req.setBody(body);
            for (String key : header.keySet()) {
                req.setHeader(key, header.get(key));
            }
            res = http.send(req);
            if (res != null) {
                if (!String.valueOf(res.getStatusCode()).startsWith('2')) {
                    UtilLog.createLogIntegration(res, req);
                } else {
                    responses = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    if (responses.size() > 0) {
                        for (Object obj : responses) {
                            Map<String,Object> mapObj = (Map<String,Object>) obj;
                            if (mapObj.containsKey('errors')) {
                                List<Object> errors = (List<Object>) mapObj.get('errors');
                                if (errors.size() > 0) {
                                    UtilLog.createLogIntegration(res, req);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            UtilLog.createLog('UtilIntegration', 'postContact', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
        return res;
    }

    /**
    * @description DELETE LEAD IN CSSM
    * @author RKA | 07-05-2024 
    * @param integrationName 
    * @param param 
    * @param header 
    **/
    public static void deleteLead(String integrationName, String param, Map<String,String> header) {
        Integration__mdt integration = Integration__mdt.getInstance(integrationName);
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse res = new HttpResponse();

        List<Object> responses = new List<Object>();
        try {
            req.setEndpoint(integration.Base_Url__c+param);
            req.setMethod(integration.Method__c);
            req.setTimeout(Integer.valueOf(integration.Timeout__c));
            for (String key : header.keySet()) {
                req.setHeader(key, header.get(key));
            }
            system.debug('req');
            system.debug(req);
            res = http.send(req);
            if (res != null) {
                if (!String.valueOf(res.getStatusCode()).startsWith('2')) {
                    UtilLog.createLogIntegration(res, req);
                } else {
                    responses = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    if (responses.size() > 0) {
                        for (Object obj : responses) {
                            Map<String,Object> mapObj = (Map<String,Object>) obj;
                            if (mapObj.containsKey('errors')) {
                                List<Object> errors = (List<Object>) mapObj.get('errors');
                                if (errors.size() > 0) {
                                    UtilLog.createLogIntegration(res, req);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            UtilLog.createLog('UtilIntegration', 'deleteLead', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
    }

    /**
    * @description 
    * @author RKA | 07-06-2024 
    * @param integrationName 
    * @param body 
    * @param header 
    * @return HttpResponse 
    **/
    /*
    public static HttpResponse postContract(String integrationName, String body, Map<String,String> header) {
        Integration__mdt integration = Integration__mdt.getInstance(integrationName);

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse res = new HttpResponse();

        List<Object> responses = new List<Object>();

        try {
            req.setEndpoint(integration.Base_Url__c);
            req.setMethod(integration.Method__c);
            req.setTimeout(Integer.valueOf(integration.Timeout__c));
            req.setBody(body);
            for (String key : header.keySet()) {
                req.setHeader(key, header.get(key));
            }
            res = http.send(req);
            if (res != null) {
                if (!String.valueOf(res.getStatusCode()).startsWith('2')) {
                    UtilLog.createLogIntegration(res, req);
                } else {
                    responses = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    if (responses.size() > 0) {
                        for (Object obj : responses) {
                            Map<String,Object> mapObj = (Map<String,Object>) obj;
                            if (mapObj.containsKey('errors')) {
                                List<Object> errors = (List<Object>) mapObj.get('errors');
                                if (errors.size() > 0) {
                                    UtilLog.createLogIntegration(res, req);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            UtilLog.createLog('UtilIntegration', 'postContract', ex.getMessage(), Double.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
        return res;
    }
    */
}