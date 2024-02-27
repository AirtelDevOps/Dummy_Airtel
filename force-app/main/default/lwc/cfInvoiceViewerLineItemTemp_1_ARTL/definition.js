let definition =
      {"states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[]},"definedActions":{"actions":[]},"name":"Active","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small"}],"margin":[{"type":"around","size":"none"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12","class":"slds-card slds-p-around_x-small slds-m-bottom_x-small"},"components":{"layer-0":{"children":[{"name":"Block","element":"block","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"label":"Block","collapsible":false,"record":"{record}","collapsedByDefault":false,"card":"{card}"},"type":"block","styleObject":{"padding":[{"type":"around","size":"x-small"}],"class":"slds-p-around_x-small","sizeClass":"slds-size_12-of-12"},"children":[{"key":"element_element_block_0_0_block_0_0","name":"Block","element":"block","size":{"isResponsive":false,"default":"3"},"stateIndex":0,"class":"slds-col ","property":{"label":"Invoice Id","collapsible":false,"record":"{record}","collapsedByDefault":false,"card":"{card}"},"type":"block","styleObject":{"padding":[{"type":"around","size":"x-small"}],"class":"slds-p-around_x-small","sizeClass":"slds-size_3-of-12 ","size":{"isResponsive":false,"default":"3"}},"children":[{"key":"element_element_element_block_0_0_block_0_0_outputField_0_0","name":"Field","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"Invoice Id","record":"{record}","type":"text","card":"{card}","fieldName":"invoice_Id"},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12"},"parentElementKey":"element_element_block_0_0_block_0_0","elementLabel":"Invoice Id-Field-0"}],"parentElementKey":"element_block_0_0","elementLabel":"Invoice Id","userUpdatedElementLabel":true},{"key":"element_element_block_0_0_block_1_0","name":"Block","element":"block","size":{"isResponsive":false,"default":"3"},"stateIndex":0,"class":"slds-col ","property":{"label":"Date","collapsible":false,"record":"{record}","collapsedByDefault":false,"card":"{card}"},"type":"block","styleObject":{"padding":[{"type":"around","size":"x-small"}],"class":"slds-p-around_x-small","sizeClass":"slds-size_3-of-12 ","size":{"isResponsive":false,"default":"3"}},"children":[{"key":"element_element_element_block_0_0_block_1_0_outputField_1_0","name":"Field","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"Date","record":"{record}","type":"text","card":"{card}","fieldName":"date","format":"DD/MM/YYYY"},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12"},"parentElementKey":"element_element_block_0_0_block_1_0","elementLabel":"Date-Field-1"}],"parentElementKey":"element_block_0_0","elementLabel":"Date","userUpdatedElementLabel":true},{"key":"element_element_block_0_0_block_2_0","name":"Block","element":"block","size":{"isResponsive":false,"default":"3"},"stateIndex":0,"class":"slds-col ","property":{"label":"Amount","collapsible":false,"record":"{record}","collapsedByDefault":false,"card":"{card}"},"type":"block","styleObject":{"padding":[{"type":"around","size":"x-small"}],"class":"slds-p-around_x-small","sizeClass":"slds-size_3-of-12 ","size":{"isResponsive":false,"default":"3"}},"children":[{"key":"element_element_element_block_0_0_block_2_0_outputField_0_0","name":"Field","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"Amount","record":"{record}","type":"text","card":"{card}","fieldName":"amount"},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12"},"parentElementKey":"element_element_block_0_0_block_2_0","elementLabel":"Amount-Field-1"}],"parentElementKey":"element_block_0_0","elementLabel":"Amount","userUpdatedElementLabel":true},{"key":"element_element_block_0_0_block_3_0","name":"Block","element":"block","size":{"isResponsive":false,"default":"3"},"stateIndex":0,"class":"slds-col ","property":{"label":"View Invoice","collapsible":false,"record":"{record}","collapsedByDefault":false,"card":"{card}"},"type":"block","styleObject":{"padding":[{"type":"around","size":"x-small"}],"class":"slds-p-around_x-small","sizeClass":"slds-size_3-of-12 ","size":{"isResponsive":false,"default":"3"}},"children":[{"key":"element_element_element_block_0_0_block_3_0_action_0_0","name":"Action","element":"action","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"label":"View Invoice","iconName":"standard-default","record":"{record}","card":"{card}","stateObj":"{record}","actionList":[{"key":"1695716040054-ryi61k7di","label":"Action","draggable":false,"isOpen":true,"card":"{card}","stateAction":{"id":"flex-action-1696419443278","type":"DataAction","displayName":"Action","vlocityIcon":"standard-default","targetType":"Web Page","openUrlIn":"Current Window","Web Page":{"targetName":"{Invoice}"},"message":"{\"type\":\"ApexRemote\",\"value\":{\"dsDelay\":\"\",\"remoteClass\":\"ARTL_CalloutEventHandler\",\"remoteMethod\":\"initiateCallout\",\"vlocityAsync\":false,\"inputMap\":{\"processName\":\"Invoice_Pdf\",\"invoiceId\":\"{invoice_Id}\"},\"jsonMap\":\"{\\\"invoice_Id\\\":\\\"{invoice_Id}\\\"}\"},\"orderBy\":{\"name\":\"\",\"isReverse\":\"\"},\"contextVariables\":[{\"name\":\"invoice_Id\",\"val\":\"\",\"id\":4}]}"},"actionIndex":0,"isTrackingDisabled":false},{"key":"1695723162267-v4whk2ejf","label":"Action","draggable":true,"isOpen":false,"card":"{card}","stateAction":{"id":"flex-action-1695725113701","type":"Custom","displayName":"Action","vlocityIcon":"standard-default","targetType":"Web Page","openUrlIn":"Current Window","Web Page":{"targetName":"{response.Invoice}"}},"actionIndex":1}],"showSpinner":"false","iconOnly":false,"displayAsButton":true,"hideActionIcon":true,"buttonVariant":"brand","ariaLabel":"View Invoice","flyoutDetails":{}},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12 ","size":{"isResponsive":false,"default":"12"}},"parentElementKey":"element_element_block_0_0_block_3_0","elementLabel":"View Invoice-Action-0"}],"parentElementKey":"element_block_0_0","elementLabel":"View Invoice","userUpdatedElementLabel":true}],"elementLabel":"Block-0"}]}},"childCards":[],"actions":[],"omniscripts":[],"documents":[]}],"dataSource":{"type":"Custom","value":{"dsDelay":"","body":"{}","resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"title":"InvoiceViewerLineItemTemp","enableLwc":true,"isFlex":true,"theme":"slds","selectableMode":"Multi","lwc":{"DeveloperName":"cfInvoiceViewerContainer_3_ARTL","Id":"0Rb7200000094u1CAA","MasterLabel":"cfInvoiceViewerContainer_3_ARTL","NamespacePrefix":"c","ManageableState":"unmanaged"},"isRepeatable":true,"hideChildCardPreview":false,"osSupport":true,"multilanguageSupport":false,"listenToWidthResize":true,"requiredPermission":"","Name":"InvoiceViewerLineItemTemp","uniqueKey":"InvoiceViewerLineItemTemp_1_ARTL","Id":"0ko7200000005feAAA","OmniUiCardKey":"InvoiceViewerLineItemTemp/ARTL/1.0","OmniUiCardType":"Child"};
  export default definition