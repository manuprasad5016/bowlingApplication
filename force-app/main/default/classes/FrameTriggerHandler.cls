/* ****************************************************************************************************************************
@ Class:          FrameTriggerHandler
@ Version:        1.0
@ Author:         Manu Prasad A (madeyilliam@salesforce.com) 
@ Purpose:        This is TriggerHandler for Frame__c custom Object
*****************************************************************************************************************************
@ Change history:  20.02.2022 / Manu Prasad A / Created the LWC Component.  
***************************************************************************************************************************** */

public with sharing class FrameTriggerHandler {

    public static void doValidationBeforeUpdate(List<Frame__c> newList){
        for(Frame__c frameRec:newList){
            if(frameRec.Attempt_1__c + frameRec.Attempt_2__c > 10){
                frameRec.addError('Cannot have more than 10 balls in a frame');
            }
        }
    }
    
    public static void afterInsertHandler(List<Frame__c> newList){
        List<Game__c> gameList = new List<Game__c>();
        Map<Id,Decimal> scoreMap = new Map<Id,Decimal>();
        Map<Id,Boolean> lastSpareCheckMap = new Map<Id,Boolean>();
        Map<Id,Boolean> lastTwoStrikeCheckMap = new Map<Id,Boolean>();
        Set<Id> gameIdSet = new Set<Id>();

        for(Frame__c frameRec:newList){
            gameIdSet.add(frameRec.Game__c);
        }
        List<Game__c> gameListNew = [Select Id,Total_Score__c,(Select Id,Attempt_1__c,Attempt_2__c from Frames__r order by Frame__c desc limit 3) from Game__c where Id IN :gameIdSet];   

        for(Game__c gameRec:gameListNew){
            scoreMap.put(gameRec.Id, gameRec.Total_Score__c);

            if(gameRec.Frames__r.size() == 3){
                if(gameRec.Frames__r[1].Attempt_1__c == 10 && gameRec.Frames__r[2].Attempt_1__c == 10){
                    lastTwoStrikeCheckMap.put(gameRec.Id, true);
                }else{
                    lastTwoStrikeCheckMap.put(gameRec.Id, false);
                }
            }else{
                lastTwoStrikeCheckMap.put(gameRec.Id, false);
            }

            if(gameRec.Frames__r.size() >= 2){
                if((gameRec.Frames__r[1].Attempt_1__c + gameRec.Frames__r[1].Attempt_2__c) == 10 && gameRec.Frames__r[1].Attempt_1__c != 10){
                    lastSpareCheckMap.put(gameRec.Id, true);
                }else{
                    lastSpareCheckMap.put(gameRec.Id, false);
                }
            }else{
                lastSpareCheckMap.put(gameRec.Id, false);
            }

        }

        for(Frame__c frameRec:newList){
            Boolean islastSpare = lastSpareCheckMap.get(frameRec.Game__c);
            Boolean isLastTwoStrike = lastTwoStrikeCheckMap.get(frameRec.Game__c);

            if(islastSpare){
                Game__c gameRec = new Game__c(Id = frameRec.Game__c);
                gameRec.Total_Score__c = scoreMap.get(frameRec.Game__c) + 10 + frameRec.Attempt_1__c;
                if(frameRec.Frame__c == 11)
                gameRec.Status__c = 'Completed';
                gameList.add(gameRec);
            }

            if(isLastTwoStrike){
                Game__c gameRec = new Game__c(Id = frameRec.Game__c);
                gameRec.Total_Score__c = scoreMap.get(frameRec.Game__c) + 20 + frameRec.Attempt_1__c;
                if(frameRec.Frame__c == 12)
                gameRec.Status__c = 'Completed';
                gameList.add(gameRec);
            }
        }
        databaseUtils.updateSobjectList(gameList, 'Update Score', 'FrameTriggerHandler');
    }


    public static void afterUpdateHandler(List<Frame__c> newList){   
        List<Game__c> gameList = new List<Game__c>();
        Map<Id,Decimal> scoreMap = new Map<Id,Decimal>();
        Map<Id,Boolean> currentNormalCheckMap = new Map<Id,Boolean>();
        Map<Id,Boolean> lastStrikeCheckMap = new Map<Id,Boolean>();
        Set<Id> gameIdSet = new Set<Id>();

        for(Frame__c frameRec:newList){
            gameIdSet.add(frameRec.Game__c);
        }
        List<Game__c> gameListNew = [Select Id,Total_Score__c,(Select Id,Attempt_1__c from Frames__r order by Frame__c desc limit 2) from Game__c where Id IN :gameIdSet];   
        for(Game__c gameRec:gameListNew){
            scoreMap.put(gameRec.Id, gameRec.Total_Score__c);

            if(gameRec.Frames__r.size() == 2){
                if(gameRec.Frames__r[1].Attempt_1__c == 10){
                    lastStrikeCheckMap.put(gameRec.Id, true);
                }else{
                    lastStrikeCheckMap.put(gameRec.Id, false);
                }
            }else{
                lastStrikeCheckMap.put(gameRec.Id, false);
            }
        }

        for(Frame__c frameRec:newList){
            Boolean isCurrentNormal = (frameRec.Attempt_1__c + frameRec.Attempt_2__c) != 10 ? true : false;
            Boolean isLastStrike = lastStrikeCheckMap.get(frameRec.Game__c);

            //Current Normal and Previous not strike
            if(isCurrentNormal && !isLastStrike){
                //Current : 2,3 . Previoud : 1,9
                Game__c gameRec = new Game__c(Id = frameRec.Game__c);
                gameRec.Total_Score__c = scoreMap.get(frameRec.Game__c) + frameRec.Attempt_1__c + frameRec.Attempt_2__c;
                if(frameRec.Frame__c == 10)
                gameRec.Status__c = 'Completed';
                gameList.add(gameRec);
            }

            //Current Normal and Previous was strike
            if(isCurrentNormal && isLastStrike){
                //Current : 6,1 . Previoud : 10,x
                Game__c gameRec = new Game__c(Id = frameRec.Game__c);
                if(frameRec.Frame__c == 11){
                    gameRec.Status__c = 'Completed';
                    gameRec.Total_Score__c = scoreMap.get(frameRec.Game__c) + 10 + (frameRec.Attempt_1__c + frameRec.Attempt_2__c);
                }else{
                    gameRec.Total_Score__c = scoreMap.get(frameRec.Game__c) + 10 + 2*(frameRec.Attempt_1__c + frameRec.Attempt_2__c);
                }
                if(frameRec.Frame__c == 10)
                gameRec.Status__c = 'Completed';
                gameList.add(gameRec);
            }

            //Current Not Normal and Previous was strike
            if(!isCurrentNormal && isLastStrike){
                //Current : 6,4 . Previoud : 10,x
                Game__c gameRec = new Game__c(Id = frameRec.Game__c);
                gameRec.Total_Score__c = scoreMap.get(frameRec.Game__c) + 10 + frameRec.Attempt_1__c + frameRec.Attempt_2__c;
                gameList.add(gameRec);
            } 
        }

        databaseUtils.updateSobjectList(gameList, 'Update Score', 'FrameTriggerHandler');
    }


}