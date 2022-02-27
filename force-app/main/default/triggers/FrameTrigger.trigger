/* ****************************************************************************************************************************
@ Class:          FrameTrigger
@ Version:        1.0
@ Author:         Manu Prasad A (madeyilliam@salesforce.com) 
@ Purpose:        Trigger on Frame__c custom Object
*****************************************************************************************************************************
@ Change history:  20.02.2022 / Manu Prasad A / Created the LWC Component.  
***************************************************************************************************************************** */

trigger FrameTrigger on Frame__c (after insert, before update, after update) {

    //Insert Operation
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            
        }else if(Trigger.isAfter){
            FrameTriggerHandler.afterInsertHandler(Trigger.new);
        }
    }

    //Update Operation
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            FrameTriggerHandler.doValidationBeforeUpdate(Trigger.new);
        }else if(Trigger.isAfter){
            FrameTriggerHandler.afterUpdateHandler(Trigger.new);
        }
    }

}