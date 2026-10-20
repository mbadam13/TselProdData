/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-09-2024
 * @last modified by  : Syaiful Syafani
**/
global with sharing class IPTVSalesExecutivePassingParamsLogin {
    global class inputValue {
        @InvocableVariable(label = 'URL Value' description = 'The Full URL get value after <?>' required = true)
        global String urlValue;
    }

    global class OutputValue {
        @InvocableVariable(label = 'Param Value' description = 'The return value is parameter only from the url' required = true)
        global string parameterValue;
    }

    @InvocableMethod(label='getParameterURL')
    global static list<OutputValue> checkApprovalStatus(List<string> inputURL){
        string parameterValue = inputURL[0].substringAfter('NIK=');
        System.debug('parameterValue:: ' + parameterValue);
        
        list<OutputValue> OutputValueList = new list<OutputValue>();
        OutputValue OutputValueClass = new OutputValue();
        OutputValueClass.parameterValue = parameterValue;
        OutputValueList.add(OutputValueClass);

        return OutputValueList;
    }
}