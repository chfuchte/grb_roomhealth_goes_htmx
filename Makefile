BINARY_NAME=bin/server

.PHONY: all air build tailwind fmt fixdeps clean run

air:
	air -c .air.toml

build:
	$(MAKE) tailwind
	go build -o $(BINARY_NAME) cmd/main.go

tailwind:
	npx @tailwindcss/cli -i ./static/css/_tailwind_input.css -o ./static/css/tailwind_generated.css --minify

fmt:
	go fmt ./...

fixdeps:
	go mod download
	go mod tidy

clean:
	rm -f $(BINARY_NAME)

run: 
	./$(BINARY_NAME)
