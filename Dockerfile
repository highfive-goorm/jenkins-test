# Build Stage (Node.js 20 기반으로 React 앱 빌드)
FROM node:20-alpine AS builder
WORKDIR /app

# 1) 의존성 정보만 먼저 복사 → 캐시 활용
COPY package.json package-lock.json ./
RUN yarn install --frozen-lockfile --prefer-offline

# 2) 애플리케이션 소스 전체 복사
COPY . .

# 3) React 앱 빌드 (CI=true로 불필요한 경고를 최소화)
RUN CI=true yarn build

# Production Stage (Nginx로 정적 파일 서빙)
FROM nginx:alpine

# 빌드 결과물만 복사
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
