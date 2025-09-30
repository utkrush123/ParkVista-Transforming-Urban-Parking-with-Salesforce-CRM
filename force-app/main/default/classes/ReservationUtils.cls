public class ReservationUtils {

    public static void sendReservationReminders() {
   
        Datetime startWindow = Datetime.now();
        Datetime endWindow   = startWindow.addHours(1);

        List<Reservation__c> reservations = [
            SELECT Id, Start_Time__c, Contact__r.Email, Parking_Lot__r.Lot_Name__c
            FROM Reservation__c
            WHERE Start_Time__c >= :startWindow
              AND Start_Time__c <= :endWindow
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Reservation__c r : reservations) {
            if (r.Contact__r != null && r.Contact__r.Email != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { r.Contact__r.Email });
                mail.setSubject('Reminder: Upcoming Reservation ' + r.Name);
                mail.setPlainTextBody(
                    'This is a reminder for your reservation at lot ' +
                    r.Parking_Lot__r.Lot_Name__c +
                    '. Your start time is ' + r.Start_Time__c.format()
                );
                emails.add(mail);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
