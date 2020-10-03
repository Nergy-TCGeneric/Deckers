-- A 'Field' is a game session.

local Deck = require "./Deck"
local CardStack = require "./CardStack"
local GenerateUUID = require "./UUIDGenerator"

local _field = {
     id = nil,
     first_user = nil,
     second_user = nil,
     phase = 0,
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

function _field:create_instance(first_userdata, second_userdata)
     assert(first_userdata and second_userdata, "One of given userdata is invalid.")
     local inst = setmetatable({}, _field)
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

function _field:put_card(uuid, card)
     assert(uuid and card, "Given uuid or card is invalid")
     local target = nil
     if self.first_user.uuid == uuid then
          target = self.first_deck
     elseif self.second_user.uuid == uuid then
          target = self.second_deck
     else
          error("None of player's uuid could be matched with given uuid")
     end
     target[card.type]:insert(card)
end

function _field:proceed_turn()
     math.randomseed(os.time())
     -- Creating randomized target selection map
     t1 = {}; t2 = {}
     for i=0,#self.first_deck do t1:insert(math.random(0, #self.second_deck)) end
     for i=0,#self.second_deck do t2:insert(math.random(0, #self.first_deck)) end

     -- Attacking target
     for i, target_idx in ipairs(t1) do
          self.second_deck[target_idx].mob.lifepoint = self.second_deck[target_idx].mob.lifepoint - self.first_deck[i].mob.atk_str
          if self.second_deck[target_idx].mob.lifepoint <= 0 then
               self.second_deck:remove(target_idx)
               print(target_idx .. " index is terminated")
          end
          -- TODO: If mob's lifepoint went below 0, trigger death event.
     end
     for i, target_idx in ipairs(t2) do
          self.first_deck[target_idx].mob.lifepoint = self.first_deck[target_idx].mob.lifepoint - self.second_deck[i].mob.atk_str
          if self.second_deck[target_idx].mob.lifepoint <= 0 then
               self.second_deck:remove(target_idx)
               print(target_idx .. " index is terminated")
          end
          -- TODO: If mob's lifepoint went below 0, trigger death event.
     end
end

return _field
