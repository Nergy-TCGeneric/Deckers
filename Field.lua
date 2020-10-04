-- A 'Field' is a game session.

local Deck = require "./Deck"
local CardStack = require "./CardStack"
local EventManager = require "./EventManager"
local GenerateUUID = require "./UUIDGenerator"

local _field = {
     id = nil,
     first_user = nil,
     second_user = nil,
     phase = 1,
     biome = nil,
     first_deck = {}, -- A deck is a list of cards
     second_deck = {},
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
     for i=1,self.first_deck:size() do 
          graveyard:push(self.first_deck:get(i))
          self.first_deck:remove(i)
     end
     for i=1,self.second_deck:size() do
          graveyard:push(self.second_deck:get(i))
          self.second_deck:remove(i)
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

function _field:create_instance(first_userdata, second_userdata)
     assert(first_userdata and second_userdata, "One of given userdata is invalid.")
     local inst = setmetatable({}, self)
     self.__index = self
     inst.id = GenerateUUID()
     inst.first_user = get_initial_userstat(first_userdata)
     inst.second_user = get_initial_userstat(second_userdata)
     inst.phase = 0
     inst.biome = nil
     inst.first_deck = Deck:create()
     inst.second_deck = Deck:create()
     inst.graveyard = CardStack:create()
     return inst
end

function _field:spawn_entity(uuid, card)
     assert(uuid and card, "Given uuid or card is invalid")
     local target = nil
     if self.first_user.uuid == uuid then
          target = self.first_deck
     elseif self.second_user.uuid == uuid then
          target = self.second_deck
     else
          error("None of player's uuid could be matched with given uuid")
     end
     target:put(card)
end

function _field:proceed_turn()
     math.randomseed(os.time())
     -- Creating randomized target selection map
     local t1, t2 = {}, {}
     if self.first_deck:size() == 1 then table.insert(t1, 1)
     else for i=0,self.first_deck:size() do table.insert(t1, math.random(1, self.second_deck:size())) end end
     if self.second_deck:size() == 1 then table.insert(t2, 1)
     else for i=0,self.second_deck:size() do table.insert(t2, math.random(1, self.first_deck:size())) end end

     -- Attacking target
     -- TODO: When attacker is dead before even trying to attack, abort it.
     for i, target_idx in ipairs(t1) do
          self.second_deck:get(target_idx).mob.lifepoint = self.second_deck:get(target_idx).mob.lifepoint - self.first_deck:get(i).mob.atk_str
          if self.second_deck:get(target_idx).mob.lifepoint <= 0 then
               EventManager.notify({
                    killer = self.first_deck:get(i),
                    dead = self.second_deck:get(target_idx)
               }, "ENTITY_DEATH")
               self.graveyard:put(self.second_deck:get(target_idx))
               self.second_deck:remove(target_idx)
          end
     end
     for i, target_idx in ipairs(t2) do
          self.first_deck:get(target_idx).mob.lifepoint = self.first_deck:get(target_idx).mob.lifepoint - self.second_deck:get(i).mob.atk_str
          if self.second_deck:get(target_idx).mob.lifepoint <= 0 then
               EventManager.notify({
                    killer = self.second_deck:get(i),
                    dead = self.first_deck:get(target_idx)
               }, "ENTITY_DEATH")
               self.graveyard:put(self.first_deck:get(target_idx))
               self.first_deck:remove(target_idx)
          end
     end

     local isEnded = false
     if self.first_deck:size() == 0 or self.second_deck:size() == 0 then isEnded = true end
     if isEnded then
          if self.first_deck:size() == 0 then first_user.stocks = first_user.stocks - 1 end
          if self.second_deck:size() == 0 then second_user.stocks = second_user.stocks - 1 end
          self.phase = self.phase + 1
          all_cards_to_graveyard()
     end

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
