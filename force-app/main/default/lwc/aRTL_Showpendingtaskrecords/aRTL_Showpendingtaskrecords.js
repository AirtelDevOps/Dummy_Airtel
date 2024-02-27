import { LightningElement,wire } from 'lwc';
import getOpenTasks from '@salesforce/apex/ARTL_ShowPendingtasks.getOpenTasks';
const column = [   
    {  fieldName: 'recordLink', hideDefaultActions : true, type: 'url',  typeAttributes: { label: { fieldName: "Subject" }, target: "_blank" }   }
];
export default class ARTL_Showpendingtaskrecords extends LightningElement {
  tasks = [];
  columns = column;

    @wire(getOpenTasks)
    wiredTasks({ error, data }) {
        if (data) {

    var temptaskList = [];  
    for (var i = 0; i < data.length; i++) {  
     let tempRecord = Object.assign({}, data[i]); //cloning object  
     tempRecord.recordLink = "/" + tempRecord.Id;  
     tempRecord.recordOwner = "/" + tempRecord.Owner.Id;  
     tempRecord.AssignedTo=tempRecord.Owner.Name;
     temptaskList.push(tempRecord);  
    } 
            this.tasks = temptaskList;
            console.log('this.tasks'+JSON.stringify(this.tasks));
        } else if (error) {
            console.error('Error fetching tasks:', error);
        }
    }
     getRecordUrl(recordId) {
        // Replace 'objectApiName' with the API name of the object you want to link to
        return `/${Task}/${recordId}`;
    }
}