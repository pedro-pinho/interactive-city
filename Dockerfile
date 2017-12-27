FROM mhart/alpine-node:4

# Home directory for Node-RED
RUN mkdir -p /usr/src/node-red

# key directory
RUN mkdir /.ssh

WORKDIR /usr/src/node-red

# Add node-red user so we aren't running as root.
RUN adduser -h /usr/src/node-red -D -H node-red \
    && chown -R node-red:node-red /usr/src/node-red

USER node-red

# package.json contains Node-RED NPM module and node dependencies
COPY package.json /usr/src/node-red/
RUN npm install node-gyp

#Dependencias
RUN npm install 

# GIT
USER root
RUN apk update
RUN apk add git

# Copy over private key, and set permissions
ADD id_rsa /.ssh/id_rsa

RUN git init
RUN git remote add origin https://fcd4fed85b8edbf5bf9ebc0e66a35398fa839233:x-oauth-basic@github.com/pedro-pinho/interactive-city
RUN git fetch
RUN git checkout -f staging

RUN chown -R node-red:node-red /usr/src/node-red/.git

USER node-red
# COPYING FLOWS
COPY flows.json /usr/src/node-red/flows.json
# Telling git who we are
RUN git config --global user.name "Pedro"
RUN git config --global user.email "pedro@iris-bot.com.br"

# User configuration directory volume
VOLUME ["/usr/src/node-red/"]
EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json

CMD ["npm", "start", "--", "--userDir", "/usr/src/node-red"]