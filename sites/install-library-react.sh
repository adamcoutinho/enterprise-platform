#!/bin/bash

set -e

PROJECT_NAME=${1:-my-ui-library}

echo "🚀 Criando biblioteca: $PROJECT_NAME"


# ==================================
# Criar projeto Vite
# ==================================

npm create vite@latest $PROJECT_NAME \
-- --template react-ts


cd $PROJECT_NAME


# ==================================
# Dependências
# ==================================

echo "📦 Instalando dependências..."

npm install


npm install -D \
vite-plugin-dts \
storybook \
@storybook/react-vite \
vitest \
@testing-library/react \
@testing-library/jest-dom


# ==================================
# Storybook
# ==================================

echo "📚 Configurando Storybook..."

npx storybook@latest init --yes


# ==================================
# Estrutura
# ==================================

echo "📁 Criando estrutura..."

mkdir -p src/components/Button
mkdir -p src/tokens
mkdir -p src/styles


# ==================================
# Limpeza
# ==================================

rm -rf src/assets
rm -f src/App.tsx
rm -f src/App.css


# ==================================
# Button
# ==================================

cat > src/components/Button/Button.types.ts <<EOF

export interface ButtonProps {

  children: React.ReactNode;

  variant?:
    | "primary"
    | "secondary";

  disabled?: boolean;

}

EOF



cat > src/components/Button/Button.tsx <<EOF

import styles from "./Button.module.css";

import type {
 ButtonProps
} from "./Button.types";


export function Button({

children,
variant="primary",
disabled=false

}:ButtonProps){


return (

<button
className={
\`\${styles.button} \${styles[variant]}\`
}
disabled={disabled}
>

{children}

</button>

)

}

EOF



cat > src/components/Button/Button.module.css <<EOF

.button{

padding:8px 16px;
border-radius:8px;
border:none;
font-weight:600;
cursor:pointer;

}


.primary{

background:#2563eb;
color:white;

}


.secondary{

background:#e5e7eb;
color:#111827;

}

EOF



cat > src/components/Button/index.ts <<EOF

export {
 Button
} from "./Button";


export type {
 ButtonProps
} from "./Button.types";

EOF



# ==================================
# Tokens
# ==================================

cat > src/tokens/colors.ts <<EOF

export const colors={

primary:{
500:"#2563eb",
600:"#1d4ed8"
},

gray:{
100:"#f3f4f6",
900:"#111827"
}

}

EOF



cat > src/tokens/spacing.ts <<EOF

export const spacing={

none:0,
xs:4,
sm:8,
md:16,
lg:24,
xl:32,
xxl:48

}

EOF



# ==================================
# Entry Library
# ==================================

cat > src/index.ts <<EOF

export * from "./components/Button";

export * from "./tokens/colors";
export * from "./tokens/spacing";

EOF



# ==================================
# Vite Config
# ==================================

cat > vite.config.ts <<EOF

import { defineConfig } from "vite";
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

name:"$PROJECT_NAME",

formats:[
"es",
"umd"
],

fileName:"$PROJECT_NAME"

},


rollupOptions:{

external:[
"react",
"react-dom"
]

}


}

})

EOF



# ==================================
# Package JSON adjustments
# ==================================

node <<EOF

const fs=require("fs");

const pkg=require("./package.json");


pkg.name="@company/$PROJECT_NAME";

pkg.main="./dist/$PROJECT_NAME.umd.js";

pkg.module="./dist/$PROJECT_NAME.js";

pkg.types="./dist/index.d.ts";


pkg.scripts={
...pkg.scripts,

build:"vite build",

test:"vitest"

};


fs.writeFileSync(
"package.json",
JSON.stringify(pkg,null,2)
);

EOF



# ==================================
# Story Button
# ==================================

mkdir -p src/components/Button


cat > src/components/Button/Button.stories.tsx <<EOF

import type { Meta, StoryObj } from "@storybook/react";

import { Button } from "./Button";


const meta:Meta<typeof Button>={

title:"Components/Button",

component:Button

};


export default meta;


type Story =
StoryObj<typeof Button>;


export const Primary:Story={

args:{

children:"Salvar",

variant:"primary"

}

};


export const Secondary:Story={

args:{

children:"Cancelar",

variant:"secondary"

}

};

EOF



echo ""
echo "✅ Biblioteca criada!"
echo ""
echo "Próximos passos:"
echo ""
echo "cd $PROJECT_NAME"
echo "npm run storybook"
echo "npm run build"
echo ""
