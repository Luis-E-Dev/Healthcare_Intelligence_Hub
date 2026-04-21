import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Case.Subject',
    'Case.Status',
    'Case.Type',
    'Case.Priority_Score__c',
    'Case.SLA_Deadline__c',
    'Case.Case_Summary__c',
    'Case.Account.Name',
    'Case.Account.Type',
    'Case.Contact.Name',
    'Case.Contact.Title'
]

export default class CaseIntelligencePanel extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS }) caseRec;

    get caseSubject() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data ? this.caseRec.data.fields.Subject.value : '';
    }

    get caseStatus() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data ? this.caseRec.data.fields.Status.value : '';
    }

    get caseType() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data ? this.caseRec.data.fields.Type.value : '';
    }

    get casePriorityScore() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data ? this.caseRec.data.fields.Priority_Score__c.value : '';
    }

    get caseSLADeadline() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data ? this.caseRec.data.fields.SLA_Deadline__c.value : '';
    }

    get caseSummary() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data ? this.caseRec.data.fields.Case_Summary__c.value : '';
    }

    get caseAccountName() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data?.fields.Account.value?.fields.Name.value ?? '';
    }

    get caseAccountType() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data?.fields.Account.value?.fields.Type.value ?? '';
    }

    get caseContactName() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data?.fields.Contact.value?.fields.Name.value ?? '';
    }

    get caseContactTitle() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return this.caseRec.data?.fields.Contact.value?.fields.Title.value ?? '';
    }

    get priorityScoreLabel() {
        console.log('Case Record Data:', JSON.stringify(this.caseRec.data));
        return `Priority Score: ${this.casePriorityScore}`;
    }
}