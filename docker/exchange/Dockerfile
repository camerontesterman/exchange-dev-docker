# This Dockerfile defines how to build container images containing a
# *development* version of Exchange. It really isn't usable for production, and
# it isn't meant to be; it's for the benefit of people hacking on Exchange.

FROM centos:7.3.1611

RUN yum -y install https://s3.amazonaws.com/exchange-development-yum/exchange-development-repo-1.0.0.noarch.rpm
RUN sed -i -e 's:keepcache=0:keepcache=1:' /etc/yum.conf && \
    yum update -y && \
    yum -y install boundless-vendor-libs \
                   bzip2-devel \
                   db4-devel \
                   expat-devel \
                   freetype-devel \
                   gcc \
                   gcc-c++ \
                   gdbm-devel \
                   git \
                   libjpeg-turbo-devel \
                   libmemcached-devel \
                   libtiff-devel \
                   libxml2-devel \
                   libxslt-devel \
                   make \
                   openldap-devel \
                   openssl-devel \
                   python27-devel \
                   python27-virtualenv \
                   readline-devel \
                   sqlite-devel \
                   tk-devel \
                   zlib-devel \
    && \
    # Create the virtualenv the app will run in
    /usr/local/bin/virtualenv /env && chmod -R 755 /env

ADD docker/home/* /root/
RUN chmod 755 /root/*.sh /root/*.py

WORKDIR /scratch
CMD ["/root/exchange.sh"]
