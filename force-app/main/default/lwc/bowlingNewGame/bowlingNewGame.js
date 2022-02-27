import { LightningElement, api, wire } from 'lwc';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import getData from '@salesforce/apex/BowlingGameController.getData';
import { publish, MessageContext } from 'lightning/messageService';
import LDSMC from '@salesforce/messageChannel/lds__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import doGameEndCheck from '@salesforce/apex/BowlingGameController.doGameEndCheck';
import endTheGame from '@salesforce/apex/BowlingGameController.endTheGame';
export default class BowlingNewGame extends LightningElement {
    @api recordId;
    frame;
    attempt;
    frameId;
    stopGame;
    recordVar;
    showSpinner = false;
    secondColumn = 'slds-col slds-size_2-of-3';
    showRules = true;
    iconName = "utility:arrow_left";
    imageUrl = 'https://images.unsplash.com/photo-1538511059256-46e76f13f071';
    submitted = false;
    executeMethod = false;
    singlePlayerRegister = false;

    // wired message context
    @wire(MessageContext)
    messageContext;

    //Method for getting the frame number and attempt from backend in case of in progress games
    @wire(getData, { parentRecId: '$recordId' })
    Record(variable) {
        this.recordVar = variable;
        if (variable.data) {
            this.frame = variable.data.frameNumber;
            this.attempt = variable.data.attemptNumber;
            this.frameId = variable.data.frameId;
            this.stopGame = variable.data.completedGame;
        } else if (variable.error) {
            console.error('getFrameData Error-->' + JSON.stringify(variable.error));
        }
    }

    submitAction() {
        this.submitted = true;
        this.updateValueHandler();
    }

