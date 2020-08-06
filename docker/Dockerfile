FROM node:8.4.0-alpine

# App settings
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY ./ /app/

# Expose port
EXPOSE 3000