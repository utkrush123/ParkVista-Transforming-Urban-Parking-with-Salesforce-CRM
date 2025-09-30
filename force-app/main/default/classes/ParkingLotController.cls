public with sharing class ParkingLotController {

    @AuraEnabled(cacheable=true)
    public static List<Parking_Lot__c> getParkingLots() {
        return [
            SELECT Id, Lot_Name__c, Available_Spots__c, Price_Per_Hour__c, Status__c 
            FROM Parking_Lot__c 
            WHERE Status__c = 'Active'
        ];
    }

    @AuraEnabled
    public static  Reservation__c bookReservation(Id lotId, Id contactId) {
        if(lotId == null || contactId == null){
            throw new AuraHandledException('Parking lot or contact Id is missing.');
        }

        Parking_Lot__c lot = [
            SELECT Id, Available_Spots__c 
            FROM Parking_Lot__c 
            WHERE Id = :lotId 
            LIMIT 1
        ];

        if(lot.Available_Spots__c <= 0) {
            throw new AuraHandledException('No available spots');
        }

        lot.Available_Spots__c -= 1;
        update lot;

        Reservation__c res = new Reservation__c(
            Parking_Lot__c = lotId,
            Contact__c = contactId,
            Reservation_Date__c = Date.today(),
            Start_Time__c = Datetime.now(),
            End_Time__c = Datetime.now().addHours(2),
            Payment_Status__c = 'Pending'
        );
        insert res;

        // Query the inserted reservation to include Parking_Lot__r.Lot_Name__c
        res = [SELECT Id, Parking_Lot__r.Lot_Name__c FROM Reservation__c WHERE Id = :res.Id LIMIT 1];
        return res;
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, List<String>> getParkingSlotsVisual() {
        Map<Id, List<String>> lotSlotsMap = new Map<Id, List<String>>();
        List<Parking_Lot__c> lots = [
            SELECT Id, Total_Slots__c, Available_Spots__c 
            FROM Parking_Lot__c 
            WHERE Status__c = 'Active'
        ];

        for(Parking_Lot__c lot : lots){
            List<String> slots = new List<String>();
            for(Integer i = 0; i < lot.Total_Slots__c; i++){
                slots.add(i < lot.Available_Spots__c ? 'A' : 'O'); // Available or Occupied
            }
            lotSlotsMap.put(lot.Id, slots);
        }
        return lotSlotsMap;
    }

    @AuraEnabled(cacheable=true)
    public static Id getContactId(Id userId) {
        if(userId == null) return null;

        // Step 1: get AccountId from User
        User u = [SELECT AccountId FROM User WHERE Id = :userId LIMIT 1];
        if(u.AccountId == null) return null;

        // Step 2: get Contact
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :u.AccountId LIMIT 1];
        return (contacts.size() > 0) ? contacts[0].Id : null;
    }
}