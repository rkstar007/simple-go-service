FROM golang:1.16.14-alpine3.15 AS golang

WORKDIR /go/src/simple-go-service

COPY go.mod go.sum ./
RUN  go mod download && go mod verify 

COPY . .

RUN go build -v -o /go/bin/simple-go-service ./...

FROM alpine:3.15

WORKDIR /go/package-manager

ENV PATH "$PATH:/go/bin"

COPY --from=golang /go/bin/simple-go-service /go/bin/

ENTRYPOINT ["simple-go-service"]