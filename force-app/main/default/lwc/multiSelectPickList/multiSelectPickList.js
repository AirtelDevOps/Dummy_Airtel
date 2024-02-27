import { LightningElement, api } from 'lwc';

export default class MultiSelectPickList extends LightningElement {

    @api options;
    @api selectedValue;
    @api selectedValues = [];
    @api label;
    @api disabled = false;
    @api multiSelect = false;
    value;
    values = [];
    optionData;
    searchString;
    noResultMessage;
    showDropdown = false;
    selectedApprove = false;
    @api yaxis;

    @api connectedCallback() {
        this.showDropdown = false;
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
        var val = [];

        if (this.selectedValues) {
            val = (JSON.parse(JSON.stringify(this.selectedValues))).split(';');
        }

        var values = val;

        if (value || values) {
            var searchString;
            var count = 0;
            for (var i = 0; i < optionData.length; i++) {
                if (this.multiSelect) {
                    if (values.includes(optionData[i].value)) {
                        optionData[i].selected = true;
                        count++;
                    }
                } else {
                    if (optionData[i].value == value) {
                        searchString = optionData[i].label;
                    }
                }
            }
            if (this.multiSelect)
                this.searchString = count + ' Option(s) Selected';
            else
                this.searchString = searchString;
        }
        this.value = value;
        this.values = values;
        this.optionData = optionData;
    }


    renderedCallback() {
        this.template.querySelector("[data-id=tel]")?.focus();
    }

    @api clearAll() {
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        for (var i = 0; i < optionData.length; i++) {
            if (this.multiSelect) {
                optionData[i].selected = false;
            }
        }

        this.searchString = 0 + ' Option(s) Selected';
        this.selectedValues = [];
        this.optionData = optionData;
    }

    filterOptions(event) {
        this.searchString = event.target.value;

        if (this.searchString && this.searchString.length > 0) {
            this.noResultMessage = '';
            if (this.searchString.length >= 2) {
                var flag = true;
                for (var i = 0; i < this.optionData.length; i++) {
                    if (this.optionData[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        this.optionData[i].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
                if (flag) {
                    this.noResultMessage = "No results found for '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }

        console.log("111: ",this.optionData);
    }

    selectItem(event) {
        var selectedVal = event.currentTarget.dataset.id;
        console.log("selectedVal ", selectedVal);
        console.log("this.this.values ", this.values );
        
        if(this.values.includes("Approved - No action required")) {
            this.selectedApprove = true;
        }
        
        if(this.values.length > 0 &&
            selectedVal == "Approved - No action required") {
                this.selectedApprove = true;
        }

        if(this.values.length == 1 && 
            this.values.includes("Approved - No action required") && 
            selectedVal == "Approved - No action required") {
                this.selectedApprove = false;
        }
        
        if (selectedVal && !this.selectedApprove) {
            var count = 0;
            var options = JSON.parse(JSON.stringify(this.optionData));
            for (var i = 0; i < options.length; i++) {
                if (options[i].value === selectedVal) {
                    if (this.multiSelect) {
                        if (this.values.includes(options[i].value)) {
                            this.values.splice(this.values.indexOf(options[i].value), 1);
                        } else {
                            this.values.push(options[i].value);
                        }
                        options[i].selected = options[i].selected ? false : true;
                    } else {
                        this.value = options[i].value;
                        this.searchString = options[i].label;
                    }
                }
                if (options[i].selected) {
                    count++;
                }
            }
            this.optionData = options;
            if (this.multiSelect) {
                this.searchString = count + ' Option(s) Selected';

                let ev = new CustomEvent('selectoption', { detail: this.values });
                this.dispatchEvent(ev);
            }


            if (!this.multiSelect) {
                let ev = new CustomEvent('selectoption', { detail: this.value });
                this.dispatchEvent(ev);
            }

            if (this.multiSelect)
                event.preventDefault();
            else
                this.showDropdown = false;
        }
    }

    showOptions() {
        if (this.disabled == false && this.options) {
            this.noResultMessage = '';
            this.searchString = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            for (var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if (options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }

    closePill(event) {
        var value = event.currentTarget.name;
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        for (var i = 0; i < options.length; i++) {
            if (options[i].value === value) {
                options[i].selected = false;
                this.values.splice(this.values.indexOf(options[i].value), 1);
            }
            if (options[i].selected) {
                count++;
            }
        }
        this.optionData = options;
        if (this.multiSelect) {
            this.searchString = count + ' Option(s) Selected';

            let ev = new CustomEvent('selectoption', { detail: this.values });
            this.dispatchEvent(ev);
        }
    }

    handleBlur() {
        var previousLabel;
        var count = 0;
console.log("this.optionData", this.optionData);
        for (var i = 0; i < this.optionData.length; i++) {
            if (this.optionData[i].value === this.value) {
                previousLabel = this.optionData[i].label;
            }
            if (this.optionData[i].selected) {
                count++;
            }
        }

        if (this.multiSelect) {
            this.searchString = count + ' Option(s) Selected';
        } else {
            this.searchString = previousLabel;
        }

        this.showDropdown = false;

        let ev = new CustomEvent('closepicklist', { detail: 'close' });
        this.dispatchEvent(ev);
    }

    handleMouseOut() {
        //this.showDropdown = false;
    }

    handleMouseIn() {
        //this.showDropdown = true;
    }

    get computedDropdownClass() {
        let axis = this.yaxis;
        axis = axis + 300;
        let directionCss = '';

        if (window.innerHeight < axis) {
            directionCss = 'showUpperDropDown';
        } else {
            directionCss = '';
        }

        let classs = 'slds-dropdown slds-dropdown_length-5 slds-dropdown_fluid ' + directionCss;
        return classs;

        /*if (this.showDropdown) {
            if (dropdownHeight === 'standard') {
                if (window.innerHeight <= VIEWPORT_HEIGHT_SMALL) {
                    dropdownLengthClass = 'slds-dropdown_length-with-icon-7';
                } else {
                    dropdownLengthClass = 'slds-dropdown_length-with-icon-10';
                }
            } else if (dropdownHeight === 'small') {
                dropdownLengthClass = 'slds-dropdown_length-with-icon-5';
            }
        }*/

        /*return classSet(
            `slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid ${dropdownLengthClass}`
        )
            .add({
                'slds-dropdown_left':
                    alignment === 'left' || alignment === 'auto',
                'slds-dropdown_center': alignment === 'center',
                'slds-dropdown_right': alignment === 'right',
                'slds-dropdown_bottom': alignment === 'bottom-center',
                'slds-dropdown_bottom slds-dropdown_right slds-dropdown_bottom-right':
                    alignment === 'bottom-right',
                'slds-dropdown_bottom slds-dropdown_left slds-dropdown_bottom-left':
                    alignment === 'bottom-left'
            })
            .toString();*/
    }
}