#!/bin/bash

set -e


PROJECT_NAME=${1:-frontend-platform}


echo "🚀 Criando monorepo: $PROJECT_NAME"


# ======================================
# Criar estrutura
# ======================================

mkdir $PROJECT_NAME

cd $PROJECT_NAME


mkdir -p apps
mkdir -p packages



# ======================================
# Root package.json
# ======================================

cat > package.json <<EOF
{
  "name": "$PROJECT_NAME",
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "test": "turbo test",
    "storybook": "pnpm --filter @platform/ui storybook"
  },
  "devDependencies": {
    "turbo": "latest"
  },
  "packageManager": "pnpm@latest"
}
EOF



# ======================================
# pnpm workspace
# ======================================

cat > pnpm-workspace.yaml <<EOF
packages:

  - apps/*

  - packages/*
EOF



# ======================================
# Turbo config
# ======================================

cat > turbo.json <<EOF
{
  "\$schema": "https://turbo.build/schema.json",

  "tasks": {

    "build": {

      "dependsOn":[
        "^build"
      ],

      "outputs":[
        "dist/**"
      ]

    },


    "dev":{

      "cache":false

    },


    "test":{}

  }

}
EOF



# ======================================
# Criar app React
# ======================================

echo "⚛️ Criando aplicação React"


pnpm create vite apps/web \
--template react-ts



# ======================================
# Criar biblioteca UI
# ======================================

echo "🎨 Criando biblioteca UI"


mkdir -p packages/ui


cd packages/ui


pnpm init



cat > package.json <<EOF
{
"name":"@platform/ui",

"version":"0.0.1",

"private":true,


"type":"module",


"scripts":{

"build":"vite build",

"storybook":"storybook dev -p 6006",

"storybook:build":"storybook build"

},


"dependencies":{

"react":"^19.0.0",
"react-dom":"^19.0.0"

},


"devDependencies":{

"vite":"latest",

"@vitejs/plugin-react":"latest",

"typescript":"latest",

"vite-plugin-dts":"latest",

"storybook":"latest",

"@storybook/react-vite":"latest"

}

}
EOF



mkdir src


mkdir -p src/components/Button
mkdir -p src/tokens



# ======================================
# Vite Library
# ======================================

cat > vite.config.ts <<EOF

import {defineConfig} from "vite";

import react from "@vitejs/plugin-react";

import dts from "vite-plugin-dts";


export default defineConfig({

plugins:[

react(),

dts({
insertTypesEntry:true
})

],


build:{


lib:{


entry:"src/index.ts",

formats:[
"es"
],


fileName:"index"


},


rollupOptions:{


external:[
"react",
"react-dom"
]


}


}


});

EOF



# ======================================
# Button
# ======================================


cat > src/components/Button/Button.tsx <<EOF

import "./button.css";


export function Button(){

return (

<button className="button">

Button

</button>

)

}

EOF



cat > src/components/Button/button.css <<EOF

.button{

padding:8px 16px;

border-radius:8px;

border:none;

background:#2563eb;

color:white;

}

EOF



cat > src/components/Button/index.ts <<EOF

export {
Button
} from "./Button";

EOF



# ======================================
# Tokens
# ======================================

cat > src/tokens/index.ts <<EOF

export const colors={

primary:"#2563eb",

danger:"#dc2626"

};


EOF



# ======================================
# Entry
# ======================================

cat > src/index.ts <<EOF

export * from "./components/Button";

export * from "./tokens";

EOF



cd ../../



# ======================================
# Instalar dependências
# ======================================

echo "📦 Instalando dependências"


pnpm install



# ======================================
# Inicializar Storybook
# ======================================

cd packages/ui


pnpm dlx storybook@latest init --yes



cd ../../



echo ""
echo "===================================="
echo "✅ Monorepo criado!"
echo "===================================="
echo ""

echo "Estrutura:"
echo ""

tree -L 3


echo ""
echo "Comandos:"
echo ""

echo "pnpm dev"
echo "pnpm build"
echo "pnpm storybook"
