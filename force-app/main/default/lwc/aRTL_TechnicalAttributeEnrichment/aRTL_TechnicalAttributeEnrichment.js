import { LightningElement, api, wire, track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import {getRelatedListRecords} from 'lightning/uiRelatedListApi';

//import getARTLJSONAttribute from '@salesforce/apex/ARTL_TechnicalAttrEnrichmentController.getJSONAttribute';
//import setAttributeValues from '@salesforce/apex/ARTL_TechnicalAttrEnrichmentController.setAttributeValues';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ARTL_TechnicalAttributeEnrichment extends OmniscriptBaseMixin(LightningElement)  {
@api recordId;
@track attributedata;
@track originalattributedata;
@track initialdata;
@track viewerCardTitle = 'Technical Attribute Viewer';
@track attributeValue;
@track activeSections = [];



    /**
     * 
     * @param {*} event 
     * @description save the JSON attribute
     */
    /*26Jan
    handleJSONAttributeSaveClick(event) {
        console.log('Inside handleJSONAttributeSaveClick')
        /*var attributeVals = {};
        for (var i = 0; i < this.attributes.length; i++) {
            attributeVals[this.attributes[i].code] = this.attributes[i].value;
        }*//*/*26Jan
        console.log(JSON.stringify(this.attributedata));
        let finalrecordInput = [];
        for(var i = 0; i < this.attributedata.length; i++){
            let attributeVals = {};
            let recordInput = {};
            recordInput['recordId'] = this.attributedata[i].productdetails.productid;
            for(var j = 0; j < this.attributedata[i].attributes.length; j++){
                console.log(this.attributedata[i].attributes[j].code);
                attributeVals[this.attributedata[i].attributes[j].code] = this.attributedata[i].attributes[j].value;
            }
            console.log(JSON.stringify(attributeVals));
            recordInput['values'] = attributeVals;
            finalrecordInput.push(recordInput);
        }
        let data = JSON.stringify(finalrecordInput);
        console.log(data);
        /*const recordInput = {};
        recordInput['recordId'] = this.techAttributeId;
        recordInput['values'] = attributeVals;
        console.log(this.techAttributeId);
        console.log(attributeVals);*/
        /*26Jan
        setAttributeValues({jSONInputs:data})   
            .then(() => {     
                /*for (var i = 0; i < this.attributes.length; i++) {
                    this.attributes[i].is_changed = false;
                    this.attributes[i].text_color = 'slds-text-color_default';
                }*//*26Jan
                this.updateJSONAttribute();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Technical attribute updated successfully',
                        variant: 'success'
                    })
                );
                if(this.attributes != undefined)
                    this.attributes = this.attributes.slice();

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Technical attribute',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }*/
    /* 26Jan
    @wire(getARTLJSONAttribute, { recordId: '$recordId'})
    getARTLJSONAttribute( { error, data }) {
        console.log('getARTLJSONAttribute ****>>>>');
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Technical attribute',
                    message: error.message,
                    letiant: 'error'
                })
            );            
        } else {
            if (data) {
                // this.wiredAttributeData = data;
                console.log('getARTLJSONAttribute>>>>');
                console.log(data);
                this.data = data;
                
                this.initialdata = JSON.parse(JSON.stringify(data));
                if(this.initialdata.length > 0){
                    this.activeSection = this.initialdata[0].productdetails.productName;
                    //for(let i =0; i < data.length; i++){
                    this.initialdata = this.initialdata.map(attributedata => {

                        let metadata = attributedata.jsonAttribute.metadata;
                        let values = attributedata.jsonAttribute.values;
                        this.activeSections.push(attributedata.productdetails.productName);
                        
                        console.log('88888' , attributedata.jsonAttribute.metadata.attributes);
                        console.log('Values>>>>',JSON.stringify(values));
                        console.log('Values*****',JSON.stringify(attributedata.jsonAttribute.metadata));
                        let attributes = [];
                        for (const [key, myAttribute] of Object.entries(metadata.attributes)) {
                            if(myAttribute.istechnical){
                                let attribute = {
                                    name: myAttribute.label,
                                    code: myAttribute.code,
                                    category_name: myAttribute.categoryName,
                                    category_code: myAttribute.categoryCode,
                                    readonly: myAttribute.readonly,
                                    text_color: 'slds-text-color_default',
                                    valueType:  myAttribute.valueType,
                                    // this following properties are used to render UI input element
                                    is_changed: false,
                                    is_picklist: myAttribute.valueType == 'picklist',
                                    is_input: myAttribute.valueType == 'text',
                                    is_date: myAttribute.valueType == 'date',
                                    is_datetime: myAttribute.valueType == 'datetime',
                                    is_number: myAttribute.valueType == 'number',
                                    is_currency: myAttribute.valueType == 'currency',
                                    is_percent: myAttribute.valueType == 'percent',
                                    is_checkbox: myAttribute.valueType == 'checkbox',
                                    // values
                                    value: values != null ? values[key] :'',
                                    display_value: values != null ? values[key] :'', // formatted value for display purpose
                                };         
                                
                                // Populate the picklist options
                                if (attribute.is_picklist) {
                                    attribute.options = [];
                                    attribute.options.push ( { label: '', value: null });
                                    if(myAttribute.values != null){
                                        myAttribute.values.forEach(item => {
                                            // console.log(item);
                                            attribute.options.push( {
                                                label: item.label,
                                                value: item.value
                                            });  

                                            if (item.value == attribute.value) {
                                                attribute.display_value = item.label;
                                            }
                                        });
                                    }
                                } 
                                
                                attribute.display_value = this.formatAttributeValue(attribute.value, attribute.valueType, attribute.options);
                                attributes.push(attribute);
                            }
                        }
                       attributedata.attributes = attributes;
                        return attributedata;
                    });
                    
                    this.attributedata = this.initialdata;
                    this.originalattributedata = this.attributedata;
                    console.log('***********');
                    console.log(JSON.stringify(this.attributedata));
                    //console.log(JSON.stringify(this.initialdata));
                }

            }

        }
    }*/
    /*26Jan
    updateJSONAttribute(){
        console.log('Inside updateJSONAttribute');
        for(var i = 0; i < this.attributedata.length; i++){
            for(var j = 0; j < this.attributedata[i].attributes.length; j++){
                
                if(this.attributedata[i].jsonAttribute.values[this.attributedata[i].attributes[j].code] != undefined){
                    this.attributedata[i].jsonAttribute.values[this.attributedata[i].attributes[j].code] = this.attributedata[i].attributes[j].value;
                    console.log(this.attributedata[i].attributes[j].code + '====' + this.attributedata[i].jsonAttribute.values[this.attributedata[i].attributes[j].code]);
                }
            }
        }
        console.log(JSON.stringify(this.attributedata));
    }*/
    /*26Jan
    handleJSONAttributeRefreshClick(event){
        console.log('Inside handleJSONAttributeRefreshClick');
        
        for(var i = 0; i < this.attributedata.length; i++){
            let attrvalue = this.attributedata[i].jsonAttribute.values;
            console.log(JSON.stringify(attrvalue));
            //if(event.target.dataset.xliid == this.attributedata[i].productdetails.productid){
                for(var j = 0; j < this.attributedata[i].attributes.length; j++){
                    console.log(attrvalue[this.attributedata[i].attributes[j].code]);
                    if(attrvalue[this.attributedata[i].attributes[j].code] != undefined){
                        console.log(event.target.dataset.code);
                        this.attributedata[i].attributes[j].display_value = this.formatAttributeValue(attrvalue[this.attributedata[i].attributes[j].code], this.attributedata[i].attributes[j].valueType, this.attributedata[i].attributes[j].options);
                        this.attributedata[i].attributes[j].value = attrvalue[this.attributedata[i].attributes[j].code];
                        this.attributedata[i].attributes[j].is_changed = false;
                    }else{
                        this.attributedata[i].attributes[j].display_value = null;
                        this.attributedata[i].attributes[j].value = null;
                        this.attributedata[i].attributes[j].is_changed = false;
                    }
                }
            //}
        }
        //console.log(JSON.stringify(this.attributedata));
    }*/
    /**
     * 
     * @param {*} event 
     */
    /*26Jan
    handleAttribueValueChange(event) {
        console.log('Code>>>>', event.target.dataset.code);
        console.log('Value>>>>', event.target.value);
        console.log('XLI Id>>>>', event.target.dataset.xliid);
        let data = event.target.dataset;
        console.log(event.target.dataset.code);
        console.log(event.target.value);
        
        if (typeof(event.target.type) === 'undefined') {
            if (event.target.options) {
                this.attributeValue = event.target.value;
            }
        } else {
            if (event.target.type === 'checkbox') {
                this.attributeValue = event.target.checked;
            } else {
                this.attributeValue = event.target.value;
            }
        }
        

        for(var i = 0; i < this.attributedata.length; i++){
            if(event.target.dataset.xliid == this.attributedata[i].productdetails.productid){
                for(var j = 0; j < this.attributedata[i].attributes.length; j++){
                    if(this.attributedata[i].attributes[j].code == event.target.dataset.code){
                        console.log(event.target.dataset.code);
                        this.attributedata[i].attributes[j].display_value = this.formatAttributeValue(this.attributeValue, this.attributedata[i].attributes[j].valueType, this.attributedata[i].attributes[j].options);
                        this.attributedata[i].attributes[j].value = this.attributeValue;
                        this.attributedata[i].attributes[j].is_changed = true;
                    }
                }
            }
        }

        console.log(JSON.stringify(this.attributedata));
        /*for (var i = 0; i < this.attributes.length; i++) {
            if(this.attributes[i].code == event.target.dataset.code){
                this.attributes[i].display_value = this.formatAttributeValue(this.attributeValue, this.attributes[i].valueType, this.attributes[i].options);
                this.attributes[i].value = this.attributeValue;
                this.attributes[i].is_changed = true;
                this.attributes[i].text_color = 'slds-text-color_error';
                //this.attributes[i].display_value = this.formatAttributeValue(this.attribute.value, this.attribute.valueType, this.attribute.options);
            }
           // attributeVals[this.attributes[i].code] = this.attributes[i].value;
        }
        //this.handleAttributeUpdateClick(event);
    }*/
     /**
     * 
     * @param {*} value attribute value
     * @param {*} valueType attribute value data type
     * @returns formatted display value
     */
    /*26Jan
    formatAttributeValue(value, valueType, options) {
        if (value == null || value === '') {
            return '';
        }

        if (valueType == 'datetime') {
            return new Date(value).toLocaleString();
        } else if (valueType == 'checkbox') {
            return value.toString();
        } else if (valueType == 'date') {
            return new Date(value).toLocaleDateString();
        } else if (valueType == 'number') {
            return new Intl.NumberFormat(LOCALE, { style: 'decimal'}).format(new Number(value));
        } else if (valueType == 'percent') {
            // CPQ engine does not use native percent control 
            return new Intl.NumberFormat(LOCALE, {style: 'decimal'}).format(new Number(value));
            // return new Intl.NumberFormat(LOCALE, {style: 'percent'}).format(new Number(value));
        } else if (valueType == 'currency') {
            return new Intl.NumberFormat(LOCALE, { style: 'currency', currency: CURRENCY, currencyDisplay: 'symbol'}).format(new Number(value));
        } else if (valueType == 'picklist') {
            var dispVal = value;
            options.forEach(item => {
                if (item.value == value) {
                    dispVal = item.label;
                }
            });           
            return dispVal;
        } else {
            return value;
        }     
    }*/
/*26Jan
    handleSaveClick(event){
        this.dispatchEvent(new CustomEvent('save', {
            detail: true
        }));
        console.log('Pn---SaveClickedAtrlTechAttr');
    }

    handleAttrChange(event){
        console.log('artl_tech.handleAttrChange'+JSON.stringify(event.detail));
        this.dispatchEvent(new CustomEvent('attributechange', {
            detail: {
                attributes: event.detail.attributes
            }
        }));
    }*/
}