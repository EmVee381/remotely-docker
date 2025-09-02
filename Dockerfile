FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

RUN apt update && apt upgrade && apt install -y nodejs

WORKDIR /

RUN git clone --branch develop --single-branch --depth 1 https://github.com/EmVee381/Remotely.git src

WORKDIR /src

WORKDIR Server

RUN dotnet restore

# Build and publish a release
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:9.0
COPY --from=build /app /app
ENV APP_UID=1654 ASPNETCORE_HTTP_PORTS=8080 DOTNET_RUNNING_IN_CONTAINER=true
RUN apt update && apt install -y --no-install-recommends ca-certificates libc6 libgcc-s1 libicu72 libssl3 libstdc++6 tzdata zlib1g curl && rm -rf /var/lib/apt/lists/*
EXPOSE ${ASPNETCORE_HTTP_PORTS}
WORKDIR /app
ENTRYPOINT ["dotnet", "Remotely_Server.dll"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 CMD curl -f http://localhost:${ASPNETCORE_HTTP_PORTS}/api/healthcheck || exit 1

