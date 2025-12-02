@echo off
REM Cross-platform setup script for ExMCP Test Server (Windows version)

echo ==========================================
echo ExMCP Test Server Local Setup
echo ==========================================
echo.

set "PROJECT_DIR=%~dp0"
set "MCP_DIR=%PROJECT_DIR%ex-mcp-test"

echo Project directory: %PROJECT_DIR%
echo.

REM Step 1: Clone or update ex-mcp-test
if exist "%MCP_DIR%" (
    echo [32m√[0m ex-mcp-test directory exists, pulling latest changes...
    cd /d "%MCP_DIR%"
    git pull
) else (
    echo → Cloning ExMCP Test Server...
    cd /d "%PROJECT_DIR%"
    git clone https://github.com/y86/ex-mcp-test.git
    cd /d "%MCP_DIR%"
)
echo.

REM Step 2: Install dependencies
echo → Installing dependencies...
call mix deps.get
if errorlevel 1 (
    echo [31mERROR: Failed to install dependencies[0m
    echo Make sure Elixir is installed and in your PATH
    pause
    exit /b 1
)
echo.

REM Step 3: Compile the project
echo → Compiling project...
call mix compile
if errorlevel 1 (
    echo [31mERROR: Failed to compile[0m
    pause
    exit /b 1
)
echo.

echo ==========================================
echo [32m√ Setup Complete![0m
echo ==========================================
echo.
echo The MCP server is configured to run with:
echo   Command: elixir --no-halt -S mix run
echo   Working Directory: ./ex-mcp-test
echo.
echo This configuration works on both Windows and Linux!
echo.
echo Next steps:
echo   1. Restart Cursor/VSCode
echo   2. The ex-mcp-test server will start automatically
echo.
echo To test manually:
echo   cd ex-mcp-test ^&^& mix run --no-halt
echo.
pause

