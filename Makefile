all: build

build:
	@go build -o ./tmp/main cmd/main.go

clean:
	@echo "Cleaning..."
	@rm -f tmp
