/* ****************************************************************************************************************************
@ Class:          BowlingGameController
@ Version:        1.0
@ Author:         Manu Prasad A (madeyilliam@salesforce.com) 
@ Purpose:        This is the controller class for bowling application LWC's
*****************************************************************************************************************************
@ Change history:  20.02.2022 / Manu Prasad A / Created the LWC Component.  
***************************************************************************************************************************** */


public with sharing class BowlingGameController {
    

    /*@methodName- getFrames
*@description- Called from bowlingFramesDetails LWC for getting the scores of each frame
*@param- Game__c id
*@return- List<FrameDataWrapper>
*/
    @AuraEnabled(Cacheable = true)
    public static List<FrameDataWrapper> getFrames(String parentRecId){
        List<Frame__c> frameList = new List<Frame__c>();
        List<FrameDataWrapper> frameWrapperList = new List<FrameDataWrapper>();
        FrameDataWrapper wrap = new FrameDataWrapper();
        try {
            frameList = [Select Id,Name,Attempt_1__c,Attempt_2__c,Frame__c from Frame__c where Game__c = :parentRecId order by Frame__c asc];
            for(Frame__c temp:frameList){ 
                wrap = new FrameDataWrapper();
                wrap.IdVal = temp.Id;
                if(temp.Frame__c != 11 && temp.Frame__c != 12){ 
                    wrap.Name = temp.Name;
                    wrap.Attempt1 = temp.Attempt_1__c;
                    wrap.Attempt2 = temp.Attempt_2__c;
                }else if(frameList.size() == 11 && temp.Frame__c == 11){
                    wrap.Name = 'Bonus Frame';
                    wrap.Attempt1 = temp.Attempt_1__c;
                    //if(temp.Attempt_2__c )
                    wrap.Attempt2 = temp.Attempt_2__c; 
                }else if(frameList.size() == 12 && temp.Frame__c == 11){
                    wrap.Name = 'Bonus Frame';
                    wrap.Attempt1 = temp.Attempt_1__c;
                    wrap.Attempt2 = frameList[11].Attempt_1__c;
                }
                if(temp.Frame__c !=12){
                frameWrapperList.add(wrap);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return frameWrapperList;
    }

  /*@methodName- getData
*@description- Called from bowlingNewGame LWC for getting the frame and attempt for inserting next score
*@param- Game__c id
*@return- DataWrapper
*/
    @AuraEnabled(Cacheable = true)
    public static DataWrapper getData(String parentRecId){
        DataWrapper wrap = new DataWrapper();
        try {
            //Get latest frame record
            List<Frame__c> frameList = [Select Id,Attempt_1__c,Attempt_2__c,Game__r.Status__c from Frame__c where Game__c = :parentRecId order by Frame__c desc];
            for(Frame__c temp:frameList){
                wrap.completedGame = false;
                if(temp.Attempt_2__c == null && temp.Attempt_1__c !=10){
                    wrap.frameNumber = frameList.size();
                    wrap.attemptNumber = 2;
                    wrap.frameId = temp.Id;
                }else if(temp.Attempt_1__c == 10 ){
                    wrap.frameNumber = frameList.size()+1;
                    wrap.attemptNumber = 1;
                }else{
                    wrap.frameNumber = frameList.size()+1;
                    wrap.attemptNumber = 1;
                }
                if(temp.Game__r.Status__c == 'Completed' || temp.Game__r.Status__c == 'Cancelled'){
                    wrap.completedGame = true;
                }
                break;
            } 
            if(frameList.size() == 0){
                wrap.frameNumber = 1;
                wrap.attemptNumber = 1;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrap;
    }

    public class DataWrapper{
        @AuraEnabled
        public Integer frameNumber;
        @AuraEnabled
        public Integer attemptNumber;
        @AuraEnabled
        public String frameId;
        @AuraEnabled
        public Boolean completedGame;
    }

    public class FrameDataWrapper{
        @AuraEnabled
        public Id IdVal;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public Decimal Attempt1;
        @AuraEnabled
        public Decimal Attempt2;
    }

/*@methodName- getScores
*@description- Called from bowlingLeaderBoard LWC for getting the list of top 20 games, sorted by Total Score high to low
*@param- None
*@return- List<Game__c>
*/
    @AuraEnabled(Cacheable = true)
    public static List<Game__c> getScores(String individualRecId){
        List<Game__c> gameList = new List<Game__c>();
        try {
            if(individualRecId !=''){
                Game__c gameRec = [Select Id, Player__c from Game__c where Id =:individualRecId];
                gameList = [Select Id,Name,Status__c,Player__r.Name,Total_Score__c from Game__c where Player__c =:gameRec.Player__c AND Id != :individualRecId order by Total_Score__c desc NULLS LAST LIMIT 50];
            }else{
                gameList = [Select Id,Name,Status__c,Player__r.Name,Total_Score__c from Game__c order by Total_Score__c desc NULLS LAST LIMIT 50];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return gameList;
    }

/*@methodName- getInProgressGames
*@description- Called from bowlingHomeScreen LWC for getting the in-progress games based on contact id
*@param- Contact Id
*@return- List<Game__c>
*/
    @AuraEnabled
    public static  List<Game__c> getInProgressGames(String playerId){
        List<Game__c> gameList = new List<Game__c>();
        try {
            gameList = [Select Id,Name,Status__c,Player__r.Name,Total_Score__c from Game__c where Player__c = :playerId AND Status__c ='In Progress' order by Total_Score__c desc NULLS LAST ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return gameList;
    }

/*@methodName- doGameEndCheck
*@description- Called from bowlingNewGame LWC for checking a game Ended or not
*@param- Game Id
*@return- Boolean
*/
@AuraEnabled
    public static Boolean doGameEndCheck(String gameId){
        Boolean gameEnded = false;
        try {
            List<Frame__c> frameList = [Select Id,Frame__c,Attempt_1__c,Attempt_2__c from Frame__c where Game__c = :gameId order by Frame__c desc LIMIT 3];
            for(Frame__c frameRec:frameList){
                if(frameRec.Frame__c == 10){
                    gameEnded = frameRec.Attempt_1__c + frameRec.Attempt_2__c != 10 ? true : false; 
                }else if(frameRec.Frame__c == 11){
                    gameEnded = frameList[1].Attempt_1__c != 10 ? true : false;
                }else if(frameRec.Frame__c == 12){
                    gameEnded =  true;
                }
                break;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return gameEnded;
    }

    @AuraEnabled
    public static void endTheGame(String gameId){
        try {
            Game__c gameRec = [Select Id,Status__c from Game__c where Id =:gameId];
            if(gameRec.Status__c == 'In Progress'){
                gameRec.Status__c = 'Cancelled';
                update gameRec;
            }else{
                throw new MyException('The game is already Ended or Cancelled');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class MyException extends Exception{

    }
    
}