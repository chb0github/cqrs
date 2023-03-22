FROM alpine
RUN apk add inotify-tools jq
RUN mkdir -p /input /output /mappers/
ADD watch.sh /bin
ADD input.json /root
ADD mappers/ /mappers/
ADD mappers/ /mappers/
RUN chmod +x /bin/watch.sh
ENTRYPOINT 'watch.sh'