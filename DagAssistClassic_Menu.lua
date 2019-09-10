------------------------------------------------
--                 DagAssist                  --
--             Dagos of Cenarius              --
------------------------------------------------

-- Not Done
-- Classic got spell ranks

if (not DagAssist) then
  DagAssist = {};
end

function PlayerKnowsSpell(checkSpellId)
  -- Calling GetSpellInfo with the spellID will always return spell information.
  -- Calling GetSpellInfo with the spell name will only return a value if the player knows the spell
  -- By nesting two calls to GetSpellInfo, we can test if the player knows the spellId
  local value = GetSpellInfo(checkSpellId);
  if (value ~= nil) then
    return (GetSpellInfo(value) ~= nil);
  else
    return false;
  end
end

function DagAssist.LoadDefaultMenu()

  local templateMenu = DagAssist.TemplateList;
  local sectionIndex = 1;

  while (sectionIndex <= table.getn(templateMenu)) do
    local sectionData = templateMenu[sectionIndex];
    local actionIndex = 1;

    while (actionIndex <= table.getn(sectionData.Actions)) do
      local actionData = sectionData.Actions[actionIndex];

      if (actionData.DA_ActionType == "spell") then
        if (PlayerKnowsSpell(actionData.DA_ActionData)) then
          actionIndex = actionIndex + 1;
        else
          table.remove(sectionData.Actions, actionIndex);
        end
      else
        actionIndex = actionIndex + 1;
      end
    end

    if (table.getn(sectionData.Actions) > 0) then
      sectionIndex = sectionIndex + 1;
    else
      table.remove(templateMenu, sectionIndex);
    end
  end

  return templateMenu;
end

--------------------------------------------------
-- To find a spell or item ID, use Wowhead.  Look up the item or spell and the check the URL for the ID
-- TelePort:Ironforge = http://www.wowhead.com/?spell=3562
-- ID = 3562
--------------------------------------------------

