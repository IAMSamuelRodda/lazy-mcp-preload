.PHONY: build clean deploy generate-hierarchy test install-deps

# Build output directory
BUILD_DIR := build
BINARY := mcp-proxy
STRUCTURE_GEN := structure_generator

# Deployment paths
DEPLOY_DIR := /home/x-forge/.claude/lazy-mcp
CONFIG_FILE := config/config.json

# Go build flags
LDFLAGS := -ldflags "-s -w"

build: install-deps
	@echo "Building $(BINARY)..."
	@mkdir -p $(BUILD_DIR)
	go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY) ./cmd/mcp-proxy
	go build $(LDFLAGS) -o $(BUILD_DIR)/$(STRUCTURE_GEN) ./structure_generator/cmd
	@echo "Build complete: $(BUILD_DIR)/$(BINARY)"

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	@echo "Clean complete"

install-deps:
	@echo "Checking Go installation..."
	@which go > /dev/null || (echo "Go not installed. Run: ./scripts/install-go.sh" && exit 1)
	@echo "Installing dependencies..."
	go mod download
	go mod tidy

generate-hierarchy: build
	@echo "Generating tool hierarchy..."
	@mkdir -p deploy/hierarchy
	./$(BUILD_DIR)/$(STRUCTURE_GEN) --config $(CONFIG_FILE) --output deploy/hierarchy
	@echo "Hierarchy generated in deploy/hierarchy/"

deploy: build generate-hierarchy
	@echo "Deploying to $(DEPLOY_DIR)..."
	@mkdir -p $(DEPLOY_DIR)
	cp $(BUILD_DIR)/$(BINARY) $(DEPLOY_DIR)/
	cp $(CONFIG_FILE) $(DEPLOY_DIR)/
	cp -r deploy/hierarchy $(DEPLOY_DIR)/
	@echo ""
	@echo "Deployment complete!"
	@echo ""
	@echo "Add to ~/.claude.json:"
	@echo '  "mcpServers": {'
	@echo '    "lazy-mcp": {'
	@echo '      "type": "stdio",'
	@echo '      "command": "$(DEPLOY_DIR)/$(BINARY)",'
	@echo '      "args": ["--config", "$(DEPLOY_DIR)/config.json"]'
	@echo '    }'
	@echo '  }'

test:
	@echo "Running tests..."
	go test -v ./...

# Development helpers
dev-run: build
	./$(BUILD_DIR)/$(BINARY) --config $(CONFIG_FILE)

fmt:
	go fmt ./...

lint:
	golangci-lint run
