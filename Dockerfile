FROM quay.io/spivegin/golang_dart_protoc_dev AS build-env
WORKDIR /opt/src/src/github.com/yyyar/

RUN git clone https://github.com/yyyar/gobetween.git
RUN cd gobetween &&\
    make deps &&\
    make build


FROM quay.io/spivegin/tlmbasedebian
WORKDIR /opt/tricll/gobetween
COPY --from=build-env /opt/src/src/github.com/yyyar/gobetween/bin /opt/bin
COPY --from=build-env /opt/src/src/github.com/yyyar/gobetween/config /opt/tricll/gobetween/config
RUN chmod +x /opt/bin/gobetween && ln -s /opt/bin/gobetween /bin/gobetween
CMD ["gobetween", "from-file", "/opt/tricll/gobetween/gobetween.toml"]