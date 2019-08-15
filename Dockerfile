FROM k8s-master:32084/dotnet/core/runtime:2.2
COPY bin/Release/netcoreapp2.2/ /app/
ENTRYPOINT ["dotnet", "/app/dotnetsample.dll"]