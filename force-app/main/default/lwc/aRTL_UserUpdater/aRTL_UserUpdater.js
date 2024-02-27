// userUpdaterLWC.js
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentUserRole from '@salesforce/apex/ARTL_UserUpdater.getCurrentUserRole';
import updateUserRole from '@salesforce/apex/ARTL_UserUpdater.updateUserRole';
import getRoleOptions from '@salesforce/apex/ARTL_UserUpdater.getRoleOptions';

export default class UserUpdaterLWC extends LightningElement {
    @api recordId; // The Id of the current User record
    @track currentUserRole;
    @track selectedRole;
    @track roles;
    @track isRoleUpdaterOpen = false;

    // Fetch the current user's role and all available roles on component initialization
    connectedCallback() {
        this.fetchCurrentUserRole();
        this.fetchRoles();
    }

    // Fetch the current user's role
    fetchCurrentUserRole() {
        getCurrentUserRole({ userId: this.recordId })
            .then(result => {
                this.currentUserRole = result;
            })
            .catch(error => {
                console.error(error);
                this.showToastMessage('Error', 'An error occurred while fetching user role.');
            });
    }

    // Fetch all roles
    fetchRoles() {
        getRoleOptions()
            .then(result => {
                this.roles = result;
            })
            .catch(error => {
                console.error(error);
                this.showToastMessage('Error', 'An error occurred while fetching roles.');
            });
    }

    // Open the role updater modal
    openRoleUpdater() {
        this.isRoleUpdaterOpen = true;
    }

    // Handle changes in the selected role within the modal
    handleRoleChange(event) {
        this.selectedRole = event.detail.value;
    }

    // Close the role updater modal
    closeRoleUpdater() {
        this.isRoleUpdaterOpen = false;
        this.selectedRole = null; // Reset selected role when closing the modal
    }

    // Update the user role
    updateUserRole() {
        if (!this.selectedRole) {
            this.showToastMessage('Error', 'Please select a new role.');
            return;
        }

        updateUserRole({
            userId: this.recordId,
            roleId: this.selectedRole
        })
            .then(() => {
                this.showToastMessage('Success', 'User role updated successfully.', 'success');
                this.closeRoleUpdater();
            })
            .catch(error => {
                console.error(error);
                this.showToastMessage('Error', 'An error occurred while updating user role.', 'error');
            });
    }

    // Show toast message
    showToastMessage(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}