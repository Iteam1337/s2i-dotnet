
# dotnet-builder
# Here you can use whatever base image is relevant for your application.
FROM microsoft/dotnet:latest

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y nodejs

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
RUN mkdir /opt/app-root
RUN chown -R 1001:1001 /opt/app-root
WORKDIR /opt/app-root

# USER 1001

# Set the default port for applications built using this image
ENV ASPNETCORE_URLS=http://*:8080
EXPOSE 8080

# Modify the usage script in your application dir to inform the user how to run
# this image.
CMD ["/usr/libexec/s2i/usage"]
