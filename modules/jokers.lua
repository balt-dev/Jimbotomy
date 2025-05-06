
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
    config = {
        extra = {
            x_mult = 2,
            chips = 1,
            chip_limit = 1000000000, -- 1 billion
            active = false
        }
    },
    loc_vars = function(self, info_queue, card)
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
    key = "domino",
    rarity = 2,
    calculate = function(self, card, context)
        if not context.joker_main then return end
        hand_chips, mult = mult, hand_chips
        return {
            message = localize("k_jimbotomy_swapped"),
            colour = {0.8, 0.45, 0.85, 1}, -- Plasma color
            sound = "jimbotomy_swap",
            chips = 0,
            remove_default_message = true
        }
    end,
}

SMODS.Joker {
    rarity = 3,
    key = "roll_the_dice",
    config = {
        extra = {
            x_mult = 1,
            chance = 5,
            total_chance = 6,
            multiplier = 1.5
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
    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize(key), colour = color})
    play_sound(sound)
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
    config = {
        extra = {
            mult = 1,
            sanitized_mult = 1
        }
    },
    loc_vars = function(self, info_queue, card)
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
                message = "+"..tostring(card.ability.extra.sanitized_mult).." "..localize("k_mult"),
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
    end
}

SMODS.Joker {
    discovered = true,
    rarity = 2,
    key = "house_of_cards",
    config = {
        extra = {
            x_mult = 5,
            used = false
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.x_mult }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local x_mult            
            if not card.ability.extra.used then
                x_mult = card.ability.extra.x_mult
                card.ability.extra.used = true
                local j = card.juice_up
                card.juice_up = function(...)
                    card.debuff = true
                    j(...)
                end
            end
            return {
                xmult = x_mult, -- will be nil when toppled, which is what we want
                message = localize("k_jimbotomy_toppled"),
                color = G.C.RED,
            }
        end
        if (context.after and context.cardarea == G.play) or 
            context.end_of_round or
            context.setting_blind or
            context.hand_drawn or
            context.post_trigger
        then
            card.debuff = card.debuff or card.ability.extra.used
        end
    end,
    eternal_compat = false,
    blueprint_compat = false
}

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    rarity = 1,
    key = "jjjoker",
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
            , colour = G.C.BLUE, delay = 0.1})
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

-- Scavenger - Uncommon
-- Gains +50 Chips when selling a card
-- -100 Chips when blind is selected

-- Plasma Joker - Rare
-- Sets Chips and Mult to
-- the square root of their product
-- (e.g. 28, 4 -> 10.6, 10.6)

SMODS.Joker {
    discovered = true,
    blueprint_compat = true,
    rarity = 1,
    key = "slugcat",
    config = {
        extra = {
            chips = 0,
            delta_chips = 0,
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.delta_chips, -2 * card.ability.extra.delta_chips, card.ability.extra.chips }
        }
    end,
    calculate = function(self, card, context)        
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.blind_select then
            card.ability.extra.chips = card.ability.extra.chips - (2 * card.ability.extra.delta_chips)
            if cmp(card.ability.extra.chips, 0) <= 0 then
                expire_joker(card, "k_jimbotomy_slugcat_starved", "tarot1", G.C.RED)
                return {}
            end 
            return {
                message = "-" .. (2 * card.ability.extra.delta_chips),
                colour = G.C.BLUE
            }
        end
        if context.using_consumeable then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.delta_chips
            return {
                message = "+" .. card.ability.extra.delta_chips,
                colour = G.C.BLUE
            }
        end
    end
}