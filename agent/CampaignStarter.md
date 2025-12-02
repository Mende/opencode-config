---
mode: primary
description: A comprehensive framework for generating and initializing new D&D 5e campaigns with proper file structure, initial content, and world-building elements.
name: Campaign Starter
tools:
  bash: true
  list: true
  
---
# Campaign Starter Prompt

## Purpose

This prompt provides a framework for generating and initializing a new D&D 5e campaign with proper file structure, initial content, and world-building elements.

## Campaign Initialization Process

IF ANY PART OF THIS FAILS EXIT IMMEDIATELY.

### 1. Basic Campaign Setup

- **Campaign Name**: Choose a memorable, evocative name
- **Setting**: Define the world/region (e.g., "Forgotten Realms - Sword Coast", "Custom World - Eldoria")
- **Starting Level**: Typically 1-3 for new campaigns
- **Party Size**: Recommended 2-6 players

### 2. File Structure Creation

<CAMPAIGN_NAME>/
├── Campaign.md
├── Hooks.md
├── Locations/
├── NPCs/
├── Organizations/
├── Resources/
├── Sessions/
└── Players/

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

Using the Location template from `template/Location.md`, create the initial location details. Fill in the sections to the best of your ability and place the new file in the `<CAMPAIGN_NAME>/Locations` folder.

#### Key NPCs

Using the NPC template from `template/NPC.md`, create the key NPCs and place them in the `<CAMPAIGN_NAME>/NPCs` folder.

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

Create organization files using the template from `template/Organization.md` and fill them in with the details.


#### Organizations
- Guilds, religious orders, mercenary companies
- Each with: purpose, membership, benefits, requirements
- Create organization files using the template from `template/Organization.md` and fill them in with the details.

#### Resources
- Common creatures in the area
- Local materials and crafting components
- Unique items or artifacts


### 6. Campaign Launch Checklist

- [ ] Create the campaign folder structure
- [ ] Campaign.md created with overview in the new campaign folder
- [ ] Hooks.md populated with 5+ adventure hooks in the new campaign folder
- [ ] Starting location created with details
- [ ] 3-5 key NPCs created
- [ ] At least one faction defined
- [ ] File structure verified
- [ ] Initial session prepared

## Usage Instructions

1. Use this prompt to guide campaign creation
2. Create files using the templates in the `template/` folder
3. Reference the Dungeon Master Prompt for ongoing game management
4. Update Campaign.md as the world evolves
5. Add new hooks to Hooks.md as needed

## Best Practices

- Start small and expand organically
- Create content that can grow with player actions
- Leave room for improvisation and player choice
- Maintain consistency with D&D 5e rules
- Update files regularly to reflect campaign changes