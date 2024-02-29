import { LightningElement, api, track, wire } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
//import integrationDetails from '@salesforce/label/c.ARTL_Integration_Details__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { invokeDR } from "vlocity_cmt/b2bUtils";

export default class ArtlAddressCorrectionCmp extends LightningElement {
    @api recordId;
    @track ipResult = [];
    @track iframeUrlConst//="https://www.airtel.in/business/b2b/bulk-resolution-utility/oft-widget?";
    @track iframeUrl;
    quoteMemberId;
    qmIdUrlObj = {};
    // submittedDataList = [];
    qmIdToGeolocationMap = {};
    @track isGeoLocation = false;
    invalidSitesExist = false;
    showLoading = false;

    closeModal() {
        this.dispatchEvent(new CustomEvent("closemodalpopup"));
    }
    connectedCallback() {
        //this.showLoading = true;
        //sagar - start
        invokeDR('ARTL_DRE_GetAPIDetails', { name: 'AddressCorrectionUrl' }).then(res => {
            console.log('AddressCorrectionUrl: ' + res);
            this.iframeUrlConst = JSON.parse(res)[0].endpoint;
            console.log('AddressCorrectionUrl:PNNN' + this.iframeUrlConst);
            //this.contactDataObj = JSON.parse(res)[0];
        }, err => {
            console.error(err);
        });
        //sagar - end
        console.log('recordIdpnnn' + this.recordId);
        //console.log('integrationDetailsDetails'+JSON.stringify(integrationDetails));
        let recordObj = { QuoteId: this.recordId };
        //Fetch QM Details
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_getQMAddressNStatus",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        };
        getDataHandler(JSON.stringify(requestData)).then(response => {
            //this.showLoading = false;
            this.ipResult = JSON.parse(response);
            this.ipResult = this.ipResult.IPResult;
            console.log('pnnn..this.ipResult'+JSON.stringify(this.ipResult));
            if(Array.isArray(this.ipResult)){
                this.invalidSitesExist = true;
                /*for (const obj of this.ipResult) {
                    if (obj.ARTL_Feasibility_Geolocation__c !== null) {
                        this.isGeoLocation = true;
                        break; // Break out of the loop if one object has non-null value
                    }
                }*/
                console.log('geoLocationVal' + this.isGeoLocation);
                //if (this.isGeoLocation) {
                    this.ipResult.forEach((item) => {
                        item.isChecked = false;
                        //item.ARTL_Feasibility_Geolocation__Latitude__s = ''; 
                        //item.ARTL_Feasibility_Geolocation__Longitude__s = ''; 
                    });
                    this.ipResult[0].isChecked = true;
                    //console.log('reuqstDatPN' + JSON.stringify(this.ipResult));
                    let urlAppendString = this.constructUrlString(this.ipResult[0]);
                    this.quoteMemberId = this.ipResult[0].Id;
                    console.log('connectedCallback.urlAppendString' + urlAppendString);
                    this.iframeUrl = this.iframeUrlConst + urlAppendString;
                //}
            }else{
                this.invalidSitesExist = false;
            }
            

        });

        //Add event listener to the Airtel-Map Iframe
        window.addEventListener("message", (OFT_ADDRESS_LOCATION) => {
            console.log('EventDetail' + JSON.stringify(OFT_ADDRESS_LOCATION.data));
            //alert('Hi');
        });
        window.addEventListener("message", (OFT_ADDRESS_SUBMITTED) => {
            console.log('COnfirmDEtails' + JSON.stringify(OFT_ADDRESS_SUBMITTED.data));
            if (OFT_ADDRESS_SUBMITTED.data.eventName === 'OFT_ADDRESS_SUBMITTED') {
                this.handleOFTAddressSubmit(OFT_ADDRESS_SUBMITTED.data);
            }
            //alert('Hi');
        });


    }
    
