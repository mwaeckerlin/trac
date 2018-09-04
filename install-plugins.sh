#!/bin/sh -e

if test $# -gt 0; then
    TRAC_PLUGINS="$*"
fi

! test -d /tmp/plugins || rm -rf /tmp/plugins
for p in ${TRAC_PACKAGES}; do
    type=${p%%:*}
    url=${p#*:}
    mkdir /tmp/plugins
    cd /tmp/plugins
    case "$type" in
        (http|https)
            case "$url" in
                (*agilo*)
                    # patch agilo it to accept newer trac versions
                    wget -qO- $type:$url | tar xz --strip-components=1
                    for f in setup.py agilo.egg-info/requires.txt; do
                        sed -i 's,trac == 1\.0\.11,trac >= 1.0.11,' $f
                    done
                    ${PY_INSTALL} .
                    ;;
                (*)
                    ${PY_INSTALL} $type:$url
                    ;;
            esac
            ;;
        (git)
            git clone $url plg
            cd plg
            ${PY_INSTALL} .
            ;;
        (svn)
            svn co $url plg
            cd plg
            ${PY_INSTALL} .
            ;;
        (*)
            echo "**** ERROR: Don't know how to install $url of type $type"
            exit 1
            ;;
    esac
    cd /
    rm -rf /tmp/plugins
done
