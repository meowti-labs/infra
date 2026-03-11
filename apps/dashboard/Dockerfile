FROM node:20-alpine AS base
WORKDIR /app

COPY package.json ./
RUN npm install --no-audit --no-fund

COPY app ./app
RUN npm run build

EXPOSE 3000
CMD ["npm", "run", "start"]
