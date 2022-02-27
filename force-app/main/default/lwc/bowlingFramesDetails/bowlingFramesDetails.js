import { LightningElement, api, wire } from 'lwc';
import getFrames from '@salesforce/apex/BowlingGameController.getFrames';
import { refreshApex } from '@salesforce/apex';
import { subscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import LDSMC from '@salesforce/messageChannel/lds__c';


export default class BowlingFramesDetails extends LightningElement {
    @api recordId;
    subscription = null;
    frames;
    framesUpdated;

    @wire(getFrames, { parentRecId: '$recordId' })
    frames;

    // Initialize messageContext for Message Service
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeMC();
    }

    // Subscribes to the message channel
    subscribeMC() {
        if (this.subscription) {
            return;
        }
        // Subscribe to the message channel to retrieve the recordId and explicitly assign it to boatId.
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, LDSMC, (message) => {
                refreshApex(this.frames);
                // window.setTimeout(()=>{
                //     refreshApex(this.frames);
                // },1000);
            }, { scope: APPLICATION_SCOPE });
        }
    }
}