#!/bin/bash

# Script para gerar um projeto React TypeScript sem dependência da pasta webapp
# Requisitos: 
# 1 - Reaproveitar todos os arquivos inclusive o package.json
# 2 - Adicionar possibilidade (Flexibilidade de nome do projeto)
# 3 - Adicionar .env
# 4 - Remover tailwind deixando somente css
# 5 - Adicionar página de variáveis de ambiente

# Nome do projeto a partir do argumento ou padrão
PROJECT_NAME=${1:-"my-app-react"}

# Verifica se o diretório de destino já existe
if [ -d "$PROJECT_NAME" ]; then
    echo "Erro: O diretório '$PROJECT_NAME' já existe."
    exit 1
fi

echo "Criando novo projeto React TypeScript: $PROJECT_NAME"

# Cria o diretório do projeto e subdiretórios
mkdir -p "$PROJECT_NAME/src/components"
mkdir -p "$PROJECT_NAME/src/routes"
mkdir -p "$PROJECT_NAME/public"

# 1 - Gerar arquivos base

echo "Gerando package.json..."
cat <<EOF > "$PROJECT_NAME/package.json"
{
  "name": "$PROJECT_NAME",
  "private": true,
  "type": "module",
  "imports": {
    "#/*": "./src/*"
  },
  "scripts": {
    "dev": "vite dev --port 3000",
    "generate-routes": "tsr generate",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest run"
  },
  "dependencies": {
    "@tanstack/react-devtools": "latest",
    "@tanstack/react-router": "latest",
    "@tanstack/react-router-devtools": "latest",
    "@tanstack/react-router-ssr-query": "latest",
    "@tanstack/react-start": "latest",
    "@tanstack/router-plugin": "^1.132.0",
    "lucide-react": "^0.545.0",
    "react": "^19.2.0",
    "react-dom": "^19.2.0"
  },
  "devDependencies": {
    "@tanstack/devtools-vite": "latest",
    "@tanstack/router-cli": "^1.132.0",
    "@testing-library/dom": "^10.4.1",
    "@testing-library/react": "^16.3.0",
    "@types/node": "^22.10.2",
    "@types/react": "^19.2.0",
    "@types/react-dom": "^19.2.0",
    "@vitejs/plugin-react": "^6.0.1",
    "jsdom": "^28.1.0",
    "typescript": "^6.0.2",
    "vite": "^8.0.0",
    "vitest": "^4.1.5"
  },
  "pnpm": {
    "onlyBuiltDependencies": [
      "esbuild",
      "lightningcss"
    ]
  }
}
EOF

echo "Gerando tsconfig.json..."
cat <<EOF > "$PROJECT_NAME/tsconfig.json"
{
  "include": ["**/*.ts", "**/*.tsx"],
  "compilerOptions": {
    "target": "ES2022",
    "jsx": "react-jsx",
    "module": "ESNext",
    "paths": {
      "#/*": ["./src/*"],
      "@/*": ["./src/*"]
    },
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "types": ["vite/client"],

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "verbatimModuleSyntax": true,
    "noEmit": true,

    /* Linting */
    "skipLibCheck": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedSideEffectImports": true
  }
}
EOF

echo "Gerando vite.config.ts..."
cat <<EOF > "$PROJECT_NAME/vite.config.ts"
import { defineConfig } from 'vite'
import { devtools } from '@tanstack/devtools-vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

const config = defineConfig({
  resolve: { tsconfigPaths: true },
  plugins: [devtools(), tanstackStart(), viteReact()],
})

export default config
EOF

echo "Gerando tsr.config.json..."
cat <<EOF > "$PROJECT_NAME/tsr.config.json"
{
  "target": "react"
}
EOF

# 2 - Gerar arquivos src

