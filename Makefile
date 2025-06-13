BINARY_NAME=bin/server

.PHONY: air build tailwind fmt download tidy run tailwind_watch build-all

# development
air:
	air -c .air.toml

tailwind_watch:
	npx @tailwindcss/cli -i ./static/css/_tailwind_input.css -o ./static/css/tailwind_generated.css --watch &

# build
build-all:
	$(MAKE) tailwind
	$(MAKE) build-only

build:
	go build -o $(BINARY_NAME) cmd/main.go -tags=build_only

tailwind:
	npx @tailwindcss/cli -i ./static/css/_tailwind_input.css -o ./static/css/tailwind_generated.css --minify

# utils
fmt:
	go fmt ./...

download:
	go mod download

tidy:
	go mod tidy

run: 
	./$(BINARY_NAME)