DagAssist.TemplateList = {
  -----------
  --CLASS ABILITIES--
  -----------
  {
    ["Name"] = "Warrior",
    ["Actions"] = {
      --WARRIOR
    }
  },
  {
    ["Name"] = "Paladin",
    ["Actions"] = {
      --PALADIN
      -- {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "48950"}, --Redemption
      -- {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "25780"}, --Righteous Fury
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "5502"}, --Sense Undead
    }
  },
  {
    ["Name"] = "Seals",
    ["Actions"] = {
      --Seals
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "20165"}, --Seal of Light
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "20166"}, --Seal of Wisdom
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "21084"}, --Seal of Righteousness
      -- {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "31801"}, --Seal of Vengeance
      -- {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "53736"}, --Seal of Corruption
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "20164"}, --Seal of Justice
      -- {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "31892"}, --Seal of Blood
      -- {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "53720"}, --Seal of the Martyr
    }
  },
  --    {
  --    ["Name"] = "Blessings",
  --    ["Actions"] = {
  --Blessings
  --    {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "48932"}, --Blessing of Might
  --    {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "48936"}, --Blessing of Wisdom
  --    {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "58054"}, --Blessing of Kings
  --    {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "20911"}, --Blessing of Sanctuary
  --    {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "48934"}, --Greater Blessing of Might
  --    {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "48938"}, --Greater Blessing of Wisdom
  --    {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "25898"}, --Greater Blessing of Kings
  --    {["DA_ActionType"] = "spell",["DA_ActionSubType"] = "spell",["DA_ActionData"] = "25899"}, --Greater Blessing of Sanctuary
  --    }
  --},
  {
    ["Name"] = "Priest",
    ["Actions"] = {
      --PRIEST
    }
  },
  {
    ["Name"] = "Shaman",
    ["Actions"] = {
      --SHAMAN
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "556"}, --Astral Recall
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "6196"}, --Far Sight
    }
  },
  {
    ["Name"] = "Druid",
    ["Actions"] = {
      --DRUID
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "18960"}, --Teleport: Moonglade
    }
  },
  {
    ["Name"] = "Rogue",
    ["Actions"] = {
      --ROGUE
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "1804"}, --Pick Lock
    }
  },
  {
    ["Name"] = "Teleports",
    ["Actions"] = {
      --MAGE
      --Teleports
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "3565"}, --Teleport: Darnassus
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "3562"}, --Teleport: Ironforge
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "3567"}, --Teleport: Orgrimmar
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "3561"}, --Teleport: Stormwind
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "3566"}, --Teleport: Thunder Bluff
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "3563"}, --Teleport: Undercity
    }
  },
  {
    ["Name"] = "Portals",
    ["Actions"] = {
      --Portals
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "11419"}, --Portal: Darnassus
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "11416"}, --Portal: Ironforge
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "11417"}, --Portal: Orgrimmar
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "10059"}, --Portal: Stormwind
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "11420"}, --Portal: Thunder Bluff
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "11418"}, --Portal: Undercity
    }
  },
  {
    ["Name"] = "Warlock",
    ["Actions"] = {
      --WARLOCK
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "126"}, --Eye of Kilrogg
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "5500"}, --Sense Demons
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "131"}, --Water Breathing
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "132"}, --Detect Invisability
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "5784"}, --Summon Felsteed
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "23161"}, --Summon Dreadsteed

      --Buffs
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "696"}, --Demon Skin
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "706"}, --Demon Armor
    }
  },
  {
    ["Name"] = "Stones",
    ["Actions"] = {
      --Soul shards
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "29893"}, --Ritual of Souls
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "698"}, --Ritual of Summoning
    }
  },
  {
    ["Name"] = "Minons",
    ["Actions"] = {
      --Minions
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "691"}, --Summon Felhunter
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "712"}, --Summon Succubus
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "697"}, --Summon Voidwalker
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "688"}, --Summon Imp
    }
  },
  {
    ["Name"] = "Hunter",
    ["Actions"] = {
      --HUNTER
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "13161"}, --Aspect of the Beast
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "5118"}, --Aspect of the Cheetah
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "13165"}, --Aspect of the Hawk
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "13163"}, --Aspect of the Monkey
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "13159"}, --Aspect of the Pack
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "20043"}, --Aspect of the Wild
    }
  },
  {
    ["Name"] = "Tracking",
    ["Actions"] = {
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "1494"}, --Track Beasts
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "19878"}, --Track Demons
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "19879"}, --Track Dragonkin
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "19880"}, --Track Elementals
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "19882"}, --Track Giants
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "19885"}, --Track Hidden
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "19883"}, --Track Humanoids (maybe redundant, it will be covered by the druid spell?)
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "19884"}, --Track Undead
    }
  },

  -----------
  --RACIALS--
  -----------
  {
    ["Name"] = "Racials",
    ["Actions"] = {

      --DWARF
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "2481"}, --Find Treasure

      --GNOME

      --HUMAN

      --NIGHT ELF

      --ORC

      --TAUREN

      --TROLL

      --UNDEAD
    }
  },

  -----------
  --Professions--
  -----------
  {
    ["Name"] = "Professions",
    ["Actions"] = {
      --ALCHEMY
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "2259"}, --Alchemy

      --BLACKSMITHING
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "2018"}, --Blacksmithing
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "9788"}, --Armorsmithing
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "12794"}, --Master Stormhammer
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "17041"}, --Master Axesmith
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "17040"}, --Master Hammersmith
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "17039"}, --Master Swordsmith

      --COOKING
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "2550"}, --Cooking
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "818"}, --Basic Campfire

      --ENCHANTING
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "7411"}, --Enchanting
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "13262"}, --Disenchant

      --ENGINEERING
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "4036"}, --Engineering

      --FIRST AID
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "3273"}, --First Aid

      --FISHING
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "7620"}, --Fishing

      --HERBALISM
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "2383"}, --Find Herbs

      --LEATHERWORKING
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "2108"}, --Leatherworking

      --MINING
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "2580"}, --Find Minerals
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "2656"}, --Smelting

      --SKINNING

      --TAILORING
      {["DA_ActionType"] = "spell", ["DA_ActionSubType"] = "spell", ["DA_ActionData"] = "3908"}, --Tailoring
    }
  },

  -----------
  --Home--
  -----------
  {
    ["Name"] = "Home",
    ["Actions"] = {
      {["DA_ActionData"] = "6948", ["DA_ActionType"] = "item", ["DA_ActionSubType"] = "|cffffffff|Hitem:6948:0:0:0:0:0:0:0:80:0|h[Hearthstone]|h|r"},
    }
  },

};
