#!/bin/bash
chown -R $OWN_BY $OWN_DIRS
chmod -R g+ws $OWN_DIRS
# run as root scripts
if [[ -d ./files/.root ]]; then
    chmod +x ./files/.root/*
    run-parts ./files/.root
fi
exec "$@"