echo "Gerando src/router.tsx..."
cat <<EOF > "$PROJECT_NAME/src/router.tsx"
import { createRouter as createTanStackRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

export function getRouter() {
  const router = createTanStackRouter({
    routeTree,
    scrollRestoration: true,
    defaultPreload: 'intent',
    defaultPreloadStaleTime: 0,
  })

  return router
}

declare module '@tanstack/react-router' {
  interface Register {
    router: ReturnType<typeof getRouter>
  }
}
EOF

echo "Gerando src/styles.css..."
cat <<'EOF' > "$PROJECT_NAME/src/styles.css"
@import url("https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,700&family=Manrope:wght@400;500;600;700;800&display=swap");

:root {
  --font-sans: "Manrope", ui-sans-serif, system-ui, sans-serif;
  --sea-ink: #173a40;
  --sea-ink-soft: #416166;
  --lagoon: #4fb8b2;
  --lagoon-deep: #328f97;
  --palm: #2f6a4a;
  --sand: #e7f0e8;
  --foam: #f3faf5;
  --surface: rgba(255, 255, 255, 0.74);
  --surface-strong: rgba(255, 255, 255, 0.9);
  --line: rgba(23, 58, 64, 0.14);
  --inset-glint: rgba(255, 255, 255, 0.82);
  --kicker: rgba(47, 106, 74, 0.9);
  --bg-base: #e7f3ec;
  --header-bg: rgba(251, 255, 248, 0.84);
  --chip-bg: rgba(255, 255, 255, 0.8);
  --chip-line: rgba(47, 106, 74, 0.18);
  --link-bg-hover: rgba(255, 255, 255, 0.9);
  --hero-a: rgba(79, 184, 178, 0.36);
  --hero-b: rgba(47, 106, 74, 0.2);
}

:root[data-theme="dark"] {
  --sea-ink: #d7ece8;
  --sea-ink-soft: #afcdc8;
  --lagoon: #60d7cf;
  --lagoon-deep: #8de5db;
  --palm: #6ec89a;
  --sand: #0f1a1e;
  --foam: #101d22;
  --surface: rgba(16, 30, 34, 0.8);
  --surface-strong: rgba(15, 27, 31, 0.92);
  --line: rgba(141, 229, 219, 0.18);
  --inset-glint: rgba(194, 247, 238, 0.14);
  --kicker: #b8efe5;
  --bg-base: #0a1418;
  --header-bg: rgba(10, 20, 24, 0.8);
  --chip-bg: rgba(13, 28, 32, 0.9);
  --chip-line: rgba(141, 229, 219, 0.24);
  --link-bg-hover: rgba(24, 44, 49, 0.8);
  --hero-a: rgba(96, 215, 207, 0.18);
  --hero-b: rgba(110, 200, 154, 0.12);
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  color: var(--sea-ink);
  font-family: var(--font-sans);
  background-color: var(--bg-base);
  background:
    radial-gradient(1100px 620px at -8% -10%, var(--hero-a), transparent 58%),
    radial-gradient(1050px 620px at 112% -12%, var(--hero-b), transparent 62%),
    radial-gradient(720px 380px at 50% 115%, rgba(79, 184, 178, 0.1), transparent 68%),
    linear-gradient(180deg, color-mix(in oklab, var(--sand) 68%, white) 0%, var(--foam) 44%, var(--bg-base) 100%);
  overflow-x: hidden;
  -webkit-font-smoothing: antialiased;
}

.page-wrap {
  width: min(1080px, calc(100% - 2rem));
  margin-inline: auto;
}

.display-title {
  font-family: "Fraunces", Georgia, serif;
}

.island-shell {
  border: 1px solid var(--line);
  background: linear-gradient(165deg, var(--surface-strong), var(--surface));
  box-shadow: 0 1px 0 var(--inset-glint) inset, 0 22px 44px rgba(30, 90, 72, 0.1), 0 6px 18px rgba(23, 58, 64, 0.08);
  backdrop-filter: blur(4px);
}

.island-kicker {
  letter-spacing: 0.16em;
  text-transform: uppercase;
  font-weight: 700;
  font-size: 0.69rem;
  color: var(--kicker);
}

.rise-in {
  animation: rise-in 700ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

@keyframes rise-in {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Header Styles */
.site-header {
  position: sticky;
  top: 0;
  z-index: 50;
  border-bottom: 1px solid var(--line);
  background: var(--header-bg);
  padding: 0 1rem;
  backdrop-filter: blur(8px);
}

.nav-container {
  max-width: 1080px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 0;
}

.nav-logo .logo-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  font-weight: 700;
  color: var(--sea-ink);
}

.logo-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: linear-gradient(90deg, var(--lagoon), #7ed3bf);
}

.nav-links {
  display: flex;
  gap: 1.5rem;
  align-items: center;
}

.nav-link {
  position: relative;
  text-decoration: none;
  color: var(--sea-ink-soft);
  font-weight: 600;
  font-size: 0.9rem;
}

.nav-link.is-active {
  color: var(--sea-ink);
}

.nav-link::after {
  content: "";
  position: absolute;
  left: 0;
  bottom: -4px;
  width: 100%;
  height: 2px;
  transform: scaleX(0);
  background: linear-gradient(90deg, var(--lagoon), #7ed3bf);
  transition: transform 170ms ease;
}

.nav-link.is-active::after {
  transform: scaleX(1);
}

/* Env Page Styles */
.demo-page {
  padding-block: 4rem;
}
.demo-panel {
  border-radius: 1.25rem;
  padding: 2rem;
  background: var(--surface-strong);
  border: 1px solid var(--line);
}
.demo-title { margin: 0; font-size: 2rem; font-weight: 800; }
.demo-muted { color: var(--sea-ink-soft); }
.demo-table-shell { margin-top: 2rem; overflow-x: auto; border: 1px solid var(--line); border-radius: 1rem; }
.demo-table { width: 100%; border-collapse: collapse; }
.demo-table th, .demo-table td { padding: 0.75rem 1rem; text-align: left; border-bottom: 1px solid var(--line); }
.demo-table th { background: var(--chip-bg); font-weight: 700; }
EOF

echo "Gerando src/routes/__root.tsx..."
cat <<'EOF' > "$PROJECT_NAME/src/routes/__root.tsx"
import { HeadContent, Scripts, Outlet, createRootRoute } from '@tanstack/react-router'
import { TanStackRouterDevtoolsPanel } from '@tanstack/react-router-devtools'
import { TanStackDevtools } from '@tanstack/react-devtools'
import Header from '../components/Header'
import appCss from '../styles.css?url'

const THEME_INIT_SCRIPT = `(function(){try{var stored=window.localStorage.getItem('theme');var mode=(stored==='light'||stored==='dark'||stored==='auto')?stored:'auto';var prefersDark=window.matchMedia('(prefers-color-scheme: dark)').matches;var resolved=mode==='auto'?(prefersDark?'dark':'light'):mode;var root=document.documentElement;root.classList.remove('light','dark');root.classList.add(resolved);if(mode==='auto'){root.removeAttribute('data-theme')}else{root.setAttribute('data-theme',mode)}root.style.colorScheme=resolved;}catch(e){}})();`

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { title: 'React App' },
    ],
    links: [
      { rel: 'stylesheet', href: appCss },
    ],
  }),
  component: RootComponent,
})