    handleChangeGeo(event){
        let index = event.currentTarget.dataset.index;
        let geoType = event.currentTarget.dataset.geotype;

        if(geoType == 'lat'){
            this.ipResult[index].ARTL_Feasibility_Geolocation__Latitude__s = event.currentTarget.value;
            this.ipResult[index].ARTL_Feasibility_Geolocation__c.latitude = event.currentTarget.value;
            
        }else if(geoType == 'long'){
            this.ipResult[index].ARTL_Feasibility_Geolocation__Longitude__s = event.currentTarget.value;
            this.ipResult[index].ARTL_Feasibility_Geolocation__c.longitude = event.currentTarget.value;
        }
        let urlAppendString = this.constructUrlString(this.ipResult[index]);
        //console.log('connectedCallback.urlAppendString' + urlAppendString);
        this.iframeUrl = this.iframeUrlConst + urlAppendString;
        console.log(this.iframeUrl);
        
        const updatedMap = {
            ...this.qmIdToGeolocationMap,
            [this.ipResult[index].id]: this.ipResult[index] 
        };
        this.qmIdToGeolocationMap = updatedMap;
    }

    handleCheckboxChange(e) {
        //const itemId = e.target.dataset.id;
        this.quoteMemberId = e.target.dataset.id;
        console.log('EventHappende' + JSON.stringify(e.detail));
        console.log('reuqstDatPN' + JSON.stringify(this.ipResult));
        console.log('Item Id:' + this.quoteMemberId);
        let filteredData;
        let urlAppendString;
        if (e.detail.checked) {
            /*this.template.querySelectorAll('lightning-input').forEach((checkbox) => {
                if (checkbox.dataset.id !== this.quoteMemberId) {
                    checkbox.checked = false;
                }
            });*/
            this.ipResult.forEach((item) => {
                item.isChecked = item.Id === this.quoteMemberId ? true : false;
            });
            filteredData = this.ipResult.filter(item => item.Id === this.quoteMemberId)[0];
            console.log('handleCheckboxChange.filteredData' + JSON.stringify(filteredData));
            //companyName=Mariner Square Loop Shop&city=Alameda&pincode=94501&lat=37.78659&long=-122.27855&address=J-17,, Mariner Square Loop, Alameda, California
            urlAppendString = this.constructUrlString(filteredData);
            this.iframeUrl = this.iframeUrlConst + urlAppendString;
            console.log('handleCheckboxChange.urlAppendString' + urlAppendString);
            this.qmIdUrlObj[this.quoteMemberId] = this.iframeUrl;
            console.log('qmIdUrlObjo/p' + JSON.stringify(this.qmIdUrlObj));
        }
        if (!e.detail.checked) {
            this.ipResult.filter(item => item.Id === this.quoteMemberId)[0].isChecked = false;
            console.log('uncheckedMap' + JSON.stringify(this.qmIdToGeolocationMap));
            if (this.qmIdToGeolocationMap && this.quoteMemberId in this.qmIdToGeolocationMap) {
                delete this.qmIdToGeolocationMap[this.quoteMemberId];
            }
        }
    }

    constructUrlString(filteredData) {
        let urlAppendString = 'companyName=' + filteredData.vlocity_cmt__StreetAddress__c + 'Shop&city=' + filteredData.vlocity_cmt__City__c + '&pincode=' +
            filteredData.vlocity_cmt__PostalCode__c + '&lat=' + filteredData.ARTL_Feasibility_Geolocation__Latitude__s + '&long=' +
            filteredData.ARTL_Feasibility_Geolocation__Longitude__s + '&address=J-17,, ' + filteredData.vlocity_cmt__StreetAddress__c + ', ' + filteredData.vlocity_cmt__City__c + ', ' + filteredData.vlocity_cmt__State__c;
        return urlAppendString;
    }

