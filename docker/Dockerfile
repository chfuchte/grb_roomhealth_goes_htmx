# build tailwindcss
FROM node:lts-slim AS tailwind-builder
WORKDIR /app

RUN apt-get update \
 && apt-get install -y make \
 && rm -rf /var/lib/apt/lists/*

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

COPY package.json .
COPY pnpm-lock.yaml .

RUN pnpm install --frozen-lockfile

COPY static/css static/css

RUN pnpm run tw:build

# build go server
FROM golang:1.24-alpine AS go-builder
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .
COPY --from=tailwind-builder /app/static/css/tailwind_generated.css ./static/css/tailwind_generated.css

RUN CGO_ENABLED=0 GOOS=linux go build -o bin/server cmd/main.go

# final image
FROM scratch
WORKDIR /app

COPY --from=go-builder /app/bin/server ./bin/server
COPY --from=go-builder /app/static ./static
COPY --from=go-builder /app/templates ./templates

EXPOSE 8080

ENTRYPOINT ["/app/bin/server"]

CMD []
