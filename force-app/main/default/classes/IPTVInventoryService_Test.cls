/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-31-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class IPTVInventoryService_Test {
    @isTest
    static void testCreateInventory(){
        // == create channel ==
        IPTV_Channel__c channelRec = new IPTV_Channel__c(
            Name                    = 'AFN',
            Keyword__c              = 'TVC PLATINUM'
        );
        Insert channelRec;

        // == create inventory ==
        IPTV_Inventory__c invRec = new IPTV_Inventory__c(
            Name                    = 'AFN PRIME TIME',
            IPTV_Channels__c        = channelRec.Id,
            Show_Time__c            = 'PRIME TIME',
            Time__c                 = '17.00 - 24.00',
            keyword__c              = 'all',
            Type__c                 = 'IPTV',
            Product_Inventory__c    = 'BOOTING ADS;NAVIGATION ADS;POTRAIT BANNER;ROTATE BANNER;LANDSCAPE ADS (HOME MENU);LANDSCAPE ADS (MOVIE MENU);LANDSCAPE ADS (APPS MENU);TV Shopping Landscape;PIP;TIMESHIFT ADS;PRE ROLL;QR Code;SCREENSAVER ADS;TVC PLATINUM;TVC GOLD;TVC SILVER;TVC ROS;TVC Cross Platform;SUPER IMPOSE;SQUEEZE FRAME;Targeted TVC Ads;Geo Targeted Creative Ads Navigation;Geo Targeted Creative Ads Pre Roll;Geo Targeted Creative Ads Time Shift;Geo Targeted Creative Ads PIP;Blocking Channel SD;Blocking Channel HD;Blocking Channel SD + HD;Blocking Channel Manage Service IPTV SD Channel;Blocking Channel Manage Service IPTV HD Channel;Blocking Channel UseeTV Go;Stilll Image;Dynamic Image;Live Streaming;Talkshow;Liputan;Webinar;TVC;Filler;Advertorial;OBB (Creative Ads);CBB (Creative Ads);BI (Creative Ads);BO (Creative Ads);Running Text (Super Impose);Credit Title (Super Impose);Adlibs (TVC);Template Host (Creative Ads);Product Placement (Creative Ads);Production (TVC);Built in (TVC);Studio Usee Hall;2 Studio + Alat +Crew;Studio (mini studio);Venue;Production Off Air;Bundling Package;Halaman Utama;Page Channel;Detail Live TV;Page VOD;Detail VOD;Page Radio;Page News & Promotion;Detail News & Promotion;Page About;Page FAQ;Detail Live TV - Showcase'
        );

        Test.startTest();
            Insert invRec;
        Test.stopTest();
    }
}