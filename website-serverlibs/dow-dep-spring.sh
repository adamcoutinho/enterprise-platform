#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOML_FILE="${SCRIPT_DIR}/libs.versions.toml"
TARGET_DIR="$SCRIPT_DIR/libs-spring"

# Verifica se o arquivo TOML existe
if [ ! -f "$TOML_FILE" ]; then
    echo "Erro: Arquivo '$TOML_FILE' não encontrado!"
    exit 1
fi

# Cria a pasta de destino se não existir, ou limpa os JARs antigos se já existir
if [ ! -d "$TARGET_DIR" ]; then
    mkdir "$TARGET_DIR"
else
    rm -rf "$TARGET_DIR"/*.jar
fi

echo "Processando o catálogo de versões..."

# Arrays e Dicionários para mapear as versões em memória (requer Bash 4+)
declare -A VERSIONS
declare -a LIBRARIES

# Estado para saber em qual seção estamos lendo no TOML
SECTION=""

while IFS= read -r line || [[ -n "$line" ]]; do
    # Remove espaços em branco nas pontas e quebras de linha
    line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/\r//')

    # Ignora linhas vazias ou comentários
    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi

    # Detecta mudança de seção []
    if [[ "$line" == "["*"]" ]]; then
        SECTION=$(echo "$line" | tr -d '[]')
        continue
    fi

    # Processa seção [versions]
    if [[ "$SECTION" == "versions" ]]; then
        if [[ "$line" == *"="* ]]; then
            key=$(echo "$line" | cut -d'=' -f1 | sed 's/[[:space:]]*$//')
            val=$(echo "$line" | cut -d'=' -f2 | tr -d '"[:space:]')
            VERSIONS["$key"]="$val"
        fi
    fi

    # Processa seção [libraries]
    if [[ "$SECTION" == "libraries" ]]; then
        if [[ "$line" == *"="* ]]; then
            LIBRARIES+=("$line")
        fi
    fi
done < "$TOML_FILE"


echo "Iniciando os downloads para a pasta: $TARGET_DIR..."

# Função para converter o formato do grupo (org.exemplo) para caminho de pasta (org/exemplo)
group_to_path() {
    echo "$1" | tr '.' '/'
}

# Processa cada biblioteca encontrada
for lib in "${LIBRARIES[@]}"; do
    # Extrai o modulo (ex: org.springframework:spring-context)
    module=$(echo "$lib" | grep -oE 'module[[:space:]]*=[[:space:]]*"[^"]+"' | cut -d'"' -f2)

    if [[ -z "$module" ]]; then
        continue
    fi

    # Divide o modulo em grupo e nome do artefato
    group=$(echo "$module" | cut -d':' -f1)
    artifact=$(echo "$module" | cut -d':' -f2)

    # Descobre a versão (seja por reference ou estática)
    version=""
    if [[ "$lib" == *"version.ref"* ]]; then
        ref_key=$(echo "$lib" | grep -oE 'version\.ref[[:space:]]*=[[:space:]]*"[^"]+"' | cut -d'"' -f2)
        version="${VERSIONS[$ref_key]}"
    elif [[ "$lib" == *"version"* ]]; then
        version=$(echo "$lib" | grep -oE 'version[[:space:]]*=[[:space:]]*"[^"]+"' | cut -d'"' -f2)
    fi

    # Se encontrou todas as informações necessárias, monta a URL do Maven
    if [[ -n "$group" && -n "$artifact" && -n "$version" ]]; then
        group_path=$(group_to_path "$group")

        # Define o repositório correto
        REPO="https://repo1.maven.org/maven2"
        if [[ "$group" == "org.glassfish.web" ]]; then
            REPO="https://repo.maven.apache.org/maven2"
        fi

        URL="${REPO}/${group_path}/${artifact}/${version}/${artifact}-${version}.jar"

        echo "Baixando: ${artifact}-${version}.jar"

        # O parâmetro -P direciona o download para a pasta especificada
        wget -q -P "$TARGET_DIR" "$URL"

        # Valida se o download deu certo
        if [ $? -eq 0 ]; then
            echo " -> Salvo em $TARGET_DIR/"
        else
            echo " -> Erro ao baixar de: $URL"
        fi
    fi
done

echo "Todos os downloads concluídos na pasta $TARGET_DIR!"
