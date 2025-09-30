public with sharing class ReservationHandler {

    public static void handleReservation(List<Reservation__c> newReservations){
        Set<Id> lotIds = new Set<Id>();
        for(Reservation__c r : newReservations){
            if(r.Parking_Lot__c != null) lotIds.add(r.Parking_Lot__c);
        }

        Map<Id, Parking_Lot__c> lotMap = new Map<Id, Parking_Lot__c>(
            [SELECT Id, Available_Spots__c, Price_Per_Hour__c 
             FROM Parking_Lot__c 
             WHERE Id IN :lotIds]
        );

        for(Reservation__c r : newReservations){
            if(r.Parking_Lot__c != null && lotMap.containsKey(r.Parking_Lot__c)){
                Parking_Lot__c lot = lotMap.get(r.Parking_Lot__c);
                if(lot.Available_Spots__c > 0){
                    lot.Available_Spots__c -= 1;
                }
            }
        }

        update lotMap.values();
    }
}
