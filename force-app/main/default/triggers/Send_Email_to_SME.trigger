trigger Send_Email_to_SME on Request_for_proposal__c (after insert, before update) {
    if (label.Send_Email_to_SME == 'YES') {
        
        if (Trigger.IsAfter && Trigger.IsInsert) {
            System.Debug('Masuk IsAfter & Is Insert');
            
            // Send Email saat RFP create
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            // Ambil ID dari Custom Notification yang dibuat di Setup
            CustomNotificationType notificationType = [
                SELECT Id, DeveloperName 
                FROM CustomNotificationType 
                WHERE DeveloperName = 'RFP_Notification' 
                LIMIT 1
            ];
            
            // Mendapatkan base URL domain Salesforce organisasi Anda secara dinamis
            String sfdcBaseUrl = URL.getOrgDomainUrl().toExternalForm();
            
            for(Request_for_proposal__c rfp : Trigger.New) {
                
                // Pembuatan URL langsung ke record RFP yang bersangkutan
                String rfpRecordUrl = sfdcBaseUrl + '/' + rfp.Id;
                
                // --- PROSES EMAIL (MENGGUNAKAN HTML) ---
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(
                    System.Label.Email_SME.split(',')
                );
                mail.setSubject('RFP Baru Telah Dibuat (' + rfp.Name + ')');
                
                // Menggunakan HTML Body agar link bisa diklik dengan rapi
                mail.setHtmlBody(
                    '<p>Kami informasikan bahwa ada Request For Proposal (RFP) baru dibuat di Salesforce.</p>' +
                    '<p>Detail record yang bersangkutan adalah:</p>' +
                    '<ul>' +
                        '<li><b>RFP ID:</b> ' + rfp.Name + '</li>' +
                        '<li><b>Owner ID:</b> ' + rfp.OwnerId + '</li>' +
                        '<li><b>Link Record:</b> <a href="' + rfpRecordUrl + '" target="_blank">Klik di sini untuk membuka RFP</a></li>' +
                    '</ul>' +
                    '<p>Mohon untuk ditindaklanjuti dan dilakukan peninjauan sesuai dengan prosedur yang berlaku.</p>' +
                    '<p>Terima kasih atas perhatiannya.</p>'
                );
                mails.add(mail);
                
                // --- PROSES IN-APP NOTIFICATION ---
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('RFP Baru Telah Dibuat');
                notification.setBody('RFP ID: ' + rfp.Name + ' telah ditambahkan. Silakan periksa detailnya.');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(rfp.Id); 
                
                Set<String> targetIds = new Set<String>{rfp.OwnerId}; 
                try {
                    notification.send(targetIds);
                } catch (Exception e) {
                    System.debug('Gagal mengirim in-app notification: ' + e.getMessage());
                }
            }
            
            if(!mails.isEmpty()) {
                Messaging.sendEmail(mails);
            }
            
        } 
        else if (Trigger.IsBefore && Trigger.IsUpdate) {
            System.Debug('Masuk IsBefore & IsUpdate');
            
            // BEST PRACTICE: Pindahkan SOQL & URL ke luar loop untuk menghindari batas SOQL Limits (Governor Limits)
            CustomNotificationType notificationType = [
                SELECT Id, DeveloperName 
                FROM CustomNotificationType 
                WHERE DeveloperName = 'RFP_Notification' 
                LIMIT 1
            ];
            
            String sfdcBaseUrl = URL.getOrgDomainUrl().toExternalForm(); 
            
            for(Request_for_proposal__c rfpRec : Trigger.New) {            
                if(rfpRec.Request_for_Proposal_Status__c == 'Ask Revision') {                
                    System.Debug('Masuk Ask Revision');              
                    
                    // Pembuatan URL langsung ke record RFP yang bersangkutan
                    String rfpRecordUrl = sfdcBaseUrl + '/' + rfpRec.Id;
                    
                    // --- PROSES IN-APP NOTIFICATION ---
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle('RFP Ask Revision');
                    notification.setBody('RFP ID: ' + rfpRec.Name + ' butuh revisi. Silakan periksa detailnya.');
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(rfpRec.Id); 
                    
                    Set<String> targetIds = new Set<String>{rfpRec.OwnerId}; 
                    try {
                        notification.send(targetIds);
                    } catch (Exception e) {
                        System.debug('Gagal mengirim in-app notification: ' + e.getMessage());
                        
                        // PENAMBAHAN APPUTILS DAN DEBUG LOG
                        String errMessage = 'Error on Send_Email_to_SME trigger (BeforeUpdate_AskRevision).::' + e.getMessage() + '::' + e.getLineNumber();
                        System.debug('==================== error message : ' + errMessage);
                        AppUtils.putError(errMessage);
                    }
                }
            }
        }
    }
}