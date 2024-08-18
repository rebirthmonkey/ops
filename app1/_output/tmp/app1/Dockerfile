# Builder Stage
FROM golang:1.22-alpine as builder

# 设置工作目录
WORKDIR /app

# 安装构建依赖
RUN apk add --no-cache git make

# 复制 go mod 和 sum 文件
RUN cd ..
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

# copy source code
COPY . .

RUN make build

# Distribution Stage
FROM alpine:3.19

# 设置工作目录
WORKDIR /app

# 从构建者阶段复制构建好的二进制文件
COPY --from=builder /bin/app /app/

# 为最终镜像设置运行时命令
#ENTRYPOINT ["/app/app"]
ENTRYPOINT /app/app -c /etc/app/config.yaml

# 暴露应用端口
EXPOSE 8888

