import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class BowlingHomeScreen extends NavigationMixin(LightningElement) {
    singlePlayerRegister = false;

    handleNavigateQuestion() {
        var compDefinition = {
            componentDef: "c:bowlingRulesScreen",
            attributes: {
                propertyValue: "500"
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }

    newGameRegister() {
        this.singlePlayerRegister = true;
    }

    closeRegistration() {
        this.singlePlayerRegister = false;
    }

    handleNavigateLeaderboard() {
        var compDefinition = {
            componentDef: "c:bowlingLeaderBoard",
            attributes: {
                propertyValue: "500"
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
}