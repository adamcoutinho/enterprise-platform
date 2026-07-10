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

# Project name from argument or prompt
PROJECT_NAME=${1:-"website"}
VERSION="1.0"

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
    echo "Error: Directory '$PROJECT_NAME' already exists."
    exit 1
fi

echo "Creating project: $PROJECT_NAME (v$VERSION)"

# Create Vite project with React and TypeScript
# Using printf to handle any potential interactive prompts
printf "\n" | bun create vite "$PROJECT_NAME" --template react-ts

cd "$PROJECT_NAME" || exit

# Install dependencies
echo "Installing dependencies..."
bun install
bun add @tanstack/react-router
bun add -D @tanstack/router-vite-plugin @tanstack/router-devtools

# Configure Vite
echo "Configuring Vite..."
cat <<EOF > vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackRouter } from '@tanstack/router-vite-plugin'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tanstackRouter(),
  ],
})
EOF

# Create initial route structure
echo "Creating route structure..."
mkdir -p src/routes

# Create a placeholder routeTree.gen.ts to satisfy user requirements
echo "Creating routeTree.gen.ts placeholder..."
cat <<EOF > src/routeTree.gen.ts
/* eslint-disable */

// @ts-nocheck

// noinspection JSUnusedGlobalSymbols

import { Route as rootRouteImport } from './routes/__root'

const IndexLazyImport = { update: (config: any) => config }
const EnvLazyImport = { update: (config: any) => config }
const LoginLazyImport = { update: (config: any) => config }

const IndexLazyRoute = IndexLazyImport.update({
  id: '/',
  path: '/',
  getParentRoute: () => rootRouteImport,
} as any).lazy(() => import('./routes/index.lazy').then((d) => d.Route))

const EnvLazyRoute = EnvLazyImport.update({
  id: '/env',
  path: '/env',
  getParentRoute: () => rootRouteImport,
} as any).lazy(() => import('./routes/env.lazy').then((d) => d.Route))

const LoginLazyRoute = LoginLazyImport.update({
  id: '/login',
  path: '/login',
  getParentRoute: () => rootRouteImport,
} as any).lazy(() => import('./routes/login.lazy').then((d) => d.Route))

export const routeTree = rootRouteImport.addChildren([IndexLazyRoute, EnvLazyRoute, LoginLazyRoute])
EOF

# Create .env files
echo "Creating .env files..."
cat <<EOF > .env
VITE_API_URL=https://api.example.com
VITE_APP_NAME="$PROJECT_NAME"
EOF

cat <<EOF > .env.example
VITE_API_URL=https://api.example.com
VITE_APP_NAME=My App
EOF

cat <<EOF > src/styles.css
:root {
  --background: #ffffff;
  --foreground: #000000;
}

.dark {
  --background: #000000;
  --foreground: #ffffff;
}

body {
  background-color: var(--background);
  color: var(--foreground);
  margin: 0;
  font-family: system-ui, -apple-system, sans-serif;
}
EOF

cat <<'EOF' > src/routes/__root.tsx
import { createRootRoute, Link, Outlet } from '@tanstack/react-router'
import { TanStackRouterDevtools } from '@tanstack/router-devtools'

export const Route = createRootRoute({
  component: () => (
    <>
      <nav style={{ 
        padding: '1rem', 
        borderBottom: '1px solid #ccc',
        display: 'flex',
        gap: '1rem',
        backgroundColor: 'var(--background)',
        color: 'var(--foreground)'
      }}>
        <Link to="/" style={{ fontWeight: 'bold' }}>Home</Link>
        <Link to="/env">Environment</Link>
        <Link to="/login">Login</Link>
      </nav>
      <hr />
      <Outlet />
      <TanStackRouterDevtools />
    </>
  ),
})
EOF

cat <<EOF > src/routes/index.lazy.tsx
// @ts-nocheck
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/')({
  component: Index,
})

function Index() {
  const appName = import.meta.env.VITE_APP_NAME

  return (
    <div style={{ padding: '1rem' }}>
      <h3>Welcome to {appName}!</h3>
      <p>This application is running with a centralized navigation bar.</p>
    </div>
  )
}
EOF

cat <<EOF > src/routes/env.lazy.tsx
// @ts-nocheck
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/env')({
  component: EnvPage,
})

function EnvPage() {
  const envVars = import.meta.env

  return (
    <div style={{ padding: '1rem' }}>
      <h3>Environment Variables</h3>
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr style={{ textAlign: 'left', borderBottom: '1px solid #ccc' }}>
            <th style={{ padding: '0.5rem' }}>Variable</th>
            <th style={{ padding: '0.5rem' }}>Value</th>
          </tr>
        </thead>
        <tbody>
          {Object.entries(envVars)
            .filter(([key]) => key.startsWith('VITE_'))
            .map(([key, value]) => (
              <tr key={key} style={{ borderBottom: '1px solid #eee' }}>
                <td style={{ padding: '0.5rem', fontWeight: '500' }}>{key}</td>
                <td style={{ padding: '0.5rem' }}>{String(value)}</td>
              </tr>
            ))}
        </tbody>
      </table>
    </div>
  )
}
EOF

cat <<EOF > src/routes/login.lazy.tsx
// @ts-nocheck
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
EOF

# Update main.tsx
echo "Updating main.tsx..."
cat <<EOF > src/main.tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import { RouterProvider, createRouter } from '@tanstack/react-router'
import './index.css'

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

const rootElement = document.getElementById('root')
if (rootElement) {
  const root = ReactDOM.createRoot(rootElement)
  root.render(
    <React.StrictMode>
      <RouterProvider router={router} />
    </React.StrictMode>,
  )
}
EOF

# Update index.html
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>$PROJECT_NAME</title>
    <style>
      :root {
        --background: #ffffff;
        --foreground: #000000;
      }
      .dark {
        --background: #000000;
        --foreground: #ffffff;
      }
      body {
        background-color: var(--background);
        color: var(--foreground);
        margin: 0;
        font-family: system-ui, -apple-system, sans-serif;
      }
    </style>
    <script>
      (function(){try{var stored=window.localStorage.getItem('theme');var mode=(stored==='light'||stored==='dark'||stored==='auto')?stored:'auto';var prefersDark=window.matchMedia('(prefers-color-scheme: dark)').matches;var resolved=mode==='auto'?(prefersDark?'dark':'light'):mode;var root=document.documentElement;root.classList.remove('light','dark');root.classList.add(resolved);if(mode==='auto'){root.removeAttribute('data-theme')}else{root.setAttribute('data-theme',mode)}root.style.colorScheme=resolved;}catch(e){}})();
    </script>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# Clean up default Vite files
rm src/App.tsx src/App.css

# Create Dockerfile
echo "Creating Dockerfile..."
cat <<EOF > Dockerfile
# Use Bun image for building
FROM oven/bun:latest AS build
WORKDIR /app

# Install dependencies
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

# Copy source and build
COPY . .
RUN bun run build

# Use Nginx to serve the static files
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create .dockerignore
echo "Creating .dockerignore..."
cat <<EOF > .dockerignore
node_modules
dist
.git
.env
EOF

echo "Done! Project '$PROJECT_NAME' created successfully."
echo "To start the development server:"
echo "  cd $PROJECT_NAME"
echo "  bun run dev"
