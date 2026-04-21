import { LightningElement, api } from 'lwc';

export default class SlaCountdown extends LightningElement {
    @api deadline;

    timeRemaining = '';
    slaStatus = '';
    statusClass = '';
    
    _intervalId;

    connectedCallback() {
        this._updateCountdown();
        this._intervalId = setInterval(() => {
            this._updateCountdown();
        }, 1000);
    }

    disconnectedCallback() {
        if (this._intervalId) {
            clearInterval(this._intervalId);
        }
    }

    _updateCountdown() {
        if (!this.deadline) {
            this.timeRemaining = '';
            this.slaStatus = '';
            this.statusClass = '';
            return;
        }

        const now = new Date();
        const deadlineDate = new Date(this.deadline);
        const diffMs = deadlineDate - now;
        const diffSeconds = Math.floor(diffMs / 1000);

        if (diffSeconds <= 0) {
            this.timeRemaining = '0s';
            this.slaStatus = 'Breach';
            this.statusClass = 'sla breach';
            return;
        }

        const hours = Math.floor(diffSeconds / 3600);
        const minutes = Math.floor((diffSeconds % 3600) / 60);
        const seconds = diffSeconds % 60;

        this.timeRemaining = `${hours}h ${minutes}m ${seconds}s`;

        if (diffSeconds <= 3600) {
            this.slaStatus = 'At Risk';
            this.statusClass = 'sla warn';
        } else {
            this.slaStatus = 'On Track';
            this.statusClass = 'sla ok';
        }
    }
}