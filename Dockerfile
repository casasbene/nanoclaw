FROM node:22-slim

# Install system dependencies for better-sqlite3
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install claude-code globally (required by agent-runner SDK)
RUN npm install -g @anthropic-ai/claude-code

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies including better-sqlite3 (native build)
RUN npm install

# Copy source code
COPY . .

# Build project
RUN npm run build

# Build agent-runner (required for Docker bypass)
RUN cd container/agent-runner && npm install && npm run build

# Create necessary directories
RUN mkdir -p data store groups

# Ensure node user owns everything it needs to write to
RUN chown -R node:node /app/data /app/store /app/groups /home/node

# Prepare .claude config dir for node user (Claude Code SDK requires it)
RUN mkdir -p /home/node/.claude && chown -R node:node /home/node/.claude

# Switch to non-root user (REQUIRED: Claude Code CLI refuses to run as root)
USER node

# The app doesn't expose a port by default, but Coolify likes one
EXPOSE 3000

# Start the app with a fallback to keep the container running on failure (for manual authentication)
CMD ["sh", "-c", "npm run start || tail -f /dev/null"]
