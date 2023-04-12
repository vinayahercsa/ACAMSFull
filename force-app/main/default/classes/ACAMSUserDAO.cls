public with sharing class ACAMSUserDAO {

    public static User queryUserById(Id userId) {
        List<User> u = [
                SELECT
                        Id,
                        ContactId
                FROM
                        User
                WHERE
                        Id = :userId
                LIMIT
                        1
        ];
        if (!u.isEmpty()) {
            return u.get(0);
        }
        return null;
    }

    public static Profile getB2BProfile() {
        List<Profile> profiles = [
                SELECT
                        Id,
                        Name
                FROM
                        Profile
                WHERE
                        Name = :ACAMSUtil.B2B_COMMERCE_USER_PROFILE
                LIMIT
                        1
        ];
        if (!profiles.isEmpty()) {
            return profiles.get(0);
        }
        return null;
    }

    public static Map<String, Profile> getProfilesMap(Set<String> profileNames) {
        Map<String, Profile> profilesMap = new Map<String, Profile>();
        List<Profile> profiles = [
                SELECT
                        Id,
                        Name
                FROM
                        Profile
                WHERE
                        Name IN :profileNames
        ];
        for (Profile profile : profiles) {
            profilesMap.put(profile.Name, profile);
        }
        return profilesMap;
    }

    public static User getDrupalIntegrationUser() {
        List<User> users = [
                SELECT
                        Id,
                        Name
                FROM
                        User
                WHERE
                        Name = 'Drupal Integration'
                LIMIT
                        1
        ];
        if (!users.isEmpty()) {
            return users.get(0);
        }
        return null;
    }

    public static ccrz__E_AccountGroup__c getAccountGroupByName(String name) {
        List<ccrz__E_AccountGroup__c> accountGroups = [
                SELECT
                        Id,
                        Name,
                        ccrz__AccountGroupID__c,
                        ccrz__PriceListSelectionMethod__c,
                        ccrz__Desc__c,
                        ccrz__ThemeName__c
                FROM
                        ccrz__E_AccountGroup__c
                WHERE
                        Name = :name
                LIMIT
                        1
        ];
        if (!accountGroups.isEmpty()) {
            return accountGroups.get(0);
        }
        return null;
    }

    public static List<User> queryContactAccountsByIds(Set<Id> userIds) {
        List<User> uList = [
                SELECT
                        Id,
                        Contact.AccountId,
                        Contact.Account.CommunityUser__c
                FROM
                        User
                WHERE
                        Id IN :userIds
        ];
        return uList;
    }

    public static List<User> queryCommunityUsersByIdsAndProfiles(Set<Id> userIds, Set<String> userProfiles) {
        List<User> uList = [
                SELECT
                        Id,
                        Email,
                        Username,
                        Account_Id__c,
                        ContactId,
                        FirstName,
                        LastName,
                        CompanyName
                FROM
                        User
                WHERE
                        Id IN :userIds
                        AND Profile.Name IN :userProfiles
        ];
        return uList;
    }
}