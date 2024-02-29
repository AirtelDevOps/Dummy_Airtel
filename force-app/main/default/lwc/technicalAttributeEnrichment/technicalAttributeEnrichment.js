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
import getJSONAttribute from '@salesforce/apex/TechnicalAttributeEnrichmentController.getJSONAttribute';
import setAttributeValues from '@salesforce/apex/TechnicalAttributeEnrichmentController.setAttributeValues';
import getMetadataRecords from '@salesforce/apex/TechnicalAttributeEnrichmentController.getMetadataRecords';
import QLIPARENTID from "@salesforce/schema/QuoteLineItem.vlocity_cmt__ParentItemId__c";
import OLIPARENTID from "@salesforce/schema/OrderItem.vlocity_cmt__ParentItemId__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const qlifields = [QLIPARENTID];
const olifields = [OLIPARENTID];

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

export default class TechnicalAttributeEnrichment extends LightningElement {
    @api recordId;
    @track techAttributeId;
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
    clonedUiAttributes
    routerMatrix;
    @track activeSections = [];

    renderedCallback() {
        this.isLoading = false;
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



    @wire(getRecord, { recordId: '$recordId', fields: qlifields })
    wiredRecord({ data, error }) {
        if (data) {
            this.parentId = data.fields.vlocity_cmt__ParentItemId__c.value;
        } else if (error) {
            // Handle errors
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: olifields })
    oliRec({ data, error }) {
        if (data) {
            this.parentId = data.fields.vlocity_cmt__ParentItemId__c.value;
        } else if (error) {
            // Handle errors
        }
    }

    /**
     * @description wired Apex method to load JSON attributes for the given xLI by Id
     */
    @wire(getJSONAttribute, { recordId: '$recordId' })
    async getJSONAttribute({ error, data }) {
        this.isLoading = true;
        //For showing save button on the tech attribute screen in the case of order item
        if (this.recordId !== undefined && this.recordId.startsWith('802')) {
            this.isOrderItem = true;
        }
        if (error) {
            if (this.parentId === null) {
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
                        is_field: myAttribute.valueType == 'field',
                        isFieldVal: false,
                        // values
                        value: values[trimmedKey],
                        fieldValue: myAttribute.fieldValue,
                        display_value: values[trimmedKey], // formatted value for display purpose
                        isRequired: false,
                        hasCustomError: false
                    };

                    //BookMarkForDelete
                    // attribute.readonly = false;

                    //Added by prabanch for technical enrichment CPQ 
                    // if (((this.recordId.substring(0, 3) === "0QL") && (myAttribute.categoryCode === 'ATC_ENTERPRISE_DETAILS' || myAttribute.categoryName === 'Technical Attributes')) || 
                    // ((this.recordId.substring(0, 3) === "802") && (myAttribute.categoryCode === 'ATC_ENTERPRISE_DETAILS' || myAttribute.categoryName === 'Technical Attributes'))) {

                    if ((this.recordId.startsWith("0QL") || this.recordId.startsWith("802")) &&
                        (myAttribute.categoryCode === this.enterpriseCatCode || myAttribute.categoryName === 'Technical Attributes')) {

                        //To make hidden attributes editable
                        if (myAttribute.hidden) {
                            attribute.readonly = false;
                        }
                        else {
                            attribute.readonly = true;
                        }

                        if (myAttribute.readonly) {
                            attribute.readonly = true;
                        }

                        //Routing type should be edittable 
                        if ((myAttribute.code === this.routingTypeCodeEill || myAttribute.code === this.routingTypeCodeMpls) && (this.recordId.substring(0, 3) === "0QL")) {
                            attribute.readonly = false;
                            //console.log('routingTypeVal' + attribute.value);
                        }
                        if ((myAttribute.code === this.routingTypeCodeEill || myAttribute.code === this.routingTypeCodeMpls) && (this.recordId.substring(0, 3) === "802")) {
                            attribute.readonly = true;
                        }


                        if (myAttribute.code === this.routingTypeCodeEill || myAttribute.code === this.routingTypeCodeMpls) {
                            attribute.readonly = false;
                        }

                        //For CND RFS field population
                        if (myAttribute.code === this.label.CustomerNeededByDate) {
                            attribute.readonly = false;
                            attribute.is_field = false;
                            attribute.is_date = true;
                            attribute.valueType = 'date';
                            if (myAttribute.fieldValue !== undefined) {
                                const datePart = myAttribute.fieldValue.split(" ")[0];
                                attribute.value = datePart;
                            }

                        }


                        //For Operation Unit and Requisition Id
                        if (myAttribute.code === 'Operating Unit' || myAttribute.code === 'Requisition Number') {
                            attribute.readonly = false;
                            attribute.isFieldVal = true;
                        }

                        if (myAttribute.code === this.label.RFS) {
                            attribute.readonly = true;
                            attribute.is_field = false;
                            attribute.is_date = true;
                            attribute.valueType = 'date';
                            if (myAttribute.fieldValue !== undefined) {
                                const datePart = myAttribute.fieldValue.split(" ")[0];
                                attribute.value = datePart;
                            }
                        }

                        if (myAttribute.code === this.serviceTypeCode) {
                            this.serviceType = values[trimmedKey];
                            console.log('serviceType---->' + this.serviceType);
                        }
                        if (myAttribute.code === this.label.OrderType) {

                            this.orderType = myAttribute.fieldValue;
                            console.log('orderType---->' + this.orderType);
                        }
                        if (myAttribute.code === this.mediaTypeCode) {
                            this.mediaType = values[trimmedKey];
                            console.log('mediaType---->' + this.mediaType);
                        }
                        if (myAttribute.code === this.label.CustomerSegment) {
                            this.customerSegement = myAttribute.fieldValue;
                        }
                        //**** CND RFS population logic finishes here */

                    }

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

                    // if (attribute.code === 'ATT_IP_Type') {
                    //     attribute.name = attribute.name + '-' + attribute.productName;
                    // }

                    attribute.display_value = this.formatAttributeValue(attribute.value, attribute.valueType, attribute.options);
                    // if ((this.recordId.substring(0, 3) === "0QL" || this.recordId.substring(0, 3) === "802") && (myAttribute.categoryCode === 'ATC_ENTERPRISE_DETAILS' || myAttribute.categoryName === 'Technical Attributes')){
                    if ((this.recordId.substring(0, 3) === "0QL" || this.recordId.substring(0, 3) === "802") && (myAttribute.categoryCode === this.enterpriseCatCode || myAttribute.categoryName === 'Technical Attributes')) {

                        //Protocol product attibutes will be shown only based on selection of Routing type attribute
                        //routingTypeSuffixVals = ['_BGP','_HYD','_BGPHYD','_STC','_All'];-->For reference

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
                    else if (this.recordId.substring(0, 3) !== "0QL" && this.recordId.substring(0, 3) !== "802" && myAttribute.code !== 'Id') {
                        this.attributes.push(attribute);
                    }
                    this.allAttributes.push(attribute);

                }
                const prodObj = this.attributes.find(obj => obj.code === 'Product');
                if (prodObj && !(prodObj.fieldValue === 'NIPS Hardware' || prodObj.fieldValue === 'NIPS Service')) {
                    this.attributes = this.attributes.filter(obj => obj.code !== "Requisition Number" && obj.code !== "Operating Unit");
                }
                this.clonedAllAttributes = JSON.parse(JSON.stringify(this.allAttributes));

                // this.clonedUiAttributes = JSON.parse(JSON.stringify(this.attributes));
                // console.log('this.attributesClone--->' + JSON.stringify(this.clonedUiAttributes));
                //To get RFS caluclation matrix
                this.getRFSMetadata();
                this.attributeValidation();
                this.getRouterMatrix();
                this.groupAttributes();

            }
        }
    }


