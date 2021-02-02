FROM quay.io/spivegin/gitonly:latest AS git

FROM quay.io/spivegin/golang:v1.15.2 AS build-env
WORKDIR /opt/src/src/github.com/yyyar/

RUN ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa && git config --global user.name "quadtone" && git config --global user.email "quadtone@txtsme.com"
COPY --from=git /root/.ssh /root/.ssh
RUN ssh-keyscan -H github.com > ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitea.com >> ~/.ssh/know_hosts

#COPY --from=gover /opt/go /opt/go
ENV deploy=c1f18aefcb3d1074d5166520dbf4ac8d2e85bf41 \
    GO111MODULE=on \
    GOPROXY=direct \
    GOSUMDB=off \
    GOPRIVATE=sc.tpnfc.us
    # GIT_TRACE_PACKET=1 \
    # GIT_TRACE=1 \
    # GIT_CURL_VERBOSE=1

RUN git config --global url.git@github.com:.insteadOf https://github.com/ &&\
    git config --global url.git@gitlab.com:.insteadOf https://gitlab.com/ &&\
    git config --global url.git@gitea.com:.insteadOf https://gitea.com/ &&\
    git config --global url."https://${deploy}@sc.tpnfc.us/".insteadOf "https://sc.tpnfc.us/"


RUN git clone https://github.com/yyyar/gobetween.git
RUN cd gobetween &&\
    make


FROM quay.io/spivegin/tlmbasedebian
WORKDIR /opt/tricll/gobetween
COPY --from=build-env /opt/src/src/github.com/yyyar/gobetween/bin /opt/bin
COPY --from=build-env /opt/src/src/github.com/yyyar/gobetween/config /opt/tricll/gobetween/config
RUN chmod +x /opt/bin/gobetween && ln -s /opt/bin/gobetween /bin/gobetween
CMD ["gobetween", "from-file", "/opt/tricll/gobetween/gobetween.toml"]