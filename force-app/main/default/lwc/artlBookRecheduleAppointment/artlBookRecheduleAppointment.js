import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";

export default class ArtlBookRecheduleAppointment extends OmniscriptBaseMixin(LightningElement) {
    sortedKeys;
    columns;
    cells;
    @track startDateString;
    @track endDateString;
    startIndex;
    endIndex;
    allHeaders;
    @track disabledPrevious = true;
    @api slotsdata;
    @api result;


    connectedCallback() {
        let apiJSON = this.result.availableOptionalAppointments;
        this.sortedKeys = Object.keys(apiJSON).sort();

        this.allHeaders = this.sortedKeys.map(key => {
            let date = new Date(key);
            let options = { weekday: 'short', month: 'short', day: 'numeric' };
            let label = date.toLocaleDateString('en-US', options);
            return {
                label: label,
                field: key
            };
        });



        this.columns = this.allHeaders.slice(0, 7);
        this.startIndex = 0;
        this.endIndex = this.columns.length - 1;
        // this.cells = this.sortedKeys.map(key => {
        //     const timeInterval = apiJSON[key][0].timeInterval;
        //     const startTime = timeInterval.start.split(":").slice(0, 2).join(":");
        //     const finishTime = timeInterval.finish.split(":").slice(0, 2).join(":");
        //     return {
        //         label: key,
        //         value: `${startTime} - ${finishTime}`,
        //         rowId: key+'T'+`${startTime} - ${finishTime}`
        //     };
        // });

        // this.inputData = [{
        //     id: this.sortedKeys[0],
        //     cells: this.cells.slice(0, 7)
        // }];
        let traveresedKeys = [];
        this.inputDataUi = []
        for (let i = 0; i < Math.max(...this.sortedKeys.map(date => apiJSON[date].length)); i++) {
            const row = { id: String(i), cells: [] };

            for (const date of this.sortedKeys) {
                const intervals = apiJSON[date];
                const cell = {
                    label: date,
                    value: "",
                    rowId: ""
                };

                if (i < intervals.length) {
                    const interval = intervals[i].timeInterval;
                    cell.value = `${interval.start.split(":").slice(0, 2).join(":")} - ${interval.finish.split(":").slice(0, 2).join(":")}`;
                    cell.rowId = `${date}T${interval.start} - ${interval.finish}`;
                }

                row.cells.push(cell);
            }

            this.inputDataUi.push(row);
        }
        this.inputData = this.inputDataUi.map(item => {
            return {
                id: item.id,
                cells: item.cells.slice(0, 7) // Slice the cells array to get only the first 7 items
            };
        });
        this.getFormattedDateRange();
    }


    getFormattedDateRange() {

        if (this.columns.length > 0) {
            const startDate = new Date(this.sortedKeys[this.startIndex]);
            const endDate = new Date(this.sortedKeys[this.endIndex - 1]);
            // Get the month name using toLocaleDateString() with options for formatting
            this.startDateString = startDate.toLocaleDateString('en-US', {
                month: 'long', // Display full month name
                day: 'numeric', // Display day of the month as a number
                year: 'numeric' // Display year as a number
            });
            this.endDateString = endDate.toLocaleDateString('en-US', {
                month: 'long', // Display full month name
                day: 'numeric', // Display day of the month as a number
                year: 'numeric' // Display year as a number
            });
        }
    }


    handleNextWeek(event) {
        this.disabledPrevious = false;
        this.startIndex = this.startIndex + 7;
        this.endIndex = this.startIndex + 7;
        if(this.endIndex > this.allHeaders.length){
            this.endIndex = this.allHeaders.length;
            this.disabledNext = true;
        }
        this.columns = this.allHeaders.slice(this.startIndex, this.endIndex);

        this.inputData = this.inputDataUi.map(item => {
            return {
                id: item.id,
                cells: item.cells.slice(this.startIndex, this.endIndex) // Slice the cells array to get only the first 7 items
            };
        });
        this.getFormattedDateRange();
    }

    handlePreviousWeek(event) {
        this.disabledNext = false;
        this.endIndex = this.startIndex;
        this.startIndex = this.endIndex - 7;
        if (this.startIndex === 0) {
            this.disabledPrevious = true;
        }
        this.columns = this.allHeaders.slice(this.startIndex, this.endIndex);

        this.inputData = this.inputDataUi.map(item => {
            return {
                id: item.id,
                cells: item.cells.slice(this.startIndex, this.endIndex) // Slice the cells array to get only the first 7 items
            };
        });
        this.getFormattedDateRange();
    }

    handleTimeClick(event) {
        const rowId = event.target.dataset.rowId;
        const times = rowId.split(" - ");
      
        // Extract date and time components
        const startDate = times[0].split("T")[0];
        const startTimeString = times[0].split("T")[1];
        const endTimeString = times[1];
      
        // Create Date objects for easier time manipulation
        const startTime = new Date(`${startDate}T${startTimeString}`);
        const endTime = new Date(`${startDate}T${endTimeString}`);

        const originalStartTime = times[0];
        const originalEndTime = startDate + "T" + times[1]; 
      
        // Format the adjusted times as strings in the desired format
        const adjustedStartTime = startTime.toISOString().slice(0, 19);
        const adjustedEndTime = endTime.toISOString().slice(0, 19);
      
        // Create the return object with the adjusted times
        const retSlot = { startTimeIP: originalStartTime, endTimeIP:originalEndTime, startTime: adjustedStartTime, endTime: adjustedEndTime };
      
        this.omniApplyCallResp({
          SelectedSlot: retSlot,
        });
        this.omniNextStep();
    }
    
    
    
}