-- A 'Field' is a game session.

local TileData = require "./TileData"
local CardStack = require "./CardStack"
local Deck = require "./Deck"
local BiomeType = require "./BiomeType"
local EventManager = require "./EventManager"
local GenerateUUID = require "./UUIDGenerator"

local _field = {}

--[[
     Field has following these properties:
     1. id : A unique identifier of field.
     2. users : List of players.
     3. phase : equivalent to 'turn'.
     4. biome : indicates which this field's biome is.
     5. tiles : instance of TileData.
     6. graveyard : instance of CardStack.
     7. active_cards : instance of Deck.
]]

-- TODO: Load these values from global config.yml
local function get_initial_userstat(user_data)
     return {
          stocks = 2,
          available_cards = user_data.selected_deck,
          manas = 10,
          actions = 2
     }
end

local function all_cards_to_graveyard(field)
     for _, deck in pairs(field.active_cards:get_decks()) do
          for __, card in ipairs(deck) do
               field.graveyard:push(card)
          end
     end
     field.active_cards:clear()
end

local function is_game_ended(field)
     local ctx = { 
          ended = false,
          lose = {}
     }
     for uuid, stat in pairs(field.users) do
          if stat.stocks <= 0 then
               ctx.ended = true
               table.insert(ctx.lose, uuid)
          end
     end
     return ctx
end

local function set_entity_target(field, entity)
     math.randomseed(os.time())
     local opponent = field.active_cards:get_opponent_deck(entity.handler_uuid)
     if #opponent == 0 then return
     elseif #opponent == 1 then entity.target = opponent[1].mob
     else entity.target = opponent[math.random(#opponent)].mob end
end

local function calculate_pathway(from, to, length) -- returns sequence of {dx, dy} with given 'length'
     assert(length > 0, "Length must be greater than 0")
     local pathway = {}
     local total = {[-1]= to.x - from.x, [1]= to.y - from.y}
     math.randomseed(os.time())
     for i=1,math.min(math.abs(total[-1])+math.abs(total[1]), length) do
          local t, idx = {[-1] = 0, [1] = 0}, (math.random(2) - 2 >= 0) and -1 or 1
          if total[-1] == 0 and total[1] == 0 then break end
          if total[idx] == 0 then idx = -1 * idx end
          t[idx] = total[idx] / math.abs(total[idx])
          total[idx] = total[idx] - t[idx]
          table.insert(pathway, {x = t[-1], y=t[1]})
     end
     return pathway
end

local function attack_entity(attacker, victim, field)
     assert(attacker and victim, "Attacker or victim is missing")
     if victim.behavior == "NEUTRAL" then victim.behavior = "HOSTILE" end
     victim.lifepoint = victim.lifepoint - (attacker.atk_str - victim.defense)
     if victim.lifepoint <= 0 then
          EventManager.notify({
               killer = attacker,
               victim = victim,
               field = field
          }, "ENTITY_DEATH")
          field.tiles:remove_entity(victim)
          local card = field.active_cards:get_by_entity(victim)
          field.graveyard:push(card)
          field.active_cards:remove_by_card(card)
          attacker.target = set_entity_target(field, attacker)
     end
end

-- Attack first, Move if cannot.
local function battle_loop(field)
     for _, tile in pairs(field.tiles:list()) do set_entity_target(field, tile.entity) end
     while not field.active_cards:get_empty_deck_owner() do
          for _, tile in pairs(field.tiles:list()) do
               local L1, L2 = field.tiles:get_entity_location(tile.entity), field.tiles:get_entity_location(tile.entity.target)
               if field.tiles:distance(L1, L2) <= tile.entity.atk_range and tile.entity.behavior == "HOSTILE" then
                    attack_entity(tile.entity, tile.entity.target, field)
               else
                    path = calculate_pathway(L1, L2, tile.entity.move_range)
                    for _, p in ipairs(path) do field.tiles:move_to_relatively(tile.entity, p) end
               end
          end
     end
end

function _field:create_instance(first_userdata, second_userdata)
     assert(first_userdata and second_userdata, "One of given userdata is invalid.")
     local inst = setmetatable({}, self)
     self.__index = self
     inst.id = GenerateUUID()
     inst.users = {}
     inst.users[first_userdata.uuid] = get_initial_userstat(first_userdata)
     inst.users[second_userdata.uuid] = get_initial_userstat(second_userdata)
     inst.phase = 0
     inst.biome = BiomeType.plains
     inst.tiles = TileData:create(8)
     inst.graveyard = CardStack:create()
     inst.active_cards = Deck:create()
     return inst
end

function _field:spawn_entity(card, loc)
     assert(card and loc, "Given loc or card is invalid")
     assert(card.type == "MOB", "spawn_entity() only accepts mob type cards")
     if card.type ~= "MOB" then return end
     card.mob.handler_uuid = card.handler_uuid
     self.tiles:spawn_entity(card.mob, loc)
     self.active_cards:put(card)
end

function _field:apply_card(card, loc)
     assert(card and loc, "Given loc or card is invalid")
     assert(card.type ~= "MOB", "apply_card() only accepts non-mob type cards")
     local target = self.tiles:get_entity_at(loc)
     card:act(self, target, card.handler_uuid)
     EventManager.notify({
          card = card,
          invoker = card.handler_uuid,
          field = self
     }, "CARD_DRAW")
     self.graveyard:push(card)
end

function _field:proceed_turn()
     battle_loop(self)
     local target = self.users[self.active_cards:get_empty_deck_owner()]
     target.stocks = target.stocks - 1
     self.tiles:clear()
     all_cards_to_graveyard(self)

     local ctx = is_game_ended(self)
     if ctx.ended then
          EventManager.notify({
               lose = ctx.lose
          }, "GAME_END")
          return
     end
     
     EventManager.notify({
          phase = self.phase
     }, "PHASE_START")
     
     self.biome = BiomeType.plains
end

return _field