# Mana plugins for Claude Code

This repository is a Claude Code plugin marketplace. It holds two plugins:

- `mana`: the Mana store at https://mcp.mana.scalarmind.com.
- `mana-dev`: the Mana store at https://mcp.mana-dev.scalarmind.com.

Install one of the two. The plugin connects the Mana MCP server. At the start of each session, it gives the agent the Mana storing rules. After 10 prompts of the person, it asks the agent to store its work in Mana before the agent stops, at most twice in a session. It also installs the Mana skills.

The Mana repository generates these files with `scripts/publish-plugin.mjs`. Do not edit them here.

## Install it for yourself

Run these two commands in a Claude Code session:

```text
/plugin marketplace add mathieubrglt/mana-plugins
/plugin install mana@mana-plugins
```

Then run `/mcp`, select the Mana server, and sign in.

## Install it for your organization

An admin adds these keys to the managed settings. Each member then gets the plugin, and a member cannot turn it off.

```json
{
  "extraKnownMarketplaces": {
    "mana-plugins": {
      "source": {
        "source": "github",
        "repo": "mathieubrglt/mana-plugins"
      },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "mana@mana-plugins": true
  }
}
```

The `autoUpdate` key makes Claude Code update this marketplace and its plugins at each startup. So each change pushed to this repository reaches every member, and no one reviews it first. The plugin hooks are shell commands that run with the privileges of the member, outside the sandbox. If your organization reviews each update, remove the `autoUpdate` key. Then a member gets a new version only after a manual update.

## Turn it off

First run `/mcp`, select the Mana server, and clear its authentication, because an uninstall keeps the sign-in. Then run `/plugin uninstall mana@mana-plugins`. When the managed settings require the plugin, only an admin can turn it off, in the managed settings.

## What the checkpoint reads

The checkpoint reads the session transcript on your machine only to count your prompts. It prints nothing from the transcript and sends nothing, so no content leaves the machine. It asks after 10 prompts since the session started or since its last checkpoint, and at most twice in a session. When it cannot read or keep its count, it lets the stop go through.
