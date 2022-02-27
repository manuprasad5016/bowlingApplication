import { LightningElement, api, wire } from 'lwc';
import getScores from '@salesforce/apex/BowlingGameController.getScores';

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
        label: "Player",
        fieldName: "PlayerName",
        sortable: "true",
        hideDefaultActions: true
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

export default class BowlingGameDetailsPage extends LightningElement {
    @api recordId;
    gamesColumn = columns;
    gamesList;
    gamesDataList;
    record;
    titleVar = 'Game History (0)';
    sortBy;
    sortDirection;

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.gamesDataList));
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
        this.gamesDataList = parseData;
    }

    @wire(getScores, { individualRecId: '$recordId' })
    Record(variable) {
        this.gamesList = variable;
        if (variable.data) {
            if (variable.data.length > 0) {
                this.titleVar = 'Game History (' + variable.data.length + ')';
                this.record = variable.data;
                this.gamesDataList = this.record.map(row => ({
                    ...row,
                    PlayerName: row.Player__r.Name,
                    NameLink: '/lightning/r/Game__c/' + row.Id + '/view'
                }));
            }
        } else if (variable.error) {
            console.error('GetScores Error-->' + JSON.stringify(variable.error));
        }
    }
}