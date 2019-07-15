FROM uneet/bugzilla

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
