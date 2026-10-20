/**
 * @description       : 
 * @author            : M B Adam  
 * @test Class        : TEST_IPTVSpotlimitService
 * @group             : 
 * @last modified on  : 07-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class IPTVChanelService {
    public static List<IPTV_Channel__c> getChanelDatawithName (String IPTVChanelName, String IPTVChanelProductInv){

        List<IPTV_Channel__c> IPTVChanelList = New List<IPTV_Channel__c>();

        IPTVChanelList = [
            SELECT Id, Name, Product_Inventory__c
            FROM IPTV_Channel__c 
            Where 
            Name = : IPTVChanelName And Product_Inventory__c =: IPTVChanelProductInv
        ];

        Integer IPTVChanelCount = IPTVChanelList.size();

        System.debug('Jumlah IPTV Chanel' + IPTVChanelCount);
        System.debug('result IPTV Chanel List' + IPTVChanelList);

        return IPTVChanelList;
    }
}