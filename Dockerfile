FROM mcr.microsoft.com/dotnet/core/runtime:2.2
COPY bin/Release/netcoreapp2.2/ /app/
ENTRYPOINT ["dotnet", "/app/dotnetsample.dll"]