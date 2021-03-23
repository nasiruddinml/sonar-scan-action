FROM newtmitch/sonar-scanner:latest

RUN npm config set unsafe-perm true && \
  npm install --silent --save-dev -g typescript && \
  npm config set unsafe-perm false
ENV NODE_PATH "/usr/lib/node_modules/"

RUN apk add --no-cache ca-certificates jq

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]