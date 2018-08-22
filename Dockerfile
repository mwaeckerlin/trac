ARG  arch=amd64
ARG  version=latest
FROM ${arch}/ubuntu:${version}

EXPOSE 8080

ENV USER=www-data
ENV GROUP=www-data
ENV DEBIAN_FRONTEND=noninteractiv
ENV AGILO_URL=http://www.agilofortrac.com
ENV AGILO_DOWNLOAD=${AGILO_URL}/download-agilo-trac/
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -qy trac python-ldap wget \
 && mkdir /var/trac \
# && trac-admin /var/trac/default initenv "Default Project" sqlite:db/trac.db \
# && trac-admin /var/trac/default permission add admin TRAC_ADMIN \
# && cd /tmp \
# && wget -q ${AGILO_URL}$(wget -qO- ${AGILO_DOWNLOAD} | sed -n 's,.*href="\([^"]*agilo-source[^"]*tar\.gz\)".*,\1,p') \
# && tar xf *.gz \
# && cd $(find -mindepth 1 -maxdepth 1 -type d) \
# && python setup.py bdist_egg \
# && mv dist/* /var/trac/default/plugins/ \
# && cd /tmp \
# && rm -rf * \
 && apt-get autoremove --purge -y wget \
 && chown -R ${USER}:${GROUP} /var/trac

ADD new-project /usr/bin/new-project

USER www-data

CMD tracd --user ${USER} --group ${GROUP} -r -e /var/trac -p 8080

VOLUME /var/trac
