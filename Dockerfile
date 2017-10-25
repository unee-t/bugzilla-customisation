FROM uneet/bugzilla

ADD skin /opt/bugzilla/skins/contrib/skin
ADD custom /opt/bugzilla/template/en/custom
VOLUME /opt/bugzilla/skins/contrib/skin
VOLUME /opt/bugzilla/template/en/custom
