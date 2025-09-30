/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-29-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class ReservationResetScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateSlotBatch batch = new UpdateSlotBatch();
        Database.executeBatch(batch);
    }
}
