#!/bin/bash
set -e

LDAP_STATUS="stop"

while [ ${LDAP_STATUS} != "start" ]; do
    SEARCH_ADMIN=`ldapsearch -h ${LDAP_SERVER} -p ${LDAP_PORT} \
        -x -D "cn=admin,{SLAPD_DN}" -b "{SLAPD_DN}" -s one dn -LLL \
        -w ${SLAPD_PASSWORD}|grep cn=admin|wc -l`
    if [ ${SEARCH_ADMIN} -eq 1 ]; then
        LDAP_STATUS="start"

        if [[ ${POLICY_ENABLED}x = "true"x || ${POLICY_ENABLED}x = "TRUE"x ]]; then
            # policy import ldap
            SEARCH_POLICY=`ldapsearch -h ${LDAP_SERVER} -p ${LDAP_PORT} \
                -x -D "cn=admin,{SLAPD_DN_P}" -b "ou=policies,{SLAPD_DN_P}" \
                -s one dn -LLL -w ${SLAPD_PASSWORD}|grep cn=default|wc -l`
            if [ ${SEARCH_POLICY} -eq 1 ]; then
                ldapdelete -h ${LDAP_SERVER} -p ${LDAP_PORT} \
                    -x -D "cn=admin,{SLAPD_DN_P}" -w ${SLAPD_PASSWORD} \
                    "cn=default,ou=policies,{SLAPD_DN_P}"
                ldapdelete -h ${LDAP_SERVER} -p ${LDAP_PORT} \
                    -x -D "cn=admin,{SLAPD_DN_P}" -w ${SLAPD_PASSWORD} \
                    "ou=policies,{SLAPD_DN_P}"
            fi
            /usr/bin/ldapadd -h ${LDAP_SERVER} -p ${LDAP_PORT} \
                -x -c -D "cn=admin,{SLAPD_DN_P}" -w ${SLAPD_PASSWORD} \
                -f {POLICY_LDIF}
        fi

        if [[ ${IMPORT_USER}x = "true"x || ${IMPORT_USER}x = "TRUE"x ]]; then
            # gerrit user import ldap
            SEARCH_RESULT1=`ldapsearch -h ${LDAP_SERVER} -p ${LDAP_PORT} \
                -x -D "cn=admin,{SLAPD_DN_U}" -b "ou=people,{SLAPD_DN_U}" \
                -s one dn -LLL -w ${SLAPD_PASSWORD}|wc -l`
            SEARCH_RESULT2=`ldapsearch -h ${LDAP_SERVER} -p ${LDAP_PORT} \
                -x -D "cn=admin,{SLAPD_DN_U}" -b "ou=group,{SLAPD_DN_U}" \
                -s one dn -LLL -w ${SLAPD_PASSWORD}|wc -l`
            SEARCH_RESULT3=`ldapsearch -h ${LDAP_SERVER} -p ${LDAP_PORT} \
                -x -D "cn=admin,{SLAPD_DN_U}" \
                -b "uid=gerrit,ou=people,{SLAPD_DN_U}" \
                -s one dn -LLL -w ${SLAPD_PASSWORD}|wc -l`
            if [[ ${SEARCH_RESULT1} -eq 0 && ${SEARCH_RESULT2} -eq 0 \
                && ${SEARCH_RESULT3} -eq 0 ]]; then
                /usr/bin/ldapadd -h ${LDAP_SERVER} -p ${LDAP_PORT} \
                   -x -c -D "cn=admin,{SLAPD_DN_U}" -w ${SLAPD_PASSWORD} \
                   -f {USER_LDIF}
            fi
        fi
    fi
    sleep 1
done
