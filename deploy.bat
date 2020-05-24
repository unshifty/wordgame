set VERSION=0.1.4

IF "%1"=="build" GOTO build
IF "%1"=="push" GOTO push
GOTO :EOF

:build
docker build -t docker.pkg.github.com/okadoke/wordgame/wordgames:%VERSION% .
GOTO :EOF

:push
docker push docker.pkg.github.com/okadoke/wordgame/wordgames:%VERSION%
GOTO :EOF