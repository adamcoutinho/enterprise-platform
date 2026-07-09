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
PROJECT_NAME=${1:-"my-app-angular"}

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
    echo "Error: Directory '$PROJECT_NAME' already exists."
    exit 1
fi

echo "Creating Angular project: $PROJECT_NAME"

# Create Angular project using Bun
# --defaults uses default options (inline style/template: false, routing: true, etc.)
# --skip-git because we might be inside another git repo
# --package-manager bun to ensure it uses bun for installs
# Using a slightly older version of Angular CLI to match Node.js 22.6.0 if latest requires higher
bun x @angular/cli@19 new "$PROJECT_NAME" --defaults --skip-git --package-manager bun

cd "$PROJECT_NAME" || exit

# Install dependencies (redundant but safe)
echo "Installing dependencies..."
bun install
bun add zone.js

# Add environment variable support (standard Angular way)
echo "Configuring environments..."
bun x ng generate environments

# Create .env files
echo "Creating .env files..."
cat <<EOF > .env
VITE_API_URL=https://api.example.com
VITE_APP_NAME="$PROJECT_NAME"
EOF

cat <<EOF > .env.example
VITE_API_URL=https://api.example.com
VITE_APP_NAME=My Angular App
EOF

# Update environment files to use "process.env" or similar if needed
# But for Angular, we usually just put them in environment.ts
# Since we want to mimic the other scripts, we'll try to use the .env values
# Note: Angular doesn't natively support .env like Vite does without extra config.
# We will use the standard environment.ts for simplicity but mentioned URLs.

cat <<EOF > src/environments/environment.ts
export const environment = {
  production: true,
  apiUrl: 'https://api.example.com',
  appName: '$PROJECT_NAME'
};
EOF

# Also update the development environment
if [ -f src/environments/environment.development.ts ]; then
cat <<EOF > src/environments/environment.development.ts
export const environment = {
  production: false,
  apiUrl: 'https://api.example.com',
  appName: '$PROJECT_NAME'
};
EOF
fi

# Also update the production environment if it exists (older Angular versions)
if [ -f src/environments/environment.prod.ts ]; then
cat <<EOF > src/environments/environment.prod.ts
export const environment = {
  production: true,
  apiUrl: 'https://api.example.com',
  appName: '$PROJECT_NAME'
};
EOF
fi

# Generate Components
echo "Generating components..."
bun x ng generate component pages/home --inline-style --inline-template --skip-tests
bun x ng generate component pages/login --inline-style --inline-template --skip-tests

# Update Home Component
cat <<EOF > src/app/pages/home/home.component.ts
import { Component } from '@angular/core';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [],
  template: \`
    <div style="padding: 2rem; text-align: center;">
      <h1>Bem-vindo ao {{ appName }}!</h1>
      <p>Esta é a página inicial.</p>
      <div style="margin-top: 1rem; padding: 1rem; background: #f4f4f4; border-radius: 8px; display: inline-block;">
        <p><strong>App Name:</strong> {{ appName }}</p>
        <p><strong>API URL:</strong> {{ apiUrl }}</p>
      </div>
    </div>
  \`,
  styles: []
})
export class HomeComponent {
  apiUrl = environment.apiUrl;
  appName = environment.appName;
}
EOF

# Update Login Component
cat <<EOF > src/app/pages/login/login.component.ts
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule],
  template: \`
    <div style="padding: 2rem; max-width: 300px; margin: 0 auto;">
      <h1>Login</h1>
      <form (submit)="handleLogin()">
        <div style="margin-bottom: 1rem; text-align: left;">
          <label for="username" style="display: block; margin-bottom: 0.5rem;">Email:</label>
          <input type="text" id="username" name="username" placeholder="Enter your email" [(ngModel)]="username" style="width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px;">
        </div>
        <div style="margin-bottom: 1rem; text-align: left;">
          <label for="password" style="display: block; margin-bottom: 0.5rem;">Password:</label>
          <input type="password" id="password" name="password" placeholder="Enter your password" [(ngModel)]="password" style="width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px;">
        </div>
        <button type="submit" style="width: 100%; padding: 0.75rem; background: #c3002f; color: white; border: none; border-radius: 4px; cursor: pointer;">Entrar</button>
      </form>
    </div>
  \`,
  styles: []
})
export class LoginComponent {
  username = '';
  password = '';

  handleLogin() {
    alert(\`Login com: \${this.username}\`);
  }
}
EOF

# Update App Routes
echo "Updating routes..."
cat <<EOF > src/app/app.routes.ts
import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home.component';
import { LoginComponent } from './pages/login/login.component';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'login', component: LoginComponent }
];
EOF

# Update App Component Template
cat <<EOF > src/app/app.component.ts
import { Component } from '@angular/core';
import { RouterOutlet, RouterLink } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink],
  template: \`
    <nav style="display: flex; gap: 1rem; padding: 1rem; background: #333; color: white;">
      <a routerLink="/" style="color: white; text-decoration: none;">Home</a>
      <a routerLink="/login" style="color: white; text-decoration: none;">Login</a>
    </nav>
    <main style="padding: 1rem;">
      <router-outlet></router-outlet>
    </main>
  \`,
  styles: []
})
export class AppComponent {
  title = '$PROJECT_NAME';
}
EOF

# Create Dockerfile
echo "Creating Dockerfile..."
cat <<EOF > Dockerfile
# Use Bun image for building
FROM oven/bun:latest AS build
WORKDIR /app

# Install dependencies
COPY package.json bun.lockb ./
RUN bun install

# Copy source and build
COPY . .
RUN bun run build

# Use Nginx to serve the static files
FROM nginx:alpine
# In Angular, the build output is usually in dist/[project-name]/browser
COPY --from=build /app/dist/$PROJECT_NAME/browser /usr/share/nginx/html
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

chmod +x .env .env.example

# Create Taskfile.yml
echo "Creating taskfile.yml..."
cat <<EOF > taskfile.yml
version: '3'

tasks:
  up:
    desc: Start the development server
    cmds:
      - ng serve --configuration development
EOF

echo "Done! Project '$PROJECT_NAME' created successfully."
echo "To start the development server:"
echo "  cd $PROJECT_NAME"
echo "  bun run start"
