import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getInProgressGames from '@salesforce/apex/BowlingGameController.getInProgressGames';
import { CloseActionScreenEvent } from 'lightning/actions';

const columns = [
    {
        label: "Name",
        fieldName: "NameLink",
        type: 'url',
        sortable: "true",
        hideDefaultActions: true,
        typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }
    },
    {
        label: "Status",
        fieldName: "Status__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Total Score",
        fieldName: "Total_Score__c",
        sortable: "true",
        hideDefaultActions: true
    }
];

export default class BowlingCreateNewGame extends NavigationMixin(LightningElement) {

    @track inprogressList;
    gamesColumn = columns;
    sortBy;
    sortDirection;

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.inprogressList));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.inprogressList = parseData;
    }

    newGameStart(event) {
        this.singlePlayerRegister = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'Game__c',
                actionName: 'view',
            },
        });
    }

    //Get In Progress game details for the contact when contact is selected
    getHistory(event) {
        if (event.target.value != '') {
            getInProgressGames({ playerId: event.target.value })
                .then((result) => {
                    if (result.length > 0) {
                        this.inprogressList = result;
                        for (let index = 0; index < this.inprogressList.length; index++) {
                            //const element = this.inprogressList[index];
                            this.inprogressList[index].NameLink = '/lightning/r/Game__c/' + this.inprogressList[index].Id + '/view';
                        }
                    }
                })
                .catch((error) => {
                    console.error('getInProgressGames Error-->' + JSON.stringify(error));
                });
        } else {
            this.inprogressList = undefined;
        }
    }

    closeRegistration() {
        this.dispatchEvent(new CustomEvent("closemodal"));
    }
}