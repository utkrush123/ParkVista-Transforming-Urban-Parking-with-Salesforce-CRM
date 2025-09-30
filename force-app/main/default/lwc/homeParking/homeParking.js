import { LightningElement, wire } from 'lwc';
import getParkingLots from '@salesforce/apex/ParkingLotController.getParkingLots';
import bookReservation from '@salesforce/apex/ParkingLotController.bookReservation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import getContactId from '@salesforce/apex/ParkingLotController.getContactId'; 

export default class HomeParking extends NavigationMixin(LightningElement) {
    parkingLots = [];
    error;
    contactId;

    connectedCallback() {
        getContactId({ userId: USER_ID })
            .then(result => {
                this.contactId = result;
            })
            .catch(error => {
                this.contactId = null;
                console.error('Error fetching Contact Id', error);
            });
    }
    @wire(getParkingLots)
    wiredLots({ error, data }) {
        if (data) {
            this.parkingLots = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.parkingLots = [];
        }
    }
    handleBook(event) {
        const lotId = event.target.dataset.id;

        if (!this.contactId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Cannot find Contact for current user.',
                    variant: 'error'
                })
            );
            return;
        }
        bookReservation({ lotId: lotId, contactId: this.contactId })
            .then(res => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `Reservation confirmed for ${res.Parking_Lot__r.Lot_Name__c}`,
                        variant: 'success'
                    })
                );
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: res.Id,
                        objectApiName: 'Reservation__c',
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error'
                    })
                );
            });
    }
}