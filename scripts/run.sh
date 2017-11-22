#!/bin/bash
chown -R www-data:www-data $OWN_DIRS
exec "$@"