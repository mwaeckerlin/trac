FROM mwaeckerlin/ubuntu-base

EXPOSE 8080

# 2018-08-23: current agilo 0.9.15 requires exactly trac 1.0.11, patched it to accept newer
# the first line must be trac in tar.gz-format
# 2019-11-25: removed agilo and updated trac
#             Used to be:
#               https://download.edgewall.org/trac/Trac-1.0.17.tar.gz
#               http://www.agilofortrac.com/download/agilo-source-0.9.15-tar.gz
ENV TRAC_DEPENDS     "python-ldap python-psycopg2 python-mysqldb subversion git \
                      python-babel python-babel-localedata python-chardet python-docutils \
                      python-genshi python-olefile python-pil python-pkg-resources \
                      python-pygments python-roman python-subversion python-setuptools \
                      python-tz \
                      graphviz plantuml mscgen"
RUN apt-get install --no-install-recommends --no-install-suggests -qy ${TRAC_DEPENDS} wget
ENV TRAC_PACKAGES    "https://download.edgewall.org/trac/Trac-1.4.tar.gz \
                      https://trac-hacks.org/svn/ldapplugin/0.12 \
                      https://trac-hacks.org/svn/timingandestimationplugin/branches/trac1.0-Permissions \
                      https://trac-hacks.org/svn/plantumlmacro/trunk \
                      https://trac-hacks.org/svn/mscgenplugin/0.11 \
                      https://trac-hacks.org/svn/customfieldadminplugin/0.11 \
                      https://trac-hacks.org/svn/diavisviewplugin/1.0 \
                      https://trac-hacks.org/svn/graphvizplugin/branches/1.2 \
                      https://trac-hacks.org/svn/icalviewplugin/0.11 \
                      https://trac-hacks.org/svn/includemacro/trunk \
                      https://trac-hacks.org/svn/tracjsganttplugin/1.2 \
                      https://trac-hacks.org/svn/masterticketsplugin/trunk \
                      https://trac-hacks.org/svn/tracwysiwygplugin/0.12 \
                      https://trac-hacks.org/svn/tractickettemplateplugin/1.0 \
                      https://trac-hacks.org/svn/tracformsplugin/trunk \
                      https://trac-hacks.org/svn/ticketcalendarplugin/0.12 \
                      https://trac-hacks.org/svn/doxygenplugin/trunk \
                      https://trac-hacks.org/svn/xmlrpcplugin/trunk"

# ignored dependencies: javascript-common libjs-excanvas libjs-jquery
#                       libjs-jquery-timepicker libjs-jquery-ui
#                       python-git python-pygit2

ENV PYTHON_PREFIX    "/opt/trac"
ENV PYTHONPATH       "${PYTHON_PREFIX}/lib/python2.7/site-packages"
ENV PYTHON_EGG_CACHE "/var/tmp/python-eggs"
ENV PATH             "${PYTHON_PREFIX}/bin:${PATH}"
ENV PY_INSTALL       "python /usr/lib/python2.7/dist-packages/easy_install.py --prefix=${PYTHON_PREFIX}"
ENV TRAC_DATA        "/var/trac"
ENV WWWUSER          "www-data"
ENV WWWGROUP         "www-data"
ENV CONTAINERNAME    "trac"
ADD install-plugins.sh /install-plugins.sh
RUN mkdir -p ${TRAC_DATA} ${PYTHONPATH%%:*} ${PYTHON_EGG_CACHE} \
 && /install-plugins.sh \
 && cd ${PYTHON_PREFIX} \
 && wget -qO- ${TRAC_PACKAGES%% *} | tar xz --strip-components=1 --wildcards '*/contrib' \
 && ( test -e /var/www || mkdir /var/www ) \
 && chown -R ${WWWUSER}:${WWWGROUP} ${TRAC_DATA} ${PYTHON_EGG_CACHE} /var/www

ADD new-project /usr/bin/new-project

USER ${WWWUSER}
VOLUME ${TRAC_DATA}

ONBUILD USER root
ONBUILD RUN mv /start.sh /start-trac.sh
ONBUILD ADD start.sh /start.sh
