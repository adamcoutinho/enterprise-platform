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
PROJECT_NAME=${1:-"my-app-svelte"}

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
    echo "Error: Directory '$PROJECT_NAME' already exists."
    exit 1
fi

echo "Creating Svelte project: $PROJECT_NAME"

# Create Vite project with Svelte and TypeScript
# Using printf to handle any potential interactive prompts
printf "\n" | bun create vite "$PROJECT_NAME" --template svelte-ts

cd "$PROJECT_NAME" || exit

# Install dependencies
echo "Installing dependencies..."
bun install
# Downgrade to Svelte 4 to ensure compatibility with svelte-routing
# Also pin Vite to version 5 to avoid Rolldown deprecation warnings in Vite 6+
bun add svelte@^4.2.18 @sveltejs/vite-plugin-svelte@^3.0.0 vite@^5.0.0
bun add svelte-routing

# Configure Vite
echo "Configuring Vite..."
# The default vite.config.ts for svelte-ts is usually fine, but we'll ensure it's there
cat <<EOF > vite.config.ts
import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
})
EOF

# Update main.ts for Svelte 4 compatibility
echo "Updating main.ts..."
cat <<EOF > src/main.ts
import './app.css'
import App from './App.svelte'

const app = new App({
  target: document.getElementById('app') || document.getElementById('root')!,
})

export default app
EOF

# Create .env files
echo "Creating .env files..."
cat <<EOF > .env
VITE_API_URL=https://api.example.com
VITE_APP_NAME="$PROJECT_NAME"
EOF

cat <<EOF > .env.example
VITE_API_URL=https://api.example.com
VITE_APP_NAME=My Svelte App
EOF

# Create pages
echo "Creating pages..."
mkdir -p src/pages

cat <<EOF > src/pages/Home.svelte
<script lang="ts">
  const apiUrl = import.meta.env.VITE_API_URL
  const appName = import.meta.env.VITE_APP_NAME
</script>

<div class="page">
  <h1>Bem-vindo ao {appName}!</h1>
  <p>Esta é a página inicial.</p>
  <div class="info">
    <p><strong>App Name:</strong> {appName}</p>
    <p><strong>API URL:</strong> {apiUrl}</p>
  </div>
</div>

<style>
  .page {
    padding: 2rem;
    text-align: center;
  }
  .info {
    margin-top: 1rem;
    padding: 1rem;
    background: #f4f4f4;
    border-radius: 8px;
    display: inline-block;
  }
</style>
EOF

cat <<EOF > src/pages/Login.svelte
<script lang="ts">
  let username = "";
  let password = "";

  function handleLogin() {
    alert(\`Login com: \${username}\`);
  }
</script>

<div class="page">
  <h1>Login</h1>
  <form on:submit|preventDefault={handleLogin}>
    <div class="field">
      <label for="username">Email:</label>
      <input type="text" id="username" placeholder="Enter your email" bind:value={username} />
    </div>
    <div class="field">
      <label for="password">Password:</label>
      <input type="password" id="password" placeholder="Enter your password" bind:value={password} />
    </div>
    <button type="submit">Entrar</button>
  </form>
</div>

<style>
  .page {
    padding: 2rem;
    max-width: 300px;
    margin: 0 auto;
  }
  .field {
    margin-bottom: 1rem;
    text-align: left;
  }
  label {
    display: block;
    margin-bottom: 0.5rem;
  }
  input {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid #ccc;
    border-radius: 4px;
  }
  button {
    width: 100%;
    padding: 0.75rem;
    background: #ff3e00;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
</style>
EOF

# Update App.svelte to show usage of .env and routing
echo "Updating App.svelte..."
cat <<EOF > src/App.svelte
<script lang="ts">
  import { Router, Link, Route } from "svelte-routing";
  import Home from "./pages/Home.svelte";
  import Login from "./pages/Login.svelte";

  export let url = "";
</script>

<Router {url}>
  <nav>
    <Link to="/">Home</Link>
    <Link to="/login">Login</Link>
  </nav>

  <main>
    <Route path="/" component={Home} />
    <Route path="/login" component={Login} />
  </main>
</Router>

<style>
  nav {
    display: flex;
    gap: 1rem;
    padding: 1rem;
    background: #333;
    color: white;
  }
  :global(nav a) {
    color: white;
    text-decoration: none;
  }
  :global(nav a:hover) {
    text-decoration: underline;
  }
  main {
    padding: 1rem;
  }
</style>
EOF

# Clean up default Vite files
rm src/lib/Counter.svelte

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
