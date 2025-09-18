if Cryptid then
	SMODS.Back {
		key = "overflow",
		atlas = 'jimbotomy_decks', pos = { x = 0, y = 0 },
		apply = function (self, back)
	        G.GAME.modifiers.jimbotomy_overflow = true
			SMODS.set_scoring_calculation('exponent')
		end
	}
end

SMODS.Back {
	key = "underflow",
	atlas = 'jimbotomy_decks', pos = { x = 2, y = 0 },
	apply = function (self, back)
        G.GAME.modifiers.jimbotomy_underflow = true
		SMODS.set_scoring_calculation('jimbotomy_underflow')
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
		res = res ^ ante
	end
	if G.GAME.modifiers.jimbotomy_underflow then
		res = res / 2
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
