# Use official Node.js image as base
FROM node:21 AS build

# Enable Corepack to use pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set working directory inside container
WORKDIR /app

# Copy only package.json and pnpm-lock.yaml for efficient caching
COPY package.json pnpm-lock.yaml turbo.json ./
COPY packages ./packages
COPY apps ./apps

# Install dependencies using pnpm
RUN pnpm install --frozen-lockfile

# Build the project
RUN pnpm turbo run build

# Create a new image with only the necessary files
FROM node:21 AS runtime

WORKDIR /app

# Copy built output and necessary files
COPY --from=build /app .

# Set environment variables
ENV NODE_ENV=production

# Expose necessary ports (e.g., 3000 for web)
EXPOSE 3000

# Start the application
CMD ["pnpm", "start"]
