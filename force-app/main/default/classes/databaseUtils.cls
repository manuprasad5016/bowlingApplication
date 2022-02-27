/* ****************************************************************************************************************************
@ Class:          databaseUtils
@ Version:        1.0
@ Author:         Manu Prasad A (madeyilliam@salesforce.com) 
@ Purpose:        This class is used for database operation and DML exception handling
*****************************************************************************************************************************
@ Change history:  20.01.2021 / Manu Prasad A / Created the Apex Class
***************************************************************************************************************************** */

public without sharing class databaseUtils{

       /*@methodName- insertSobjectList
    *@description- Method to insert the sobject list passed
    *@param- List<sobject>
    *@return- void
   */
      public Static void insertSobjectList(List<Sobject> listOfRecords , String succesMsg, String errorClass){
        
           List<String> exceptionList = new List<String>();
           try{
                Database.SaveResult[] srList = Database.insert(listOfRecords,FALSE);                        
                for (Database.SaveResult sr : srList) {                                                                
                    if (sr.isSuccess()){
                        //System.debug(succesMsg + sr.getId());
                    }
                    else{                                  
                        for(Database.Error err : sr.getErrors()){                                        
                            exceptionList.add(errorClass+err.getStatusCode()+ err.getMessage()+err.getFields()); 
                        }                                       
                    }                             
                }
                if(!exceptionList.isEmpty()){ 
                    //ExceptionUtil.insertDMLException(exceptionList,errorClass);
                }
            }catch(Exception ex){
                //Insert into exceptionlog object using platform events
            }
      }

         /*@methodName- updateSobjectList
    *@description- Method to update the sobject list passed
    *@param- List<sobject>
    *@return- void
   */
  public Static Database.SaveResult[] updateSobjectList(List<Sobject> listOfRecords , String succesMsg, String errorClass){
      
    List<String> exceptionList = new List<String>();
    Database.SaveResult[] srList = Database.Update(listOfRecords,FALSE);                        
    for (Database.SaveResult sr : srList) {                                                                
        if (sr.isSuccess()){
            //System.debug(succesMsg + sr.getId());
        }
        else{                                  
            for(Database.Error err : sr.getErrors()){                                        
                exceptionList.add(errorClass+err.getStatusCode()+ err.getMessage()+err.getFields()); 
            }                                       
        }                             
    }
    if(!exceptionList.isEmpty()){ 
        //ExceptionUtil.insertDMLException(exceptionList,errorClass);
    }
    return srList;
}


       /*@methodName- upsertSobjectList
    *@description- Method to upsert the sobject list passed
    *@param- List<sobject>
    *@return- void
   */
      public Static Database.UpsertResult[] upsertSobjectList(List<Sobject> listOfRecords , String succesMsg, String errorClass){
      
           List<String> exceptionList = new List<String>();
           Database.UpsertResult[] srList = Database.upsert(listOfRecords,FALSE);                        
           for (Database.UpsertResult sr : srList) {                                                                
               if (sr.isSuccess()){
                   System.debug(succesMsg + sr.getId());
               }
               else{                                  
                   for(Database.Error err : sr.getErrors()){                                        
                       exceptionList.add(errorClass+err.getStatusCode()+ err.getMessage()+err.getFields()); 
                   }                                       
               }                             
           }
           if(!exceptionList.isEmpty()){ 
               //ExceptionUtil.insertDMLException(exceptionList,errorClass);
           }
           return srList;
      }
      
       /*@methodName- deleteSobjectList
    *@description- Method to delete the sobject list passed
    *@param- List<sobject>
    *@return- void
   */
      public Static void deleteSobjectList(List<Sobject> listOfRecords , String succesMsg, String errorClass){
      
           List<String> exceptionList = new List<String>();
           Database.DeleteResult[] srList = Database.delete(listOfRecords,FALSE);                        
           for (Database.DeleteResult sr : srList) {                                                                
               if (sr.isSuccess()){
                   System.debug(succesMsg + sr.getId());
               }
               else{                                  
                   for(Database.Error err : sr.getErrors()){                                        
                       exceptionList.add(errorClass+err.getStatusCode()+ err.getMessage()+err.getFields()); 
                   }                                       
               }                             
           }
           if(!exceptionList.isEmpty()){ 
               //ExceptionUtil.insertDMLException(exceptionList,errorClass);
           }
      }

      public class MyException extends Exception{

    }
   }