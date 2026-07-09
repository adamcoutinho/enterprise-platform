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
PROJECT_NAME=${1:-"my-platform"}

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
    echo "Error: Directory '$PROJECT_NAME' already exists."
    exit 1
fi

echo "Creating project: $PROJECT_NAME"

# Create Vite project with React and TypeScript
printf "\n" | bun create vite "$PROJECT_NAME" --template react-ts

cd "$PROJECT_NAME" || exit

# Install dependencies
echo "Installing dependencies..."
bun install
bun add @tanstack/react-router lucide-react
bun add -D @tanstack/router-vite-plugin @tanstack/router-devtools

# Configure Vite
echo "Configuring Vite..."
cat <<EOF > vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-vite-plugin'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    TanStackRouterVite({
      routesDirectory: './src/routes',
      generatedRouteTree: './src/routeTree.gen.ts',
    }),
  ],
})
EOF

# Create the requested structure
echo "Creating structure (apps, shared, routes)..."
mkdir -p src/apps
mkdir -p src/shared
mkdir -p src/routes

# Create .env files
echo "Creating .env files..."
cat <<EOF > .env
VITE_API_URL=https://api.example.com
VITE_APP_NAME="$PROJECT_NAME"
VITE_ENVIRONMENT=development
EOF

cat <<EOF > .env.example
VITE_API_URL=https://api.example.com
VITE_APP_NAME=My App
VITE_ENVIRONMENT=production
EOF

# Create Shared Layout
echo "Creating Shared Layout..."
cat <<EOF > src/shared/Layout.tsx
import React from 'react'
import { Link, Outlet } from '@tanstack/react-router'
import { LayoutDashboard, Briefcase, Home, Settings } from 'lucide-react'

export const Layout = ({ children }: { children?: React.ReactNode }) => {
  return (
    <div style={{ minHeight: '100-screen', backgroundColor: '#f3f4f6', display: 'flex', flexDirection: 'column', fontFamily: 'sans-serif' }}>
      <header style={{ backgroundColor: 'white', boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.05)', padding: '1rem' }}>
        <nav style={{ maxWidth: '80rem', margin: '0 auto', display: 'flex', gap: '1.5rem', alignItems: 'center' }}>
          <h1 style={{ fontSize: '1.25rem', fontWeight: 'bold', marginRight: '1rem', color: '#111827' }}>Platform</h1>
          <Link 
            to="/" 
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#4b5563', textDecoration: 'none' }}
            activeProps={{ style: { color: '#2563eb', fontWeight: '600' } }}
          >
            <Home size={18} /> Home
          </Link>
          <Link 
            to="/app" 
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#4b5563', textDecoration: 'none' }}
            activeProps={{ style: { color: '#2563eb', fontWeight: '600' } }}
          >
            <LayoutDashboard size={18} /> App
          </Link>
          <Link 
            to="/careers" 
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#4b5563', textDecoration: 'none' }}
            activeProps={{ style: { color: '#2563eb', fontWeight: '600' } }}
          >
            <Briefcase size={18} /> Careers
          </Link>
          <Link 
            to="/env" 
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#4b5563', textDecoration: 'none' }}
            activeProps={{ style: { color: '#2563eb', fontWeight: '600' } }}
          >
            <Settings size={18} /> Env
          </Link>
        </nav>
      </header>
      <main style={{ flex: 1, maxWidth: '80rem', width: '100%', margin: '0 auto', padding: '1.5rem', boxSizing: 'border-box' }}>
        {children || <Outlet />}
      </main>
      <footer style={{ backgroundColor: 'white', borderTop: '1px solid #e5e7eb', padding: '1rem', textAlign: 'center', color: '#6b7280' }}>
        &copy; 2026 My Platform
      </footer>
    </div>
  )
}
EOF

# Create Apps components
echo "Creating App components..."

# Home App
cat <<EOF > src/apps/HomeApp.tsx
export const HomeApp = () => (
  <div style={{ backgroundColor: 'white', padding: '1.5rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1)' }}>
    <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '1rem' }}>Welcome Home</h2>
    <p>This is the main landing page (http://localhost:5173).</p>
  </div>
)
EOF

