BINARY_NAME=bin/server

.PHONY: air build fmt fixdepsclean run

air:
	air -c .air.toml

build:
	go build -o $(BINARY_NAME) cmd/main.go

fmt:
	go fmt ./...

fixdeps:
	go mod download
	go mod tidy

clean:
	rm -f $(BINARY_NAME)

run: 
	./$(BINARY_NAME)
