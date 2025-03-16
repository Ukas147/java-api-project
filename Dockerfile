# 1ª Fase: Build da aplicação
FROM eclipse-temurin:17-jdk-alpine AS build

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o Maven Wrapper e o arquivo pom.xml primeiro (para cache de dependências)
COPY .mvn/ .mvn
COPY mvnw .
COPY pom.xml .

# Concede permissão de execução ao Maven Wrapper (caso necessário)
RUN chmod +x mvnw

# Baixa dependências no cache (sem compilar ainda)
RUN ./mvnw dependency:go-offline -B

# Copia o restante do código-fonte
COPY src ./src

# Compila e empacota a aplicação (gera o .jar na pasta target)
RUN ./mvnw package -DskipTests -B

# 2ª Fase: Runtime (container final mais leve)
FROM eclipse-temurin:17-jre-alpine

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o .jar gerado na fase de build
COPY --from=build /app/target/*.jar app.jar

# Expõe a porta do Spring Boot (ajuste se for diferente)
EXPOSE 8080

# Comando para rodar o aplicativo
CMD ["java", "-jar", "app.jar"]