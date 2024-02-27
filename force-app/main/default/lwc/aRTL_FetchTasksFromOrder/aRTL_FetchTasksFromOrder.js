import { LightningElement, api, wire} from 'lwc';
import fetchTasksFromOrder from '@salesforce/apex/ARTL_FetchTasksFromOrderController.getTasks';
import getReportId from '@salesforce/apex/ARTL_FeasibilityUtility.getReportId';

const columns = [
    {label: 'Task ID', fieldName: 'Id', type: 'text' },
    {label: 'Subject', fieldName: 'SubjectLink', type: 'url', typeAttributes: { label: { fieldName: 'SubjectName' }, target: '_blank' } },
    { label: 'Product Name', fieldName: 'Product_Name__c', type: 'text' },
    { label: 'Related To', fieldName: 'RelatedTo', type: 'url', typeAttributes: { label: { fieldName: 'RelatedToName' }, target: '_blank' } },
    { label: 'Status', fieldName: 'Status', type: 'picklist' },
    { label: 'Account Name', fieldName: 'AccountLink', type: 'url', typeAttributes: { label: { fieldName: 'AccountName' }, target: '_blank' } },
    { label: 'Assigned To', fieldName: 'OwnerLink', type: 'url', typeAttributes: { label: { fieldName: 'OwnerName' },target: '_blank' } },
    { label: 'Completed Date', fieldName: 'vlocity_cmt__CompletedDate__c', type: 'date' },
    { label: 'Task Type', fieldName: 'ARTL_TaskType__c', type: 'picklist' }
];

export default class ARTL_FetchTasksFromOrder extends LightningElement {
    @api recordId; 
    taskList = [];
    columns = columns;
    whatIds = new Set();
    isModalOpen = false;
    reportId;

    @wire(fetchTasksFromOrder, { orderId: '$recordId' })
    wiredTasks({ error, data }) {
        if (data) {
            this.taskList = data.map(task => ({
                ...task,
                SubjectLink: `/${task.Id}`,
                SubjectName: task.Subject, 
                RelatedTo: `/${task.WhatId}`, 
                RelatedToName: task.What.Name ,
                OwnerLink : `/${task.OwnerId}`,
                OwnerName: task.Owner.Name,
                AccountLink : `/${task.AccountId}`,
                AccountName: task.Account && task.Account.Name ? task.Account.Name : ' '
            }));
            data.forEach(task => {
                
                
                this.whatIds.add(task.WhatId); // Store WhatId for each task
            });
             
        } else if (error) {
            console.error('Error retrieving tasks:', error);
        }
    } 
    handleUpdateTasks() {
        this.getReportIdAndFilter();
    
    }
    getReportIdAndFilter() {
        getReportId({ reportName: 'ARTL_OrderWithTask_VPF' })
            .then(result => {
                this.reportId = result;
                this.filterReport(Array.from(this.whatIds));
            })
            .catch(error => {
                console.error('Error retrieving reportId:', error);
            });
    }
    filterReport(whatIds) {
        const filterValue = `fv0=${whatIds.join(',')}`;
        const url = `/lightning/r/Report/${this.reportId}/view${filterValue ? `?${filterValue}` : ''}`;
        window.open(url, '_blank');
    }
    

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

}