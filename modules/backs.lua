if Cryptid then
	SMODS.Back {
		key = "overflow",
		atlas = 'jimbotomy_decks', pos = { x = 0, y = 0 },
		apply = function (self, back)
	        G.GAME.modifiers.jimbotomy_overflow = true
		end
	}
end

SMODS.Back {
	key = "underflow",
	atlas = 'jimbotomy_decks', pos = { x = 2, y = 0 },
	apply = function (self, back)
        G.GAME.modifiers.jimbotomy_underflow = true
	end,
	config = {
		hands = 3
	}
}

SMODS.Back {
	key = "criminal",
	atlas = 'jimbotomy_decks', pos = { x = 1, y = 0 },
	apply = function (self, back)
        G.GAME.modifiers.jimbotomy_criminal = true
	end
}

function jimbotomy_on_enter_shop_hook()
	G.GAME.modifiers.shop_disabled = false
end

local ORIG_inc_career_stat = inc_career_stat
function inc_career_stat(key, value)
	if key == "c_shop_dollars_spent" and G.GAME.modifiers.jimbotomy_overflow then
		G.GAME.modifiers.shop_disabled = true
	end
	return ORIG_inc_career_stat(key, value)
end

local ORIG_get_blind_amount = get_blind_amount
function get_blind_amount(ante)
	local res = ORIG_get_blind_amount(ante)
	if G.GAME.modifiers.jimbotomy_overflow then
		res = res ^ (ante^2 + 0.5)
	end
	if G.GAME.modifiers.jimbotomy_underflow then
		res = (math.abs(res)) ^ (1 / 1.1)
	end
	return res
end


local Card_set_cost = Card.set_cost
function Card:set_cost()
	if G.GAME.modifiers.jimbotomy_criminal then
		self.cost = 0
		self.sell_cost = 0
		self.extra_cost = 0
		self.sell_cost_label = "0"
		return
	end
	Card_set_cost(self)
end

SMODS.Scoring_Calculation {
    key = "underflow",
    func = function(self, chips, mult, flames) return chips + mult end,
    colour = G.C.BLUE,
    text = "+"
}

SMODS.Scoring_Calculation {
    key = "overflow",
    func = function(self, chips, mult, flames) return chips ^ math.log(math.max(1, mult), 2) end,
    colour = G.C.GREEN,
    text = "^l2"
}

local Blind_set_blind = Blind.set_blind

function Blind:set_blind(...)
	if G.GAME.modifiers.jimbotomy_overflow then
		SMODS.set_scoring_calculation('jimbotomy_overflow')
	end
	if G.GAME.modifiers.jimbotomy_underflow then
		SMODS.set_scoring_calculation('jimbotomy_underflow')
	end
	return Blind_set_blind(self, ...)
end