function RootComponent() {
  return (
    <html lang="en">
      <head>
        <script dangerouslySetInnerHTML={{ __html: THEME_INIT_SCRIPT }} />
        <HeadContent />
      </head>
      <body>
        <Header />
        <Outlet />
        <TanStackDevtools
          config={{ position: 'bottom-right' }}
          plugins={[
            {
              name: 'Tanstack Router',
              render: <TanStackRouterDevtoolsPanel />,
            },
          ]}
        />
        <Scripts />
      </body>
    </html>
  )
}
EOF

echo "Gerando src/routes/index.tsx..."
cat <<'EOF' > "$PROJECT_NAME/src/routes/index.tsx"
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({ component: App })

function App() {
  return (
    <main className="page-wrap" style={{ paddingBlock: '4rem' }}>
      <section className="island-shell rise-in" style={{ borderRadius: '2rem', padding: '3rem', position: 'relative', overflow: 'hidden' }}>
        <p className="island-kicker">React Template</p>
        <h1 className="display-title" style={{ fontSize: '3rem', marginBlock: '1rem' }}>
          Start simple, ship quickly.
        </h1>
        <p style={{ color: 'var(--sea-ink-soft)', fontSize: '1.2rem', maxWidth: '600px' }}>
          This base starter intentionally keeps things light: clean structure, and the essentials you need to build from scratch.
        </p>
      </section>
    </main>
  )
}
EOF

