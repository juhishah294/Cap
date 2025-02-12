# Stage 1: Build
FROM node:20 AS build

# Set working directory
WORKDIR /app

# Install PNPM manually to avoid Corepack signature issues
RUN npm install -g pnpm@10.3.0

# Copy package files first to leverage Docker cache
COPY package.json pnpm-lock.yaml turbo.json ./

# Install dependencies (without unnecessary verification)
RUN pnpm install --frozen-lockfile --no-verify-store-integrity

# Copy remaining files after dependencies are installed
COPY patches ./patches  
COPY packages ./packages
COPY apps ./apps

# Build the project using Turbo
RUN pnpm turbo run build

# Stage 2: Runtime
FROM node:20 AS runtime

# Set working directory
WORKDIR /app

# Copy only necessary built files from the build stage
COPY --from=build /app ./

# Install only production dependencies to reduce image size
RUN pnpm install --frozen-lockfile --prod

# Set production environment
ENV NODE_ENV=production

# Use non-root user for better security
USER node

# Expose the necessary port
EXPOSE 3000

# Start the application
CMD ["pnpm", "start"]
