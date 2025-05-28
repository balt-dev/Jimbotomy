
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
    atlas = 'jimbotomyJokers', pos = { x = 2, y = 0 },
    config = {
        extra = {
            x_mult = 2,
            chips = 1,
            chip_limit = 1000000000, -- 1 billion
            active = false
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = "Other", key = "jimbotomy_programmer_art"}
        return {
            vars = {
                card.ability.extra.x_mult,
                card.ability.extra.chips,
                card.ability.extra.chip_limit
            }
        }
    end,
    calculate = function(self, card, context)
        if not context.joker_main then return end
        if nerd_joker_active then
            return {
                xmult = card.ability.extra.x_mult,
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
    end
}


SMODS.Joker {
    atlas = 'jimbotomyJokers', pos = { x = 1, y = 0 },
    pixel_size = { w = 48, h = 95 },
    key = "domino",
    rarity = 3,
    calculate = function(self, card, context)
        if not context.joker_main then return end
        hand_chips, mult = mult, hand_chips
        return {
            message = localize("k_jimbotomy_swapped"),
            colour = G.C.GOLD,
            sound = "jimbotomy_swap",
            chips = 0,
            remove_default_message = true
        }
    end
}

SMODS.Joker {
    rarity = 3,
    key = "roll_the_dice",
    atlas = 'jimbotomyJokers', pos = { x = 3, y = 0 },
    config = {
        extra = {
            x_mult = 1,
            chance = 5,
            total_chance = 6,
            multiplier = 1.25
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.j_oops
        return {
            vars = {
                card.ability.extra.x_mult,
                card.ability.extra.chance,
                card.ability.extra.total_chance,
                card.ability.extra.multiplier,
                G.localization.descriptions.Joker.j_oops.name
            }
        }
    end,
    eternal_compat = false,
    calculate = function(self, card, context)
        if context.selling_self then
            local random_seed = (G.GAME and G.GAME.pseudorandom.seed or "") .. "." .. "jimbotomy_roll_the_dice"
            local rand = pseudorandom(random_seed)
            local success = cmp(rand * card.ability.extra.chance, card.ability.extra.multiplier) >= 0
            if success then
                local copy = copy_card(card, nil, nil, nil, card.edition and card.edition.negative)
                copy.ability.extra.x_mult = copy.ability.extra.x_mult * card.ability.extra.multiplier
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
                        blocking = false, func = function()
                            play_sound('tarot2', 0.76, 0.4)
                            return true end
                    })
                )
                return {
                    message = localize('k_nope_ex'),
                    colour = G.C.RED,
                }
            end
        end
        if context.joker_main then
            return { xmult = card.ability.extra.x_mult }
        end
    end,
    update = function(self, card, dt)
        card.sell_cost = 0
    end
}

local function expire_joker(card, key, sound, color)
    card_eval_status_text(card, 'extra', nil, nil, nil, {sound = sound, message = localize(key), colour = color})
    card:juice_up(0.3, 0.4)
    G.E_MANAGER:add_event(
        Event({
            trigger = 'after', delay = 0.2, blockable = false,
            func = function()    
                card.T.r = -0.2
                card.states.drag.is = true
                card.children.center.pinch.x = true
            return true; end
        })
    )
    G.E_MANAGER:add_event(
        Event({
            trigger = 'after', delay = 0.6, blockable = false,
            func = function()
                G.jokers:remove_card(card)
                card:remove()
            return true; end
        })
    )
end

SMODS.Joker {
    discovered = true,
    rarity = 2,
    key = "hourglass",
    atlas = 'jimbotomyJokers', pos = { x = 1, y = 1 },
    config = {
        extra = {
            mult = 30
        }
    },
    loc_vars = function(self, info_queue, card)
        card.ability.extra.sanitized_mult = sanitize(card.ability.extra.mult)
        info_queue[#info_queue+1] = {set = "Other", key = "jimbotomy_programmer_art"}
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
        if context.joker_main and not card.ability.extra.done then
            return {
                mult = card.ability.extra.mult,
                message = "+"..tostring(card.ability.extra.sanitized_mult or card.ability.extra.mult).." "..localize("k_mult"),
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
    eternal_compat = false
}

SMODS.Joker {
    discovered = true,
    rarity = 3,
    key = "house_of_cards",
    atlas = 'jimbotomyJokers', pos = { x = 3, y = 1 },
    config = {
        extra = {
            x_mult = 1,
            delta_x_mult = 0.3,
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = "Other", key = "jimbotomy_programmer_art"}
        return {
            vars = {
                card.ability.extra.x_mult,
                card.ability.extra.delta_x_mult,
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.x_mult
            }
        end
        if context.post_score then
            card.ability.extra.dead = cmp(context.score, G.GAME.blind.chips) < 0
        end
        if context.end_of_round and context.cardarea == G.jokers and not card.ability.extra.dead then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.delta_x_mult
            return {
                message = localize("k_upgrade_ex")
            }
        end
        if (context.hand_drawn or (context.end_of_round and context.cardarea == G.jokers)) and card.ability.extra.dead then
            expire_joker(card, "k_jimbotomy_toppled", "tarot1", G.C.RED)
        end
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
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = 
                "+" .. tostring(card.ability.extra.gain_chips)
            , colour = G.C.BLUE, delay = 0.03})
        end
        if context.joker_main then
            increase()
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.modify_scoring_hand or context.scoring_name or context.ignore_debuff then return end
        increase()
    end
}

-- Slugcat - Uncommon
-- Gains +5 Mult when using a consumable
-- -10 Mult when Blind is selected

-- Plasma Joker - Rare
-- Sets Chips and Mult to
-- the square root of their product
-- (e.g. 28, 4 -> 10.6, 10.6)

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    rarity = 3,
    key = "slugcat",
    atlas = 'jimbotomyJokers', pos = { x = 2, y = 1 },
    config = {
        extra = {
            mult = 30,
            delta_mult = 5,
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = "Other", key = "jimbotomy_programmer_art"}
        return {
            vars = { card.ability.extra.delta_mult, 2 * card.ability.extra.delta_mult, card.ability.extra.mult }
        }
    end,
    calculate = function(self, card, context)        
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.setting_blind then
            card.ability.extra.mult = card.ability.extra.mult - (2 * card.ability.extra.delta_mult)
            if cmp(card.ability.extra.mult, 0) <= 0 then
                expire_joker(card, "k_jimbotomy_slugcat_starved", "tarot1", G.C.RED)
                return {}
            end 
            return {
                message = "-" .. (2 * card.ability.extra.delta_mult),
                colour = G.C.RED
            }
        end
        if context.using_consumeable then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.delta_mult
            return {
                message = "+" .. card.ability.extra.delta_mult,
                colour = G.C.RED
            }
        end
    end
}

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    rarity = 2,
    atlas = 'jimbotomyJokers', pos = { x = 0, y = 0 },
    key = "plasma_joker",
    calculate = function(self, card, context)        
        if context.joker_main then
            local product = hand_chips * mult
            local sqrt_product = math.sqrt(product)
            hand_chips = sqrt_product
            mult = sqrt_product
            local j = card.juice_up
            card.juice_up = function(...)
                ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
                ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
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
                colour = {0.8, 0.45, 0.85, 1}, -- Plasma color
                sound = "gong",
                chips = 0,
            }
        end
    end,

}