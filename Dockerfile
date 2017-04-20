
# dotnet-builder
# Here you can use whatever base image is relevant for your application.
FROM microsoft/dotnet:1.1-sdk

# TODO: Move this to something relevant; probably will be in your private registry
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y nodejs

EXPOSE 8080

ENV DOTNET_CORE_VERSION=1.1

# Set the labels that are used for OpenShift to describe the builder image.
LABEL io.k8s.description="Dotnet Builder" \
    io.k8s.display-name="Dotnet 1.1" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,webserver,html,dotnet" \
    # this label tells s2i where to find its mandatory scripts
    # (run, assemble, save-artifacts)
    io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

# Copy the S2I scripts to /usr/libexec/s2i since we set the label that way
COPY ./s2i/bin/ /usr/libexec/s2i

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

RUN mkdir -p /opt/app-root/src
RUN useradd -u 1001 -r -g 0 -d /opt/app-root/src -s /sbin/nologin -c "Default Application User" default
RUN chown -R 1001:1001 /opt/app-root

USER 1001

# Don't download/extract docs for nuget packages
ENV NUGET_XMLDOC_MODE=skip

# Switch back to root for changing dir ownership/permissions
USER 0

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && chmod -R og+rwx /opt/app-root

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/opt/app-root \
    ENABLED_COLLECTIONS=rh-dotnetcore11

# Directory with the sources is set as the working directory. This should
# be a folder outside $HOME as this might cause issues when compiling sources.
# See https://github.com/redhat-developer/s2i-dotnetcore/issues/28
WORKDIR /opt/app-root/src

# Run container by default as user with id 1001 (default)
USER 1001

# Set the default port for applications built using this image
ENV ASPNETCORE_URLS=http://*:8080

# Modify the usage script in your application dir to inform the user how to run
# this image.
CMD ["/usr/libexec/s2i/usage"]
