#node baseimage
FROM node:16

#change dir
WORKDIR /app

#copy files.json from local to this dir
COPY *.json ./

#install dependencies 
RUN npm install

#copy rest of files
COPY . .

#build
RUN npm run build

#port of app
EXPOSE 3000

#start app
CMD [ "npm" , "start" ]
