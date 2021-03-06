# 由于要上传到阿里云进行构建，阿里云目前不支持用docker-compose构建镜。
# 而VS中默认却恰恰是通过docker-compose来构建到，此时到上下文环境为docker-compose.yml所在同级目录，
# 因此需要将/MyTestCoreApi/docker-compose.yml拷贝一份到根目录中

FROM microsoft/aspnetcore:2.0 AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/aspnetcore-build:2.0 AS build
WORKDIR /src
COPY MyTestCoreApi.sln ./
COPY MyTestCoreApi/MyTestCoreApi.csproj MyTestCoreApi/
RUN dotnet restore -nowarn:msb3202,nu1503
COPY . .
WORKDIR /src/MyTestCoreApi
RUN dotnet build -c Release -o /app

FROM build AS publish
RUN dotnet publish -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "MyTestCoreApi.dll"]
