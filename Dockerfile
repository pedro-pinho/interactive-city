FROM mhart/alpine-node:4

# Home directory for Node-RED application source code.
RUN mkdir -p /usr/src/node-red

# User data directory, contains flows, config and nodes.
RUN mkdir /data

WORKDIR /usr/src/node-red

# Add node-red user so we aren't running as root.
RUN adduser -h /usr/src/node-red -D -H node-red \
    && chown -R node-red:node-red /data \
    && chown -R node-red:node-red /usr/src/node-red

USER node-red

# package.json contains Node-RED NPM module and node dependencies
COPY package.json /usr/src/node-red/
RUN npm install node-gyp

#Dependencias
RUN npm install --save --production node-red-node-watson@0.5.23
RUN npm install --save --production node-red-contrib-facebook-messenger-writer@0.0.3
RUN npm install --save node-red-contrib-viseo-loop@0.2.0
RUN npm install --save --production node-red-dashboard@2.6.1
RUN npm install --save --production node-red-node-cf-cloudant@0.2.17
RUN npm install --save --production node-red-node-twitter@0.1.12

RUN npm install 

# GIT
RUN sudo apt-get update
RUN sudo apt-get install git
RUN git config --global user.name "Flows"
RUN git config --global user.email "pedro@iris-bot.com.br"
RUN git remote add origin https://github.com/pedro-pinho/interactive-city
RUN git push --all --set-upstream origin 

# User configuration directory volume
VOLUME ["/data"]
EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json

CMD ["npm", "start", "--", "--userDir", "/data"]
