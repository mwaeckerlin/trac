FROM mwaeckerlin/base

EXPOSE 8080

ENV TRAC_PLUGINS     "http://www.agilofortrac.com/download/agilo-source-0.9.15-tar.gz \
                      https://trac-hacks.org/svn/ldapplugin/0.12 \
                      https://trac-hacks.org/svn/timingandestimationplugin/branches/trac1.0-Permissions \
                      https://trac-hacks.org/svn/plantumlmacro/trunk \
                      https://trac-hacks.org/svn/customfieldadminplugin/0.11 \
                      https://trac-hacks.org/svn/diavisviewplugin/1.0 \
                      https://trac-hacks.org/svn/graphvizplugin/branches/1.0 \
                      https://trac-hacks.org/svn/icalviewplugin/0.11 \
                      https://trac-hacks.org/svn/includemacro/trunk \
                      https://trac-hacks.org/svn/tracjsganttplugin/1.2 \
                      https://trac-hacks.org/svn/masterticketsplugin/trunk \
                      https://trac-hacks.org/svn/tracwysiwygplugin/0.12"

# libbz2 expat libffi gdbm ncurses-terminfo-base ncurses-terminfo
# ncurses-libs readline sqlite-libs python2 py-setuptools py-genshi
# trac
ENV TRAC_DEPENDS     "python2 py-setuptools py-genshi \
                      subversion py-subversion git py-pygit2 \
                      graphviz"
ENV TMP_PKGS         "wget zlib-dev"

# 2018-08-23: current agilo 0.9.15 requires exactly trac 1.0.11
ENV TRAC_SRC         "https://download.edgewall.org/trac/Trac-1.0.11.tar.gz"
ENV PYTHONPATH       "/opt/trac/lib/python2.7/site-packages"
ENV PYTHON_EGG_CACHE "/var/tmp/python-eggs"
ENV PATH             "/opt/trac/bin:${PATH}"
ENV TRAC_DATA        "/var/trac"
ENV WWWUSER          "www-data"
ENV CONTAINERNAME    "trac"
ADD install-plugins.sh /install-plugins.sh
RUN apk add ${TRAC_DEPENDS} ${TMP_PKGS} \
 && adduser -S ${WWWUSER} \
 && mkdir -p ${TRAC_DATA} ${PYTHONPATH%%:*} ${PYTHON_EGG_CACHE} \
 && cd /tmp \
 && wget -qOtrac.tgz ${TRAC_SRC} \
 && tar xf trac.tgz \
 && cd Trac* \
 && python setup.py install --prefix=/opt/trac \
 && cd /tmp \
 && rm -rf * \
 && apk del --purge ${TMP_PKGS} \
 && ( test -e /var/www || mkdir /var/www ) \
 && chown -R ${WWWUSER} ${TRAC_DATA} ${PYTHON_EGG_CACHE} /var/www 
# && /install-plugins.sh

ADD new-project /usr/bin/new-project

USER ${WWWUSER}
VOLUME ${TRAC_DATA}

ONBUILD USER root
ONBUILD RUN mv /start.sh /start-trac.sh
ONBUILD ADD start.sh /start.sh
