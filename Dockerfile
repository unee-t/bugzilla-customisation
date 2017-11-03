FROM uneet/bugzilla

COPY bugzilla_admin /opt/bugzilla/bugzilla_admin

# Add start script
ADD start /opt/

RUN ./checksetup.pl

# Run start script
CMD ["/opt/start"]

# Expose web server port
EXPOSE 80

ADD skin /opt/bugzilla/skins/contrib/skin
ADD custom /opt/bugzilla/template/en/custom
VOLUME /opt/bugzilla/skins/contrib/skin
VOLUME /opt/bugzilla/template/en/custom

