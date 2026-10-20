@isTest
public class Test_Trigger_Update_KertasKerja {
    static testMethod void UnitTest() {
       
        Account accDWS = new Account();
        accDWS.Name = 'DWS';
        insert accDWS;
        
        Kertas_Kerja__c kkRec = new Kertas_Kerja__c();
        kkRec.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Direct Sales';
        kkRec.Month__c = 'January';
        kkRec.Year__c = '2021';
        kkRec.Type__c = 'Media Seller';
        kkRec.Media_Seller__c = accDWS.id;
        kkRec.Status_Approval_PrivyId__c = 'Attach';     
        kkRec.Status__c = '';  
        insert kkRec; 
        
        kkRec.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Direct Sales';
        kkRec.Month__c = 'January';
        kkRec.Year__c = '2021';
        kkRec.Type__c = 'Media Seller';
        kkRec.Media_Seller__c = accDWS.id;
        kkRec.Status_Approval_PrivyId__c = 'Attach';     
        kkRec.Status__c = 'Attach';  
        update kkRec; 
        

        
        kkRec.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Direct Sales';
        kkRec.Month__c = 'January';
        kkRec.Year__c = '2021';
        kkRec.Type__c = 'Media Seller';
        kkRec.Media_Seller__c = accDWS.id;
        kkRec.Status_Approval_PrivyId__c = 'Completed';     
        kkRec.Status__c = 'Completed';
        update kkRec;
        
        kkRec.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Direct Sales';
        kkRec.Month__c = 'January';
        kkRec.Year__c = '2021';
        kkRec.Type__c = 'Media Seller';
        kkRec.Media_Seller__c = accDWS.id;
        kkRec.Status_Approval_PrivyId__c  = 'Review';     
        kkRec.Status__c = 'Review';        
        
         try
        	{update kkRec;}
        catch(Exception ex)
        	{Boolean expectedExceptionThrown =  ex.getMessage().contains('Please attach Kertas Kerja document.:') ? true : false;}
        
        
    }
}