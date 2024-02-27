let definition =
      {"dataSource":{"contextVariables":[],"orderBy":{"isReverse":false,"name":""},"type":"ApexRemote","value":{"dsDelay":"","inputMap":{"accountId":"{Parent.accountId}","cartId":"{Parent.cartId}","id":"{Parent.id}"},"remoteClass":"CpqAppHandler","remoteMethod":"getAppliedPromotionsByAccount","resultVar":"[\"records\"]","vlocityAsync":false}},"dynamicCanvasWidth":{"type":"desktop"},"enableLwc":true,"globalCSS":false,"isFlex":true,"lwc":{"DeveloperName":"cfCpqPromotionDetailView_2_Vlocity","Id":"0Rb5Y000000LzE8SAK","ManageableState":"unmanaged","MasterLabel":"cfCpqPromotionDetailView_2_Vlocity","NamespacePrefix":"vlocity_cmt"},"multilanguageSupport":true,"states":[{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"children":[{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Modal-Header-Text-0","key":"element_element_element_block_0_0_block_0_0_outputField_0_0","name":"Text","parentElementKey":"element_element_block_0_0_block_0_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BLabel.CPQPromotionAllCaps%7D%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-header-promotionheading","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-header-promotionheading","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"DetailView-Modal-Header","key":"element_element_block_0_0_block_0_0","name":"Block","parentElementKey":"element_block_0_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#ECEBEA","radius":"","style":"solid","type":"","width":"1"},"class":"slds-modal__header cpq__promotiondetailview-modal-header ","container":{"class":""},"customClass":"slds-modal__header cpq__promotiondetailview-modal-header ","elementStyleProperties":{},"height":"","inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ECEBEA 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#ECEBEA","radius":"","style":"solid","type":"","width":"1"},"class":"slds-modal__header cpq__promotiondetailview-modal-header ","container":{"class":""},"customClass":"slds-modal__header cpq__promotiondetailview-modal-header ","elementStyleProperties":{},"height":"","inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ECEBEA 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block","userUpdatedElementLabel":true},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Modal-Body-Name","key":"element_element_element_block_0_0_block_1_0_outputField_0_0","name":"Text","parentElementKey":"element_element_block_0_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[],"id":"state-condition-object","isParent":true},"mergeField":"%3Cdiv%3E%7Bname%7D%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-namecode","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-namecode","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-namecode","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-namecode","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"text","userUpdatedElementLabel":true},{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Modal-Body-Description-A","key":"element_element_element_block_0_0_block_1_0_outputField_1_0","name":"Text","parentElementKey":"element_element_block_0_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"description","id":"state-new-condition-0","operator":"!=","type":"custom","value":"undefined"}],"id":"state-condition-object","isParent":true},"mergeField":"%3Cdiv%3E%7Bdescription%7D%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-description slds-m-top_medium","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-description slds-m-top_medium","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-description slds-m-top_medium","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-description slds-m-top_medium","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"text","userUpdatedElementLabel":true},{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Modal-Body-Description-S","key":"element_element_element_block_0_0_block_1_0_outputField_2_0","name":"Text","parentElementKey":"element_element_block_0_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"Description","id":"state-new-condition-7","operator":"!=","type":"custom","value":"undefined"},{"field":"Description.value","id":"state-new-condition-16","logicalOperator":"&&","operator":"!=","type":"custom","value":"undefined"}],"id":"state-condition-object","isParent":true},"mergeField":"%3Cdiv%3E%7BDescription.value%7D%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-description slds-m-top_medium","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-description slds-m-top_medium","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-description slds-m-top_medium","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-description slds-m-top_medium","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"text","userUpdatedElementLabel":true},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Body-StartDate-Block-Text","key":"element_element_element_element_block_0_0_block_1_0_block_3_0_outputField_0_0","name":"Text","parentElementKey":"element_element_element_block_0_0_block_1_0_block_3_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BLabel.CPQOfferStartsLabel%7D%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":true,"large":"3","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates-label slds-m-right_x-small","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates-label slds-m-right_x-small","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"3","medium":"12","small":"12"},"sizeClass":"slds-large-size_3-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"text","userUpdatedElementLabel":true},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Body-PromotionStartDate","key":"element_element_element_element_element_block_0_0_block_1_0_block_3_0_block_1_0_outputField_0_0","name":"Field","parentElementKey":"element_element_element_element_block_0_0_block_1_0_block_3_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"vlocity_cmt__effectivestartdate__c","id":"state-new-condition-56","operator":"!=","type":"custom","value":"undefined"}],"id":"state-condition-object","isParent":true},"fieldName":"vlocity_cmt__effectivestartdate__c","format":"DD/MM/YYYY","placeholder":"{Label.CPQStartDateOfPromotionPlaceholder}","record":"{record}","type":"datetime","useAbsoluteDate":true},"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"element","userUpdatedElementLabel":true},{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Body-StartDate-Block-Block-1-Field-0-clone-0","key":"element_element_element_element_element_block_0_0_block_1_0_block_3_0_block_1_0_outputField_1_0","name":"Field","parentElementKey":"element_element_element_element_block_0_0_block_1_0_block_3_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"vlocity_cmt__CommitmentStartDate__c","id":"state-new-condition-35","operator":"!=","type":"custom","value":"undefined"},{"field":"vlocity_cmt__CommitmentStartDate__c.value","id":"state-new-condition-42","logicalOperator":"&&","operator":"!=","type":"custom","value":"undefined"}],"id":"state-condition-object","isParent":true},"fieldName":"vlocity_cmt__CommitmentStartDate__c.value","format":"DD/MM/YYYY","placeholder":"{Label.CPQStartDateOfPromotionPlaceholder}","record":"{record}","type":"datetime","useAbsoluteDate":true},"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"element","userUpdatedElementLabel":true}],"class":"slds-col ","element":"block","elementLabel":"DetailView-Body-StartDate-Block-Block-1","key":"element_element_element_element_block_0_0_block_1_0_block_3_0_block_1_0","name":"Block","parentElementKey":"element_element_element_block_0_0_block_1_0_block_3_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":9,"isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":9,"isResponsive":false},"sizeClass":"slds-size_9-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":9,"isResponsive":false},"sizeClass":"slds-size_9-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"DetailView-Body-StartDate-Block","key":"element_element_element_block_0_0_block_1_0_block_3_0","name":"Block","parentElementKey":"element_element_block_0_0_block_1_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"6","isResponsive":false,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-m-top_large","container":{"class":""},"customClass":"slds-m-top_large","elementStyleProperties":{},"inlineStyle":"\n","margin":[],"padding":[],"size":{"default":"6","isResponsive":false,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-size_6-of-12 ","style":"     : #ccc 1px solid; \n         \n","text":{"align":"","color":""}},"type":"block","userUpdatedElementLabel":true},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-BodyEndDateTextField","key":"element_element_element_element_block_0_0_block_1_0_block_4_0_outputField_0_0","name":"Text","parentElementKey":"element_element_element_block_0_0_block_1_0_block_4_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BLabel.CPQOfferEndsLabel%7D%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":true,"large":"3","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates-label slds-m-right_x-small","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates-label slds-m-right_x-small","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"3","medium":"12","small":"12"},"sizeClass":"slds-large-size_3-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"text","userUpdatedElementLabel":true},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Body-PromotionEndDate","key":"element_element_element_element_element_block_0_0_block_1_0_block_4_0_block_1_0_outputField_0_0","name":"Field","parentElementKey":"element_element_element_element_block_0_0_block_1_0_block_4_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"vlocity_cmt__effectiveenddate__c","id":"state-new-condition-123","operator":"!=","type":"custom","value":"undefined"}],"id":"state-condition-object","isParent":true},"fieldName":"vlocity_cmt__effectiveenddate__c","format":"DD/MM/YYYY","placeholder":"{Label.CPQEndDateOfPromotionPlaceholder}","record":"{record}","type":"datetime","useAbsoluteDate":true},"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"element","userUpdatedElementLabel":true},{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Body-EndDate-Block-Field-1-clone-0","key":"element_element_element_element_element_block_0_0_block_1_0_block_4_0_block_1_0_outputField_1_0","name":"Field","parentElementKey":"element_element_element_element_block_0_0_block_1_0_block_4_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"vlocity_cmt__CommitmentEndDate__c","id":"state-new-condition-130","operator":"!=","type":"custom","value":"undefined"},{"field":"vlocity_cmt__CommitmentEndDate__c.value","id":"state-new-condition-137","logicalOperator":"&&","operator":"!=","type":"custom","value":"undefined"}],"id":"state-condition-object","isParent":true},"fieldName":"vlocity_cmt__CommitmentEndDate__c.value","format":"DD/MM/YYYY","placeholder":"{Label.CPQEndDateOfPromotionPlaceholder}","record":"{record}","type":"datetime","useAbsoluteDate":true},"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-dates    slds-p-top_xxx-small  ","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"element","userUpdatedElementLabel":true}],"class":"slds-col ","element":"block","elementLabel":"DetailView-Body-EndDate-Block-Block-1","key":"element_element_element_element_block_0_0_block_1_0_block_4_0_block_1_0","name":"Block","parentElementKey":"element_element_element_block_0_0_block_1_0_block_4_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":9,"isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":9,"isResponsive":false},"sizeClass":"slds-size_9-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":9,"isResponsive":false},"sizeClass":"slds-size_9-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"DetailView-Body-EndDate-Block","key":"element_element_element_block_0_0_block_1_0_block_4_0","name":"Block","parentElementKey":"element_element_block_0_0_block_1_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"6","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-m-top_large","container":{"class":""},"customClass":"slds-m-top_large","elementStyleProperties":{},"inlineStyle":"\n","margin":[],"padding":[],"size":{"default":"6","isResponsive":false},"sizeClass":"slds-size_6-of-12 ","style":"     : #ccc 1px solid; \n         \n","text":{"align":"","color":""}},"type":"block","userUpdatedElementLabel":true},{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Modal-Body-Text-5","key":"element_element_element_block_0_0_block_1_0_outputField_5_0","name":"Text","parentElementKey":"element_element_block_0_0_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BParent.displayAddToCartBtn%7D%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Body-OfferSKUTextField","key":"element_element_element_block_0_0_block_1_0_outputField_6_0","name":"Text","parentElementKey":"element_element_block_0_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"vlocity_cmt__Code__c","id":"state-new-condition-84","operator":"!=","type":"custom","value":"undefined"}],"id":"state-condition-object","isParent":true},"mergeField":"%3Cdiv%3EPromotion%20Code%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-m-top_x-small cpq__promotiondetailview-modal-body-promotion-code-label","container":{"class":""},"customClass":"slds-m-top_x-small cpq__promotiondetailview-modal-body-promotion-code-label","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-m-top_x-small cpq__promotiondetailview-modal-body-promotion-code-label","container":{"class":""},"customClass":"slds-m-top_x-small cpq__promotiondetailview-modal-body-promotion-code-label","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"text","userUpdatedElementLabel":true},{"class":"slds-col ","element":"outputField","elementLabel":"DetailView-Body-PromotionId","key":"element_element_element_block_0_0_block_1_0_outputField_7_0","name":"Field","parentElementKey":"element_element_block_0_0_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"vlocity_cmt__Code__c","id":"state-new-condition-77","operator":"!=","type":"custom","value":"undefined"}],"id":"state-condition-object","isParent":true},"fieldName":"vlocity_cmt__Code__c","placeholder":"{Label.CPQIdOfPromotion}","record":"{record}","type":"text"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"cpq__promotiondetailview-modal-body-promotion-namecode","container":{"class":""},"customClass":"cpq__promotiondetailview-modal-body-promotion-namecode","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"element","userUpdatedElementLabel":true}],"class":"slds-col ","element":"block","elementLabel":"DetailView-Modal-Body","key":"element_element_block_0_0_block_1_0","name":"Block","parentElementKey":"element_block_0_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small slds-modal__content slds-p-around_large cpq__promotiondetailview-modal-body ","container":{"class":""},"customClass":"slds-modal__content slds-p-around_large cpq__promotiondetailview-modal-body ","elementStyleProperties":{},"inlineStyle":"border: 1px solid #ECEBEA;","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         border: 1px solid #ECEBEA;","text":{"align":"","color":""}},"type":"block","userUpdatedElementLabel":true},{"children":[{"children":[{"class":"slds-col ","element":"action","elementLabel":"DetailView-Modal-Footer-See-Details","key":"element_element_element_element_block_0_0_block_2_0_block_0_0_action_0_0","name":"Action","parentElementKey":"element_element_element_block_0_0_block_2_0_block_0_0","property":{"buttonVariant":"outline-brand","card":"{card}","displayAsButton":true,"hideActionIcon":true,"iconOnly":false,"record":"{record}","stateAction":{"Web Page":{"targetName":"/apex"},"displayName":"Cancel","eventName":"reload","id":"flex-action-1616510288438","openUrlIn":"Current Window","targetType":"Web Page","type":"cardAction","vlocityIcon":"standard-default"},"stateObj":"{record}"},"size":{"default":"12","isResponsive":false,"large":"12","medium":"9","small":"8"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-text-align_right  cpq__promotiondetailview-modal-footer-buttons  cpq__promotiondetailview-cancelbuttom-tempchange","container":{"class":""},"customClass":" cpq__promotiondetailview-modal-footer-buttons  cpq__promotiondetailview-cancelbuttom-tempchange","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false,"large":"12","medium":"9","small":"8"},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"right","color":""}},"type":"element","userUpdatedElementLabel":true},{"class":"slds-col ","element":"action","elementLabel":"DetailView-Modal-Footer-AddtoCart-Button","key":"element_element_element_element_block_0_0_block_2_0_block_0_0_action_1_0","name":"Action","parentElementKey":"element_element_element_block_0_0_block_2_0_block_0_0","property":{"buttonVariant":"brand","card":"{card}","data-conditions":{"group":[{"field":"Parent.hideAddToCartButton","id":"state-new-condition-150","operator":"==","type":"custom","value":"undefined"},{"field":"Parent.hideAddToCartButton","id":"state-new-condition-6","logicalOperator":"||","operator":"!=","type":"custom","value":"true"}],"id":"state-condition-object","isParent":true},"displayAsButton":true,"hideActionIcon":true,"record":"{record}","stateAction":{"displayName":"{Label.CPQAddToCart}","eventName":"cpq","extraParams":{"actionObjName":"addtocart","cartId":"{Parent.cartId}","input":"{}","methodName":"addToCartPromoItem","record":"{record}","remoteMethod":"postCartsPromoItems","responseEventName":"cpq_addpromo_response"},"hasExtraParams":true,"id":"flex-action-1628672469496","message":"cpq_ui_event","openUrlIn":"Current Window","subType":"PubSub","type":"Event","vlocityIcon":"standard-default"},"stateObj":"{record}"},"size":{"default":"12","isResponsive":false,"large":"12","medium":"3","small":"4"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-m-left_small  cpq__promotiondetailview-modal-footer-buttons","container":{"class":""},"customClass":"slds-m-left_small  cpq__promotiondetailview-modal-footer-buttons","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false,"large":"12","medium":"3","small":"4"},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"element","userUpdatedElementLabel":true}],"class":"slds-col ","element":"block","elementLabel":"DetailView-Modal-Footer-Button-Block","key":"element_element_element_block_0_0_block_2_0_block_0_0","name":"Block","parentElementKey":"element_element_block_0_0_block_2_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":12,"isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":" cpq__promotiondetailview-modal-footer-button-block","container":{"class":""},"customClass":" cpq__promotiondetailview-modal-footer-button-block","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":12,"isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"block","userUpdatedElementLabel":true}],"class":"slds-col ","element":"block","elementLabel":"DetailView-Modal-Footer","key":"element_element_block_0_0_block_2_0","name":"Block","parentElementKey":"element_block_0_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-modal__footer ","container":{"class":""},"customClass":"slds-modal__footer ","elementStyleProperties":{},"inlineStyle":"border: 1px solid #ECEBEA;","margin":[],"padding":[],"size":{"default":"12","isResponsive":false,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         border: 1px solid #ECEBEA;","text":{"align":"","color":""}},"type":"block","userUpdatedElementLabel":true}],"class":"slds-col ","element":"block","elementLabel":"DetailView","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"customClass":"","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}},"type":"block","userUpdatedElementLabel":true}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Default","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     : #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"theme":"slds","title":"cpqPromotionDetailViewForAssetViewer","Name":"cpqPromotionDetailViewForAssetViewer","uniqueKey":"cpqPromotionDetailViewForAssetViewer","Id":"0ko7200000004DJAAY","OmniUiCardKey":"cpqPromotionDetailViewForAssetViewer/Vlocity/1/1622630227517"};
  export default definition