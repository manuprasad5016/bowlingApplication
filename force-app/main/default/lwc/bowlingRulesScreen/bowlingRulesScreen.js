import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class BowlingRulesScreen extends NavigationMixin(LightningElement) {
    @api propertyValue;
}