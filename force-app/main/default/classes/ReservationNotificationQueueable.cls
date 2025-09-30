public class ReservationNotificationQueueable implements Queueable {

    private List<Id> reservationIds;

    public ReservationNotificationQueueable(List<Reservation__c> res){
        this.reservationIds = new List<Id>();
        for(Reservation__c r : res){
            this.reservationIds.add(r.Id);
        }
    }

    public void execute(QueueableContext ctx){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Reservation__c> reservations = [
            SELECT Id, Name, Parking_Lot__r.Lot_Name__c, Contact__r.Email
            FROM Reservation__c
            WHERE Id IN :reservationIds
        ];

        for(Reservation__c r : reservations){
            if(r.Contact__r != null && r.Contact__r.Email != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[]{r.Contact__r.Email});
                mail.setSubject('Reservation Confirmed: ' + r.Name);
                mail.setPlainTextBody(
                    'Your reservation for lot ' + r.Parking_Lot__r.Lot_Name__c + ' is confirmed.'
                );
                emails.add(mail);
            }
        }

        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}
