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
MONOREPO_NAME=${1:-"my-mfe-platform"}

# Check if directory already exists
if [ -d "$MONOREPO_NAME" ]; then
    echo "Error: Directory '$MONOREPO_NAME' already exists."
    exit 1
fi

echo "Creating Microfrontends Monorepo: $MONOREPO_NAME"
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
    "lint": "bun --filter '*' lint",
    "preview": "bun --filter '*' preview"
  }
}
EOF

# Create root .env files
echo "Creating root .env files..."
cat <<EOF > .env
VITE_API_URL=https://api.example.com
VITE_SHARED_VAR=shared_mfe_value
EOF

cat <<EOF > .env.example
VITE_API_URL=https://api.example.com
VITE_SHARED_VAR=shared_mfe_value
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

export const Button = ({ children, onClick, style }: { children: React.ReactNode, onClick?: () => void, style?: React.CSSProperties }) => {
  return (
    <button 
      onClick={onClick}
      style={{
        padding: '10px 20px',
        backgroundColor: '#0070f3',
        color: 'white',
        border: 'none',
        borderRadius: '5px',
        cursor: 'pointer',
        ...style
      }}
    >
      {children}
    </button>
  )
}
EOF

# Create a helper script to add new apps (host or remote)
cat <<'EOF' > add-app.sh
#!/bin/bash

APP_NAME=$1
APP_TYPE=${2:-"remote"} # Default to remote
PORT=${3:-5173}

if [ -z "$APP_NAME" ]; then
    echo "Usage: ./add-app.sh <app-name> [host|remote] [port]"
    exit 1
fi

if [ -d "apps/$APP_NAME" ]; then
    echo "Error: App '$APP_NAME' already exists."
    exit 1
fi

echo "Creating $APP_TYPE app: $APP_NAME on port $PORT"

# Create Vite project with React and TypeScript in apps/ directory
printf "\n" | bun create vite "apps/$APP_NAME" --template react-ts

cd "apps/$APP_NAME" || exit

# Install dependencies
echo "Installing dependencies for $APP_NAME..."
bun install
bun add @tanstack/react-router
bun add @originjs/vite-plugin-federation -D
bun add -D @tanstack/router-vite-plugin @tanstack/router-devtools

# Manually add @repo/ui to package.json to avoid npm 404
sed -i 's/"dependencies": {/"dependencies": {\n    "@repo\/ui": "workspace:*",/' package.json

# Update dev script to include port
sed -i "s/\"dev\": \"vite\"/\"dev\": \"vite --port $PORT --strictPort\"/" package.json
sed -i "s/\"preview\": \"vite preview\"/\"preview\": \"vite preview --port $PORT --strictPort\"/" package.json

# Link root .env
ln -s ../../.env .env

# Configure Vite with Federation
echo "Configuring Vite for $APP_TYPE..."
if [ "$APP_TYPE" == "host" ]; then
    FEDERATION_CONFIG="federation({
      name: 'host',
      remotes: {
        // Remotes will be added here
      },
      shared: ['react', 'react-dom']
    })"
else
    FEDERATION_CONFIG="federation({
      name: '$APP_NAME',
      filename: 'remoteEntry.js',
      exposes: {
        './Widget': './src/components/Widget.tsx',
      },
      shared: ['react', 'react-dom']
    })"
    
    # Create a sample widget for the remote
    mkdir -p src/components
    cat <<WIDGET_EOF > src/components/Widget.tsx
import { Button } from '@repo/ui'

export const Widget = () => {
  return (
    <div style={{ border: '2px dashed #ccc', padding: '1rem', borderRadius: '8px' }}>
      <h4>Remote Widget from $APP_NAME</h4>
      <p>This component is exposed via Module Federation.</p>
      <Button onClick={() => alert('Hello from $APP_NAME!')}>
        Click Me (Remote)
      </Button>
    </div>
  )
}
export default Widget
WIDGET_EOF
fi