# Dashboard App
cat <<EOF > src/apps/DashboardApp.tsx
export const DashboardApp = () => (
  <div style={{ backgroundColor: 'white', padding: '1.5rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1)' }}>
    <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '1rem' }}>Dashboard App</h2>
    <p>This is the main application area (http://localhost:5173/app).</p>
  </div>
)
EOF

# Careers App
cat <<EOF > src/apps/CareersApp.tsx
export const CareersApp = () => (
  <div style={{ backgroundColor: 'white', padding: '1.5rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1)' }}>
    <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '1rem' }}>Careers</h2>
    <p>Join our team! (http://localhost:5173/careers).</p>
  </div>
)
EOF

# Env App
cat <<EOF > src/apps/EnvApp.tsx
export const EnvApp = () => {
  const envVars = import.meta.env;
  
  return (
    <div style={{ backgroundColor: 'white', padding: '1.5rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1)' }}>
      <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '1rem' }}>Environment Variables</h2>
      <div style={{ overflowX: 'auto' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '1rem' }}>
          <thead>
            <tr style={{ borderBottom: '2px solid #e5e7eb', textAlign: 'left' }}>
              <th style={{ padding: '0.5rem' }}>Variable</th>
              <th style={{ padding: '0.5rem' }}>Value</th>
            </tr>
          </thead>
          <tbody>
            {Object.entries(envVars)
              .filter(([key]) => key.startsWith('VITE_'))
              .map(([key, value]) => (
                <tr key={key} style={{ borderBottom: '1px solid #e5e7eb' }}>
                  <td style={{ padding: '0.5rem', fontWeight: '500', color: '#374151' }}>{key}</td>
                  <td style={{ padding: '0.5rem', color: '#6b7280', fontFamily: 'monospace' }}>{String(value)}</td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
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

# Create Routes
echo "Creating Routes..."

cat <<'EOF' > src/routes/__root.tsx
import { createRootRoute, Link, Outlet } from '@tanstack/react-router'
import { TanStackRouterDevtools } from '@tanstack/router-devtools'
import { Layout } from '../shared/Layout'

export const Route = createRootRoute({
  component: () => (
    <>
      <Layout />
      <TanStackRouterDevtools />
    </>
  ),
  notFoundComponent: () => (
    <Layout>
      <div style={{ textAlign: 'center', padding: '2rem' }}>
        <h2>404 - Page Not Found</h2>
        <p>The page you are looking for does not exist.</p>
        <Link to="/" style={{ color: '#2563eb', textDecoration: 'underline' }}>
          Go back home
        </Link>
      </div>
    </Layout>
  ),
})
EOF

cat <<EOF > src/routes/index.lazy.tsx
import { createLazyFileRoute } from '@tanstack/react-router'
import { HomeApp } from '../apps/HomeApp'

export const Route = createLazyFileRoute('/')({
  component: HomeApp,
})
EOF

cat <<EOF > src/routes/app.lazy.tsx
import { createLazyFileRoute } from '@tanstack/react-router'
import { DashboardApp } from '../apps/DashboardApp'

export const Route = createLazyFileRoute('/app')({
  component: DashboardApp,
})
EOF

cat <<EOF > src/routes/careers.lazy.tsx
import { createLazyFileRoute } from '@tanstack/react-router'
import { CareersApp } from '../apps/CareersApp'

export const Route = createLazyFileRoute('/careers')({
  component: CareersApp,
})
EOF

cat <<EOF > src/routes/env.lazy.tsx
import { createLazyFileRoute } from '@tanstack/react-router'
import { EnvApp } from '../apps/EnvApp'

export const Route = createLazyFileRoute('/env')({
  component: EnvApp,
})
EOF

# Update main.tsx
echo "Updating main.tsx..."
cat <<EOF > src/main.tsx
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

# Reset index.css to pure CSS
cat <<EOF > src/index.css
body {
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  background-color: #f3f4f6;
}
EOF

# Update index.html
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Platform</title>
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
echo "Structure created: src/{apps,shared,routes}"
echo "URLs configured:"
echo "  http://localhost:5173/"
echo "  http://localhost:5173/app"
echo "  http://localhost:5173/careers"
echo "  http://localhost:5173/env"
echo ""
echo "To start development:"
echo "  cd \$PROJECT_NAME"
echo "  bun run dev"
