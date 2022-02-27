import { LightningElement,api } from 'lwc';

export default class HorizontalCards extends LightningElement {

    @api title;
    @api value1;
    @api value2;

    connectedCallback(){
        if(this.value1 == 10){
            this.value2 = '-';
        }
    }
}