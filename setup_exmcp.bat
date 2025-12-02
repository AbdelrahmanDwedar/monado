@echo off
echo ========================================
echo ExMCP Test Server Setup for Cursor
echo ========================================
echo.

set "INSTALL_DIR=C:\Users\Lenovo\Projects\ex-mcp-test"

echo Step 1: Checking if directory exists...
if exist "%INSTALL_DIR%" (
    echo Directory already exists. Pulling latest changes...
    cd /d "%INSTALL_DIR%"
    git pull
) else (
    echo Cloning ExMCP Test Server...
    cd /d C:\Users\Lenovo\Projects
    git clone https://github.com/y86/ex-mcp-test.git
    cd /d "%INSTALL_DIR%"
)
echo.

echo Step 2: Installing dependencies...
call mix deps.get
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    echo Make sure Elixir is installed and in your PATH
    pause
    exit /b 1
)
echo.

echo Step 3: Building release...
call mix release
if errorlevel 1 (
    echo ERROR: Failed to build release
    pause
    exit /b 1
)
echo.

echo Step 4: Updating Cursor configuration...
set "MCP_CONFIG=%USERPROFILE%\.cursor\mcp.json"
set "EXE_PATH=%INSTALL_DIR%\_build\prod\rel\ex_mcp_test\bin\ex_mcp_test.bat"

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo ExMCP Test Server is now installed at:
echo %INSTALL_DIR%
echo.
echo The executable is at:
echo %EXE_PATH%
echo.
echo IMPORTANT: Update your Cursor MCP config at:
echo %MCP_CONFIG%
echo.
echo Change the command path to:
echo "%EXE_PATH%"
echo.
echo Then restart Cursor to use the MCP server.
echo.
pause