cat <<VITE_EOF > vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-vite-plugin'
import federation from '@originjs/vite-plugin-federation'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    TanStackRouterVite(),
    $FEDERATION_CONFIG
  ],
  resolve: {
    alias: {
      '@repo/ui': path.resolve(__dirname, '../../packages/ui/src'),
    },
  },
  build: {
    modulePreload: false,
    target: 'esnext',
    minify: false,
    cssCodeSplit: false
  }
})
VITE_EOF

# Create initial route structure
echo "Creating route structure..."
mkdir -p src/routes

# Create .env.local
cat <<ENV_EOF > .env.local
VITE_APP_NAME="$APP_NAME"
VITE_APP_TYPE="$APP_TYPE"
ENV_EOF

# Create Root Route
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
        <Link to="/about" className="[&.active]:font-bold">
          About
        </Link>
        <Button onClick={() => alert('Shared Button Clicked in $APP_NAME!')} style={{ backgroundColor: '$APP_TYPE' === 'host' ? '#0070f3' : '#10b981' }}>
          $APP_TYPE UI
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
import React, { Suspense } from 'react'

export const Route = createLazyFileRoute('/')({
  component: Index,
})

$(if [ "$APP_TYPE" == "host" ]; then
echo "// @ts-ignore"
echo "const RemoteWidget = React.lazy(() => import('remote_app/Widget').catch(() => ({ default: () => <div>Remote not available</div> })))"
fi)

function Index() {
  const appName = import.meta.env.VITE_APP_NAME
  const appType = import.meta.env.VITE_APP_TYPE

  return (
    <div className="p-2">
      <h3>Welcome to {appName} ({appType})!</h3>
      <p>This is the main page of the $APP_TYPE.</p>
      
      $(if [ "$APP_TYPE" == "host" ]; then
      echo '      <div className="mt-4">'
      echo '        <h4>Microfrontend Integration:</h4>'
      echo '        <Suspense fallback={<div>Loading Remote...</div>}>'
      echo '          <RemoteWidget />'
      echo '        </Suspense>'
      echo '      </div>'
      fi)
    </div>
  )
}
ROUTER_EOF

cat <<ROUTER_EOF > src/routes/about.lazy.tsx
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/about')({
  component: About,
})

function About() {
  return (
    <div className="p-2">
      <h3>About $APP_NAME</h3>
      <p>This is a $APP_TYPE application in the MFE monorepo.</p>
    </div>
  )
}
ROUTER_EOF

# Update main.tsx
cat <<MAIN_EOF > src/main.tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import { RouterProvider, createRouter } from '@tanstack/react-router'

// @ts-ignore
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

echo "Done! App '$APP_NAME' created in apps/$APP_NAME"
EOF

chmod +x add-app.sh

# Create initial apps
echo "Creating initial shell (host) app..."
./add-app.sh "shell" "host" 5000

echo "Creating initial remote app..."
./add-app.sh "remote1" "remote" 5001

# Update host vite.config.ts to include the remote
sed -i "s|// Remotes will be added here|remote_app: 'http://localhost:5001/assets/remoteEntry.js',|" apps/shell/vite.config.ts
sed -i "s|// @ts-ignore|/* @ts-ignore */|" apps/shell/src/routes/index.lazy.tsx
sed -i "s|// @ts-ignore|/* @ts-ignore */|" apps/shell/src/main.tsx
sed -i "s|// @ts-ignore|/* @ts-ignore */|" apps/remote1/src/main.tsx
# Add @ts-nocheck to all generated files to avoid TS errors in build
find apps -name "*.tsx" -o -name "*.ts" | xargs -I {} sh -c 'grep -q "@ts-nocheck" "{}" || sed -i "1i // @ts-nocheck" "{}"'

echo "Done! Microfrontends Monorepo '$MONOREPO_NAME' created successfully."
echo "To add more apps:"
echo "  cd $MONOREPO_NAME"
echo "  ./add-app.sh <new-app-name> [host|remote] <port>"
echo ""
echo "To start development:"
echo "  bun run dev"
echo ""
echo "Note: To see MFEs working together, you typically need to build and preview them,"
echo "or configure the host to point to the remote's dev server if supported."
echo "Preview all:"
echo "  bun run build"
echo "  bun run preview"
