# ACT Recommendations for Alex ACT Visual Storytelling

## Your Brain

Edition v0.9.9 is installed with the v1 brain (33 instructions, 16 skills, 20 prompts, 3 worker agents).

## First Steps

1. **Fill in your identity**: Edit `.github/copilot-instructions.local.md` with your project context, domain vocabulary, preferences, and constraints. This is heir-owned and survives Edition upgrades.
2. **Browse the Plugin Mall**: Run `/mall search <keyword>` to find plugins relevant to your project.
3. **Install a plugin**: Run `/mall install <name>` to add capabilities from the Mall.

## Recommended Plugins

Based on your project structure:

| Plugin | Category | Why |
| --- | --- | --- |
| `data-analysis` | data-analytics | Data exploration and analysis patterns |
| `data-visualization` | data-analytics | Chart and dashboard design |

## Commands to Try

```text
/mall search data
/convert to word
/meditate
```

## Upgrade

To pull future Edition releases:

```bash
node .github/scripts/upgrade-self.cjs --apply
```
