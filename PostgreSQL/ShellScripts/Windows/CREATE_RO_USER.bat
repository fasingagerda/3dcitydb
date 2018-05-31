@echo off
:: Shell script to create a read-only user for a specific database schema
:: on PostgreSQL/PostGIS

:: read database connection details  
call CONNECTION_DETAILS.bat

:: add PGBIN to PATH
set PATH=%PGBIN%;%PATH%

:: cd to path of the shell script
cd /d %~dp0

:: Welcome message
echo  _______   ___ _ _        ___  ___
echo ^|__ /   \ / __(_) ^|_ _  _^|   ^\^| _ )
echo  ^|_ \ ^|) ^| (__^| ^|  _^| ^|^| ^| ^|) ^| _ \
echo ^|___/___/ \___^|_^|\__^|\_, ^|___/^|___/
echo                      ^|__/
echo.
echo 3D City Database - The Open Source CityGML Database
echo.
echo ###############################################################################
echo.
echo This script will guide you through the process of setting up a read-only user
echo for a specific 3DCityDB schema. Please follow the instructions of the script.
echo Enter the required parameters when prompted and press ENTER to confirm.
echo Just press ENTER to use the default values.
echo.
echo Documentation and help:
echo    3DCityDB website:    https://www.3dcitydb.org
echo    3DCityDB on GitHub:  https://github.com/3dcitydb
echo.
echo Having problems or need support?
echo    Please file an issue here:
echo    https://github.com/3dcitydb/3dcitydb/issues
echo.
echo ###############################################################################

:: cd to path of the SQL scripts
cd ..\..\SQLScripts\UTIL\RO_USER

:: Prompt for USERNAME --------------------------------------------------------
:username
set var=
echo.
echo Please enter a username for the read-only user.
set /p var="(USERNAME must not be empty): "

if /i not "%var%"=="" (
  set USERNAME=%var%
) else (
  echo.
  echo Illegal input! USERNAME must not be empty.
  goto username
)

:: Prompt for PASSWORD --------------------------------------------------------
:password
set var=
echo.
echo Please enter a password for the read-only user.
set /p var="(PASSWORD must not be empty): "

if /i not "%var%"=="" (
  set PASSWORD=%var%
) else (
  echo.
  echo Illegal input! PASSWORD must not be empty.
  goto password
)

:: List the existing 3DCityDB schemas -----------------------------------------
echo.
echo Reading existing 3DCityDB schemas from the database "%PGUSER%@%PGHOST%:%PGPORT%/%CITYDB%" ...
"%PGBIN%\psql" -d "%CITYDB%" -f "..\SCHEMAS\QUERY_SCHEMA.sql"

if errorlevel 1 (
  echo Failed to read 3DCityDB schemas from database.
  pause
  exit /b %errorlevel%
)

:: Prompt for schema name -----------------------------------------------------
set var=
set SCHEMA_NAME=citydb
echo Please enter the name of the 3DCityDB schema "%USERNAME%" shall have access to.
set /p var="(default SCHEMA_NAME=%SCHEMA_NAME%): "
if /i not "%var%"=="" set SCHEMA_NAME=%var%

:: Run CREATE_RO_USER.sql to create a read-only user for a specific schema ----
echo.
echo Connecting to the database "%PGUSER%@%PGHOST%:%PGPORT%/%CITYDB%" ...
"%PGBIN%\psql" -d "%CITYDB%" -f "CREATE_RO_USER.sql" -v username="%USERNAME%" -v password="%PASSWORD%" -v schema_name="%SCHEMA_NAME%"

pause