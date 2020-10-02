-- A 'Field' is a game session.

local Deck = require "./Deck"

local _field = {
     first_user = nil,
     second_user = nil,
     phase = 0,
     first_deck = {}, -- A deck is a list of cards
     second_deck = {}
}

local function get_initial_userstat(user_data)
     return {
          uuid = user_data.uuid,
          stocks = 2,
          available_cards = user_data.selected_deck
     }
end

function _field:create_instance(first_userdata, second_userdata)
     assert(first_userdata and second_userdata, "One of given userdata is invalid.")
     inst = setmetatable({}, _field)
     inst.__index = self
     inst["first_user"] = get_initial_userstat(first_userdata)
     inst["second_user"] = get_initial_userstat(second_userdata)
     inst["phase"] = 0
     inst["first_deck"] = Deck:create()
     inst["second_deck"] = Deck:create()
     return inst
end

function _field:proceed_turn()
     -- First, apply priority between cards
     -- Card priority should be applied like this order: SPECIAL > MAGIC > EQUIPMENT = MOB = BIOME
     for _, specials in ipairs(self["first_deck"]["SPECIAL"]) do
          specials.act()
     end
     for _, specials in ipairs(self["second_deck"]["SPECIAL"]) do
          specials.act()
     end

     math.randomseed(os.time())
     -- Creating randomized target selection map
     t1 = {}; t2 = {}
     for i=0,#self.first_deck do t1:insert(math.random(0, #self.second_deck)) end
     for i=0,#self.second_deck do t2:insert(math.random(0, #self.first_deck)) end

     -- Attacking target
     for i, target_idx in ipairs(t1) do
          self.second_deck[target_idx].health = self.second_deck[target_idx].health - self.first_deck[i].atk_str
     end
     for i, target_idx in ipairs(t2) do
          self.first_deck[target_idx].health = self.first_deck[target_idx].health - self.second_deck[i].atk_str
     end
end

return _field
