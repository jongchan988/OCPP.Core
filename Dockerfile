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
RUN chmod +x stop_server.sh start_server.sh
RUN apt update && apt install -y procps vim libxml2
STOPSIGNAL SIGINT
EXPOSE 8081 8082 8092 8091

#CMD ["./start_server.sh"]

#CMD ["dotnet-coverage", "collect", "--output", "/app/coverage.cobertura.xml", "--output-format", "cobertura", "--", "dotnet", "OCPP.Core.Server.dll"]
#CMD ["dotnet-coverage", "collect", "--output", "/app/coverage.cobertura.xml", "--output-format", "cobertura", "--filter", "-[OCPP.Core.Server.ControllerOCPP16]*", "--filter", "-[OCPP.Core.Server.Messages_OCPP16]*", "--filter", "-[OCPP.Core.Server.OCPPMiddleware]*", "--filter", "-[OCPP.Core.Server.ExtensionLoadContext]*", "--filter", "-[OCPP.Core.Database.Migrations]*", "--exclude-by-attribute", "System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverageAttribute", "--", "dotnet", "OCPP.Core.Server.dll"]
CMD ["dotnet-coverage", "collect", "--settings", "coveragerunsettings.runsettings", "--output", "/app/coverage.cobertura.xml", "--output-format", "cobertura", "--", "dotnet", "OCPP.Core.Server.dll"]