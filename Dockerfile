FROM node:20 AS build

# Set working directory
WORKDIR /app

# Install PNPM manually to avoid Corepack signature issues
RUN npm install -g pnpm@10.3.0

# Copy package files & patches directory (if exists)
COPY package.json pnpm-lock.yaml turbo.json ./
COPY patches ./patches  

# Copy monorepo structure
COPY packages ./packages
COPY apps ./apps

# Install dependencies with fallback for missing files
RUN pnpm install --frozen-lockfile --no-verify-store-integrity

# Build the project using Turbo
RUN pnpm turbo run build

# Create runtime image
FROM node:20 AS runtime

# Set working directory
WORKDIR /app

# Copy built files from the build stage
COPY --from=build /app .

# Set production environment
ENV NODE_ENV=production

# Expose the necessary port
EXPOSE 3000

# Start the application
CMD ["pnpm", "start"]
