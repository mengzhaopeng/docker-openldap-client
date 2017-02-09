FROM debian:jessie

MAINTAINER mzp <qiuranke@gmail.com>

RUN apt-get update && apt-get install -y ldap-utils --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# ldap server information
ENV LDAP_SERVER localhost
ENV LDAP_PORT 389
ENV SLAPD_PASSWORD secret
ENV SLAPD_DOMAIN example.com

# Policy setup information
ENV POLICY_ENABLED false
ENV PWD_EXPIRE_DAY 7
ENV PWD_FAILURE_COUNT 20
ENV PWD_GRACE_AUTH 0
ENV PWD_IN_HISTORY 5
ENV PWD_LOCKOUT TRUE
ENV PWD_LOCKOUT_DURATION 30
ENV PWD_MAX_AGE 90
ENV PWD_MAX_FAILURE 5
ENV PWD_MIN_AGE 0
ENV PWD_MIN_LENGTH 6
ENV PWD_MUST_CHANGE FALSE
ENV PWD_SAFE_MODIFY FALSE

# Import gerrit user information
ENV IMPORT_USER false

# Copy configuration file
COPY setup.sh /setup.sh
COPY load_data.sh /usr/local/bin/load_data.sh

CMD ["/setup.sh"]
