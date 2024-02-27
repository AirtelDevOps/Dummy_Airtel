// UserUpdater.cls
public with sharing class ARTL_UserUpdater {

    @AuraEnabled(cacheable=true)
    public static List<UserRole> getAllRoles() {
        // Query all roles
        return [SELECT Id, Name FROM UserRole];
    }

    @AuraEnabled
    public static String getCurrentUserRole(String userId) {
        // Query user's role
        User userWithRole = [SELECT Id, UserRole.Name FROM User WHERE Id = :userId LIMIT 1];
        return userWithRole.UserRole != null ? userWithRole.UserRole.Name : null;
    }

    @AuraEnabled
    public static void updateUserRole(String userId, String roleId) {
        // Retrieve the user
        User userToUpdate = [SELECT Id, UserRoleId FROM User WHERE Id = :userId LIMIT 1];

        // Set the new role
        userToUpdate.UserRoleId = roleId;

        // Perform the update
        update userToUpdate;
    }

    @AuraEnabled(cacheable=true)
    public static List<RoleOption> getRoleOptions() {
        // Get all roles as picklist options
        List<UserRole> allRoles = getAllRoles();
        List<RoleOption> options = new List<RoleOption>();

        for (UserRole role : allRoles) {
            options.add(new RoleOption(role.Id, role.Name));
        }

        return options;
    }

    public class RoleOption {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;

        public RoleOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}