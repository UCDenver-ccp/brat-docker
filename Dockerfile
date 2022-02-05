# start from a base ubuntu image
FROM ubuntu

# set users cfg file
ARG USERS_CFG=users.json

ARG BRAT_USERNAME
ARG BRAT_PASSWORD
ARG BRAT_EMAIL

ENV BRAT_USERNAME=$BRAT_USERNAME
ENV BRAT_PASSWORD=$BRAT_PASSWORD
ENV BRAT_EMAIL=$BRAT_EMAIL

# Install pre-reqs
RUN apt-get update
RUN apt-get install -y curl vim sudo wget rsync git
# noninteractive mode to avoid prompt to input time zone
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2
RUN apt-get install -y python
RUN apt-get install -y supervisor
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Clone  brat
RUN mkdir /var/www/brat
RUN git clone https://github.com/nlplab/brat.git /var/www/brat

# create a symlink so users can mount their data volume at /bratdata rather than the full path
RUN mkdir /bratdata && mkdir /bratcfg
RUN chown -R www-data:www-data /bratdata /bratcfg 
RUN chmod o-rwx /bratdata /bratcfg
RUN ln -s /bratdata /var/www/brat/data
RUN ln -s /bratcfg /var/www/brat/cfg 

# And make that location a volume
VOLUME /bratdata
VOLUME /bratcfg

ADD brat_install_wrapper.sh /usr/bin/brat_install_wrapper.sh
RUN chmod +x /usr/bin/brat_install_wrapper.sh

# Make sure apache can access it
RUN chown -R www-data:www-data /var/www/brat/

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

# add the user patching script
ADD user_patch.py /var/www/brat/user_patch.py

# Enable cgi
RUN a2enmod cgi

EXPOSE 80

# We can't use apachectl as an entrypoint because it starts apache and then exits, taking your container with it. 
# Instead, use supervisor to monitor the apache process
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

CMD ["/usr/bin/supervisord"]





