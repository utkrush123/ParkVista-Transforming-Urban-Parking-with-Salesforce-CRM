import { LightningElement, wire } from 'lwc';
import getParkingLots from '@salesforce/apex/ParkingLotController.getParkingLots';

export default class ParkingReservation extends LightningElement {
    @wire(getParkingLots) parkingLots;
    
    handleBooking(event) {
        const lotId = event.target.dataset.id;
        // Emit custom event for booking
        const bookingEvent = new CustomEvent('reserve', { detail: lotId });
        this.dispatchEvent(bookingEvent);
    }
}
