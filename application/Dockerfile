FROM nginx:1.14.0-alpine

RUN apk upgrade && apk add --no-cache --virtual ca-certificates

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

