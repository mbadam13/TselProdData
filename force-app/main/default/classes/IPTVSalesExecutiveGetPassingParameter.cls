/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * Test Class         : IPTVSalesExecutiveGetPassingParamTest
 * @last modified on  : 04-25-2024
 * @last modified by  : Ahmat Zulkifli Murad
**/
global without sharing class IPTVSalesExecutiveGetPassingParameter {
    global class inputValue {
        @InvocableVariable(label = 'URL Value' description = 'The Full URL get value after <?>' required = true)
        global String urlValue;
    }

    global class OutputValue {
        @InvocableVariable(label = 'Param Value' description = 'The return value is parameter only from the url' required = true)
        global string parameterValue;
    }


    @InvocableMethod(label='getParameterURL')
    global static list<OutputValue> checkApprovalStatus(List<string> inputURL){//List<InputApprovalResponse> inputList) {
        string parameterValue = inputURL[0].substringAfter('extUsername_Text=');
        System.debug('parameterValue:: ' + parameterValue);
        
        list<OutputValue> OutputValueList = new list<OutputValue>();
        OutputValue OutputValueClass = new OutputValue();
        OutputValueClass.parameterValue = parameterValue;
        OutputValueList.add(OutputValueClass);

        return OutputValueList;
    }


}