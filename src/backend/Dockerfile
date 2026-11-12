FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
 
COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/backend ./cmd/api 

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app 

COPY --from=builder /app/backend . 

EXPOSE 8081 

CMD [ "./backend" ]

