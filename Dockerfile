FROM nginx:alpine



COPY ./doc.conf /etc/nginx/conf.d/default.conf


WORKDIR docs

# COPY docs .

## 本地构建命令
# docker build -t docs -f WinDockerfile .
## windows本地运行
# docker run -itd --name docs -p 80:80 -v /F/document/docs:/docs/ docs

