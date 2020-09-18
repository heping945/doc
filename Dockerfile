FROM nginx:alpine



COPY ./doc.conf /etc/nginx/conf.d/default.conf


WORKDIR docs

# COPY docs .

## 服务器构建命令
# docker build -t docs .
## windows本地运行
# docker run -itd --name docs -p 80:80 -v /root/app/doc/docs:/docs/ docs

