import { LightningElement, api, wire, track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';
import ProtocolSuffixes from '@salesforce/label/c.ProtocolSuffixes';
import AttributeValidationFields from '@salesforce/label/c.AttributeValidationFields';
import RFSQueryFields from '@salesforce/label/c.RFS_Query_Fields';
import ErrorUpdatingAttributeToast from '@salesforce/label/c.Error_updating_attribute_Toast';
import AttributeUpdatedToast from '@salesforce/label/c.AttributeUpdatedToast';
import VerifyFieldValuesToast from '@salesforce/label/c.VerifyFieldValuesToast';
import InvalidFieldValuesTitle from '@salesforce/label/c.Invalid_Field_Values_Title';
import StaticAttributes from '@salesforce/label/c.Static_Attributes';
import Static from '@salesforce/label/c.Static';
import PrivateNPublicBGPAttributes from '@salesforce/label/c.Private_N_Public_BGP_Attributes';
import PrivateBGP from '@salesforce/label/c.Private_BGP';
import PublicBGP from '@salesforce/label/c.Public_BGP';
import StaticNBGPHybridAttributes from '@salesforce/label/c.Static_N_BGP_Hybrid_Attributes';
import CustomerSegment from '@salesforce/label/c.Customer_Segment';
import StaticwithPrivateBGP from '@salesforce/label/c.Static_with_Private_BGP';
import StaticwithPublicBGP from '@salesforce/label/c.Static_with_Public_BGP';
import OrderType from '@salesforce/label/c.Order_Type';
import RFS from '@salesforce/label/c.RFS';
import CustomerNeededByDate from '@salesforce/label/c.Customer_Needed_By_Date'; //cu-Customer_Needed_By_Date
import getTaskDetail from '@salesforce/apex/TaskTechnicalAttributeEnrichmentCtlr.getTaskDetails';
import getJSONAttribute from '@salesforce/apex/TaskTechnicalAttributeEnrichmentCtlr.getJSONAttribute';
import setAttributeValues from '@salesforce/apex/TaskTechnicalAttributeEnrichmentCtlr.setAttributeValues';
import getMetadataRecords from '@salesforce/apex/TaskTechnicalAttributeEnrichmentCtlr.getMetadataRecords';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const actions = [
    { label: 'Details', name: 'show_details' }
];
const columns = [
    // { label: 'Code', fieldName: 'code', sortable: true },
    { label: 'Name', fieldName: 'name', sortable: true },
    { label: 'Value', fieldName: 'value', editable: true, sortable: true, cellAttributes: { class: { fieldName: 'text_color' } } },
    { label: 'Code', fieldName: 'code', sortable: true },
    { label: 'Category', fieldName: 'category_name', sortable: true },
    {
        type: 'button-icon',
        typeAttributes: { iconName: 'utility:edit', iconClass: "slds-button__icon", name: 'edit', variant: 'bare' },
        fixedWidth: 30,
    }

];

export default class TaskTechnicalAttributeEnrichment extends LightningElement {
    @api recordId;
    @api olirecordId;
    @api taskrecordId;
    @track techAttributeId;
    @track taskSubject;
    // wiredAttributeData;

    // @track record;
    // @track jsonAttributeField;
    // Attribute List
    @track attributes;
    @track customfieldsmap;

    @track sortBy;
    @track sortDirection;
    @track viewerCardTitle = 'Technical Attribute Viewer';

    // Attribute Info
    @track attribute;
    @track attributeValue;
    @track allAttributes;
    @track groupedAttributes = [];

    @track columns = columns;
    //routingTypeSuffixVals = ['_BGP', '_HYD', '_BGPHYD', '_STC', '_All'];
    label = {
        ProtocolSuffixes,
        AttributeValidationFields,
        RFSQueryFields,
        ErrorUpdatingAttributeToast,
        AttributeUpdatedToast,
        VerifyFieldValuesToast,
        InvalidFieldValuesTitle,
        StaticAttributes,
        Static,
        PrivateNPublicBGPAttributes,
        PrivateBGP,
        PublicBGP,
        StaticNBGPHybridAttributes,
        CustomerSegment,
        StaticwithPrivateBGP,
        StaticwithPublicBGP,
        OrderType,
        RFS,
        CustomerNeededByDate
    };
    routingTypeSuffixVals = JSON.parse(JSON.stringify(this.label.ProtocolSuffixes || []).replace(/'|\[|\]|,/g, '')).split(' ').filter(Boolean);
    attributeValidationFields = JSON.parse(JSON.stringify(this.label.AttributeValidationFields || []).replace(/'|\[|\]|,/g, '')).split(' ').filter(Boolean);
    RFSQueryFields = JSON.parse(JSON.stringify(this.label.RFSQueryFields || []).replace(/'|\[|\]|,/g, '')).split(' ').filter(Boolean);
    StaticAttributes = JSON.parse(JSON.stringify(this.label.StaticAttributes || []).replace(/'|\[|\]|,/g, '')).split(' ').filter(Boolean);
    PrivateNPublicBGPAttributes = JSON.parse(JSON.stringify(this.label.PrivateNPublicBGPAttributes || []).replace(/'|\[|\]|,/g, '')).split(' ').filter(Boolean);
    StaticNBGPHybridAttributes = JSON.parse(JSON.stringify(this.label.StaticNBGPHybridAttributes || []).replace(/'|\[|\]|,/g, '')).split(' ').filter(Boolean);


    @track isLoading = true;
    serviceType;
    mediaType;
    rfsMetada;
    customerSegement;
    orderType;
    isOrderItem = false
    attrValidations;
    enterpriseCatCode = 'ATC_ENTERPRISE_DETAILS';
    serviceTypeCode = 'ATT_SERVICE_TYPE';
    mediaTypeCode = 'ATT_MEDIA';
    routingTypeCodeEill = 'ATT_ROUTING_TYPE';
    routingTypeCodeMpls = 'ATT_ROUTING_TYPE_MPLS'
    clonedAllAttributes;
    routerMatrix;
    @track activeSections = [];

    renderedCallback() {
        
        this.isLoading = false;
    }
    connectedCallback(){
        console.log('recordId>>>' + this.recordId);
        this.taskrecordId = this.recordId;
    }

    /**
     * 
     * @param {*} value attribute value
     * @param {*} valueType attribute value data type
     * @returns formatted display value
     */
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
        } else if (valueType == 'number' || valueType == 'double') {
            return new Intl.NumberFormat(LOCALE, { style: 'decimal' }).format(new Number(value));
        } else if (valueType == 'percent') {
            // CPQ engine does not use native percent control 
            return new Intl.NumberFormat(LOCALE, { style: 'decimal' }).format(new Number(value));
            // return new Intl.NumberFormat(LOCALE, {style: 'percent'}).format(new Number(value));
        } else if (valueType == 'currency') {
            return new Intl.NumberFormat(LOCALE, { style: 'currency', currency: CURRENCY, currencyDisplay: 'symbol' }).format(new Number(value));
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
    }
    @wire (getTaskDetail, { recordId: '$recordId'})
    gettaskDetails({error,data}){
        console.log('Inside gettaskDetails');
        console.log(data);
        if (data && data.Order_Product__c != undefined) {
            this.taskSubject = data.Subject;
            this.olirecordId = data.Order_Product__c;
            this.taskrecordId = this.recordId;
            console.log(this.taskSubject + '====='+this.taskrecordId + '=====' + this.olirecordId);
        }
        else{
            console.log(error);
        }
    }


    /**
     * @description wired Apex method to load JSON attributes for the given xLI by Id
     */
    @wire(getJSONAttribute, { recordId: '$olirecordId', tasktype: '$taskSubject', taskrecordId: '$taskrecordId'})
    async getJSONAttribute({ error, data }) {
        this.isLoading = true;
        //For showing save button on the tech attribute screen in the case of order item
        if (this.olirecordId !== undefined && this.olirecordId.startsWith('802')) {
            this.isOrderItem = true;
        }
        if (error) {
            if (this.olirecordId === null) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading JSONAttributes',
                        message: error.message,
                        variant: 'error'
                    })
                );
            }

        } else {
            if (data) {
                var metadata = data.metadata;
                console.log(data);
                var values = data.values;
                this.attributes = [];
                this.allAttributes = [];
                let isProtocolAttribute;
                let suffixArrayToAdd = [];
                //this.activeSections = 

                await this.getAttrValidations();

                for (const [key, myAttribute] of Object.entries(metadata.attributes)) {
                    // Remove the portion starting from three underscores:
                    const trimmedKey = key.replace(/^(.*?)___.*$/, '$1');
                    isProtocolAttribute = false;
                    var attribute = {
                        name: myAttribute.label,
                        code: myAttribute.code,
                        category_name: myAttribute.categoryName,
                        category_code: myAttribute.categoryCode,
                        readonly: myAttribute.readonly,
                        text_color: 'slds-text-color_default',
                        valueType: myAttribute.valueType,
                        therecordId: myAttribute.theRecordId,
                        productName: myAttribute.productName,
                        objectName: myAttribute.objectName,
                        // this following properties are used to render UI input element
                        is_changed: false,
                        is_picklist: myAttribute.valueType == 'picklist',
                        is_input: myAttribute.valueType == 'text',
                        is_date: myAttribute.valueType == 'date',
                        is_datetime: myAttribute.valueType == 'datetime',
                        is_number: myAttribute.valueType == 'double',
                        is_currency: myAttribute.valueType == 'currency',
                        is_percent: myAttribute.valueType == 'percent',
                        is_checkbox: myAttribute.valueType == 'checkbox',
                        is_textarea: myAttribute.valueType == 'textarea',
                        is_field: myAttribute.valueType == 'field',
                        isFieldVal: false,
                        // values
                        value: values[trimmedKey],
                        fieldValue: myAttribute.fieldValue != null ? myAttribute.fieldValue : '',
                        display_value: values[trimmedKey], // formatted value for display purpose
                        isRequired: false,
                        hasCustomError: false
                    };

                    // Populate the picklist options
                    if (attribute.is_picklist) {
                        attribute.options = [];
                        attribute.options.push({ label: '', value: null });

                        myAttribute.values.forEach(item => {
                            // console.log(item);
                            attribute.options.push({
                                label: item.label,
                                value: item.value
                            });

                            if (item.value == attribute.value) {
                                attribute.display_value = item.label;
                            }
                        });
                    }

                    attribute.display_value = this.formatAttributeValue(attribute.value, attribute.valueType, attribute.options);
                    if ((this.olirecordId.substring(0, 3) === "0QL" || this.olirecordId.substring(0, 3) === "802") && (myAttribute.categoryCode === this.enterpriseCatCode || myAttribute.categoryName === 'Technical Attributes')) {
                        this.routingTypeSuffixVals.forEach(suffix => {
                            if (myAttribute.code.endsWith(suffix) || myAttribute.code === 'Id') {
                                isProtocolAttribute = true;
                            }
                        });
                        if (!isProtocolAttribute) {
                            this.attributes.push(attribute);
                            isProtocolAttribute = false;
                            if (attribute.value === this.label.StaticwithPrivateBGP || attribute.value === this.label.StaticwithPublicBGP) {
                                suffixArrayToAdd = this.StaticNBGPHybridAttributes;
                                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
                            }
                            if (attribute.value === this.label.PrivateBGP || attribute.value === this.label.PublicBGP) {
                                suffixArrayToAdd = this.PrivateNPublicBGPAttributes;
                                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
                            }
                            if (attribute.value === this.label.Static) {
                                suffixArrayToAdd = this.StaticAttributes;
                                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
                            }
                        }
                    }
                    else if (this.olirecordId.substring(0, 3) !== "0QL" && this.olirecordId.substring(0, 3) !== "802" && myAttribute.code !== 'Id') {
                        this.attributes.push(attribute);
                    }
                    this.allAttributes.push(attribute);

                }
                this.clonedAllAttributes = JSON.parse(JSON.stringify(this.allAttributes));
                //console.log(this.clonedAllAttributes);
                console.log('this.attributes--->' + JSON.stringify(this.clonedAllAttributes));
                //To get RFS caluclation matrix
                this.getRFSMetadata();
                this.attributeValidation();
                this.getRouterMatrix();
                this.groupAttributes();

            }
        }
    }


    groupAttributes() {
        

        const grpAttributes = {};
        //console.log(this.attributes);
        //console.log(JSON.parse(JSON.stringify(this.attributes)));
        this.attributes.forEach(attribute => {
            const productName = attribute.productName || '';

            if (!grpAttributes[productName]) {
                grpAttributes[productName] = {
                    productName: productName,
                    attributes: []
                };
            }

            grpAttributes[productName].attributes.push(attribute);
        });

        this.groupedAttributes = Object.values(grpAttributes);
        let fna = JSON.parse(JSON.stringify(this.attributes));
        console.log('groupedAttributes---->');
        console.log(fna);
       // console.log('groupedAttributes---->'+JSON.stringify(this.groupedAttributes));

    }

    /**
     * 
     * @param {*} value attribute value
     * @param {*} valueType attribute value data type
     * @returns formatted display value
     */
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
            return new Intl.NumberFormat(LOCALE, { style: 'decimal' }).format(new Number(value));
        } else if (valueType == 'percent') {
            // CPQ engine does not use native percent control 
            return new Intl.NumberFormat(LOCALE, { style: 'decimal' }).format(new Number(value));
            // return new Intl.NumberFormat(LOCALE, {style: 'percent'}).format(new Number(value));
        } else if (valueType == 'currency') {
            return new Intl.NumberFormat(LOCALE, { style: 'currency', currency: CURRENCY, currencyDisplay: 'symbol' }).format(new Number(value));
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
    }



    //Added by Prabanch to handle attribute value change
    handleAttribueValueChange(event) {

        this.isAttributeChanged = true
        let selectedAttributeVal;
        let rfsVal;
        let rfsDate;
        let selectedDate;
        if (typeof (event.target.type) === 'undefined') {
            if (event.target.options) {
                selectedAttributeVal = event.target.value;
            }
        }
        else {
            if (event.target.type === 'checkbox') {
                selectedAttributeVal = event.target.checked;
            } else {
                selectedAttributeVal = event.target.value;
            }
        }
        console.log('handleAttribueValueChange.selectedAttributeVal' + event.target.dataset.code);
        console.log('Record ID:----->' + event.target.dataset.recordId);
        console.log('selectedAttributeVal----->' + selectedAttributeVal);
        let suffixArrayToAdd = [];
        if (this.olirecordId.substring(0, 3) === "0QL" || this.olirecordId.substring(0, 3) === "802" || this.taskrecordId.substring(0, 3) === "00T") {

            this.allAttributes.forEach(allAttr => {
                console.log(allAttr.code + '==='+ event.target.dataset.code + '====' +allAttr.therecordId + '===' + event.target.dataset.recordId);
                if (allAttr.code === event.target.dataset.code && allAttr.therecordId === event.target.dataset.recordId) {
                    console.log('Inside if>>>>');
                    allAttr.value = selectedAttributeVal;
                    allAttr.is_changed = true;
                    allAttr.display_value = this.formatAttributeValue(selectedAttributeVal, allAttr.valueType, allAttr.options);
                    console.log('display_value>>>>' +allAttr.display_value);
                    if (allAttr.code === this.label.CustomerNeededByDate) {
                        allAttr.isFieldVal = true;
                    }
                }
            });

            //****To restrict attribute values for routing type starts here
            if (selectedAttributeVal === this.label.StaticwithPrivateBGP || selectedAttributeVal === this.label.StaticwithPublicBGP) {
                suffixArrayToAdd = this.StaticNBGPHybridAttributes;
                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
            }
            if (selectedAttributeVal === this.label.PrivateBGP || selectedAttributeVal === this.label.PublicBGP) {
                suffixArrayToAdd = this.PrivateNPublicBGPAttributes;
                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
            }
            if (selectedAttributeVal === this.label.Static) {
                suffixArrayToAdd = this.StaticAttributes;
                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
            }
            if (selectedAttributeVal === 'None') {
                suffixArrayToAdd = [];
                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
            }
            //****To restric attribute values for routing type ends here
        }


        if (event.target.dataset.code === this.label.CustomerNeededByDate) {
            rfsVal = this.getRFSVal();
            if (rfsVal !== undefined) {
                selectedDate = new Date(selectedAttributeVal);

                // Calculate the new date by adding rfsVal days
                selectedDate.setDate(selectedDate.getDate() + rfsVal);

                // Format the result as needed
                rfsDate = selectedDate.toISOString().split('T')[0];

                console.log('rfsDate ----> ' + rfsDate);
                this.allAttributes.forEach(attr => {
                    if (attr.code === this.label.RFS) {
                        attr.value = rfsDate;
                        attr.is_changed = true;
                        attr.display_value = this.formatAttributeValue(rfsDate, attr.valueType, attr.options);
                        attr.isFieldVal = true;
                    }
                });
            }

        }

        console.log(JSON.stringify(this.allAttributes));


        //Perform attribute validation for each field
        this.attributeValidation();

        if (event.target.dataset.code === 'ATT_ROUTER_MODEL') {
            this.routerMatrixValidation(selectedAttributeVal);
        }
        /******Once the attribute is changed, for QLI, the attributes has to be passed as event to the parent LWC- cb2bDataTable for saving*/
        if (this.olirecordId.substring(0, 3) === "0QL") {
            this.dispatchEvent(new CustomEvent('attributechange', {
                detail: {
                    attributes: this.attributes
                }
            }));
        }
        this.groupAttributes();
    }

    /***To display routing type attributes based on the selection of routing type
     *  Input is attribute suffix list which needs to be displayed in the UI
    */
    addOrRemoveAttributeForRouting(suffixArrayToAdd) {
        // To remove other routing attributes from the UI
        const attrToRemove = [...new Set([...suffixArrayToAdd, ...this.routingTypeSuffixVals])].filter(value => {
            return !(suffixArrayToAdd.includes(value) && this.routingTypeSuffixVals.includes(value));
        });
        console.log('attrToRemove--->' + JSON.stringify(attrToRemove));

        // Remove other protocol attributes from UI
        this.attributes = this.attributes.filter(attributeInUi => !attrToRemove.some(removeAttr => attributeInUi.code.endsWith(removeAttr)));

        // Parse through attribute suffixes
        console.log('addOrRemoveAttributeForRouting.suffixArrayToAdd' + JSON.stringify(suffixArrayToAdd));
        suffixArrayToAdd.forEach(suffix => {
            // The new attribute needs to be added to the UI only if it is not present in the UI already
            if (!this.attributes.some(attributeInUi => attributeInUi.code.endsWith(suffix))) {
                this.allAttributes.forEach(attribute => {
                    if (attribute.code.endsWith(suffix)) {
                        this.attributes.push(attribute);
                    }
                });
            }
        });
    }

    /*** On click save action */
    handleJSONAttributeSaveClick(event) {

        let objName;
        if (this.olirecordId.substring(0, 3) === "0QL") {
            objName = 'QuoteLineItem';
        }
        else {
            objName = 'OrderItem';
        }
        let hasError = false;

        //From the attibutes JSON, only the attribute which has values needs to be saved to the backend
        const finaltask ={};
        const outputJson = this.attributes.reduce((result, item) => {
            if (item.value) {
                const id = item.therecordId;
                const attributeName = item.code;
                const attributeValue = item.value;
                if(item.objName == 'Task'){
                    finaltask[id]= result.theRecordId,
                    finaltask[item.code] = item.value
                }
                if (!result[id]) {
                    result[id] = {
                        Id: id,
                        fieldVal: {},
                        vlocity_cmt__AttributeSelectedValues__c: {},
                    };
                }

                if (item.hasCustomError) {
                    hasError = true;
                } else {
                    result[id][item.isFieldVal ? "fieldVal" : "vlocity_cmt__AttributeSelectedValues__c"][attributeName] = attributeValue;
                }

            }

            if (item.hasCustomError) {
                hasError = true;
            }

            return result;
        }, {});
        console.log('outputJsonPnn--->' + JSON.stringify(outputJson));
        console.log(this.finaltask);
        if (hasError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.InvalidFieldValuesTitle,
                    message: this.label.VerifyFieldValuesToast,
                    variant: 'error'
                })
            );
        }
        else {
            const attrListToUpdate = Object.values(outputJson);
            console.log('attrListToUpdate.Vals' + JSON.stringify(attrListToUpdate));

            /** Apex method to save the changes to the backend */
            setAttributeValues({ selectedAttributeJSON: JSON.stringify(attrListToUpdate), objName: objName }).
                then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: this.label.AttributeUpdatedToast,
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.ErrorUpdatingAttributeToast,
                            message: error.message,
                            variant: 'error'
                        })
                    );
                });
        }

    }

    /** Invoke apex method to retrieve the RFX matrix */
    getRFSMetadata() {
        //getRFSMappingData({})
        const fieldsToQuery = this.RFSQueryFields;
        //const result = await getAttributeValidations({});
        getMetadataRecords({ metadataName: 'ARTL_RFS_Mapping__mdt', fields: fieldsToQuery })
            .then(result => {
                this.rfsMetada = result;

            })
            .catch(error => {
                console.log('error:', JSON.stringify(error));
            });

    }

    /**TO calculate RFS date */
    getRFSVal() {
        let rfsDays;
        //console.log('rfsMetada--->' + JSON.stringify(this.rfsMetada));

        this.rfsMetada.forEach(rfsmdt => {
            if (
                this.serviceType && rfsmdt.Service_Type__c.toLowerCase() === this.serviceType.toLowerCase() &&
                this.mediaType && rfsmdt.Media__c.toLowerCase() === this.mediaType.toLowerCase() &&
                this.orderType && rfsmdt.Order_Type__c.toLowerCase() === this.orderType.toLowerCase() &&
                this.customerSegement && rfsmdt.Customer_Segment__c.toLowerCase() === this.customerSegement.toLowerCase()
            ) {
                rfsDays = rfsmdt.Days__c;
            }

        });

        console.log('rfsDays---->' + rfsDays);
        return rfsDays;
    }
    /*** Apex method to retrieve attribute validations set in the custom metadata */
    async getAttrValidations() {
        try {
            const fieldsToQuery = this.attributeValidationFields;
            console.log('pnnn=>>>>' + JSON.stringify(fieldsToQuery));
            //const result = await getAttributeValidations({});
            const result = await getMetadataRecords({ metadataName: 'Artl_AttributeValidation__mdt', fields: fieldsToQuery });
            this.attrValidations = JSON.parse(JSON.stringify(result));
            console.log('attrValidations---->' + JSON.stringify(this.attrValidations));
        } catch (error) {
            console.log('error:', JSON.stringify(error));
        }
    }

    attributeValidation() {
        let isMatch;
        let regexpVal;
        let customErrorMsg;
        this.attributes.forEach((uiAttribute) => {
            this.attrValidations.forEach((validation) => {
                if (uiAttribute.code.toLowerCase() === validation.AttributeCode__c.toLowerCase()) {
                    let attrJson = JSON.parse(validation.Attribute_JSON__c);

                    if (attrJson.isRequired && (uiAttribute.value !== undefined)) {
                        console.log('uiAttribute.value--->2' + JSON.stringify(uiAttribute));
                        uiAttribute.hasCustomError = false;
                    }


                    // /*** If there is no dependency on another attribute value */
                    if (!attrJson.isDependentValue && uiAttribute.value !== undefined) {
                        const searchKey = uiAttribute.value.toLowerCase();
                        const foundKey = Object.keys(attrJson.value).find(key => key.toLowerCase() === searchKey);
                       
                        if (foundKey) {
                            const attributesToHide = attrJson.value[foundKey].attributesToHide;
                            this.attributes = this.attributes.filter(att => {
                                if (attributesToHide.includes(att.code) && uiAttribute.theRecordId === att.theRecordId) {
                                    console.log('Removing element from the array: ' + att.code);
                                    return false; // Filter out the element
                                }
                                return true; // Keep the element
                            });
                        }
                        if (attrJson.value.hasOwnProperty('type')) {

                            customErrorMsg = this.getCustomErrorMsg(attrJson.value, uiAttribute.value);
                            console.log('customErrorMsg2--->' + customErrorMsg);
                            if (customErrorMsg !== undefined) {
                                uiAttribute.hasCustomError = true;
                                uiAttribute.customErrorMsg = customErrorMsg;
                            }
                            if (customErrorMsg === undefined) {
                                uiAttribute.hasCustomError = false;
                            }
                        }

                    }


                    /**If attirbute validation is based on the value of another attribute*/
                    if (attrJson.isDependentValue) {
                        const dependentObj = this.attributes.find(obj => obj.code === attrJson.dependentAttribtue);
                        if (dependentObj && dependentObj.value !== undefined && attrJson.value[dependentObj.value] !== undefined) {
                            console.log('customErrorMsg--->' + JSON.stringify(dependentObj));
                            if (attrJson.value[dependentObj.value].type !== 'picklist') {
                                customErrorMsg = this.getCustomErrorMsg(attrJson.value[dependentObj.value], uiAttribute.value);
                            }
                            if (attrJson.value[dependentObj.value].type === 'picklist') {
                                customErrorMsg = this.getCustomErrorMsg(attrJson.value[dependentObj.value], validation.AttributeCode__c + '___' + uiAttribute.therecordId);
                            }


                            if (customErrorMsg !== undefined) {
                                uiAttribute.hasCustomError = true;
                                uiAttribute.customErrorMsg = customErrorMsg;
                            }
                            if (customErrorMsg === undefined) {
                                uiAttribute.hasCustomError = false;
                            }
                        }
                        else if (dependentObj && (dependentObj.value === undefined || dependentObj.value === '')) {
                            uiAttribute.hasCustomError = true;
                            uiAttribute.customErrorMsg = 'Depenendent attibute- ' + dependentObj.name + ', cannot be empty';
                        }

                    }

                    // /*** To perform regex validation */
                    if (attrJson.regex !== '') {
                        var inpRegex = attrJson.regex;
                        var stringWithBackslashes = inpRegex.replace(/\./g, '\\.');
                        regexpVal = new RegExp(stringWithBackslashes);
                        isMatch = regexpVal.test(uiAttribute.value);
                        if (!isMatch) {
                            uiAttribute.hasCustomError = true;
                            uiAttribute.customErrorMsg = attrJson.value.error;
                        }
                        else {
                            uiAttribute.hasCustomError = false;
                        }
                    }


                    if (uiAttribute.value === undefined) {
                        uiAttribute.hasCustomError = false;
                    }

                    if (attrJson.isRequired && (uiAttribute.value === undefined || uiAttribute.value === '')) {
                        console.log('uiAttribute.value--->' + JSON.stringify(uiAttribute));
                        uiAttribute.hasCustomError = true;
                        uiAttribute.customErrorMsg = uiAttribute.name + ' is required';
                    }


                }
            })
        });
    }
    /** To return custom error message stored in the custom metadata */
    getCustomErrorMsg(attJson, uiValue) {
        let customError;
        if (attJson.operator === 'Range') {
            const [minValue, maxValue] = attJson.value[0].split('-').map(Number);
            let isInRange;
            // Check if the number falls within the range
            if (uiValue !== undefined) {
                isInRange = uiValue >= minValue && uiValue <= maxValue;
            }
            console.log('isInRange--->' + isInRange);
            if (!isInRange || uiValue === undefined) {
                customError = attJson.error;
            }

        }
        if (attJson.operator === '<' || attJson.operator === '>' || attJson.operator === '!=' || attJson.operator === '=='
            || attJson.operator === '<=' || attJson.operator === '>=') {

            if (attJson.type !== 'date' && attJson.type !== 'picklist') {
                let isError = false;
                attJson.value.forEach(val => {
                    switch (attJson.operator) {
                        case '<':
                            if (!(uiValue < val)) {
                                isError = true;
                            }
                            break;
                        case '>':
                            if (!(uiValue > val)) {
                                isError = true;
                            }
                            break;

                        case '>=':
                            if (!(uiValue >= val)) {
                                isError = true;
                            }
                            break;
                        case '<=':
                            if (!(uiValue <= val)) {
                                isError = true;
                            }
                            break;
                        case '==':
                            if (!(attJson.value.includes(uiValue))) {
                                isError = true;
                            }
                            break;
                        case '!=':
                            if (!(uiValue !== val)) {
                                isError = true;
                            }
                            break;
                        default:
                            break;
                    }
                });
                if (isError) {
                    customError = attJson.error;
                }

            }
            if (attJson.type === 'date') {
                uiValue = new Date(uiValue);
                if (attJson.value[0] === 'Today') {
                    console.log('today--->')
                    const today = new Date();
                    today.setHours(0, 0, 0, 0);

                    switch (attJson.operator) {
                        case '<':
                            if (!(uiValue.getTime() < today.getTime())) {
                                customError = attJson.error;
                            }
                            break;
                        case '>':

                            if (!(uiValue.getTime() > today.getTime())) {
                                console.log('greaterthan')
                                customError = attJson.error;
                            }
                            break;

                        case '>=':
                            if (!(uiValue.getTime() >= today.getTime())) {
                                customError = attJson.error;
                            }
                            break;
                        case '<=':
                            if (!(uiValue.getTime() <= today.getTime())) {
                                customError = attJson.error;
                            }
                            break;
                        case '==':
                            if (!(uiValue.getTime() == today.getTime())) {
                                customError = attJson.error;
                            }
                            break;
                        case '!=':
                            if (!(uiValue.getTime() != today.getTime())) {
                                customError = attJson.error;
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
            if (attJson.type === 'picklist') {
                // const clonedAllAttributes = JSON.parse(JSON.stringify(this.allAttributes));
                const splitValues = uiValue.split('___');
                // Filter allAttributes to get relevant items
                const filteredAllArray = this.clonedAllAttributes.filter(obj => obj.code === splitValues[0] && obj.therecordId === splitValues[1]);
                // Map to filter options based on attJson.value
                const filteredOptions = filteredAllArray.map(item => ({
                    ...item,
                    options: item.options.filter(option => attJson.value.includes(option.value))
                }));

                console.log('attrJson----->7', JSON.stringify(filteredOptions));

                // Update options of relevant items in attributes
                this.attributes.forEach(item => {
                    if (item.code === splitValues[0] && item.therecordId === splitValues[1]) {
                        item.options = filteredOptions[0].options;
                    }
                });
            }

        }
        return customError;

    }

    //to get router matrix metadata
    async getRouterMatrix() {
        try {
            const fieldsToQuery = ['Cost__c', 'Is_Active__c', 'Is_Default__c', 'Is_NSH__c', 'Item_Code__c', 'Make__c', 'Max_Bandwidth__c', 'Min_Bandwidth__c', 'Model__c'];
            const result = await getMetadataRecords({ metadataName: 'Artl_RouterMatrix__mdt', fields: fieldsToQuery });
            this.routerMatrix = JSON.parse(JSON.stringify(result));
        } catch (error) {
            console.log('error:', JSON.stringify(error));
        }
    }

    routerMatrixValidation(selectedRouterModel) {
        const routerObj = this.routerMatrix.find(obj => obj.Model__c === selectedRouterModel);
        const bandwidthAttObj = this.attributes.find(obj => obj.code === 'ATT_ACCESS_BANDWIDTH');
        const routerTypeAttObj = this.attributes.find(obj => obj.code === 'ATT_ROUTER_TYPE');
        if ((routerObj.Is_NSH__c && routerTypeAttObj.value !== 'Non-Standard') ||
            (!routerObj.Is_NSH__c && routerTypeAttObj.value === 'Non-Standard')) {
            this.attributes.forEach(uiAtt => {
                if (uiAtt.code === 'ATT_ROUTER_MODEL') {
                    uiAtt.hasCustomError = true;
                    uiAtt.customErrorMsg = 'Router Model is not compatible with the Router Type';
                }
            });
        }

        if (routerObj) {
            const bandwidth = bandwidthAttObj.value.split(' ');
            let bandwidthVal = parseInt(bandwidth[0]);
            if (bandwidth[1] === 'Gbps') {
                bandwidthVal = bandwidthVal * 1000;
            }
            if (!(bandwidthVal >= parseInt(routerObj.Min_Bandwidth__c.trim()) && bandwidthVal <= parseInt(routerObj.Max_Bandwidth__c.trim()))) {
                this.attributes.forEach(uiAtt => {
                    if (uiAtt.code === 'ATT_ROUTER_MODEL') {
                        uiAtt.hasCustomError = true;
                        uiAtt.customErrorMsg = 'Router Model is not compatible with the selected access bandwidth';
                    }
                });
            }

        }

    }
}