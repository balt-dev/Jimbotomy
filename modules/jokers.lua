local function is_prime(num)
    if cmp(num, 1) <= 0 then
        return false
    end
    if cmp(num, 2) == 0 then
        return true
    end
    if cmp(num % 2, 0) == 0 then
        return false
    end
    local i = 3
    while cmp(i * i, num) <= 0 do
        if cmp(num % i, 0) == 0 then
            return false
        end
        i = i + 2
    end
    return true
end

local last_score = 0
local nerd_joker_active = false

SMODS.Joker {
    key = "nerd_joker",
    discovered = true,
    atlas = 'jimbotomyJokers', pos = { x = 2, y = 0 },
    config = {
        extra = {
            xmult = 2,
            chips = 1,
            chip_limit = 1000000000, -- 1 billion
            active = false
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.chips,
                card.ability.extra.chip_limit
            }
        }
    end,
    calculate = function(self, card, context)
        if not context.joker_main then return end
        if nerd_joker_active or context.forcetrigger then
            return {
                xmult = card.ability.extra.xmult,
                chips = card.ability.extra.chips
            }
        end
        return {}
    end,
    update = function(self, card, dt)
        if not G.GAME then return end
        if last_score ~= G.GAME.chips then
            last_score = G.GAME.chips
            nerd_joker_active = cmp(last_score, card.ability.extra.chip_limit) < 0 and is_prime(math.floor(last_score))
        end
        if nerd_joker_active and not card.ability.extra.juicing then
            card.ability.extra.juicing = true
            juice_card_until(card, function()
                if not nerd_joker_active then
                    card.ability.extra.juicing = false
                    return false
                end
                return true
            end, true)
        end
    end,
    demicoloncompat = true
    -- implementing jokerdisplay for this would require pre-computing the hand
}


SMODS.Joker {
    atlas = 'jimbotomyJokers', pos = { x = 1, y = 0 },
    pixel_size = { w = 48, h = 95 },
    key = "domino",
    discovered = true,
    rarity = 3,
    calculate = function(self, card, context)
        if not context.joker_main then return end
        return {
			swap = true, -- smods has a method for this
            message = localize("k_jimbotomy_swapped"),
            colour = G.C.GOLD,
            sound = "jimbotomy_swap",
            chips = 0,
            remove_default_message = true
        }
    end,
    demicoloncompat = true
}

