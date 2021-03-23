FROM openjdk:11.0.10-slim

RUN apt-get update
RUN mkdir -p /usr/share/man/man1
RUN apt-get install -y curl git tmux htop maven sudo unzip ca-certificates jq

# Install Node - allows for scanning of Typescript
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN sudo apt-get install -y nodejs build-essential

# non-root user
ENV USER=sonarscanner
ENV UID=12345
ENV GID=23456
RUN addgroup --gid $GID sonarscanner
RUN adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

# Set timezone to CST
ENV TZ=Asia/Singapore
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /usr/src

ARG SCANNER_VERSION=4.5.0.2216
ENV SCANNER_FILE=sonar-scanner-cli-${SCANNER_VERSION}-linux.zip
ENV SCANNER_EXPANDED_DIR=sonar-scanner-${SCANNER_VERSION}-linux
RUN curl --insecure -o ${SCANNER_FILE} \
    -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${SCANNER_FILE} && \
	unzip -q ${SCANNER_FILE} && \
	rm ${SCANNER_FILE} && \
	mv ${SCANNER_EXPANDED_DIR} /usr/lib/sonar-scanner && \
	ln -s /usr/lib/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

ENV SONAR_RUNNER_HOME=/usr/lib/sonar-scanner

# ensure Sonar uses the provided Java for musl instead of a borked glibc one
RUN sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /usr/lib/sonar-scanner/bin/sonar-scanner

# Separating ENTRYPOINT and CMD operations allows for core execution variables to
# be easily overridden by passing them in as part of the `docker run` command.
# This allows the default /usr/src base dir to be overridden by users as-needed.
CMD ["sonar-scanner", "-Dsonar.projectBaseDir=/usr/src"]

RUN npm config set unsafe-perm true && \
  npm install --silent --save-dev -g typescript && \
  npm config set unsafe-perm false
ENV NODE_PATH "/usr/lib/node_modules/"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]