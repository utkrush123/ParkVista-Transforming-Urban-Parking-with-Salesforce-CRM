import { LightningElement, wire, track } from 'lwc';
import getParkingLots from '@salesforce/apex/ParkingLotController.getParkingLots';

export default class ParkingAvailability extends LightningElement {
    @track lots = [];

    connectedCallback() {
        this.fetchLots();
    }

    fetchLots() {
        getParkingLots()
            .then(result => {
                // Prepare lots with slot array
                this.lots = result.map(lot => {
                    const total = lot.Total_Slots__c || 0;
                    const available = lot.Available_Spots__c || 0;
                    const slots = [];
                    for (let i = 0; i < total; i++) {
                        slots.push({
                            id: `${lot.Id}-${i}`,
                            label: i < available ? 'A' : 'O',
                            class: i < available ? 'available' : 'occupied'
                        });
                    }
                    return { ...lot, slots };
                });
            })
            .catch(error => {
                console.error('Error fetching parking lots', error);
            });
    }
}
