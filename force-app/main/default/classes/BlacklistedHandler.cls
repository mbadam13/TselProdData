public class BlacklistedHandler {
      
    public static void blacklistmethod(list<SID_Tools__c> lstSID) {
        // Business logic.
        try {
             set <String> senderID = new set <String> ();
             for(SID_Tools__c SI : lstSID) {
                if(SI.Is_Manual_SID__c == false) {
                 
                    if(SI.Status__c == 'Negotiation') {
                        List<ContentVersion> attachments = AppUtils.getPrivyFilesOnBase64(SI.id);
                        if (attachments.size() == 0) {
                             SI.addError('Negotiation Need Upload File PrivyID');
                        }
                    }

                    // --- PERBAIKAN DI SINI ---
                    // 1. Ubah ke lowercase
                    // 2. Hapus semua kecuali huruf a-z dan angka 0-9 (Tanda + dan Spasi akan hilang)
                    String newName = SI.Sender_ID__c.toLowercase();
                    newName = newName.replaceAll('[^a-z0-9]', ''); 
                    String TestingSID = newName;
                    // -------------------------
                     
                    senderID.add(SI.Sender_ID__c.toLowercase());
                    System.debug('Id Strings-' + TestingSID);
                     
                    set<String> blacklistsenderID = new Set<string>();
                    for(Blacklist__c BL : [SELECT id, Name FROM Blacklist__c]) {
                        
                        // Bersihkan juga nama di blacklist agar pembandingan (equals) akurat
                        String str_bl_name = BL.name.toLowercase();
                        str_bl_name = str_bl_name.replaceAll('[^a-z0-9]', '');
                        
                        Boolean result = TestingSID.equals(str_bl_name);
                        
                        if(result == true) {
                            SI.addError('Sender ID Tidak Diizinkan. Silakan hubungi tim DigiAds Partnership');
                        }
                    }
    
                    boolean valid = false;
                    while (Valid != true) {
                        String randomString = AppUtils.fungsirandom();
                        
                        // Cek apakah SID sudah ada di database untuk menghindari duplikat
                        LIST<SID_tools__c> sidlist = [SELECT id, Name, SID__c FROM SID_tools__c where SID__c =: SI.SID_Name__c + randomString];
                        
                        if(sidlist.size() == 0) {
                            valid = true;
                            // SID disusun dari Formula (SID_Name__c) + Name yang sudah bersih + Random String
                            SI.SID__c = SI.SID_Name__c + newName + randomString;
                        } else {
                            valid = false;
                        }
                    }
    
                    SI.newSenderid__c = newName;
                }
             }
         }
         catch(exception e) {
            string errMessage = 'Error on blacklistmethod function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
         }
    }

    public static void blacklistmethodUpdate(list<SID_Tools__c> lstSID) {
         for(SID_Tools__c SI : lstSID) {
            if(SI.Status__c == 'Negotiation') {
                List<ContentVersion> attachments = AppUtils.getPrivyFilesOnBase64(SI.id);
                if (attachments.size() == 0) {
                     SI.addError('Negotiation Need Upload File PrivyID');
                }
            }
         }
    }
}