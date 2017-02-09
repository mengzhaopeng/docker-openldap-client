#!/bin/bash
set -e

POLICY_LDIF=/usr/local/bin/default-policy.ldif
USER_LDIF=/usr/local/bin/user.ldif
LOAD_DATA=/usr/local/bin/load_data.sh

# Convert FQDN to LDAP base DN
SLAPD_TMP_DN=".${SLAPD_DOMAIN}"
while [ -n "${SLAPD_TMP_DN}" ]; do
    SLAPD_DN=",dc=${SLAPD_TMP_DN##*.}${SLAPD_DN}"
    SLAPD_TMP_DN="${SLAPD_TMP_DN%.*}"
done
SLAPD_DN="${SLAPD_DN#,}"
sed -i "s/{SLAPD_DN}/${SLAPD_DN}/g" ${LOAD_DATA}

if [[ ${POLICY_ENABLED}x = "true"x || ${POLICY_ENABLED}x = "TRUE"x ]]; then
    # Policy file made
    rm -f ${POLICY_LDIF}
    echo "# Define password policy" > ${POLICY_LDIF}
    echo "dn: ou=policies,${SLAPD_DN}" >> ${POLICY_LDIF}
    echo "objectClass: organizationalUnit" >> ${POLICY_LDIF}
    echo "ou: policies" >> ${POLICY_LDIF}
    echo "" >> ${POLICY_LDIF}
    echo "dn: cn=default,ou=policies,${SLAPD_DN}" >> ${POLICY_LDIF}
    echo "objectClass: applicationProcess" >> ${POLICY_LDIF}
    echo "objectClass: pwdPolicy" >> ${POLICY_LDIF}
    echo "cn: default" >> ${POLICY_LDIF}
    echo "pwdAllowUserChange: TRUE" >> ${POLICY_LDIF}
    echo "pwdAttribute: userPassword" >> ${POLICY_LDIF}
    echo "pwdCheckQuality: 1" >> ${POLICY_LDIF}
    if [ "`expr ${PWD_EXPIRE_DAY} + 0`" != "" ]; then
        echo "pwdExpireWarning: $[${PWD_EXPIRE_DAY}*24*60*60]" >> ${POLICY_LDIF}
    else
        echo "pwdExpireWarning: $[7*24*60*60]" >> ${POLICY_LDIF}
    fi
    if [ "`expr ${PWD_FAILURE_COUNT} + 0`" != "" ]; then
        echo "pwdFailureCountInterval: ${PWD_FAILURE_COUNT}" >> ${POLICY_LDIF}
    else
        echo "pwdFailureCountInterval: 20" >> ${POLICY_LDIF}
    fi
    if [ "`expr ${PWD_GRACE_AUTH} + 0`" != "" ]; then
        echo "pwdGraceAuthNLimit: ${PWD_GRACE_AUTH}" >> ${POLICY_LDIF}
    else
        echo "pwdGraceAuthNLimit: 0" >> ${POLICY_LDIF}
    fi
    if [ "`expr ${PWD_IN_HISTORY} + 0`" != "" ]; then
        echo "pwdInHistory: ${PWD_IN_HISTORY}" >> ${POLICY_LDIF}
    else
        echo "pwdInHistory: 5" >> ${POLICY_LDIF}
    fi
    if [[ ${PWD_LOCKOUT}x = "false"x || ${PWD_LOCKOUT}x = "FALSE"x ]]; then
        echo "pwdLockout: FALSE" >> ${POLICY_LDIF}
    else
        echo "pwdLockout: TRUE" >> ${POLICY_LDIF}
    fi
    if [ "`expr ${PWD_LOCKOUT_DURATION} + 0`" != "" ]; then
        echo "pwdLockoutDuration: $[${PWD_LOCKOUT_DURATION}*60]" >> ${POLICY_LDIF}
    else
        echo "pwdLockoutDuration: $[30*60]" >> ${POLICY_LDIF}
    fi
    if [ "`expr ${PWD_MAX_AGE} + 0`" != "" ]; then
        echo "pwdMaxAge: $[${PWD_MAX_AGE}*24*60*60]" >> ${POLICY_LDIF}
    else
        echo "pwdMaxAge: $[90*24*60*60]" >> ${POLICY_LDIF}
    fi
    if [ "`expr ${PWD_MAX_FAILURE} + 0`" != "" ]; then
        echo "pwdMaxFailure: ${PWD_MAX_FAILURE}" >> ${POLICY_LDIF}
    else
        echo "pwdMaxFailure: 5" >> ${POLICY_LDIF}
    fi
    if [ "`expr ${PWD_MIN_AGE} + 0`" != "" ]; then
        echo "pwdMinAge: ${PWD_MIN_AGE}" >> ${POLICY_LDIF}
    else
        echo "pwdMinAge: 0" >> ${POLICY_LDIF}
    fi
    if [ "`expr ${PWD_MIN_LENGTH} + 0`" != "" ]; then
        echo "pwdMinLength: ${PWD_MIN_LENGTH}" >> ${POLICY_LDIF}
    else
        echo "pwdMinLength: 6" >> ${POLICY_LDIF}
    fi
    if [[ ${PWD_MUST_CHANGE}x = "true"x || ${PWD_MUST_CHANGE}x = "TRUE"x ]]; then
        echo "pwdMustChange: TRUE" >> ${POLICY_LDIF}
    else
        echo "pwdMustChange: FALSE" >> ${POLICY_LDIF}
    fi
    if [[ ${PWD_SAFE_MODIFY}x = "true"x || ${PWD_SAFE_MODIFY}x = "TRUE"x ]]; then
        echo "pwdSafeModify: TRUE" >> ${POLICY_LDIF}
    else
        echo "pwdSafeModify: FALSE" >> ${POLICY_LDIF}
    fi

    sed -i "s/{SLAPD_DN_P}/${SLAPD_DN}/g" ${LOAD_DATA}
    sed -i "s#{POLICY_LDIF}#${POLICY_LDIF}#g" ${LOAD_DATA}
