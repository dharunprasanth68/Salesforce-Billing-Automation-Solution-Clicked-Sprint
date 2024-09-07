public with sharing class BillEmailer {
    // Modified method to accept multiple PDFs for a single email
    public static void sendEmails(String email, List<Blob> pdfBlobs) {
        // Create the email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ email });
        mail.setSubject('Your Bill');
        mail.setPlainTextBody('Please find your bills attached.');

        // Attach all PDFs to the email
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (Blob pdfBlob : pdfBlobs) {
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.Body = pdfBlob;
            attach.FileName = 'Bill-' + Date.today().format() + '.pdf';
            attach.ContentType = 'application/pdf';
            attachments.add(attach);
        }
        mail.setFileAttachments(attachments);

        // Send the email
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        System.debug('Email sent to ' + email + ' with ' + pdfBlobs.size() + ' attachments.');
    }
}