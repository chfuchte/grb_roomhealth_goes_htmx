BINARY_NAME=bin/server

.PHONY: all air build tailwind fmt fixdeps run tailwind_watch

# development
air:
	air -c .air.toml

tailwind_watch:
	npx @tailwindcss/cli -i ./static/css/_tailwind_input.css -o ./static/css/tailwind_generated.css --watch &

# build
build:
	$(MAKE) tailwind
	go build -o $(BINARY_NAME) cmd/main.go

tailwind:
	npx @tailwindcss/cli -i ./static/css/_tailwind_input.css -o ./static/css/tailwind_generated.css --minify

# format and fix dependencies
fmt:
	go fmt ./...

fixdeps:
	go mod download
	go mod tidy

run: 
	./$(BINARY_NAME)
