# syntax=docker/dockerfile:1

FROM scottyhardy/docker-wine as winetricks

ENV USE_XVFB=yes
ENV XVFB_SERVER=:95
ENV XVFB_SCREEN=0
ENV XVFB_RESOLUTION=320x240x8
ENV DISPLAY=:95
ENV USER_SUDO=no

RUN /usr/bin/entrypoint winetricks --force -q dotnet20
RUN /usr/bin/entrypoint winetricks --force -q dxsdk_jun2010

FROM betterweb/alpine

RUN apk add --no-cache make makedepend jq py3-pip git wine zip
RUN pip install --break-system-packages binary_reader crc
RUN adduser -Ds /bin/sh wineuser

COPY --from=winetricks --chown=wineuser /home/wineuser/.wine/drive_c/windows/system32/d3dcompiler_*.dll /home/wineuser/.wine/drive_c/windows/system32/
COPY --from=winetricks --chown=wineuser ["/home/wineuser/.wine/drive_c/Program Files (x86)/Microsoft DirectX SDK (June 2010)/Utilities/bin/x64/fxc.exe", "/home/wineuser/.wine/drive_c/Program Files (x86)/Microsoft DirectX SDK (June 2010)/Utilities/bin/x64/"]
RUN /usr/local/bin/gosu wineuser /usr/bin/wineboot

COPY fxc /usr/bin/

ENTRYPOINT ["/usr/local/bin/gosu", "wineuser"]
