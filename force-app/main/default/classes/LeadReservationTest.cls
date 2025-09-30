@isTest
public class LeadReservationTest {
    @isTest
    static void testLeadConversionCreatesReservation() {
        // Setup Lot
        Parking_Lot__c lot = new Parking_Lot__c(Name='Pune Central', Total_Slots__c=10, Available_Spots__c=10);
        insert lot;

        // Setup Lead
        Lead ld = new Lead(LastName='Ravi Demo', Company='TestCo', Reservation_Created__c=false);
        insert ld;

        // Fake conversion
        ld.IsConverted = true;
        ld.ConvertedContactId = [SELECT Id FROM Contact LIMIT 1].Id;
        update ld;

        // Verify Reservation
        Reservation__c res = [SELECT Id, Parking_Lot__c, Status__c FROM Reservation__c LIMIT 1];
        System.assertEquals('Pending', res.Status__c);
        System.assertEquals(lot.Id, res.Parking_Lot__c);

        // Verify slot reduced
        lot = [SELECT Available_Spots__c FROM Parking_Lot__c WHERE Id = :lot.Id];
        System.assertEquals(9, lot.Available_Spots__c);
    }
}
