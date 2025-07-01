FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# 테스트 커버리지 도구 설치
RUN dotnet tool install --global dotnet-coverage
ENV PATH="$PATH:/root/.dotnet/tools"

COPY . .
RUN dotnet restore
RUN dotnet build -c Release
RUN dotnet publish -c Release -o /out

# ------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS runtime
WORKDIR /app

RUN dotnet tool install --global dotnet-coverage
ENV PATH="$PATH:/root/.dotnet/tools"

COPY --from=build /out ./
COPY start_server.sh ./
COPY stop_server.sh ./
RUN apt update && apt install -y procps vim libxml2
STOPSIGNAL SIGINT
EXPOSE 8081 8082 8092 8091

CMD ["./start_server.sh"]

#CMD ["dotnet-coverage", "collect", "--output", "/app/coverage.json", "--output-format", "json", "--", "dotnet", "OCPP.Core.Server.dll"]