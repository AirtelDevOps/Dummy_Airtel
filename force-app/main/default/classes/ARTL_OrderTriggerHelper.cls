public class ARTL_OrderTriggerHelper {
    public Static Set<String> setOfRoles = New Set<String>{'Secondary KAM','Voice KAM','PM','SAM'};
	public static void shareAccountrecords(List<Order> newOrderList){
        Set<Id> setOfAccountIds = new Set<Id>();
        Map<Id,List<AccountTeamMember>> mapOfAccMember = new Map<Id,List<AccountTeamMember>>();
        List<OrderShare> lstOfOrderTobeShared = new List<OrderShare>();
        for(Order ord: newOrderList){
            setOfAccountIds.add(ord.AccountId);
        }
        if(!setOfAccountIds.isEmpty()){
            for(AccountTeamMember memeber: [Select Id,UserId,TeamMemberRole,AccountId 
								FROM AccountTeamMember 
									WHERE AccountId IN:setOfAccountIds AND TeamMemberRole IN:setOfRoles]){
                 
				if(mapOfAccMember.containsKey(memeber.AccountId)){
					mapOfAccMember.get(memeber.AccountId).add(memeber);
				}else{
					mapOfAccMember.put(memeber.AccountId, new List<AccountTeamMember>{memeber});
				}
            }
        }
        for(Order ordrec: newOrderList){
            if(mapOfAccMember.containsKey(ordrec.AccountId)){
                for(AccountTeamMember temMember : mapOfAccMember.get(ordrec.AccountId)){
                    lstOfOrderTobeShared.add(new OrderShare(
                        OrderAccessLevel = 'Edit',
                        OrderId = ordrec.id,
                        RowCause='Manual',
                        UserOrGroupId = temMember.UserId
                    ));
                }
                
            }                    
        }
        if(!lstOfOrderTobeShared.isEmpty()){
            if(!Test.isRunningTest()){
            	insert lstOfOrderTobeShared;
            }
        }
    }
}