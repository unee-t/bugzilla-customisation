FROM ubuntu

# BEGIN STUFF THAT SHOULD BE IN A BASE IMAGE
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl apache2 make gcc g++ jq \
    libxml2-dev libgd-dev vim-tiny libdbd-mysql-perl \
    libapache2-mod-perl2 libmariadb-client-lgpl-dev msmtp msmtp-mta gettext-base tzdata git gnutls-bin

RUN apt-get install -y cpanminus
RUN cpanm --notest App::cpm Module::CPANfile

RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

RUN a2dissite 000-default

# END STUFF FOR BASE IMAGE

ARG BUGZILLA_BRANCH="synthesis"

RUN git clone -b $BUGZILLA_BRANCH https://github.com/bugzilla/bugzilla.git /opt/bugzilla
WORKDIR /opt/bugzilla
COPY gen-cpanfile.pl /usr/local/bin/gen-cpanfile.pl
RUN perl Build.PL && \
    perl /usr/local/bin/gen-cpanfile.pl && \
    cpm install -g --with-recommends --without-test

# Set up apache link to bugzilla
ADD bugzilla.conf /etc/apache2/sites-available/
RUN a2dismod mpm_event
RUN a2enmod rewrite headers expires cgi mpm_prefork remoteip
RUN a2ensite bugzilla

# email sending configuration
COPY msmtprc /etc/msmtprc.temp

COPY bugzilla_admin /opt/bugzilla/bugzilla_admin

# Add start script
ADD start /opt/

RUN ./checksetup.pl

RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

# Run start script
CMD ["/opt/start"]

# Expose web server port
EXPOSE 80

ADD skin /opt/bugzilla/skins/contrib/skin
ADD custom /opt/bugzilla/template/en/custom
VOLUME /opt/bugzilla/skins/contrib/skin
VOLUME /opt/bugzilla/template/en/custom
