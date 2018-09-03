#!/bin/sh

for f in $(find ${TRAC_DATA} -mindepth 1 -maxdepth 1 -type d); do
    trac-admin $f upgrade
    trac-admin $f wiki upgrade
done

tracd --user ${WWWUSER} -r -e ${TRAC_DATA} -p 8080

