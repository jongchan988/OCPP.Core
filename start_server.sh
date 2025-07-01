#!/bin/bash
dotnet-coverage collect \
  --output /app/coverage.cobertura.xml \
  --output-format cobertura \
  -- dotnet OCPP.Core.Server.dll  > server.log 2>&1 &
sleep 1
tail -f server.log