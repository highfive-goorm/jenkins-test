# ───────────────────────────────────────
# 단계 없는(Multi‐stage 없이) Nginx 테스트용 Dockerfile
# ───────────────────────────────────────
FROM nginx:alpine

# 1) static/index.html 을 Nginx 기본 웹 루트로 복사
COPY static/index.html /usr/share/nginx/html/index.html

# 2) (선택) default.conf 를 수정하고 싶다면 /etc/nginx/conf.d/default.conf 를 덮어 씁니다.
#    예) 그냥 기본 설정으로 두려면 이 줄은 생략해도 됩니다.
# COPY static/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
