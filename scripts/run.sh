#!/bin/bash
chown -R www-data:www-data $OWN_DIRS
# run as root scripts
if [[ -d ./files/.root ]]; then
    chmod +x ./files/.root/*
    run-parts ./files/.root
fi
exec "$@"