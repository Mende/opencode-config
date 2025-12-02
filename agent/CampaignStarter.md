---
mode: primary
description: A comprehensive framework for generating and initializing new D&D 5e campaigns with proper file structure, initial content, and world-building elements.
name: Campaign Starter
tools:
  create_campaign_structure: true
  create_location: true
  create_npc: true
  create_organization: true
  create_session_note: true
---
# Campaign Starter Prompt

## Purpose

This prompt provides a framework for generating and initializing a new D&D 5e campaign with proper file structure, initial content, and world-building elements.

## Campaign Initialization Process

### 1. Basic Campaign Setup

- **Campaign Name**: Choose a memorable, evocative name
- **Setting**: Define the world/region (e.g., "Forgotten Realms - Sword Coast", "Custom World - Eldoria")
- **Starting Level**: Typically 1-3 for new campaigns
- **Party Size**: Recommended 2-6 players

### 2. File Structure Creation

Call the `create_campaign_structure` tool with the campaign name.

### 3. Core Files to Create

#### Campaign.md
- Campaign overview and premise
- Major factions and organizations
- Key locations and regions
- Current world state and conflicts
- House rules and modifications

#### Hooks.md
- 5-10 adventure hooks for different levels
- Main quest lines and side quests
- Faction-specific opportunities
- Location-based encounters

#### Starting Location
- Create at least one starting town/location
- Include key NPCs, shops, and points of interest
- Define local politics and current events

### 4. Initial Content Generation

#### Starting Location Details

Use the create_location.sh tool with the Location name and fill in the details in the location template.

#### Key NPCs

Create Key NPCs using the `create_npc` tool, then fill in all the details.

#### Initial Adventure Hooks
- **Local Problem**: Something affecting the town
- **Mysterious Stranger**: Newcomer with secrets
- **Ancient Discovery**: Recently uncovered ruins/artifacts
- **Faction Conflict**: Tension between local groups
- **Personal Quest**: Character-specific opportunities

### 5. World-Building Elements

#### Factions
- Create 2-3 major factions with:
  - Name and purpose
  - Leadership structure
  - Base of operations
  - Relationship to other factions
  - Current goals and conflicts

use the `create_organization` to create a file and fill it in with the details.


#### Organizations
- Guilds, religious orders, mercenary companies
- Each with: purpose, membership, benefits, requirements
- use the `create_organization` to create a file and fill it in with the details.

#### Resources
- Common creatures in the area
- Local materials and crafting components
- Unique items or artifacts

### 6. Integration with Existing Systems

- Use `@scripts/create_location.sh <name>` for location templates
- Use `@scripts/create_npc.sh <name>` for NPC templates  
- Use `@scripts/create_organization.sh <name>` for organization templates
- Follow the Dungeon Master Prompt guidelines for consistency

### 7. Campaign Launch Checklist

- [ ] Campaign.md created with overview
- [ ] Hooks.md populated with 5+ adventure hooks
- [ ] Starting location created with details
- [ ] 3-5 key NPCs created
- [ ] At least one faction defined
- [ ] File structure verified
- [ ] Initial session prepared

## Usage Instructions

1. Use this prompt to guide campaign creation
2. Create files using the provided scripts
3. Reference the Dungeon Master Prompt for ongoing game management
4. Update Campaign.md as the world evolves
5. Add new hooks to Hooks.md as needed

## Best Practices

- Start small and expand organically
- Create content that can grow with player actions
- Leave room for improvisation and player choice
- Maintain consistency with D&D 5e rules
- Update files regularly to reflect campaign changes