import { LightningElement, api, track } from 'lwc';
import bookReservation from '@salesforce/apex/ParkingLotController.bookReservation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReservationForm extends LightningElement {
    @api lotId; // set from parent or page
    @track lotName = 'Lot A'; // example, replace with actual lot name

    handleBooking(event) {
        const contactId = '003XXXXXXXXXXXX'; // replace with current user's contact Id

        bookReservation({ lotId: this.lotId, contactId: contactId })
            .then(res => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Reservation Confirmed!',
                    variant: 'success'
                }));
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }
}
