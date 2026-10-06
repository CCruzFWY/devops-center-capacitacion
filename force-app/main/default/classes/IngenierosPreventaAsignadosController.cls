public class IngenierosPreventaAsignadosController {
    
    @AuraEnabled
    public static List <String> getPiklistValues() {
        List<String> plValues = new List<String>();
        List<User> usuariosPreventa = [Select id,name from User where UserRole.Name = 'Pre Venta' and Profile.Name = 'Preventa' and isActive = true]; 
        for(User us : usuariosPreventa){
            plValues.add(us.Name);
        }
        plValues.sort();
        return plValues;
    }
    @AuraEnabled
    public static List<String> getSelectedValues(String recordId){
        
        Solicitud_Preventa__c record = [select id,Ingeniero_de_Preventa_asigando_2__c from Solicitud_Preventa__c where id =: recordId];
        String fieldValue = record.Ingeniero_de_Preventa_asigando_2__c;
        System.debug('fieldValue: ' +fieldValue);
        List<String> plValues = fieldValue.split(';');
        plValues.sort();
        System.debug('Lista: ' +plValues);
        return plValues;
    }
    @AuraEnabled
    public static void saveValues(List<String> values, String recordId){
        List<Boolean> process = RecuperaAprobacion(recordId);
        if(process[0]){
            String fieldNameValue = String.join(values, ';');
            Set<String> userNames = new Set<String>(values);
            Solicitud_Preventa__c record = [select id,Ingeniero_de_Preventa_asigando_2__c,OwnerId,RecordType.Name from Solicitud_Preventa__c where id =: recordId];
            List<User> usersList = [select id,email from User where isActive = true and UserRole.Name = 'Pre Venta' and Profile.Name = 'Preventa' and Name in : userNames];
            List<String> emails = new List<String>();
            for(User us : usersList){
                emails.add(us.email);
            }
            String fieldEmailValue = String.join(emails, ';');
            record.Preventa_correos__c = fieldEmailValue;
            record.Ingeniero_de_Preventa_asigando_2__c = fieldNameValue;
            update record;
            if(process[1]){
                submitRequest(recordId,record.OwnerId,record.RecordType.Name); 
            }
        }
    }
    
    @AuraEnabled
    public static List<String> profileInfo(String recordId){
        try{
            List<String> response = new List<String>();
            String profileId = UserInfo.getProfileId();
            Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
            response.add(profile.name);
            Solicitud_Preventa__c record = [select id,Estado_de_la_solicitud__c from Solicitud_Preventa__c where id =: recordId];
            response.add(record.Estado_de_la_solicitud__c);
            return response;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    }    
    public static List<boolean> RecuperaAprobacion(id recordId){
        Boolean modificar = false;
        Boolean hayProceso = false;
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObject.Id =: recordId
            AND ProcessInstance.Status = 'Pending' 
        ]; 
        if(workItems.size() > 0){
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
            pwr.setAction('Removed');
            pwr.setWorkItemId(workItems[0].id);
            
            Approval.ProcessResult result = Approval.process(pwr);
            
            if(result.isSuccess()){
                System.debug(':::Aprobación Recuperada:::');
                modificar = true;
                hayProceso = true;
            }else{
                for(DataBase.Error err : result.getErrors()){
                    System.debug('::Error al recuperar -- Code :: ' + err.getStatusCode() +' Mensaje:: '+ err.getMessage());
                    modificar = false;
                    hayProceso = false;
                } 
            }   
        }else{
            modificar = true;
            hayProceso = false;
        }
        List<Boolean> process = new List<Boolean>();
        process.add(modificar);
        process.add(hayProceso);
        return process;
    }
    
    public static void submitRequest(id recordId,id user,string recordTypeName){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();      
        req1.setObjectId(recordId);
        req1.setSubmitterId(user); 
        if(recordTypeName.contains('MKT')){
            req1.setProcessDefinitionNameOrId('AprobacionPreventaMKT');    
        }else if(!recordTypeName.contains('Arquitectura') || !recordTypeName.contains('MKT')){
            req1.setProcessDefinitionNameOrId('Aprobacion_de_preventa2');   
        }        
        
        req1.setSkipEntryCriteria(true);
        
        Approval.ProcessResult result = Approval.process(req1);        
    }
    
}