FROM node:18-alpine as builder

WORKDIR /usr/src/app

COPY package*.json .
RUN npm install

COPY index.js .

EXPOSE 3000

CMD ["node", "index.js"]