echo "Gerando src/routes/about.tsx..."
cat <<'EOF' > "$PROJECT_NAME/src/routes/about.tsx"
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/about')({
  component: About,
})

function About() {
  return (
    <main className="page-wrap" style={{ paddingBlock: '4rem' }}>
      <section className="island-shell" style={{ borderRadius: '2rem', padding: '3rem' }}>
        <p className="island-kicker">About</p>
        <h1 className="display-title" style={{ fontSize: '3rem' }}>
          A small starter with room to grow.
        </h1>
      </section>
    </main>
  )
}
EOF

echo "Gerando src/routes/env.tsx..."
cat <<'EOF' > "$PROJECT_NAME/src/routes/env.tsx"
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/env')({
  component: EnvComponent,
})

function EnvComponent() {
  const envVars = Object.entries(import.meta.env).filter(([key]) => 
    key.startsWith('VITE_') || ['MODE', 'DEV', 'PROD', 'SSR'].includes(key)
  )

  return (
    <div className="page-wrap demo-page">
      <div className="demo-panel">
        <h2 className="demo-title">Variáveis de Ambiente</h2>
        <p className="demo-muted">Lista das variáveis acessíveis via import.meta.env</p>
        
        <div className="demo-table-shell">
          <table className="demo-table">
            <thead>
              <tr>
                <th>Chave</th>
                <th>Valor</th>
              </tr>
            </thead>
            <tbody>
              {envVars.map(([key, value]) => (
                <tr key={key}>
                  <td><code>{key}</code></td>
                  <td>{String(value)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
EOF

echo "Gerando src/components/Header.tsx..."
cat <<'EOF' > "$PROJECT_NAME/src/components/Header.tsx"
import { Link } from '@tanstack/react-router'

export default function Header() {
  return (
    <header className="site-header">
      <nav className="nav-container">
        <div className="nav-logo">
          <Link to="/" className="logo-link">
            <span className="logo-dot" />
            React App
          </Link>
        </div>

        <div className="nav-links">
          <Link to="/" className="nav-link" activeProps={{ className: 'is-active' }}>
            Home
          </Link>
          <Link to="/about" className="nav-link" activeProps={{ className: 'is-active' }}>
            About
          </Link>
          <Link to="/env" className="nav-link" activeProps={{ className: 'is-active' }}>
            Env
          </Link>
        </div>
      </nav>
    </header>
  )
}
EOF

# 3 - Adicionar .env
echo "Criando arquivo .env..."
cat <<EOF > "$PROJECT_NAME/.env"
VITE_APP_NAME=$PROJECT_NAME
VITE_API_URL=http://localhost:3000
NODE_ENV=development
EOF

cat <<EOF > "$PROJECT_NAME/.env.example"
VITE_APP_NAME=App Name
VITE_API_URL=http://localhost:3000
NODE_ENV=development
EOF

# 6 - Adicionar Dockerfile
echo "Gerando Dockerfile..."
cat <<EOF > "$PROJECT_NAME/Dockerfile"
# Estágio de construção
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

# Estágio de produção
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

echo "Gerando .dockerignore..."
cat <<EOF > "$PROJECT_NAME/.dockerignore"
node_modules
dist
.env
.git
Dockerfile
EOF

echo "Gerando taskfile.yml..."
cat <<EOF > "$PROJECT_NAME/taskfile.yml"
version: '3'

tasks:
  build:
    desc: Build the docker image
    cmds:
      - docker build -t $PROJECT_NAME .

  run:
    desc: Run the container
    cmds:
      - docker run -p 8080:80 $PROJECT_NAME

  stop:
    desc: Stop the container
    cmds:
      - docker stop \$(docker ps -q --filter ancestor=$PROJECT_NAME)
EOF

echo "--------------------------------------------------"
echo "Projeto '$PROJECT_NAME' criado com sucesso!"
echo "--------------------------------------------------"
echo "Para iniciar:"
echo "  cd $PROJECT_NAME"
echo "  bun install  # ou npm install / yarn"
echo "  bun run dev  # ou npm run dev / yarn dev"
echo "--------------------------------------------------"
