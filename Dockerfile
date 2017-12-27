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

#Dependencias
RUN npm install node-gyp
RUN npm install 

# GIT
USER root
RUN apk update && apk add git

# Copy over private key, and set permissions
ADD id_rsa /.ssh/id_rsa

RUN git init \
	&& git remote add origin https://github.com/pedro-pinho/interactive-city

RUN git fetch && git checkout -f staging

RUN chown -R node-red:node-red /usr/src/node-red/.git

USER node-red
# COPYING FLOWS
COPY flows.json /usr/src/node-red/flows.json

# copia novamente o package pois git checkout deu overwrite
COPY package.json /usr/src/node-red/

# Telling git who we are
RUN git config --global user.name "Pedro"  \
	&& git config --global user.email "pedro@iris-bot.com.br"

# User configuration directory volume
VOLUME ["/usr/src/node-red/"]
EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json

CMD ["npm", "start", "--", "--userDir", "/usr/src/node-red"]