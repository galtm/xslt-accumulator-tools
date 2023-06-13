#! /bin/bash

for xspecfile in *.xspec; do
    if /tmp/xspec/bin/xspec.sh -e "${xspecfile}" &> result.log; then
        echo "OK: ${xspecfile}"
    else
        echo "FAILED: ${xspecfile}"
        echo "---------- result.log"
        cat result.log
        echo "----------"
        exit 1
    fi
done