    groupAttributes() {
        // const groupedAttributesMap = new Map();

        // this.attributes.forEach(attribute => {
        //     const productName = attribute.productName || ' ';
        //     if (!groupedAttributesMap.has(productName)) {
        //         groupedAttributesMap.set(productName, []);
        //     }
        //     groupedAttributesMap.get(productName).push(attribute);
        // });

        // this.groupedAttributes = Array.from(groupedAttributesMap, ([productName, attributes]) => ({
        //     productName,
        //     attributes
        // }));
        // console.log('groupedAttributes---->'+JSON.stringify(this.groupedAttributes));
        const groupedAttributes = {};

        this.attributes.forEach(attribute => {
            const productName = attribute.productName || '';

            if (!groupedAttributes[productName]) {
                groupedAttributes[productName] = {
                    productName: productName,
                    attributes: []
                };
            }

            groupedAttributes[productName].attributes.push(attribute);
        });

        this.groupedAttributes = Object.values(groupedAttributes);
        //console.log('groupedAttributes---->'+JSON.stringify(this.groupedAttributes));

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
        let suffixArrayToAdd = [];
        if (this.recordId.substring(0, 3) === "0QL" || this.recordId.substring(0, 3) === "802") {

            this.allAttributes.forEach(allAttr => {
                if (allAttr.code === event.target.dataset.code && allAttr.therecordId === event.target.dataset.recordId) {
                    allAttr.value = selectedAttributeVal;
                    allAttr.is_changed = true;
                    allAttr.display_value = this.formatAttributeValue(selectedAttributeVal, allAttr.valueType, allAttr.options);
                    if (allAttr.code === this.label.CustomerNeededByDate) {
                        allAttr.isFieldVal = true;
                    }
                }
            });

            //****To restrict attribute values for routing type starts here
            if (selectedAttributeVal === this.label.StaticwithPrivateBGP || selectedAttributeVal === this.label.StaticwithPublicBGP) {
                //this.attributes = this.clonedUiAttributes;
                suffixArrayToAdd = this.StaticNBGPHybridAttributes;
                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
            }
            if (selectedAttributeVal === this.label.PrivateBGP || selectedAttributeVal === this.label.PublicBGP) {
                suffixArrayToAdd = this.PrivateNPublicBGPAttributes;
                this.addOrRemoveAttributeForRouting(suffixArrayToAdd);
            }
            if (selectedAttributeVal === this.label.Static) {
                // this.attributes = this.clonedUiAttributes;
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
            }
            else {
                let today = new Date();
                today.setDate(today.getDate() + 20);
                rfsDate = today.toISOString().split('T')[0];
            }

            this.allAttributes.forEach(attr => {
                if (attr.code === this.label.RFS) {
                    attr.value = rfsDate;
                    attr.is_changed = true;
                    attr.display_value = this.formatAttributeValue(rfsDate, attr.valueType, attr.options);
                    attr.isFieldVal = true;
                }
            });


        }




        //Perform attribute validation for each field
        this.attributeValidation();

        if (event.target.dataset.code === 'ATT_ROUTER_MODEL') {
            this.routerMatrixValidation(selectedAttributeVal);
        }
        /******Once the attribute is changed, for QLI, the attributes has to be passed as event to the parent LWC- cb2bDataTable for saving*/
        if (this.recordId.substring(0, 3) === "0QL") {
            this.dispatchEvent(new CustomEvent('attributechange', {
                detail: {
                    attributes: this.attributes
                }
            }));
        }

         this.handleAttributeChangeValidate(event.target.dataset.code);

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
        if (this.recordId.substring(0, 3) === "0QL") {
            objName = 'QuoteLineItem';
        }
        else {
            objName = 'OrderItem';
        }
        let hasError = false;

        //From the attibutes JSON, only the attribute which has values needs to be saved to the backend

        const outputJson = this.attributes.reduce((result, item) => {
            if (item.value) {
                const id = item.therecordId;
                const attributeName = item.code;
                const attributeValue = item.value;

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
                    // if (objName === 'QuoteLineItem') {
                    //     //console.log('SaveQLI')
                    //     this.dispatchEvent(new CustomEvent('save', {
                    //         detail: true
                    //     }));
                    // }
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
        // console.log('rfsMetada--->' + JSON.stringify(this.rfsMetada));

        this.rfsMetada.forEach(rfsmdt => {


            if (
                this.serviceType &&
                rfsmdt.Service_Type__c &&
                rfsmdt.Service_Type__c.toLowerCase() === this.serviceType.toLowerCase() &&
                this.mediaType &&
                rfsmdt.Media__c &&
                rfsmdt.Media__c.toLowerCase() === this.mediaType.toLowerCase() &&
                this.orderType &&
                rfsmdt.Order_Type__c &&
                rfsmdt.Order_Type__c.toLowerCase() === this.orderType.toLowerCase() &&
                this.customerSegement &&
                rfsmdt.Customer_Segment__c &&
                rfsmdt.Customer_Segment__c.toLowerCase() === this.customerSegement.toLowerCase()
            ) {
                rfsDays = rfsmdt.Days__c;
            }


        });
        return rfsDays;
    }


    /*** Apex method to retrieve attribute validations set in the custom metadata */
    async getAttrValidations() {
        try {
            const fieldsToQuery = this.attributeValidationFields;
            //const result = await getAttributeValidations({});
            const result = await getMetadataRecords({ metadataName: 'Artl_AttributeValidation__mdt', fields: fieldsToQuery });
            this.attrValidations = JSON.parse(JSON.stringify(result));
        } catch (error) {
            console.log('error:', JSON.stringify(error));
        }
    }

    attributeValidation() {
        let isMatch;
        let regexpVal;
        let customErrorMsg;
        this.attributes.forEach((uiAttribute) => {
            uiAttribute.hasCustomError = false;
            this.attrValidations.forEach((validation) => {
                if (uiAttribute && (uiAttribute.code.toLowerCase() === validation.AttributeCode__c.toLowerCase())) {
                    let attrJson = JSON.parse(validation.Attribute_JSON__c);

                    if (attrJson.isRequired && ((uiAttribute.value !== undefined) || (uiAttribute.fieldValue !== undefined))) {
                        uiAttribute.hasCustomError = false;
                    }


                    // /*** If there is no dependency on another attribute value */
                    if (!attrJson.isDependentValue) {

                        if (uiAttribute.value !== undefined) {
                            const searchKey = uiAttribute.value.toLowerCase();
                            const foundKey = Object.keys(attrJson.value).find(key => key.toLowerCase() === searchKey);

                            if (foundKey) {
                                const attributesToHide = attrJson.value[foundKey].attributesToHide;
                                this.attributes = this.attributes.filter(att => !(attributesToHide.includes(att.code) && uiAttribute.theRecordId === att.theRecordId));
                            }
                            if (uiAttribute.value && uiAttribute.value !== '') {
                                const customErrorMsg = this.getCustomErrorMsg(attrJson.value, uiAttribute.value);
                                uiAttribute.hasCustomError = customErrorMsg !== undefined;
                                uiAttribute.customErrorMsg = uiAttribute.hasCustomError ? customErrorMsg : undefined;
                            }



                        } else if (!uiAttribute.is_changed && !uiAttribute.value && attrJson.defaultValue) {
                            uiAttribute.value = attrJson.defaultValue;
                            uiAttribute.is_changed = true;
                        }
                    }



                    /**If attirbute validation is based on the value of another attribute*/


                    if (attrJson.isDependentValue) {
                        const dependentObj = this.attributes.find(obj => obj.code === attrJson.dependentAttribtue);
                        if (dependentObj.value) {
                            uiAttribute.hasCustomError = false;
                        }
                        if (dependentObj && dependentObj.value !== undefined && attrJson.value[dependentObj.value]) {

                            if (attrJson.value[dependentObj.value].type !== 'picklist' && attrJson.value[dependentObj.value].type !== 'text') {
                                if (!attrJson.value[dependentObj.value].defaultValue) {
                                    customErrorMsg = this.getCustomErrorMsg(attrJson.value[dependentObj.value], uiAttribute.value);
                                }
                                else {
                                    uiAttribute.value = attrJson.value[dependentObj.value].defaultValue;
                                    if (attrJson.value[dependentObj.value].isReadOnly) {
                                        uiAttribute.readonly = true;
                                    }
                                }

                            }
                            if (attrJson.value[dependentObj.value].type === 'picklist') {
                                if (attrJson.value[dependentObj.value].value) {
                                    customErrorMsg = this.getCustomErrorMsg(attrJson.value[dependentObj.value], validation.AttributeCode__c + '___' + uiAttribute.therecordId);
                                }

                            }
                            if (attrJson.value[dependentObj.value].type === 'text') {
                                if (dependentObj.value && uiAttribute.previousDependentObjVal !== dependentObj.value) {
                                    uiAttribute.value = '';
                                    uiAttribute.previousDependentObjVal = dependentObj.value;
                                }



                                const validateObj = attrJson.value[dependentObj.value];
                                if (validateObj && validateObj.copyAttributeFrom) {
                                    const foundItem = this.attributes.find(item => item.code === validateObj.copyAttributeFrom);
                                    if (foundItem && foundItem.value) {
                                        uiAttribute.value = foundItem.value;
                                    }
                                }
                                if (validateObj && validateObj.isReadOnly) {
                                    uiAttribute.readonly = true;
                                    uiAttribute.hasCustomError = false;
                                }
                                if (validateObj && !validateObj.isReadOnly) {
                                    uiAttribute.readonly = false;
                                    uiAttribute.hasCustomError = false;
                                }
                            }

                            //uiAttribute.hasCustomError = false;
                            if (customErrorMsg !== undefined) {
                                uiAttribute.hasCustomError = true;
                                uiAttribute.customErrorMsg = customErrorMsg;
                            }
                            if (customErrorMsg === undefined) {
                                uiAttribute.hasCustomError = false;
                            }
                        }
                        if (uiAttribute && uiAttribute.value && dependentObj && dependentObj.value !== undefined && attrJson.attributesToHide) {
                            const searchKey = uiAttribute.value.toLowerCase();
                            const foundKey = Object.keys(attrJson.attributesToHide).find(key => key.toLowerCase() === searchKey);
                            if (foundKey) {
                                const attributesToHide = attrJson.attributesToHide[foundKey];
                                this.attributes = this.attributes.filter(att => {
                                    if (attributesToHide.includes(att.code) && uiAttribute.theRecordId === att.theRecordId) {
                                        return false; // Filter out the element
                                    }
                                    return true; // Keep the element
                                });
                            }
                            if (!foundKey) {
                                //const attVals = Object.keys(attrJson.attributesToHide);
                                const output = Object.values(attrJson.attributesToHide).reduce((acc, val) => acc.concat(val), []);
                                if (output) {
                                    const allAttFilter = this.clonedAllAttributes.filter(obj => output.includes(obj.code));
                                    if (allAttFilter) {
                                        allAttFilter.forEach(obj => {
                                            const found = this.attributes.some(attr => attr.therecordId === obj.therecordId && attr.code === obj.code);
                                            if (!found) {
                                                this.attributes.push(obj);
                                            }
                                        });
                                        this.groupAttributes();
                                    }

                                }
                                const allAttFilter = this.clonedAllAttributes.filter(obj => output.includes(obj.code));
                                allAttFilter.forEach(obj => {
                                    const found = this.attributes.some(attr => attr.therecordId === obj.therecordId && attr.code === obj.code);
                                    if (!found) {
                                        this.attributes.push(obj);
                                    }
                                });


                            }

                        }

                        // if(dependentObj.isRequired && !uiAttribute.value){
                        //     uiAttribute.hasCustomError = true;
                        //     uiAttribute.customErrorMsg = uiAttribute.name + ' is required';
                        //     uiAttribute.isRequired = true;
                        // }



                        // if ((dependentObj.value === undefined || dependentObj.value === '') && dependentObj.isRequired)
                        // if ((dependentObj.value === undefined || dependentObj.value === '') ) {
                        //     uiAttribute.hasCustomError = true;
                        //     uiAttribute.customErrorMsg = 'Depenendent attibute- ' + dependentObj.name + ', cannot be empty';
                        // }

                        if ((attrJson.value[dependentObj.value]?.isRequired) && (!(uiAttribute.value) || !(uiAttribute.display_value))) {
                            uiAttribute.hasCustomError = true;
                            uiAttribute.customErrorMsg = uiAttribute.name + ' is required';
                            uiAttribute.isRequired = true;
                        }


                    }

                    // /*** To perform regex validation */
                    if (attrJson.regex !== '' && uiAttribute.value) {
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


                    // if (uiAttribute.value === undefined) {
                    //     uiAttribute.hasCustomError = false;
                    // }

                    if (attrJson.isRequired && (uiAttribute.value === undefined || uiAttribute.value === '') && (!uiAttribute.fieldValue)) {
                        uiAttribute.hasCustomError = true;
                        uiAttribute.customErrorMsg = uiAttribute.name + ' is required';
                        uiAttribute.isRequired = true;
                    }


                }
            })
        });
        this.groupAttributes();
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
                const splitValues = uiValue.split('___');

                // Filter allAttributes to get relevant items
                const filteredAllArray = this.clonedAllAttributes.filter(obj => obj.code === splitValues[0] && obj.therecordId === splitValues[1]);
                // Map to filter options based on attJson.value
                const filteredOptions = filteredAllArray.map(item => ({
                    ...item,
                    options: item.options.filter(option => attJson.value.includes(option.value))
                }));

                // Update options of relevant items in attributes
                this.attributes.forEach(item => {
                    if (item.code === splitValues[0] && item.therecordId === splitValues[1]) {
                        item.options = filteredOptions[0].options;
                        // if (!(filteredOptions[0]?.options.includes(item.value))) {
                        //     item.value = '';
                        // }

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
        // if ((routerObj.Is_NSH__c && routerTypeAttObj.value !== 'Non-Standard') ||
        //     (!routerObj.Is_NSH__c && routerTypeAttObj.value === 'Non-Standard')) {
        //     this.attributes.forEach(uiAtt => {
        //         if (uiAtt.code === 'ATT_ROUTER_MODEL') {
        //             uiAtt.hasCustomError = true;
        //             uiAtt.customErrorMsg = 'Router Model is not compatible with the Router Type';
        //         }
        //     });
        // }
        if (routerObj) {
            if ((routerObj?.Is_NSH__c && routerTypeAttObj?.value !== 'Non-Standard') ||
                (!routerObj?.Is_NSH__c && routerTypeAttObj?.value === 'Non-Standard')) {
                this.attributes.forEach(uiAtt => {
                    if (uiAtt.code === 'ATT_ROUTER_MODEL') {
                        uiAtt.hasCustomError = true;
                        uiAtt.customErrorMsg = 'Router Model is not compatible with the Router Type';
                    }
                });
            }
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




        // if (routerObj) {
        //     const bandwidthVal = bandwidthAttObj.value.match(/\d+/)[0];
        //     //console.log('tet------>'+bandwidthAttObj.value.match(/\d+/)[1])

        //     if (!(parseInt(bandwidthVal) >= parseInt(routerObj.Min_Bandwidth__c.trim()) && parseInt(bandwidthVal) <= parseInt(routerObj.Max_Bandwidth__c.trim()))){
        //         this.attributes.forEach(uiAtt => {
        //             if (uiAtt.code === 'ATT_ROUTER_MODEL') {
        //                 uiAtt.hasCustomError = true;
        //                 uiAtt.customErrorMsg = 'Router Model is not compatible with the selected access bandwidth';
        //             }
        //         });
        //     }
        // }
    }

    handleAttributeChangeValidate(changedAttrCode) {

        const attributeObj = this.attrValidations.find(obj => obj.AttributeCode__c === changedAttrCode);
        if (attributeObj?.Attribute_JSON__c) {
            let attrJson = JSON.parse(attributeObj.Attribute_JSON__c);
            if (attrJson.isDependentValue) {
                const dependentObj = this.attributes.find(obj => obj.code === attrJson.dependentAttribtue);
                if (!dependentObj?.value || !dependentObj?.display_value) {
                    this.attributes.forEach(uiAtt => {
                        if (uiAtt.code === changedAttrCode) {
                            uiAtt.hasCustomError = true;
                            uiAtt.customErrorMsg = 'Dependent attribute- ' + dependentObj.name + ' cannot be empty';
                        }
                    });
                }
            }
        }
    }

}