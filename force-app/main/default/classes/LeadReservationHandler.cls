public class LeadHandler {
    
    public static void createReservationFromLead(List<Lead> newLeads){
        List<Reservation__c> reservationsToInsert = new List<Reservation__c>();
        List<Parking_Lot__c> parkingLotsToUpdate = new List<Parking_Lot__c>();
        
        // Query available Parking Lots
        Map<Id, Parking_Lot__c> parkingMap = new Map<Id, Parking_Lot__c>(
            [SELECT Id, Name, Available_Spots__c FROM Parking_Lot__c WHERE Available_Spots__c > 0 LIMIT 1]
        );
        
        for(Lead l : newLeads){
            if(parkingMap.isEmpty()){
                // No available parking
                continue;
            }
            
            Parking_Lot__c pl = parkingMap.values().iterator().next();
            
            // Create Reservation
            Reservation__c res = new Reservation__c();
            res.Lead__c = l.Id;
            res.Parking_Lot__c = pl.Id;
            res.Start_Time__c = System.now();
            reservationsToInsert.add(res);
            
            // Update parking lot availability
            pl.Available_Spots__c = pl.Available_Spots__c - 1;
            parkingLotsToUpdate.add(pl);
            
            // Send email notification
            sendEmailNotification(l, pl);
        }
        
        if(!reservationsToInsert.isEmpty())
            insert reservationsToInsert;
        
        if(!parkingLotsToUpdate.isEmpty())
            update parkingLotsToUpdate;
    }
    
    private static void sendEmailNotification(Lead l, Parking_Lot__c pl){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { l.Email });
        mail.setSubject('Parking Reservation Confirmed');
        mail.setPlainTextBody('Hello ' + l.FirstName + ',\n\n' +
                              'Your parking reservation at ' + pl.Name + ' has been confirmed.\n\n' +
                              'Thank you!');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