SMODS.Joker {
    rarity = 3,
    key = "roll_the_dice",
    discovered = true,
    atlas = 'jimbotomyJokers', pos = { x = 3, y = 0 },
    config = {
        extra = {
            xmult = 1,
            chance = 5,
            total_chance = 6,
            multiplier = 1.25
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_oops
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.chance,
                card.ability.extra.total_chance,
                card.ability.extra.multiplier,
                G.localization.descriptions.Joker.j_oops.name
            }
        }
    end,
    eternal_compat = false,
    calculate = function(self, card, context)
        if context.selling_self or context.forcetrigger then
            if context.forcetrigger then self:start_dissolve() end
            local random_seed = (G.GAME and G.GAME.pseudorandom.seed or "") .. "." .. "jimbotomy_roll_the_dice"
            local rand = pseudorandom(random_seed)
            local success = cmp(rand * card.ability.extra.chance, card.ability.extra.multiplier) >= 0
            if success then
                local copy = copy_card(card)
                copy.ability.extra.xmult = copy.ability.extra.xmult * card.ability.extra.multiplier
                copy:add_to_deck()
                G.jokers:emplace(copy)
                return {
                    message = localize('k_copied_ex'),
                    colour = G.C.BLUE,
                }
            else
                play_sound('tarot2', 1, 0.4)
                G.E_MANAGER:add_event(
                    Event({
                        trigger = 'after',
                        delay = 0.06 * G.SETTINGS.GAMESPEED,
                        blockable = false,
                        blocking = false,
                        func = function()
                            play_sound('tarot2', 0.76, 0.4)
                            return true
                        end
                    })
                )
                return {
                    message = localize('k_nope_ex'),
                    colour = G.C.RED,
                }
            end
        end
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end,
    update = function(self, card, dt)
        card.sell_cost = 0
    end,
    demicoloncompat = true,
	joker_display_def = function(JokerDisplay)
		---@type JDJokerDefinition
		return {
			text = {
				{
					border_nodes = {
						{ text = "X" },
						{ ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp"}
					}
				}
			}
		}
	end
}

local function expire_joker(card, key, sound, color)
    card_eval_status_text(card, 'extra', nil, nil, nil, { sound = sound, message = localize(key), colour = color })
    card:juice_up(0.3, 0.4)
    G.E_MANAGER:add_event(
        Event({
            trigger = 'after',
            delay = 0.2,
            blockable = false,
            func = function()
                card.T.r = -0.2
                card.states.drag.is = true
                card.children.center.pinch.x = true
                return true;
            end
        })
    )
    G.E_MANAGER:add_event(
        Event({
            trigger = 'after',
            delay = 0.6,
            blockable = false,
            func = function()
                G.jokers:remove_card(card)
                card:remove()
                return true;
            end
        })
    )
end

SMODS.Joker {
    discovered = true,
    rarity = 2,
    key = "hourglass",
    discovered = true,
    atlas = 'jimbotomyJokers', pos = { x = 1, y = 1 },
    config = {
        extra = {
            mult = 30
        }
    },
	--[[dependencies = {
		items = { -- attempt at disabling if Cryptid's "Timer Mechanics" toggle is disabled, but apparently it's not that simple. :(
			"set_cry_timer" 
		},
	},]]
    loc_vars = function(self, info_queue, card)
        card.ability.extra.sanitized_mult = sanitize(card.ability.extra.mult)
        return {
            main_start = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", minh = 0.3 },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = "+",
                                colour = G.C.RED,
                                scale = 0.32,
                            }
                        },
                        {
                            n = G.UIT.T,
                            config = {
                                ref_table = card.ability.extra,
                                ref_value = "sanitized_mult",
                                colour = G.C.RED,
                                scale = 0.32,
                            }
                        },
                        {
                            n = G.UIT.T,
                            config = {
                                text = " " .. localize("k_mult"),
                                colour = G.C.BLACK,
                                scale = 0.32,
                            }
                        }
                    },
                }
            }
        }
    end,
    calculate = function(self, card, context)
        if (context.forcetrigger or context.joker_main) and not card.ability.extra.done then
            return {
                mult = card.ability.extra.mult,
                message = "+" ..
                    tostring(card.ability.extra.sanitized_mult or card.ability.extra.mult) .. " " .. localize("k_mult"),
                colour = G.C.RED,
                remove_default_message = true,
                sound = "multhit1"
            }
        end
    end,
    update = function(self, card, dt)
        if dt == 0 then return end
        if card.area ~= G.jokers then return end
        card.ability.extra.mult = card.ability.extra.mult - G.real_dt / 10
        card.ability.extra.sanitized_mult = sanitize(card.ability.extra.mult)
        if cmp(card.ability.extra.mult, 0) <= 0 and not card.ability.extra.done then
            card.ability.extra.done = true
            expire_joker(card, "k_jimbotomy_hourglass_done", "tarot1", G.C.GOLD)
        end
    end,
    eternal_compat = false,
    demicoloncompat = true,
	--[[joker_display_def = function(JokerDisplay)
		---@type JDJokerDefinition
		return {
			text = { -- why doesnt this work????????
				{
					{ text = "+" },
					{ ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult"}
				}
			}
		}
	end]]
}

SMODS.Joker {
    discovered = true,
    rarity = 3,
    key = "house_of_cards",
    discovered = true,
    atlas = 'jimbotomyJokers', pos = { x = 3, y = 1 },
    config = {
        extra = {
            xmult = 1,
            delta_xmult = 0.3,
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Other", key = "jimbotomy_guest_art", vars = {"Zygahedron (GitHub)"} }
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.delta_xmult,
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.post_score then
            card.ability.extra.dead = cmp(context.score, G.GAME.blind.chips) < 0
        end
        if context.end_of_round and context.cardarea == G.jokers and not card.ability.extra.dead then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.delta_xmult
            return {
                message = localize("k_upgrade_ex")
            }
        end
        if (context.hand_drawn or (context.end_of_round and context.cardarea == G.jokers)) and card.ability.extra.dead then
            expire_joker(card, "k_jimbotomy_toppled", "tarot1", G.C.RED)
        end
    end,
    demicoloncompat = true,
	joker_display_def = function(JokerDisplay)
		---@type JDJokerDefinition
		return {
			text = {
				{
					border_nodes = {
						{ text = "X" },
						{ ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp"}
					}
				}
			}
		}
	end
}

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    rarity = 2,
    key = "jjjoker",
    atlas = 'jimbotomyJokers', pos = { x = 0, y = 1 },
    config = {
        extra = {
            chips = 0,
            gain_chips = 0.1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.chips, card.ability.extra.gain_chips }
        }
    end,
    calculate = function(self, card, context)
        function increase()
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.gain_chips
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message =
                    "+" .. tostring(card.ability.extra.gain_chips)
                ,
                colour = G.C.BLUE,
                delay = 0.03
            })
        end

        if context.joker_main or context.forcetrigger then
            increase()
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.modify_scoring_hand or context.scoring_name or context.ignore_debuff or context.cry_press then return end
        increase()
    end,
    demicoloncompat = true
}