fi

if [[ ${IMPORT_USER}x = "true"x || ${IMPORT_USER}x = "TRUE"x ]]; then
    if [ ! -f ${USER_LDIF} ]; then
        # gerrit user-related information made
        rm -f ${USER_LDIF}
        echo "dn: ou=people,${SLAPD_DN}" > ${USER_LDIF}
        echo "objectClass: organizationalUnit" >> ${USER_LDIF}
        echo "ou: people" >> ${USER_LDIF}
        echo "description: Information for all users" >> ${USER_LDIF}
        echo "" >> ${USER_LDIF}
        echo "dn: ou=group,${SLAPD_DN}" >> ${USER_LDIF}
        echo "objectClass: organizationalUnit" >> ${USER_LDIF}
        echo "ou: group" >> ${USER_LDIF}
        echo "description: Information for all groups" >> ${USER_LDIF}
        echo "" >> ${USER_LDIF}
        echo "dn: uid=gerrit,ou=people,${SLAPD_DN}" >> ${USER_LDIF}
        echo "objectClass: posixAccount" >> ${USER_LDIF}
        echo "objectClass: inetOrgPerson" >> ${USER_LDIF}
        echo "objectClass: organizationalPerson" >> ${USER_LDIF}
        echo "objectClass: person" >> ${USER_LDIF}
        echo "homeDirectory: /home/gerrit" >> ${USER_LDIF}
        echo "loginShell: /bin/false" >> ${USER_LDIF}
        echo "uid: gerrit" >> ${USER_LDIF}
        echo "cn: gerrit admin" >> ${USER_LDIF}
        echo "sn: gerrit" >> ${USER_LDIF}
        echo "givenName: gerrit" >> ${USER_LDIF}
        echo "uidNumber: 10000" >> ${USER_LDIF}
        echo "gidNumber: 10000" >> ${USER_LDIF}
    fi
    sed -i "s/{SLAPD_DN_U}/${SLAPD_DN}/g" ${LOAD_DATA}
    sed -i "s#{USER_LDIF}#${USER_LDIF}#g" ${LOAD_DATA}
fi

exec ${LOAD_DATA}
