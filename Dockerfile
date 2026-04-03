FROM node:20-slim

# Install system dependencies for better-sqlite3 and docker-cli (to talk to host docker)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    curl \
    ca-certificates \
    gnupg \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies including better-sqlite3 (native build)
RUN npm install

# Copy source code
COPY . .

# Build project
RUN npm run build

# Create necessary directories
RUN mkdir -p data store groups

# The app doesn't expose a port by default, but Coolify likes one
EXPOSE 3000

# Start the app with a fallback to keep the container running on failure (for manual authentication)
CMD ["sh", "-c", "npm run start || tail -f /dev/null"]
