# Local MCP Server Setup for Monado

This guide sets up the ExMCP Test Server locally in your project with cross-platform support.

## Quick Setup

### On Windows:
```bash
setup_local_mcp.bat
```

### On Linux/Mac:
```bash
chmod +x setup_local_mcp.sh
./setup_local_mcp.sh
```

## Manual Setup

If the scripts don't work, follow these steps:

```bash
# 1. Clone ExMCP Test Server into your project
git clone https://github.com/y86/ex-mcp-test.git

# 2. Install dependencies
cd ex-mcp-test
mix deps.get
mix compile

# 3. Go back to project root
cd ..
```

## Cursor Configuration

### Option 1: Use Cursor Settings (Recommended)

1. Open Cursor Settings (Ctrl/Cmd + ,)
2. Search for "MCP"
3. Click "Edit in settings.json"
4. Add this configuration:

```json
{
	"mcpServers": {
		"ex-mcp-test": {
			"command": "elixir",
			"args": [
				"--no-halt",
				"-S",
				"mix",
				"run"
			],
			"cwd": "${workspaceFolder}/ex-mcp-test"
		}
	}
}
```

### Option 2: Create Local .cursor Directory

If Cursor supports local MCP configs (check Cursor docs):

```bash
# Create .cursor directory manually
mkdir .cursor

# Copy the configuration
# On Windows:
copy .cursor-mcp.json .cursor\mcp.json

# On Linux/Mac:
cp .cursor-mcp.json .cursor/mcp.json
```

## Why This Configuration is Cross-Platform

✅ **Uses relative paths**: `${workspaceFolder}/ex-mcp-test` works on both Windows and Linux

✅ **Uses elixir command**: Works anywhere Elixir is installed

✅ **No hardcoded paths**: The `cwd` (current working directory) is relative to your workspace

✅ **Standard Mix commands**: `mix run --no-halt` is the Elixir standard

## How It Works

When Cursor starts, it will:
1. Look for the MCP server configuration
2. Change directory to `ex-mcp-test/` (relative to your project)
3. Run `elixir --no-halt -S mix run`
4. Connect to the MCP server via JSON-RPC

## Testing the Server Manually

To verify the server works:

```bash
cd ex-mcp-test
mix run --no-halt
```

You should see the server start. Press Ctrl+C twice to exit.

## What This Provides

The ExMCP Test Server adds these capabilities to Cursor:

- **prompts/list** - List available prompts
- **resources/list** - List available resources  
- **tools/list** - List available tools
- **tools/call** - Execute tools

This enhances Cursor's understanding of your Elixir project!

## Troubleshooting

### Server doesn't start
- Make sure Elixir is installed: `elixir --version`
- Check dependencies are installed: `cd ex-mcp-test && mix deps.get`
- Try running manually to see errors: `cd ex-mcp-test && mix run --no-halt`

### Cursor doesn't detect the server
- Restart Cursor completely
- Check if Cursor supports local MCP configs (may need to use global config)
- Verify the JSON syntax in your configuration

### Path issues on Windows
- Make sure you're using forward slashes `/` in the config, not backslashes `\`
- The `${workspaceFolder}` variable should be automatically expanded by Cursor

## Alternative: Global Configuration

If local configuration doesn't work, you can add it globally:

1. Open `~/.cursor/mcp.json` (or `C:\Users\YourName\.cursor\mcp.json` on Windows)
2. Add:

```json
{
	"mcpServers": {
		"ex-mcp-test-monado": {
			"command": "elixir",
			"args": [
				"--no-halt",
				"-S",
				"mix",
				"run"
			],
			"cwd": "C:/Users/Lenovo/Projects/monado/ex-mcp-test"
		}
	}
}
```

Note: Use forward slashes even on Windows for the absolute path.

## Removing the MCP Server

To remove:
1. Delete the `ex-mcp-test/` directory
2. Remove the MCP configuration from Cursor settings
3. Restart Cursor

## References

- [ExMCP Test Server on MCP Servers](https://mcpservers.org/servers/y86/ex-mcp-test)
- Model Context Protocol: https://modelcontextprotocol.io/

