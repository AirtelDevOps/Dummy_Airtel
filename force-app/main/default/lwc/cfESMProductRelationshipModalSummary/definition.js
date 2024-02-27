let definition =
      {"dataSource":{"contextVariables":[],"orderBy":{"isReverse":false,"name":""},"type":"Custom","value":{"body":"[{\"Rules\":[]}]","dsDelay":"","resultVar":""}},"enableLwc":true,"events":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1644914573054-sem4ztp9h","label":"Action","stateAction":{"eventName":"setValues","extraParams":{"captureName":"{Name}"},"fieldValues":[{"fieldName":"capturedData","fieldValue":"{action.data}"},{"fieldName":"Rules","fieldValue":"{action.rules}"},{"fieldName":"minQuantity","fieldValue":"{action.minimumQuantity}"},{"fieldName":"maxQuantity","fieldValue":"{action.maximumQuantity}"},{"fieldName":"defQuantity","fieldValue":"{action.defQuantity}"},{"fieldName":"Session.relatedProductId","fieldValue":"{action.relatedProductId}"},{"fieldName":"Session.ruleId","fieldValue":"{action.ruleId}"}],"hasExtraParams":true,"id":"flex-action-1648219576202","message":"fireRules","subType":"PubSub","type":"cardAction"}}],"channelname":"ESMProductRelationshipModal","displayLabel":"ESMProductRelationshipModal:rule","element":"action","eventLabel":"pubsub","eventname":"rule","eventtype":"pubsub","key":"event-0","recordIndex":"0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":true,"isOpen":true,"key":"1646294023046-uq1lsa6pf","label":"Action","stateAction":{"Web Page":{"targetName":"/apex"},"displayName":"Action","eventName":"setValues","fieldValues":[{"fieldName":"Rules","fieldValue":"{action.rules}"}],"id":"flex-action-1646294045827","openUrlIn":"Current Window","targetType":"Web Page","type":"cardAction","vlocityIcon":"standard-default"}}],"channelname":"ESMProductRelationshipModal","displayLabel":"ESMProductRelationshipModal:setRules","element":"action","eventLabel":"pubsub","eventname":"setRules","eventtype":"pubsub","key":"event-1","recordIndex":"0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1648219587070-r4tay1m3w","label":"Action","stateAction":{"displayName":"Action","eventName":"setValues","fieldValues":[{"fieldName":"counter","fieldValue":"{action.counter}"}],"id":"flex-action-1648457993088","openUrlIn":"Current Window","subType":"PubSub","type":"cardAction","vlocityIcon":"standard-default"}}],"channelname":"ESMProductRelationshipModal","displayLabel":"ESMProductRelationshipModal:recordCounter","element":"action","eventLabel":"pubsub","eventname":"recordCounter","eventtype":"pubsub","key":"event-2","recordIndex":"0","showSpinner":"false"}],"globalCSS":true,"isFlex":true,"lwc":{"DeveloperName":"cfESMProductRelationshipModalSummary_5_Salesforce","Id":"0RbHn000000JFqvCAC","ManageableState":"unmanaged","MasterLabel":"cfESMProductRelationshipModalSummary_5_Salesforce","NamespacePrefix":"vlocity_cmt"},"selectableMode":"Multi","sessionVars":[],"states":[{"actions":[],"childCards":["ESMProductDetails","ESMSpecificRuleForProduct","ESM_QuoteItemDataTableSummary"],"components":{"layer-0":{"children":[{"children":[{"class":"slds-col ","element":"customLwc","elementLabel":"Edit Product Relationship-Custom LWC-0","key":"element_element_block_0_0_customLwc_0_0","name":"Custom LWC","parentElementKey":"element_block_0_0","property":{"cartId":"{Parent.CartId}","customlwcname":"b2bFlexCardProductRelationship","parentQuoteLineItemId":"{Parent.ParentQuoteLineItemId}","productId":"{Parent.ProductId}","quoteLineItemId":"{Parent.QuoteLineItemId}","ruleId":"{Parent.ruleId}","ruleRelatedItems":"{Parent.ruleRelatedItems}","uniqueKey":"flexcard"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Edit Product Relationship-Text-1","key":"element_element_block_0_0_outputField_1_0","name":"Text","parentElementKey":"element_block_0_0","property":{"card":"{card}","mergeField":"%3Cdiv%20class=%22slds-text-body_regular%22%3E%3Cspan%20style=%22background-color:%20#ffffff;%20color:%20#000000;%22%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2014pt;%20background-color:%20#ffffff;%22%3E%7BLabel.CMEXEditProductRelationships%7D%3C/span%3E%3C/strong%3E%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#9D9C9C","radius":"","style":"","type":"border_bottom","width":"4px"},"class":"slds-border_bottom slds-p-bottom_x-small b2b-padding-card","container":{"class":""},"customClass":"b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-bottom: #9D9C9C 4pxpx solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#9D9C9C","radius":"","style":"","type":"border_bottom","width":"4px"},"class":"slds-border_bottom slds-p-bottom_x-small b2b-padding-card","container":{"class":""},"customClass":"b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-bottom: #9D9C9C 4pxpx solid; \n         ","text":{"align":"","color":""}}}],"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"Edit Product Relationship","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Edit Product Relationships","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-text-align_center ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"center","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-text-align_center ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"center","color":""}}}],"type":"block","userUpdatedElementLabel":true},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Block-1-Text-0","key":"element_element_block_1_0_outputField_0_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22font-size:%2012pt;%20color:%20#000000;%22%3E%3Cstrong%3E%7BLabel.CMEXProduct%7D%3C/strong%3E%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#FDFDFD","radius":"","style":"","type":"border_top","width":"5"},"class":"slds-border_top b2b-padding-left","container":{"class":""},"customClass":"b2b-padding-left","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     border-top: #FDFDFD 5px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#FDFDFD","radius":"","style":"","type":"border_top","width":"5"},"class":"slds-border_top b2b-padding-left","container":{"class":""},"customClass":"b2b-padding-left","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     border-top: #FDFDFD 5px solid; \n         ","text":{"align":"","color":""}}}],"type":"text"},{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-1-FlexCard-1","key":"element_element_block_1_0_childCardPreview_1_0","name":"FlexCard","parentElementKey":"element_block_1_0","property":{"cardName":"ESMProductDetails","cardNode":"{records}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Active"},"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"border_bottom","width":""},"class":"slds-border_bottom ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     border-bottom: #ccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"border_bottom","width":""},"class":"slds-border_bottom ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     border-bottom: #ccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-1-Text-2","key":"element_element_block_1_0_outputField_2_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%20class=%22slds-text-heading_small%22%3E%3Cspan%20style=%22color:%20#000000;%22%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2012pt;%22%3E%7BLabel.CMEXRules%7D%3C/span%3E%3C/strong%3E%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#F1F1F2","radius":"","style":"","type":"border_top","width":"1.94713"},"class":"slds-border_top slds-p-vertical_x-small b2b-padding-left","container":{"class":""},"customClass":"b2b-padding-left","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"vertical:x-small","size":"x-small","type":"vertical"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-top: #F1F1F2 1.94713px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#F1F1F2","radius":"","style":"","type":"border_top","width":"1.94713"},"class":"slds-border_top slds-p-vertical_x-small b2b-padding-left","container":{"class":""},"customClass":"b2b-padding-left","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"vertical:x-small","size":"x-small","type":"vertical"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-top: #F1F1F2 1.94713px solid; \n         ","text":{"align":"","color":""}}}],"type":"text"},{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-1-FlexCard-4","key":"element_element_block_1_0_childCardPreview_3_0","name":"FlexCard","parentElementKey":"element_block_1_0","property":{"cardName":"ESMSpecificRuleForProduct","cardNode":"{record.Rules}","isChildCardTrackingEnabled":false,"parentAttribute":{"allRecords":"{Rules}"},"recordId":"{recordId}","selectedState":"Active"},"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#FFFFFF","radius":"","style":"","type":"border_top","width":"7"},"class":"slds-border_top ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     border-top: #FFFFFF 7px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#FFFFFF","radius":"","style":"","type":"border_top","width":"7"},"class":"slds-border_top ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":true,"large":"12","medium":"12","small":"12"},"sizeClass":"slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-small-size_12-of-12 slds-size_12-of-12 ","style":"     border-top: #FFFFFF 7px solid; \n         ","text":{"align":"","color":""}}}],"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-1","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"4","isResponsive":true,"large":"4","medium":"4","small":"4"},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":"border_right","width":"1"},"class":"slds-border_right b2b-left-hand-side-panel b2b-padding-card","container":{"class":""},"customClass":"b2b-left-hand-side-panel b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":true,"large":"4","medium":"4","small":"4"},"sizeClass":"slds-large-size_4-of-12 slds-medium-size_4-of-12 slds-small-size_4-of-12 slds-size_4-of-12 ","style":"     border-right: #cccccc 1px solid; \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":"border_right","width":"1"},"class":"slds-border_right b2b-left-hand-side-panel b2b-padding-card","container":{"class":""},"customClass":"b2b-left-hand-side-panel b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":true,"large":"4","medium":"4","small":"4"},"sizeClass":"slds-large-size_4-of-12 slds-medium-size_4-of-12 slds-small-size_4-of-12 slds-size_4-of-12 ","style":"     border-right: #cccccc 1px solid; \n         ","text":{"align":"","color":""}}}],"type":"block"},{"children":[{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Block-0-Text-0","key":"element_element_element_block_2_0_block_0_0_outputField_0_0","name":"Text","parentElementKey":"element_element_block_2_0_block_0_0","property":{"card":"{card}","mergeField":"%3Cdiv%20class=%22slds-text-body_regular%22%3E%3Cspan%20style=%22color:%20#000000;%20font-size:%2010pt;%22%3E%3Cstrong%3E%7BLabel.CMEXRule%7D%3C/strong%3E%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"3","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":[],"width":"7px"},"class":" slds-p-top_x-small slds-p-left_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:x-small","size":"x-small","type":"top"},{"label":"left:small","size":"small","type":"left"}],"size":{"default":"3","isResponsive":false},"sizeClass":"slds-size_3-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":[],"width":"7px"},"class":" slds-p-top_x-small slds-p-left_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:x-small","size":"x-small","type":"top"},{"label":"left:small","size":"small","type":"left"}],"size":{"default":"3","isResponsive":false},"sizeClass":"slds-size_3-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Block-0-Field-2","key":"element_element_element_block_2_0_block_0_0_outputField_1_0","name":"Field","parentElementKey":"element_element_block_2_0_block_0_0","property":{"card":"{card}","fieldName":"capturedData","placeholder":"output","record":"{record}","type":"text"},"size":{"default":"7","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:x-small","size":"x-small","type":"top"}],"size":{"default":"7","isResponsive":false},"sizeClass":"slds-size_7-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:x-small","size":"x-small","type":"top"}],"size":{"default":"7","isResponsive":false},"sizeClass":"slds-size_7-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Block-0-Text-3","key":"element_element_element_block_2_0_block_0_0_outputField_2_0","name":"Text","parentElementKey":"element_element_block_2_0_block_0_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22color:%20#000000;%20font-size:%2010pt;%22%3E%3Cstrong%3E%7BLabel.CMEXCardinality%7D%3C/strong%3E%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"3","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_xx-small slds-p-left_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:xx-small","size":"xx-small","type":"top"},{"label":"left:small","size":"small","type":"left"}],"size":{"default":"3","isResponsive":false},"sizeClass":"slds-size_3-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_xx-small slds-p-left_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:xx-small","size":"xx-small","type":"top"},{"label":"left:small","size":"small","type":"left"}],"size":{"default":"3","isResponsive":false},"sizeClass":"slds-size_3-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Block-0-Field-4","key":"element_element_element_block_2_0_block_0_0_outputField_3_0","name":"Field","parentElementKey":"element_element_block_2_0_block_0_0","property":{"card":"{card}","fieldName":"Max: {maxQuantity} , Min: {minQuantity} , Default: {defQuantity}","placeholder":"output","record":"{record}","type":"text"},"size":{"default":"9","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_xx-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:xx-small","size":"xx-small","type":"top"}],"size":{"default":"9","isResponsive":false},"sizeClass":"slds-size_9-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_xx-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:xx-small","size":"xx-small","type":"top"}],"size":{"default":"9","isResponsive":false},"sizeClass":"slds-size_9-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-2-Block-0","key":"element_element_block_2_0_block_0_0","name":"Block","parentElementKey":"element_block_2_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_x-small slds-p-bottom_small b2b-padding-card","container":{"class":""},"customClass":"b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:x-small","size":"x-small","type":"bottom"},{"label":"bottom:small","size":"small","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_x-small slds-p-bottom_small b2b-padding-card","container":{"class":""},"customClass":"b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:x-small","size":"x-small","type":"bottom"},{"label":"bottom:small","size":"small","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"block"},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Block-2-Text-0","key":"element_element_element_block_2_0_block_1_0_outputField_0_0","name":"Text","parentElementKey":"element_element_block_2_0_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22font-size:%2010pt;%22%3E%7BLabel.CMEXRelatedProducts%7D%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"#F7F6F6","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-left_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"left:small","size":"small","type":"left"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"background-color:#F7F6F6;      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"#F7F6F6","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-left_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"left:small","size":"small","type":"left"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"background-color:#F7F6F6;      \n         ","text":{"align":"","color":""}}}],"type":"text"},{"class":"slds-col ","element":"baseInputElement","elementLabel":"Block-2-Block-2-Select-1","key":"element_element_element_block_2_0_block_1_0_baseInputElement_1_0","name":"Select","parentElementKey":"element_element_block_2_0_block_1_0","property":{"card":"{card}","propertyObj":{"customProperties":[{"id":0,"label":"name","value":"b2b_filterValue-flexcard"}],"label":" ","options":[{"group":"","id":1,"label":"Quote","value":"{Label.CMEXQuote}"},{"group":"","id":2,"label":"Asset","value":"{Label.CMEXAsset}"}],"type":"combobox","value":"{Label.CMEXQuote}"},"record":"{record}","type":"combobox"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-left_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"left:small","size":"small","type":"left"}],"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-left_small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"left:small","size":"small","type":"left"}],"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"element"},{"class":"slds-col ","element":"baseInputElement","elementLabel":"Block-2-Block-2-Text-2","key":"element_element_element_block_2_0_block_1_0_baseInputElement_2_0","name":"Text","parentElementKey":"element_element_block_2_0_block_1_0","property":{"card":"{card}","propertyObj":{"customProperties":[{"id":0,"label":"name","value":"b2b_searchKey-flexcard"}],"fieldBinding":"","imask":"","label":" ","placeholder":""},"record":"{record}","type":"text"},"size":{"default":"7","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-right_small slds-m-bottom_xx-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:xx-small","size":"xx-small","type":"bottom"}],"padding":[{"label":"right:small","size":"small","type":"right"}],"size":{"default":"7","isResponsive":false},"sizeClass":"slds-size_7-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-right_small slds-m-bottom_xx-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:xx-small","size":"xx-small","type":"bottom"}],"padding":[{"label":"right:small","size":"small","type":"right"}],"size":{"default":"7","isResponsive":false},"sizeClass":"slds-size_7-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Block-2-Text-3","key":"element_element_element_block_2_0_block_1_0_outputField_3_0","name":"Text","parentElementKey":"element_element_block_2_0_block_1_0","property":{"card":"{card}","mergeField":"%3Cp%20class=%22slds-text-color_default%22%3E%3Cspan%20style=%22color:%20#236fa1;%22%3E%7Bcounter%7D%20%7BLabel.CMEXSelected%7D%3C/span%3E%3C/p%3E","record":"{record}"},"size":{"default":"3","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_small ","container":{"class":""},"customClass":"","elementStyleProperties":{},"height":"","inlineStyle":"","margin":[],"maxHeight":"","minHeight":"","padding":[{"label":"top:small","size":"small","type":"top"}],"selectedStyles":"","size":{"default":"3","isResponsive":false},"sizeClass":"slds-size_3-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":""},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_small ","container":{"class":""},"customClass":"","elementStyleProperties":{},"height":"","inlineStyle":"","margin":[],"maxHeight":"","minHeight":"","padding":[{"label":"top:small","size":"small","type":"top"}],"selectedStyles":"","size":{"default":"3","isResponsive":false},"sizeClass":"slds-size_3-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":""}}],"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"Block-2-Block-2","key":"element_element_block_2_0_block_1_0","name":"Block","parentElementKey":"element_block_2_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"#F7F6F6","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_x-small b2b-padding-card","container":{"class":""},"customClass":"b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"background-color:#F7F6F6;      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"#F7F6F6","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_x-small b2b-padding-card","container":{"class":""},"customClass":"b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"background-color:#F7F6F6;      \n         ","text":{"align":"","color":""}}}],"type":"block"},{"children":[{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-2-Block-3-FlexCard-1","key":"element_element_element_block_2_0_block_2_0_childCardPreview_1_0","name":"FlexCard","parentElementKey":"element_element_block_2_0_block_2_0","property":{"cardName":"ESM_QuoteItemDataTableSummary","cardNode":"","isChildCardTrackingEnabled":false,"parentAttribute":{"cartId":"{Parent.CartId}","realtedProductId":"{Session.relatedProductId}","ruleId":"{Session.ruleId}"},"recordId":"{recordId}","selectedState":"Active"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-2-Block-3","key":"element_element_block_2_0_block_2_0","name":"Block","parentElementKey":"element_block_2_0","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:x-small","size":"x-small","type":"top"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-top_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"top:x-small","size":"x-small","type":"top"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"block"}],"class":"slds-col ","element":"block","elementLabel":"Block-2","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"8","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"8","isResponsive":false},"sizeClass":"slds-size_8-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"8","isResponsive":false},"sizeClass":"slds-size_8-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"block"}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Active","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-card slds-p-around_x-small slds-m-around_none b2b-padding-card","container":{"class":"slds-card"},"customClass":"b2b-padding-card","elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"around:none","size":"none","type":"around"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"theme":"slds","title":"ESMProductRelationshipModalSummary","Id":"a5aHn00000I0sZNAAG","vlocity_cmt__GlobalKey__c":"ESMProductRelationshipModalSummary/Salesforce/5/1648732045097"};
  export default definition