#!/bin/sh -e

if test $# -gt 0; then
    TRAC_PLUGINS="$*"
fi

! test -d /tmp/plugins || rm -rf /tmp/plugins
for p in ${TRAC_PLUGINS}; do
    type=${p%%:*}
    url=${p#*:}
    mkdir /tmp/plugins
    cd /tmp/plugins
    case "$type" in
        (http|https)
            easy_install --prefix /opt/trac $type:$url
            ;;
        (git)
            git clone $url plg
            cd plg
            easy_install --prefix /opt/trac .
            ;;
        (svn)
            svn co $url plg
            cd plg
            easy_install --prefix /opt/trac .
            ;;
        (*)
            echo "**** ERROR: Don't know how to install $url of type $type"
            exit 1
            ;;
    esac
    cd /
    rm -rf /tmp/plugins
done
