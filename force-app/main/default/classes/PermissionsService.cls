/**
 * Copyright (c) 2024, Prateek Mathur
 * All rights reserved.

 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. 
 */
public with sharing class PermissionsService {
    
    @InvocableMethod(label = 'Check Field Permissions' description = 'Determine if a user has read/write permission on a field of an object')
    public static List<String> determineFieldPermission(List<PermissionsQueryInput> queryInputList) {

        // Find the user based on the userName received
        List<User> userList = [SELECT Id FROM User WHERE Name = :queryInputList.get(0).userNameToCheck];
        if (userList.isEmpty()) {
            return new List<String> {'Apologies, but I couldn\'t find the user for which permissions need to be checked'};
        }

        Id userId = userList.get(0).Id;
        String fieldToCheckString = queryInputList.get(0).objectAPINameToCheck + '.' + queryInputList.get(0).fieldAPINameToCheck;
        
        List<FieldPermissions> fieldPermissionsList = [SELECT Id FROM FieldPermissions WHERE Field = :fieldToCheckString 
            AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId AND IsActive = TRUE)];

        if (fieldPermissionsList.isEmpty()) {
            return new List<String> {'The user ' + queryInputList.get(0).userNameToCheck + ' DOES NOT HAVE access to the field ' + queryInputList.get(0).fieldAPINameToCheck + ' on the ' + queryInputList.get(0).objectAPINameToCheck + ' object.'};
        }
        
        return new List<String> {'The user ' + queryInputList.get(0).userNameToCheck + ' HAS access to the field ' + queryInputList.get(0).fieldAPINameToCheck + ' on the ' + queryInputList.get(0).objectAPINameToCheck + ' object.'};
    }

    public class PermissionsQueryInput {

        @InvocableVariable(
            description = 'User for which we want to determine the object and field permissions for. Must be of the string data type, and expected to receive the full name of the user')
        public String userNameToCheck;

        @InvocableVariable(
            description = 'The object name on which to check the permission for. Must be of the String data type, and expected to receive the fully Qualified API Name of the Object'
        )
        public String objectAPINameToCheck;

        @InvocableVariable(
            description = 'The field name on which to check the permission for. Must be of the String data type, and expected to receive the fully qualified API Name of the Field'
        )
        public String fieldAPINameToCheck;
    }
}