    updateValueHandler(event) {
        try{
            if (this.submitted) {
                this.executeMethod = true;
            } else if (event.which == 13) {
                this.executeMethod = true;
            } else {
                this.executeMethod = false;
            }

            if (this.executeMethod) {
                this.submitted = false;
                this.showSpinner = true;
                var inputCmp = this.template.querySelector("[data-field='pinsDown']");
                var enteredValue = inputCmp.value;
                console.log('Frame-->' + this.frame);
                console.log('Attempt-->' + this.attempt);
                if (enteredValue >= 0 && enteredValue <= 10 && enteredValue != '') {
                    inputCmp.setCustomValidity('');

                    if (this.attempt == 1) {
                        //Create Frame record and Update the Game Record with score
                        var nameVal = 'Frame ' + this.frame;
                        var fields = {};
                        if (enteredValue == 10) {
                            this.imageUrl = 'https://media2.giphy.com/media/1YaJqvpJKkASs4f6ic/giphy.gif?cid=790b76113c6dbbdcac90ad9a929d1ab9cf44f5186064499e&rid=giphy.gif&ct=g';
                            fields = { 'Attempt_1__c': enteredValue, 'Attempt_2__c': 0, 'Game__c': this.recordId, Name: nameVal, Frame__c: this.frame };
                        } else {
                            this.imageUrl = 'https://images.unsplash.com/photo-1538511059256-46e76f13f071';
                            fields = { 'Attempt_1__c': enteredValue, 'Game__c': this.recordId, Name: nameVal, Frame__c: this.frame };
                        }
                        var objRecordInput = { 'apiName': 'Frame__c', fields };
                        // LDS method to create record.
                        createRecord(objRecordInput).then(response => {
                            console.log('Insert-->' + JSON.stringify(response));
                            inputCmp.value = '';
                            this.frameId = response.id;
                            this.showSpinner = false;

                            if (enteredValue == 10) {
                                if (this.frame == 10) {
                                    this.displayToast('Success', 'Hooray !', '2 more balls to go');
                                }
                                if (this.frame == 11) {
                                    this.doValidation(true);
                                }
                                if (this.frame == 12) {
                                    this.displayToast('Success', 'Hooray !', 'Game Completed');
                                    this.stopGame = true;
                                }
                                this.attempt = 1;
                                this.frame += 1;
                                if (this.frame == 10) {
                                    this.displayToast('Success', 'Hooray !', 'Its the 10th Frame');
                                }
                            } else {
                                if (this.frame == 11) {
                                    this.doValidation(true);
                                } else if (this.frame == 12) {
                                    //this.doValidation(false);
                                    this.stopGame = true;
                                }
                                this.attempt += 1;
                            }
                            // Using the lightning message channel to update the bowlingFrameDetails LWC Component data
                            const payload = { variable1: enteredValue };
                            publish(this.messageContext, LDSMC, payload);
                        }).catch(error => {
                            console.error('createRecord Error-->' + JSON.stringify(error));
                            this.showSpinner = false;
                        });
                    } else if (this.attempt == 2) {
                        //Update Frame record and Update the Game Record with score
                        const fields = {};
                        fields["Id"] = this.frameId;
                        fields["Attempt_2__c"] = enteredValue;
                        const recordInput = { fields };
                        updateRecord(recordInput)
                            .then((result) => {
                                console.log('Update-->' + JSON.stringify(result));
                                inputCmp.value = '';
                                if (result.fields.Attempt_1__c.value + result.fields.Attempt_2__c.value == 10) {
                                    this.imageUrl = 'https://3.bp.blogspot.com/-RnMXXWYUPXE/Xdh5_oDMJ3I/AAAAAAAOs98/RZ1IIrQysiosTOp9-foumWzZXSY6qazVwCLcBGAsYHQ/s1600/AW4036006_22.gif';
                                }
                                if (this.frame == 10) {
                                    if (result.fields.Attempt_1__c.value + result.fields.Attempt_2__c.value == 10) {
                                        this.displayToast('Success', 'Hooray !', 'Its a Spear. 1 more ball left');
                                    } else {
                                        this.displayToast('Success', 'Hooray !', 'Game Completed');
                                        this.stopGame = true;
                                    }
                                    //this.doValidation();
                                } else if (this.frame == 11) {
                                    this.displayToast('Success', 'Hooray !', 'Game Completed');
                                    this.stopGame = true;
                                }
                                this.attempt = 1;
                                this.frame += 1;
                                if (this.frame == 10) {
                                    this.displayToast('Success', 'Hooray !', 'Its the 10th Frame');
                                }
                                this.showSpinner = false;
                                // Using the lightning message channel to update the bowlingFrameDetails LWC Component data
                                const payload = { variable1: enteredValue };
                                publish(this.messageContext, LDSMC, payload);
                            })
                            .catch(error => {
                                console.error('Frame Update failed-->' + JSON.stringify(error));
                                this.displayToast('Warning', 'Warning !', error.body.output.errors[0].message);
                                this.showSpinner = false;
                            })
                    }
                } else {
                    this.showSpinner = false;
                    inputCmp.setCustomValidity('Please enter a number between 0 and 10');
                }
                inputCmp.reportValidity();
            }
        }catch(errorVar){
            console.error('Catch-->'+errorVar);
        }
    }

    hideRules() {
        this.showRules = !this.showRules;
        if (this.showRules) {
            this.secondColumn = 'slds-col slds-size_2-of-3';
            this.iconName = "utility:arrow_left";
        } else {
            this.secondColumn = 'slds-col slds-size_3-of-3';
            this.iconName = "utility:arrow_right";
        }
    }

    displayToast(variant, title, message) {
        //Show toast
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }

    doValidation(fromEleven) {
        doGameEndCheck({ gameId: this.recordId })
            .then((result) => {
                if (result) {
                    this.displayToast('Success', 'Hooray !', 'Game Completed');
                    this.stopGame = true;
                } else if (fromEleven) {
                    this.displayToast('Success', 'Hooray !', '1 more balls to go');
                }
            })
            .catch((error) => {
                console.error('doGameEndCheck Error-->' + JSON.stringify(error));
            });
    }

    endGame() {
        if (confirm('Are you sure, you want to End the game ?') == true) {
            endTheGame({ gameId: this.recordId })
                .then((result) => {
                    this.displayToast('Success', 'See you !', 'Game Ended');
                    this.stopGame = true;
                    window.setTimeout(()=>{
                        location.href = '/lightning/n/Bowling';
                    },1000); 
                })
                .catch((error) => {
                    console.error('endTheGame Error-->' + JSON.stringify(error));
                    this.displayToast('Warning', 'Sorry !', error.body.message);
                });
        }
    }

    newGame() {
        this.singlePlayerRegister = true;
    }

    closeRegistration() {
        this.singlePlayerRegister = false;
    }
}