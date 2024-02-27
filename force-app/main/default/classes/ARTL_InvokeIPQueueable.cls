public class ARTL_InvokeIPQueueable implements Queueable, Database.AllowsCallouts{
    Map<String, Object> ipInput = new Map<String, Object> ();
    Map<String, Object> ipOutput = new Map<String, Object> ();
    Map<String, Object> ipOptions = new Map<String, Object> ();
    String ipName;
    String recordId;
    public ARTL_InvokeIPQueueable(String recordId,String ipName){
        System.debug('recordId - ' + recordId);
        System.debug('ipName - ' + ipName);
        this.ipName = ipName;
        this.ipinput = new Map<String,Object>();
        this.ipoutput = new Map<String,Object>();
        this.ipOptions = new Map<String,Object>();
        this.recordId = recordId;
    }
    public ARTL_InvokeIPQueueable(String recordId,String ipName,Map<String,Object> ipInput){
        System.debug('recordId - ' + recordId);
        System.debug('ipName - ' + ipName);
        this.ipName = ipName;
        this.ipinput = ipInput;
        this.ipoutput = new Map<String,Object>();
        this.ipOptions = new Map<String,Object>();
        this.recordId = recordId;
    }
    public void execute(QueueableContext context) {
        this.ipInput.put('recordId',this.recordId);
        System.debug('ip input - ' + this.ipInput);
        this.ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(ipName, ipInput, (new Map<string, object>()));
        System.debug('ip output - ' + this.ipOutput);
    }
}