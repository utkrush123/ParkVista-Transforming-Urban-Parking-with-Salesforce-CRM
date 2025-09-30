global class UpdateSlotBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Total_Slots__c FROM Parking_Lot__c]);
    }

    global void execute(Database.BatchableContext BC, List<Parking_Lot__c> scope){
        for(Parking_Lot__c lot : scope){
            lot.Available_Spots__c = lot.Total_Slots__c;
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC){}
}
