# Builder image
FROM node:4.9.1-alpine AS stage1
WORKDIR /app
COPY package.json .
COPY app.js .
RUN npm install && \
    npm run build

# Main image
FROM node:4.9.1-alpine
WORKDIR /app
COPY --from=stage1 /app/build /app
EXPOSE 8080
ENTRYPOINT ["node", "app.js"] 

