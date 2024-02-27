global with sharing class SummaryViewHelper implements vlocity_cmt.VlocityOpenInterface { 
    private static final String MEDIA_ATTR_CODE = 'ATT_MEDIA';
    private static final String REQUEST_MEDIA_NODE = 'feasibilityMedia';
    private static final String MEDIA_NODE = 'media';
    private static final String BANDWIDTH_NODE = 'maxBandwidth';

    private static List<String> RESPONSE_MEDIA_NODE_LIST = new List<String>{'wirelineNetworkElement', 'wirelessNetworkElement', 'fourGNetworkElement', 'fiveGNetworkElement', 'thirdPartyResponse', 'offNetResponse'};
    private static final String CHILD_ITEM_QUERY = 'SELECT Id, ARTL_Feasibility__r.ARTL_Feasibility_Status__c, ARTL_Feasibility_Request__c, ARTL_Feasibility_Response__c, vlocity_cmt__RootItemId__c, vlocity_cmt__AttributeSelectedValues__c FROM QuoteLineItem WHERE QuoteId=\'\'{0}\'\' AND vlocity_cmt__ParentItemId__c!=null AND vlocity_cmt__RootItemId__c IN ({1})';

    private static final Map<String,String> MEDIA_MAPPINGS = new Map<String,String>{'FTTH'=>'FTTH', 'Third_Party'=>'Third Party', 'RF_P2MP'=>'RF P2MP'};

    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options){

        if (methodName == 'getMedia') 
            output.put('result', getMedia(input));
       
        else
            throw new SummaryViewHelperException ('Unknown method: ' + methodName );
    
        return true;
    }

    private static Map<String,Object> getMedia(Map<String,Object> input){
        String cartId = (String)input.get('CartId');
        List<Object> rootItemList = (List<Object>)input.get('ItemList');

        Map<String,Object> result;

        result = getMediaFromChildProduct( cartId, rootItemList );
        result.putAll( getMediaFromRootProduct( cartId, rootItemList ) );

        return result;
    }

    private static Map<String,Object> getMediaFromChildProduct(String cartId, List<Object> rootItemList){
        Map<String,SObject> rootItemMap = new Map<String,SObject>();
        Map<String,Object> result = new Map<String,Object>();

        for( Object rootItem : rootItemList )
            rootItemMap.put( (String)((SObject)rootItem).get('vlocity_cmt__AssetReferenceId__c'), (SObject)rootItem );

        String childItemQuery = String.format(CHILD_ITEM_QUERY, new List<String>{cartId, '\''+String.join( new List<String>(rootItemMap.keySet()), '\',\'')+'\''});
        System.debug( '🎃' + childItemQuery );

        for( SObject item : Database.query(childItemQuery) ){
            System.debug( '🎃' + JSON.serialize(((SObject)item).getSObject('ARTL_Feasibility__r')) );
            System.debug( '🎃' + ((SObject)item).get('ARTL_Feasibility_Response__c') );

            if( 'Feasible'==(((SObject)item).getSObject('ARTL_Feasibility__r'))?.get('ARTL_Feasibility_Status__c') && String.isNotBlank( (String)((SObject)item).get('ARTL_Feasibility_Response__c')) ){

                Map<String,Object> feasibilityResponse = (Map<String,Object>)JSON.deserializeUntyped((String)item.get('ARTL_Feasibility_Response__c'));
                Set<String> availableMedia = getAvailableMedia(feasibilityResponse);
                List<Object> mediaBandwidth = getMediaBandwidth(feasibilityResponse);
                String defaultMedia = getDeafualtMedia((Map<String,Object>)JSON.deserializeUntyped((String)item.get('vlocity_cmt__AttributeSelectedValues__c')), (Map<String,Object>)JSON.deserializeUntyped((String)item.get('ARTL_Feasibility_Request__c')));

                result.put( (String)item.get('vlocity_cmt__RootItemId__c'), new Map<String,Object>{ 'Id'=>item.Id, 'availableMedia'=>availableMedia, 'default'=> availableMedia.contains(defaultMedia) ? defaultMedia : null, 'mediaBandwidth'=>mediaBandwidth} );
            }
        }

        return result;
    }

    private static Map<String,Object> getMediaFromRootProduct(String cartId, List<Object> rootItemList){
        Map<String,SObject> rootItemMap = new Map<String,SObject>();
        Map<String,Object> result = new Map<String,Object>();

        for( Object rootItem : rootItemList )
            if( 'Feasible'==(((SObject)rootItem).getSObject('ARTL_Feasibility__r'))?.get('ARTL_Feasibility_Status__c') && String.isNotBlank( (String)((SObject)rootItem).get('ARTL_Feasibility_Response__c')) )
                rootItemMap.put( (String)((SObject)rootItem).get('vlocity_cmt__AssetReferenceId__c'), (SObject)rootItem );

        for( SObject rootItem : rootItemMap.values() ){

            Map<String,Object> feasibilityResponse = (Map<String,Object>)JSON.deserializeUntyped((String)rootItem.get('ARTL_Feasibility_Response__c'));
            Set<String> availableMedia = getAvailableMedia(feasibilityResponse);
            List<Object> mediaBandwidth = getMediaBandwidth(feasibilityResponse);
            String defaultMedia = getDeafualtMedia((Map<String,Object>)JSON.deserializeUntyped((String)rootItem.get('vlocity_cmt__AttributeSelectedValues__c')), (Map<String,Object>)JSON.deserializeUntyped((String)rootItem.get('ARTL_Feasibility_Request__c')));

            result.put( (String)rootItem.get('vlocity_cmt__AssetReferenceId__c'), new Map<String,Object>{ 'Id'=>rootItem.Id, 'availableMedia'=>availableMedia, 'default'=> availableMedia.contains(defaultMedia) ? defaultMedia : null, 'mediaBandwidth'=>mediaBandwidth} );
        }

        return result;
    }

    private static Set<String> getAvailableMedia(Map<String,Object> feasibilityResponse){
        Set<String> result = new Set<String>();
        for( String mediaNode : RESPONSE_MEDIA_NODE_LIST )
            if( feasibilityResponse.get(mediaNode)!=null )
                result.add( getMediaMapping((String)((Map<String,Object>)feasibilityResponse.get(mediaNode)).get(MEDIA_NODE)) );
        return result;
    }

    private static List<Map<String,Object>> getMediaBandwidth(Map<String,Object> feasibilityResponse){
        List<Map<String,Object>> result = new List<Map<String,Object>>();
        for( String mediaNode : RESPONSE_MEDIA_NODE_LIST )
            if( feasibilityResponse.get(mediaNode)!=null )
                result.add( new Map<String,Object>{ getMediaMapping((String)((Map<String,Object>)feasibilityResponse.get(mediaNode)).get(MEDIA_NODE))=>(String)((Map<String,Object>)feasibilityResponse.get(mediaNode)).get(BANDWIDTH_NODE)} );
        return result;
    }

    private static String getDeafualtMedia(Map<String,Object> attributeValues, Map<String,Object> feasibilityRequest){
        if( attributeValues!=null && attributeValues.get(MEDIA_ATTR_CODE)!=null )
            return (String)attributeValues.get(MEDIA_ATTR_CODE);

        if( feasibilityRequest!=null && feasibilityRequest.get(REQUEST_MEDIA_NODE)!=null )
            return getMediaMapping((String)feasibilityRequest.get(REQUEST_MEDIA_NODE));

        return null;
    }

    private static String getMediaMapping(String media){
        if(MEDIA_MAPPINGS.containsKey(media))
            return MEDIA_MAPPINGS.get(media);

        return media;
    }


    public class SummaryViewHelperException extends Exception{}
}