# build stage
FROM node:20 AS builder
WORKDIR /app

# node deps
COPY package.json package-lock.json* /app/
RUN npm ci --legacy-peer-deps

# copy app and build
COPY . /app
ENV NODE_OPTIONS=--max_old_space_size=8192
RUN npm run build

# runtime stage
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*

# copy built files
COPY --from=builder /app/dist /usr/share/nginx/html

# copy nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

