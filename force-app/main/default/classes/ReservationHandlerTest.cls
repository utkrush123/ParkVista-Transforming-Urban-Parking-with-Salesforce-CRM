@IsTest
private class ReservationHandlerTest {

    @IsTest static void testReservationTrigger() {
        Contact c = new Contact(
            LastName = 'Test User',
            Email = 'test@example.com'
        );
        insert c;
        Parking_Lot__c lot = new Parking_Lot__c(
            Lot_Name__c = 'Test Lot',
            Total_Slots__c = 10,
            Available_Spots__c = 10,
            Price_Per_Hour__c = 50,
            Status__c = 'Active'
        );
        insert lot;
        Reservation__c res = new Reservation__c(
            Parking_Lot__c = lot.Id,
            Contact__c = c.Id,
            Reservation_Date__c = Date.today(),
            Start_Time__c = Datetime.now(),
            End_Time__c = Datetime.now().addHours(2),
            Payment_Status__c = 'Pending'
        );

        Test.startTest();
        insert res;
        Test.stopTest();
        lot = [SELECT Available_Spots__c FROM Parking_Lot__c WHERE Id = :lot.Id];
        System.assertEquals(9, lot.Available_Spots__c, 'Available spots should decrement by 1');
    }
}
