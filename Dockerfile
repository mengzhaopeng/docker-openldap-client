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
# This attribute controls whether and when a warning message of password expiration will be returned on a bind attempt.
ENV PWD_EXPIRE_DAY 7
# This attribute controls when the count of consecutive password failures is reset.
ENV PWD_FAILURE_COUNT 20
# This attribute controls whether to allow any further bind operation after a password has expired - frequently referred to as a grace period.
ENV PWD_GRACE_AUTH 0
# This attribute controls the number of passwords that are maintained in a list of previously used passwords - a password history - for the account.
ENV PWD_IN_HISTORY 5
# This attribute controls the action taken when an account has had more consecutive failed bind attempts with invalid passwords than is defined by pwdMaxFailure.
ENV PWD_LOCKOUT TRUE
# This attribute controls how long an account remains locked and is only relevant if pwdLockout is TRUE.
ENV PWD_LOCKOUT_DURATION 30
# It defines the maximum time - in seconds - a password is valid - after which it is deemed to be no longer usable and any bind operations attempted with the expired password will be treated as invalid.
ENV PWD_MAX_AGE 90
# This attribute controls how many consecutive password failures are allowed before the action defined by pwdLockout is taken.
ENV PWD_MAX_FAILURE 5
# This attribute controls the minimum time in seconds between password changes.
ENV PWD_MIN_AGE 0
# This attribute controls whether minimum password length checks will be enforced by the server.
ENV PWD_MIN_LENGTH 6
# This attribute controls whether the user must change their password after an account is reset by an administrator following an account lockout and is only relevant if pwdLockout is TRUE.
ENV PWD_MUST_CHANGE FALSE
# This attribute controls whether a user must send the current password during a password modification operation.
ENV PWD_SAFE_MODIFY FALSE

# Import gerrit user information
ENV IMPORT_USER false

# Copy configuration file
COPY setup.sh /setup.sh
COPY load_data.sh /usr/local/bin/load_data.sh

CMD ["/setup.sh"]
