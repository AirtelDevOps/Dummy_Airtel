let definition =
      {"dataSource":{"contextVariables":[],"orderBy":{"isReverse":false,"name":""},"type":"Custom","value":{"body":"{\"displayDurationSection\": true}","dsDelay":"","resultVar":""}},"enableLwc":true,"events":[{"actionList":[{"card":"{card}","draggable":true,"isOpen":false,"key":"1628592041630-5iemr7zys","label":"Duration","stateAction":{"actionConditions":{"group":[{"field":"{action.toggletype}","hasMergeField":true,"id":"state-new-condition-0","operator":"==","type":"custom","value":"duration"}],"id":"state-condition-object","isParent":true},"eventName":"setValues","fieldValues":[{"fieldName":"Session.duration","fieldValue":"{action.value}"}],"id":"flex-action-1628591854481","type":"cardAction"}},{"card":"{card}","draggable":false,"isOpen":true,"key":"1628592041630-n94aptwil","label":"Action","stateAction":{"actionConditions":{"group":[{"field":"{action.field}","hasMergeField":true,"id":"state-new-condition-0","operator":"==","type":"custom","value":"allocation"}],"id":"state-condition-object","isParent":true},"eventName":"setValues","fieldValues":[{"fieldName":"displayDurationSection","fieldValue":"{action.value}"}],"id":"flex-action-1628592050282","type":"cardAction"}}],"channelname":"customDiscoutField","displayLabel":"customDiscoutField:baseinputvaluechange","element":"action","eventLabel":"pubsub","eventname":"baseinputvaluechange","eventtype":"pubsub","key":"event-0","recordIndex":"0"}],"globalCSS":false,"isFlex":true,"lwc":{"DeveloperName":"cfCpqCreateCustomDiscountDurationDetails_1_Vlocity","Id":"0RbHn000000JFrTCAC","ManageableState":"unmanaged","MasterLabel":"cfCpqCreateCustomDiscountDurationDetails_1_Vlocity","NamespacePrefix":"vlocity_cmt"},"multilanguageSupport":true,"selectableMode":"Multi","sessionVars":[{"name":"duration","val":"date"}],"states":[{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-0","key":"element_element_block_0_0_outputField_0_0","name":"Text","parentElementKey":"element_block_0_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BLabel.CPQDuration%7D%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"section_title","container":{"class":""},"customClass":"section_title","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"section_title","container":{"class":""},"customClass":"section_title","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"Block-1","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"customClass":"","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"customClass":"","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block"},{"children":[{"children":[{"class":"slds-col ","element":"baseInputElement","elementLabel":"Block-1-Block-0-ComboBox-0","key":"element_element_element_block_1_0_block_0_0_baseInputElement_0_0","name":"ComboBox","parentElementKey":"element_element_block_1_0_block_0_0","property":{"card":"{card}","propertyObj":{"customProperties":[{"id":0,"label":"options","value":"[{\"label\":\"{Label.CPQDiscountEndDate}\", \"value\":\"date\"},{\"label\":\"{Label.CPQDiscountMonths}\", \"value\":\"month\"}]"},{"id":1,"label":"data-field","value":"durationtype"},{"id":2,"label":"data-toggletype","value":"duration"},{"id":4,"label":"name","value":"customDiscoutField"}],"label":"{Label.CPQDuration}","name":"customDiscoutField","type":"combobox","value":"{Session.duration}"},"record":"{record}","type":"combobox"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-1-Block-0","key":"element_element_block_1_0_block_0_0","name":"Block","parentElementKey":"element_block_1_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":true,"large":"5","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":true,"large":"5","medium":"12","small":"12"},"sizeClass":"slds-large-size_5-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":true,"large":"5","medium":"12","small":"12"},"sizeClass":"slds-large-size_5-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block"},{"children":[{"class":"slds-col ","element":"baseInputElement","elementLabel":"Block-1-Block-1-Date-0","key":"element_element_element_block_1_0_block_1_0_baseInputElement_0_0","name":"Date","parentElementKey":"element_element_block_1_0_block_1_0","property":{"card":"{card}","propertyObj":{"customProperties":[{"id":0,"label":"name","value":"customDiscoutField"},{"id":1,"label":"data-field","value":"enddate"}],"format":"yyyy-MM-dd","label":"{Label.CPQDiscountEndDate}","localeFormat":"en-US","name":"Block-1-Block-1-Date-0","outputFormat":"yyyy-MM-dd"},"record":"{record}","type":"date"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-1-Block-1","key":"element_element_block_1_0_block_1_0","name":"Block","parentElementKey":"element_block_1_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"data-conditions":{"group":[{"field":"Session.duration","hasMergeField":false,"id":"state-new-condition-0","operator":"==","type":"custom","value":"date"}],"id":"state-condition-object","isParent":true},"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":true,"large":"7","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":true,"large":"7","medium":"12","small":"12"},"sizeClass":"slds-large-size_7-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":true,"large":"7","medium":"12","small":"12"},"sizeClass":"slds-large-size_7-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block"},{"children":[{"class":"slds-col ","element":"baseInputElement","elementLabel":"Block-1-Block-1-clone-0-Number-0","key":"element_element_element_block_1_0_block_2_0_baseInputElement_0_0","name":"Number","parentElementKey":"element_element_block_1_0_block_2_0","property":{"card":"{card}","propertyObj":{"customProperties":[{"id":0,"label":"name","value":"customDiscoutField"},{"id":1,"label":"data-field","value":"months"},{"id":2,"label":"min","value":"1"}],"imask":"","label":"{Label.CPQDiscountMonths}"},"record":"{record}","type":"number"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-1-Block-1-clone-0","key":"element_element_block_1_0_block_2_0","name":"Block","parentElementKey":"element_block_1_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"data-conditions":{"group":[{"field":"Session.duration","hasMergeField":false,"id":"state-new-condition-7","operator":"==","type":"custom","value":"month"}],"id":"state-condition-object","isParent":true},"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":true,"large":"7","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":true,"large":"7","medium":"12","small":"12"},"sizeClass":"slds-large-size_7-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":true,"large":"7","medium":"12","small":"12"},"sizeClass":"slds-large-size_7-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-1","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small field-row","container":{"class":""},"customClass":"field-row","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small field-row","container":{"class":""},"customClass":"field-row","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block"}]}},"conditions":{"group":[{"field":"displayDurationSection","hasMergeField":false,"id":"state-new-condition-14","operator":"!=","type":"custom","value":"Order"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Active","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-card cpq-create_discount-duration_details","container":{"class":"slds-card"},"customClass":"cpq-create_discount-duration_details","elementStyleProperties":{},"inlineStyle":"text-align: left;","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         text-align: left;","text":{"align":"","color":""}}}],"theme":"slds","title":"cpqCreateCustomDiscountDurationDetails","Id":"a5aHn00000I0sZvAAG","vlocity_cmt__GlobalKey__c":"cpqCreateCustomDiscountDurationDetails/Vlocity/1/1624467766708"};
  export default definition