-- A 'Field' is a game session.

local TileData = require "./TileData"
local CardStack = require "./CardStack"
local EventManager = require "./EventManager"
local GenerateUUID = require "./UUIDGenerator"

local _field = {
     id = nil,
     first_user = nil,
     second_user = nil,
     phase = 1,
     biome = nil,
     tiles = {},
     graveyard = {} -- Stack of lastly used cards, maximum 10 cards
}

-- TODO: Load these values from global config.yml
local function get_initial_userstat(user_data)
     return {
          uuid = user_data.uuid,
          stocks = 2,
          available_cards = user_data.selected_deck,
          manas = 10,
          actions = 2
     }
end

local function all_cards_to_graveyard()
     for _, tile in pairs(self.tiles:list()) do
          graveyard.push(tile.entity)
     end
end

local function is_game_ended()
     local ctx = { 
          ended = false,
          winner = {}
     }
     if self.first_user.stocks <= 0 then
          ctx.ended = true
          table.insert(ctx.winner, second_user) end
     if self.second_user.stocks <= 0 then
          ctx.ended = true
          table.insert(ctx.winner, first_user) end
     if #ctx.winner > 2 then ctx.winner = {} end
     return ctx
end

-- Remind that 'Commander' requires only two players
local function set_entity_target(entity)
     math.randomseed(os.time())
     for uuid, entities in tiles:entities() do
          if uuid ~= entity.handler_uuid then
               if #entities == 1 then entity.target = entities[1]
               else entity.target = entities[math.random(#entities)] end
               break 
          end
     end
end

local function calculate_pathway(from, to, length) -- returns sequence of {dx, dy} with given 'length'
     assert(length > 0, "Length must be greater than 0")
     local pathway = {}
     local total = {dx = to.x - from.x, dy = to.y - from.y}
     math.randomseed(os.time())
     for i=0,math.min(math.abs(total.dx)+math.abs(total.dy), length) do
          local t, idx = {0, 0}, math.random(2)
          if total[idx] > 0 then
               t[idx] = total[idx] / math.abs(total[idx])
               total[idx] = total[idx] - (total[idx] / math.abs(total[idx]))
          else
               if idx == 1 then
                    t[2] = total[2] / math.abs(total[2])
                    total[2] = total[2] - (total[2] / math.abs(total[2]))
               elseif idx == 2 then 
                    t[1] = total[1] / math.abs(total[1])
                    total[1] = total[1] - (total[1] / math.abs(total[1]))
               end
          end
          table.insert(pathway, t)
     end
     return pathway
end

-- Attack first, Move if cannot.
local function battle_loop()
     for _, tile in pairs(tiles.list()) do set_entity_target(tile.entity) end
     while true do
          for _, tile in pairs(tiles.list()) do
               local L1, L2 = self.tiles:get_entity_location(tile.entity), self.tile:get_entity_location(tile.entity.target)
               if self.tiles:distance(L1, L2) <= tile.entity.atk_range then
                    tile.entity.target.lifepoint = tile.entity.target.lifepoint - (tile.entity.atk_str - tile.entity.target.defense)
                    if tile.entity.target.lifepoint <= 0 then
                         EventManager.notify({
                              killer = tile.entity,
                              dead = tile.entity.target,
                              field = self
                         }, "ENTITY_DEATH")
                         self.tiles:remove_entity(tile.entity.target)
                         self.graveyard:push(tile.entity.target)
                         tile.entity.target = set_entity_target(tile.entity)
                    end
               else
                    path = calculate_pathway(L1, L2, tile.entity.move_range)
                    for _, p in ipairs(path) do self.tiles:move_to_relatively(tile.entity, p) end
               end
          end
          for _, v in pairs(self.tiles:entities()) do
               if #v == 0 then return
          end
     end
end

function _field:create_instance(first_userdata, second_userdata)
     assert(first_userdata and second_userdata, "One of given userdata is invalid.")
     local inst = setmetatable({}, self)
     self.__index = self
     inst.id = GenerateUUID()
     inst.first_user = get_initial_userstat(first_userdata)
     inst.second_user = get_initial_userstat(second_userdata)
     inst.phase = 0
     inst.biome = nil
     inst.tiles = TileData:create(8)
     inst.graveyard = CardStack:create()
     return inst
end

function _field:spawn_entity(card, loc)
     assert(card and loc, "Given loc or card is invalid")
     card.mob.handler_uuid = card.handler_uuid
     self.tiles:spawn_entity(card.mob, loc)
end

function _field:proceed_turn()
     battle_loop()
     all_cards_to_graveyard()
     local entities = self.tiles:entities()
     for uuid, v in pairs(entities) do
          local target = nil
          if uuid == first_user.uuid then target = first_user
          elseif uuid == second_user.uuid then target = second_user end
          if #v == 0 then target.stocks = target.stocks - 1 end
     end
     self.tiles:clear()

     local ctx = is_game_ended()
     if ctx.ended then
          EventManager.notify({
               winner = ctx.winner
          }, "GAME_END")
          return
     end
     
     EventManager.notify({
          phase = self.phase
     }, "PHASE_START")
end

return _field
