FROM node:20 AS build

# Enable Corepack & update pnpm
RUN corepack enable && corepack prepare pnpm@10.3.0 --activate

WORKDIR /app

# Copy package files & patches directory (if exists)
COPY package.json pnpm-lock.yaml turbo.json ./
COPY patches ./patches  # Ensure patches are included

COPY packages ./packages
COPY apps ./apps

# Install dependencies with fallback for missing files
RUN pnpm install --frozen-lockfile --no-verify-store-integrity

# Build the project
RUN pnpm turbo run build

# Create runtime image
FROM node:20 AS runtime
WORKDIR /app

COPY --from=build /app .

ENV NODE_ENV=production

EXPOSE 3000

CMD ["pnpm", "start"]
