#!/bin/bash

# Add Bun to PATH if it exists in the default location
if [ -d "$HOME/.bun/bin" ]; then
    export PATH="$HOME/.bun/bin:$PATH"
fi

# Check if bun is installed
if ! command -v bun &> /dev/null
then
    echo "Bun is not installed. Please install it first: https://bun.sh/"
    exit 1
fi

# Monorepo name from argument or prompt
MONOREPO_NAME=${1:-"my-platform"}

# Check if directory already exists
if [ -d "$MONOREPO_NAME" ]; then
    echo "Error: Directory '$MONOREPO_NAME' already exists."
    exit 1
fi

echo "Creating monorepo: $MONOREPO_NAME"
mkdir -p "$MONOREPO_NAME/apps"
mkdir -p "$MONOREPO_NAME/packages/ui"
cd "$MONOREPO_NAME" || exit

# Initialize root package.json for Bun workspaces
cat <<EOF > package.json
{
  "name": "$MONOREPO_NAME",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "dev": "bun --filter '*' dev",
    "build": "bun --filter '*' build",
    "lint": "bun --filter '*' lint"
  }
}
EOF

# Create root .env files
echo "Creating root .env files..."
cat <<EOF > .env
VITE_API_URL=https://api.example.com
VITE_SHARED_VAR=shared_value
EOF

cat <<EOF > .env.example
VITE_API_URL=https://api.example.com
VITE_SHARED_VAR=shared_value
EOF

# Create shared UI package
echo "Creating shared UI package..."
cat <<EOF > packages/ui/package.json
{
  "name": "@repo/ui",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts"
  },
  "scripts": {
    "lint": "oxlint"
  },
  "dependencies": {
    "react": "^19.2.7"
  }
}
EOF

mkdir -p packages/ui/src
cat <<EOF > packages/ui/src/index.ts
export * from './Button'
EOF

cat <<EOF > packages/ui/src/Button.tsx
import React from 'react'

export const Button = ({ children, onClick }: { children: React.ReactNode, onClick?: () => void }) => {
  return (
    <button 
      onClick={onClick}
      style={{
        padding: '10px 20px',
        backgroundColor: '#0070f3',
        color: 'white',
        border: 'none',
        borderRadius: '5px',
        cursor: 'pointer'
      }}
    >
      {children}
    </button>
  )
}
EOF

# Create a helper script to add new apps
cat <<'EOF' > add-app.sh
#!/bin/bash

APP_NAME=$1

if [ -z "$APP_NAME" ]; then
    echo "Usage: ./add-app.sh <app-name>"
    exit 1
fi

if [ -d "apps/$APP_NAME" ]; then
    echo "Error: App '$APP_NAME' already exists."
    exit 1
fi

echo "Creating app: $APP_NAME"

# Create Vite project with React and TypeScript in apps/ directory
printf "\n" | bun create vite "apps/$APP_NAME" --template react-ts

cd "apps/$APP_NAME" || exit

# Install dependencies
echo "Installing dependencies for $APP_NAME..."
bun install
bun add @tanstack/react-router
# bun add @repo/ui # Bun handles workspace dependencies automatically if in package.json, 
# but let's add it to package.json manually to avoid registry 404
bun add -D @tanstack/router-vite-plugin @tanstack/router-devtools

# Manually add @repo/ui to package.json to avoid npm 404
# We use "workspace:*" for Bun workspaces
sed -i 's/"dependencies": {/"dependencies": {\n    "@repo\/ui": "workspace:*",/' package.json

# Link root .env
ln -s ../../.env .env

# Configure Vite
echo "Configuring Vite..."
cat <<VITE_EOF > vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-vite-plugin'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    TanStackRouterVite(),
  ],
  resolve: {
    alias: {
      '@repo/ui': path.resolve(__dirname, '../../packages/ui/src'),
    },
  },
})
VITE_EOF

# Create initial route structure
echo "Creating route structure..."
mkdir -p src/routes

# Create .env files
echo "Creating .env files..."
# Root .env is already linked, but we can add app-specific overrides here if needed
cat <<ENV_EOF > .env.local
VITE_APP_NAME="$APP_NAME"
ENV_EOF

cat <<ROUTER_EOF > src/routes/__root.tsx
import { createRootRoute, Link, Outlet } from '@tanstack/react-router'
import { TanStackRouterDevtools } from '@tanstack/router-devtools'
import { Button } from '@repo/ui'

export const Route = createRootRoute({
  component: () => (
    <>
      <div className="p-2 flex gap-2 items-center">
        <Link to="/" className="[&.active]:font-bold">
          Home
        </Link>{' '}
        <Link to="/login" className="[&.active]:font-bold">
          Login
        </Link>
        <Button onClick={() => alert('Shared Button Clicked!')}>
          Shared UI
        </Button>
      </div>
      <hr />
      <Outlet />
      <TanStackRouterDevtools />
    </>
  ),
})
ROUTER_EOF

cat <<ROUTER_EOF > src/routes/index.lazy.tsx
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/')({
  component: Index,
})

function Index() {
  const apiUrl = import.meta.env.VITE_API_URL
  const appName = import.meta.env.VITE_APP_NAME
  const sharedVar = import.meta.env.VITE_SHARED_VAR

  return (
    <div className="p-2">
      <h3>Welcome to {appName}!</h3>
      <p>API URL: {apiUrl}</p>
      <p>Shared Var: {sharedVar}</p>
    </div>
  )
}
ROUTER_EOF

cat <<ROUTER_EOF > src/routes/login.lazy.tsx
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/login')({
  component: Login,
})

function Login() {
  return (
    <div className="p-2">
      <h3>Login Page</h3>
      <form>
        <div>
          <label>Username: </label>
          <input type="text" />
        </div>
        <div>
          <label>Password: </label>
          <input type="password" />
        </div>
        <button type="submit">Login</button>
      </form>
    </div>
  )
}
ROUTER_EOF

# Update main.tsx
echo "Updating main.tsx..."
cat <<MAIN_EOF > src/main.tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import { RouterProvider, createRouter } from '@tanstack/react-router'

// Import the generated route tree
import { routeTree } from './routeTree.gen'

// Create a new router instance
const router = createRouter({ routeTree })

// Register the router instance for type safety
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>,
)
MAIN_EOF

# Clean up default Vite files
rm src/App.tsx src/App.css

# Create Dockerfile
echo "Creating Dockerfile..."
cat <<DOCKER_EOF > Dockerfile
# Use Bun image for building
FROM oven/bun:latest AS build
WORKDIR /app

# Install dependencies (from root for monorepo)
COPY package.json bun.lockb ../../
COPY apps/$APP_NAME/package.json ./
RUN bun install --frozen-lockfile

# Copy source and build
COPY . .
RUN bun run build

# Use Nginx to serve the static files
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKER_EOF

# Create .dockerignore
echo "Creating .dockerignore..."
cat <<DOCKER_EOF > .dockerignore
node_modules
dist
.git
.env
DOCKER_EOF

echo "Done! App '$APP_NAME' created in apps/$APP_NAME"
EOF

chmod +x add-app.sh

# Create initial app if provided as second argument
if [ -n "$2" ]; then
    ./add-app.sh "$2"
else
    echo "Creating initial app: website"
    ./add-app.sh "website"
fi

echo "Done! Monorepo '$MONOREPO_NAME' created successfully."
echo "To add more apps:"
echo "  cd $MONOREPO_NAME"
echo "  ./add-app.sh <new-app-name>"
echo ""
echo "To start development for all apps:"
echo "  bun run dev"
