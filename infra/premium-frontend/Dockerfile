# Stage 1: Build
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Install Tailwind inside container
RUN npm install -D tailwindcss@3 postcss autoprefixer


RUN npm run build

# Stage 2: Serve
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]