-- Slugcat - Uncommon
-- Gains +5 Mult when using a consumable
-- -10 Mult when Blind is selected

-- Plasma Joker - Rare
-- Sets Chips and Mult to
-- the square root of their product
-- (e.g. 28, 4 -> 10.6, 10.6)

G.FUNCS.slugcat_starving = function(e)
    if e.config.ref_table.ability.extra.has_eaten then
        e.config.colour = mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8)
    else
        e.config.colour = mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8)
    end
    e.config.ref_table.slugcat_eaten_ui = ' ' ..
        localize('k_jimbotomy_slugcat_eaten_' .. tostring(e.config.ref_table.ability.extra.has_eaten)) .. ' '
end

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    rarity = 3,
    key = "slugcat",
    atlas = 'jimbotomyJokers', pos = { x = 2, y = 1 },
    config = {
        extra = {
            mult = 30,
            added_mult = 10,
            mult_percent = 5,
            has_eaten = true
        }
    },
    loc_vars = function(self, info_queue, card)
        card.slugcat_eaten_ui = card.slugcat_eaten_ui or '';

        return {
            vars = { card.ability.extra.added_mult, card.ability.extra.mult_percent, card.ability.extra.mult },
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", minh = 0.4 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { ref_table = card, align = "m", colour = G.C.JOKER_GREY, r = 0.05, padding = 0.06, func = 'slugcat_starving' },
                            nodes = {
                                { n = G.UIT.T, config = { ref_table = card, ref_value = 'slugcat_eaten_ui', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                            }
                        }
                    }
                }
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.setting_blind and not context.forcetrigger then
            if not card.ability.extra.has_eaten then
                expire_joker(card, "k_jimbotomy_slugcat_starved", "tarot1", G.C.RED)
                return {}
            end
            card.ability.extra.has_eaten = false
            juice_card_until(card, function()
                return not card.ability.extra.has_eaten
            end, true)
            card.ability.extra.mult = card.ability.extra.mult * (1 - (card.ability.extra.mult_percent / 100));
            return {
                message = "-" .. (card.ability.extra.mult_percent) .. "%",
                colour = G.C.RED
            }
        end
        if context.using_consumeable or context.forcetrigger then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.added_mult
            card.ability.extra.has_eaten = true
            return {
                message = "+" .. card.ability.extra.added_mult,
                colour = G.C.RED
            }
        end
    end,
    demicoloncompat = true,
	joker_display_def = function(JokerDisplay)
		---@type JDJokerDefinition
		return {
			text = {
				{ text = "+" , colour=G.C.MULT},
				{ ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult", colour=G.C.MULT}
			}--[[,
			reminder_text = {
				{ text = "nil"}
			}]]
		}
	end--[[,  --apparently this doesn't work.
	style_function = function(card, text, reminder_text, extra)
		print(reminder_text.children) -- look for how to set reminder_text
		reminder_text.children[0].config.colour = G.C.GREEN and card.ability.extra.has_eaten or G.C.RED
		reminder_text.children[0].config.text = localize('k_jimbotomy_slugcat_eaten_' .. tostring(e.config.ref_table.ability.extra.has_eaten)) .. ' '
	end,]]
}

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    rarity = 1,
    atlas = 'jimbotomyJokers', pos = { x = 0, y = 0 },
    key = "plasma_joker",
    calculate = function(self, card, context)
        if context.joker_main or context.forcetrigger then
            local product = hand_chips * mult
            local sqrt_product = math.sqrt(product)
            hand_chips = sqrt_product
            mult = sqrt_product
            local j = card.juice_up
            card.juice_up = function(...)
                ease_colour(G.C.UI_CHIPS, { 0.8, 0.45, 0.85, 1 })
                ease_colour(G.C.UI_MULT, { 0.8, 0.45, 0.85, 1 })
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    delay = 1,
                    func = (function()
                        ease_colour(G.C.UI_CHIPS, G.C.BLUE, 1)
                        ease_colour(G.C.UI_MULT, G.C.RED, 1)
                        return true
                    end)
                }))
                j(...)
                card.juice_up = j
            end
            return {
                mult = 0,
                remove_default_message = true,
                message = localize("k_balanced"),
                colour = { 0.8, 0.45, 0.85, 1 }, -- Plasma color
                sound = "gong",
                chips = 0,
            }
        end
    end,
    demicoloncompat = true
}

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    name = "slot_machine",
    atlas = 'jimbotomyJokers',
    pos = { x = 0, y = 2 },
    key = "slot_machine",
    calculate = function(self, card, context)
        if context.selling_self or context.forcetrigger then
            local random_seed = (G.GAME and G.GAME.pseudorandom.seed or "") .. "." .. "jimbotomy_slot_machine"
            local options = {"Tarot", "Tarot", "Planet", "Planet", "Planet", "Spectral"}
            local card
            local failsafe = 0
            while true do
                if card then card:remove() end
                local option = options[math.floor(pseudorandom(random_seed) * (#options)) + 1]
                card = create_card(option, nil, nil, nil, nil, nil, nil, random_seed)
                failsafe = failsafe + 1
                if failsafe == 100 then
                    card:remove()
                    return {
                        message = "Failsafe!?"
                    }
                end
                local res, val = pcall(card.can_use_consumeable, card, true, true)
                if res and val then break end
            end
            card:add_to_deck()
            G.FUNCS.use_card({config = {ref_table = card}}, true)
            G.GAME.consumeable_buffer = 0
        end
    end,
    eternal_compat = false,
    demicoloncompat = true
}

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    rarity = 4,
    name = "baltdev",
    atlas = 'jimbotomyJokers',
    pos = { x = 4, y = 0 }, soul_pos = { x = 4, y = 1 },
    key = "baltdev",
    config = {
        extra = {
            added_xmult = 0.1,
            per_chips = 10,
            chip_counter = 0,
            xmult = 1
        },
		pronouns = 'pn_they_them'
    },
    cost = 20,
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.added_xmult, card.ability.extra.per_chips, card.ability.extra.xmult, card.ability.extra.chip_counter },
            main_end = { {
                n = G.UIT.T,
                config = {
                    text = localize("k_jimbotomy_baltdev_note"),
                    colour = G.C.UI.TEXT_INACTIVE,
                    scale = 0.32 * 0.8,
                }
            } }
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.forcetrigger then
            local ch = card.ability.extra.chip_counter
            ch = ch + context.other_card:get_chip_bonus()
            card.ability.extra.chip_counter = ch % card.ability.extra.per_chips
            if ch < card.ability.extra.per_chips then
                return {
                    message = ("%g/%g"):format(sanitize(ch, 10), sanitize(card.ability.extra.per_chips, 10)),
                    message_card = card,
                    colour = G.C.BLUE
                }
            end
            local trigger_count = math.floor(ch / card.ability.extra.per_chips)
            local delta_xmult = trigger_count * card.ability.extra.added_xmult
            card.ability.extra.xmult = card.ability.extra.xmult + delta_xmult
            return {
                message = localize("k_upgrade_ex"),
                message_card = card,
            }
        end
        if context.joker_main or context.forcetrigger then
            return { xmult = card.ability.extra.xmult }
        end
    end,
    demicoloncompat = true,
	joker_display_def = function(JokerDisplay) 
		---@type JDJokerDefinition
		return {
			text = {
				{
					border_nodes = {
						{ text = "X" },
						{ ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp"}
					}
				}
			},
			reminder_text = {
				{ text = "(" },
				{ ref_table = "card.ability.extra", ref_value = "chip_counter", colour = G.C.CHIPS },
				{ text = "/" },
				{ ref_table = "card.ability.extra", ref_value = "per_chips", colour = G.C.CHIPS },
				{ text = ")" }
			}
		}
	end
}

SMODS.Joker {
    discovered = true,
    rarity = 2,
    key = "chain",
    discovered = true,
    atlas = 'jimbotomyJokers', pos = { x = 1, y = 2 },
    config = {
        extra = {
            odds = 6,
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Other", key = "jimbotomy_guest_art", vars = {"ninja22. (Discord)"} }
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'madness_credit_card')
        return {
            vars = { numerator, denominator, localize{type = 'name_text', key="tag_coupon", set="Tag"} },
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and 
            SMODS.pseudorandom_probability(card, 'jimbotomy_chain', 1, card.ability.extra.odds)
        then
            local consumeable = context.consumeable
            local copy = copy_card(consumeable)
            copy:add_to_deck()
            G.consumeables:emplace(copy)
            return {
                message = localize('k_copied_ex'),
                message_card = card
            }
        end
    end,
}

local ffi = require("ffi")

local C
if ffi.os == "Windows" then
    C = ffi.load("msvcrt")
else
    C = ffi.C 
end

ffi.cdef[[
    void* malloc(size_t size);
    void free(void* ptr);
]]


SMODS.Joker {
    discovered = true,
    rarity = 1,
    key = "segfault",
    discovered = true,
    atlas = 'jimbotomyJokers', pos = { x = 2, y = 2 },
    config = {},
    loc_vars = function(self, info_queue, card)
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ptr = ffi.cast("double *", C.malloc(ffi.sizeof("double"))) -- Uninitialized!
            local mult = ptr[0]
            C.free(ptr)
            if math.abs(mult) == math.huge or mult ~= mult then mult = 0 end
            return { mult = mult }
        end
    end,
}