    handleOFTAddressSubmit(addressSubmittedData) {
        console.log('handleOFTAddressSubmit.addressSubmittedData' + JSON.stringify(addressSubmittedData));
        console.log('handleOFTAddressSubmit.ipResultBefore' + JSON.stringify(this.ipResult));
        console.log('handleOFTAddressSubmit.quoteMemberId' + this.quoteMemberId);
        this.ipResult.forEach((item) => {
            if (item.Id === this.quoteMemberId) {
                //alert('Hi');
                item.ARTL_Feasibility_Geolocation__c.latitude = parseFloat(addressSubmittedData.lat).toFixed(4);
                item.ARTL_Feasibility_Geolocation__c.longitude = parseFloat(addressSubmittedData.long).toFixed(4);
                item.ARTL_Feasibility_Error_Margin__c = addressSubmittedData.address.errorMargin;
                item.ARTL_Feasibility_Geolocation__Longitude__s = parseFloat(addressSubmittedData.lat).toFixed(4);
                item.ARTL_Feasibility_Geolocation__Latitude__s = parseFloat(addressSubmittedData.long).toFixed(4);
                item.isChecked = false;
                // if(addressSubmittedData.address.errorMargin<25){
                //     item.ARTL_Address_Verification_Status__c = '<img src=\"/resource/1700210369000/Icon_Green?\" alt=\"Green\" style=\"height:20px; width:12px;\" border=\"0\"/>';
                // }
                // else if(addressSubmittedData.address.errorMargin>25 && addressSubmittedData.address.errorMargin<49){
                //     item.ARTL_Address_Verification_Status__c = '<img src=\"/resource/1700210320000/Icon_Yellow?\" alt=\"Yellow\" style=\"height:20px; width:12px;\" border=\"0\"/>';
                // }
                // else{
                //     item.ARTL_Address_Verification_Status__c = '<img src=\"/resource/1700555016000/Icon_Red\" alt=\"Red\" style=\"height:20px; width:12px;\" border=\"0\"/>';
                // }
            }
        });
        console.log('handleOFTAddressSubmit.ipResultAfter' + JSON.stringify(this.ipResult));
        // const updatedMap = {'result':[
        //     {'Id':this.quoteMemberId,
        //     "ARTL_Feasibility_Geolocation__Longitude__s": parseFloat(addressSubmittedData.long).toFixed(4),
        //     "ARTL_Feasibility_Geolocation__Latitude__s":parseFloat(addressSubmittedData.lat).toFixed(4)}
        // ]}
        const updatedMap = {
            ...this.qmIdToGeolocationMap,
            [this.quoteMemberId]: {
                "ARTL_Feasibility_Geolocation__c": {
                    "latitude": parseFloat(addressSubmittedData.lat).toFixed(4),
                    "longitude": parseFloat(addressSubmittedData.long).toFixed(4)
                },
                "ARTL_Feasibility_Error_Margin__c": 24,//KB: Sagar- updating it to valid address if user is correcting the address through address correction(requested by Sidhant) //addressSubmittedData.address.errorMargin,
                "ARTL_Feasibility_Geolocation__Longitude__s": parseFloat(addressSubmittedData.long).toFixed(4),
                "ARTL_Feasibility_Geolocation__Latitude__s": parseFloat(addressSubmittedData.lat).toFixed(4),
            }
        };
        this.qmIdToGeolocationMap = updatedMap;
        console.log('handleOFTAddressSubmit.qmIdToGeolocationMap' + JSON.stringify(this.qmIdToGeolocationMap));
    }

    handleSubmit(e) {
        const outputArray = Object.keys(this.qmIdToGeolocationMap).map((key) => {
            return {
                Id: key,
                ...this.qmIdToGeolocationMap[key]
            };
        });

        console.log('addressCorrection.handleSubmit.outputArray' + JSON.stringify(outputArray));
        const ipInput = {
            "result": Object.keys(this.qmIdToGeolocationMap).map((key) => {
                return {
                    Id: key,
                    ...this.qmIdToGeolocationMap[key]
                };
            })
        };
        console.log('addressCorrection.handleSubmit.ipInput' + JSON.stringify(ipInput));
        console.log('addressCorrection.handleSubmit.qmIdToGeolocationMap' + JSON.stringify(this.qmIdToGeolocationMap));
        if (ipInput.result.length > 0) {
            //alert('Hi');
            let requestData = {
                "type": "integrationprocedure",
                "value": {
                    "ipMethod": "ARTL_UpdateQuoteMemberGeoLocation",
                    "inputMap": ipInput,
                    "optionsMap": ''
                }
            };
            getDataHandler(JSON.stringify(requestData)).then(response => {
                let updateipResult = JSON.parse(response);
                updateipResult = updateipResult.IPResult;
                console.log('upadteIPREs' + JSON.stringify(updateipResult));
                this.ShowToast('Success', 'Address Corrected Successfully', "success", "dismissable")
                this.closeModal();
                setTimeout(function(){
                    window.location.reload();
                }, 2000);
                
            });

        }

    }

    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}