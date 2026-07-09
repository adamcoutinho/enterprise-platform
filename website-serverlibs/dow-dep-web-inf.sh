#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOML_FILE="$SCRIPT_DIR/versoes.toml"
TARGET_DIR="$SCRIPT_DIR/lib-web-inf"

# Verifica se o arquivo TOML existe
if [ ! -f "$TOML_FILE" ]; then
    echo "Erro: Arquivo de configuração '$TOML_FILE' não foi encontrado!"
    exit 1
fi

echo "Carregando versões do arquivo $TOML_FILE..."

# Lê o arquivo TOML, ignora seções [] e comentários #, e exporta como variáveis do Shell
while IFS='=' read -r key value; do
    # Remove espaços em branco
    key=$(echo "$key" | tr -d '[:space:]')
    value=$(echo "$value" | tr -d '[:space:]' | tr -d '"' | tr -d "'")

    # Ignora linhas vazias, comentários ou definições de seção []
    if [[ -z "$key" || "$key" == \#* || "$key" == \[* ]]; then
        continue
    fi

    # Define a variável dinamicamente no escopo do script
    declare "$key=$value"
done < "$TOML_FILE"


# ==============================================================================
# PROCESSO DE DOWNLOAD
# ==============================================================================

# Cria a pasta de destino se não existir, ou limpa os JARs antigos se já existir
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
else
    rm -rf "$TARGET_DIR"/*.jar
fi

# Função auxiliar para mapear a URL base do Maven Central
download_maven() {
    local path=$1
    local repo="https://repo1.maven.org/maven2"

    # Se for a biblioteca específica da glassfish que usa outra URL, ajustamos o repo
    if [[ "$path" == *"org/glassfish/web"* ]]; then
        repo="https://repo.maven.apache.org/maven2"
    fi

    # O parâmetro -P direciona o download para a pasta informada em TARGET_DIR
    wget -q -P "$TARGET_DIR" "${repo}/${path}"
    echo "DOWNLOAD CONCLUÍDO -> $TARGET_DIR/$path"
}

echo "Iniciando o download dos JARs para a pasta: $TARGET_DIR..."

# 1. JDBC Postgres
download_maven "org/postgresql/postgresql/${V_POSTGRES}/postgresql-${V_POSTGRES}.jar"

# 2. Hibernate e dependências core
download_maven "org/hibernate/orm/hibernate-core/${V_HIBERNATE_CORE}/hibernate-core-${V_HIBERNATE_CORE}.jar"
download_maven "org/hibernate/common/hibernate-commons-annotations/${V_HIBERNATE_COMMONS}/hibernate-commons-annotations-${V_HIBERNATE_COMMONS}.jar"
download_maven "org/jboss/logging/jboss-logging/${V_LOGGING}/jboss-logging-${V_LOGGING}.jar"
download_maven "org/hibernate/validator/hibernate-validator/${V_HIBERNATE_VALIDATOR}/hibernate-validator-${V_HIBERNATE_VALIDATOR}.jar"
download_maven "com/fasterxml/classmate/${V_CLASSMATE}/classmate-${V_CLASSMATE}.jar"
download_maven "io/smallrye/jandex/${V_JANDEX}/jandex-${V_JANDEX}.jar"
download_maven "net/bytebuddy/byte-buddy/${V_BYTE_BUDDY}/byte-buddy-${V_BYTE_BUDDY}.jar"
download_maven "org/antlr/antlr4-runtime/${V_ANTLR}/antlr4-runtime-${V_ANTLR}.jar"

# 3. Pacote Jackson (JSON)
JACKSON_MODULES=(
    "core/jackson-annotations"
    "core/jackson-core"
    "core/jackson-databind"
    "module/jackson-module-kotlin"
    "dataformat/jackson-dataformat-yaml"
    "dataformat/jackson-dataformat-properties"
    "datatype/jackson-datatype-jsr310"
    "datatype/jackson-datatype-jdk8"
)
for mod in "${JACKSON_MODULES[@]}"; do
    name=$(basename "$mod")
    download_maven "com/fasterxml/jackson/${mod}/${V_JACKSON}/${name}-${V_JACKSON}.jar"
done

# 4. Outras bibliotecas gerais e Jakarta
download_maven "org/jetbrains/kotlin/kotlin-reflect/${V_KOTLIN}/kotlin-reflect-${V_KOTLIN}.jar"
download_maven "org/jetbrains/kotlin/kotlin-stdlib/${V_KOTLIN_STDLIB}/kotlin-stdlib-${V_KOTLIN_STDLIB}.jar"
download_maven "org/jetbrains/kotlin/kotlin-stdlib-jdk8/${V_KOTLIN_STDLIB}/kotlin-stdlib-jdk8-${V_KOTLIN_STDLIB}.jar"
download_maven "jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/${V_JSTL_API}/jakarta.servlet.jsp.jstl-api-${V_JSTL_API}.jar"
download_maven "org/glassfish/web/jakarta.servlet.jsp.jstl/${V_JSTL_IMPL}/jakarta.servlet.jsp.jstl-${V_JSTL_IMPL}.jar"
download_maven "jakarta/servlet/jakarta.servlet-api/${V_SERVLET_API}/jakarta.servlet-api-${V_SERVLET_API}.jar"
download_maven "org/apache/commons/commons-lang3/${V_LANG3}/commons-lang3-${V_LANG3}.jar"
download_maven "jakarta/transaction/jakarta.transaction-api/${V_TRANSACTION}/jakarta.transaction-api-${V_TRANSACTION}.jar"
download_maven "jakarta/servlet/jsp/jakarta.servlet.jsp-api/${V_JSP_API}/jakarta.servlet.jsp-api-${V_JSP_API}.jar"
download_maven "jakarta/platform/jakarta.jakartaee-api/${V_JAKARTAEE}/jakarta.jakartaee-api-${V_JAKARTAEE}.jar"
download_maven "commons-logging/commons-logging/${V_COMMONS_LOGGING}/commons-logging-${V_COMMONS_LOGGING}.jar"

# 5. Spring Framework Core e Módulos
SPRING_MODULES=(
    "spring-webmvc" "spring-context" "spring-beans" "spring-web"
    "spring-core" "spring-aop" "spring-context-support"
    "spring-expression" "spring-test" "spring-jdbc" "spring-orm" "spring-tx"
)
download_maven "org/springframework/batch/spring-batch-core/${V_SPRING_BATCH}/spring-batch-core-${V_SPRING_BATCH}.jar"
for mod in "${SPRING_MODULES[@]}"; do
    download_maven "org/springframework/${mod}/${V_SPRING}/${mod}-${V_SPRING}.jar"
done

# 6. Dependências do Spring (Micrometer / JSON)
download_maven "org/eclipse/yasson/${V_YASSON}/yasson-${V_YASSON}.jar"
download_maven "org/eclipse/parsson/parsson/${V_PARSSON}/parsson-${V_PARSSON}.jar"
download_maven "io/micrometer/micrometer-observation/${V_MICROMETER}/micrometer-observation-${V_MICROMETER}.jar"
download_maven "io/micrometer/micrometer-core/${V_MICROMETER}/micrometer-core-${V_MICROMETER}.jar"
download_maven "io/micrometer/micrometer-commons/${V_MICROMETER}/micrometer-commons-${V_MICROMETER}.jar"

# 7. Spring Data
download_maven "org/springframework/data/spring-data-jpa/${V_SPRING_DATA}/spring-data-jpa-${V_SPRING_DATA}.jar"
download_maven "org/springframework/data/spring-data-commons/${V_SPRING_DATA}/spring-data-commons-${V_SPRING_DATA}.jar"

echo "Downloads concluídos com sucesso na pasta $TARGET_DIR!"
