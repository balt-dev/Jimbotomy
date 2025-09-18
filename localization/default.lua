return {
	descriptions = {
		Other = {
			jimbotomy_programmer_art = {
				name = "Programmer Art",
				text = {
					"The art for this card is unfinished.",
					"It will change in a later update!"
				}
			},
			jimbotomy_guest_art = {
				name = "Guest Art",
				text = {
					"Art by {C:attention}#1#{}"
				}
			}
		},
		Joker = {
			j_jimbotomy_nerd_joker = {
				name = "Nerd Joker",
				text = {
					"{X:mult,C:white} x#1# {} Mult, {C:chips}+#2#{} Chips",
					"if round score is {C:attention}prime{}",
					"{C:inactive}Inactive if round score > #3#{}"
				}
			},
			j_jimbotomy_domino = {
				name = "Domino",
				text = {
					"Swaps {C:mult}Mult{} and {C:chips}Chips{}"
				}
			},
			j_jimbotomy_chain = {
				name = "Chain",
				text = {
					"{C:green}#1# in #2#{} chance to",
					"{C:attention}duplicate{} used consumables"
				}
			},
			j_jimbotomy_roll_the_dice = {
				name = "Roll The Dice",
				text = {
					"On selling, {C:green}#2# in #3#{} chance",
					"to copy with {C:attention}x#4#{} as much {X:mult,C:white}xMult{}",
					"{C:inactive}(Currently {X:mult,C:white} x#1# {C:inactive} Mult)",
					"{C:inactive}Unaffected by {C:green}#5#{}"
				}
			},
			j_jimbotomy_hourglass = {
				name = "Hourglass",
				text = {
					"{C:mult}-0.1{} Mult per second"
				}
			},
			j_jimbotomy_house_of_cards = {
				name = "House of Cards",
				text = {
					"Gains {X:mult,C:white} x#2# {} Mult per round",
					"{C:red}Self-destructs{} if hand scores below Blind requirement",
					"{C:inactive}(Currently {X:mult,C:white} x#1# {C:inactive} Mult)",
				}
			},
			j_jimbotomy_jjjoker = {
				name = "JJJoker",
				text = {
					"{C:chips}+#2#{} Chips when any Joker trigger effect is fired",
					"{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)"
				}
			},
			j_jimbotomy_slugcat = {
				name = "Slugcat",
				text = {
					"{C:mult}+#1#{} Mult when using a {C:attention}consumable{}",
					"{C:mult}-#2#%{} Mult when blind is selected",
					"{C:red}Destroyed if no consumables used since last blind{}",
					"{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)"
				}
			},
			j_jimbotomy_plasma_joker = {
				name = "Plasma Joker",
				text = {
					"Sets {C:chips}Chips{} and {C:mult}Mult#{} to",
					"the square root of their {C:attention}product{}"
				}
			},
			j_jimbotomy_broken_lock = {
				name = "Broken Lock",
				text = {
					"This joker acts as if it was",
					"{C:attention}Eternal{} until it is sold"
				}
			},
			j_jimbotomy_baltdev = {
				name = "baltdev",
				text = {
					"Gains {X:mult,C:white} x#1# {} Mult",
					"for every #2# {C:chips}Chips{} gained from",
					"a playing card's base value",
					"{C:inactive}(Currently {X:mult,C:white} x#3# {C:inactive} Mult, {C:chips}#4#{C:inactive}/{C:chips}#2#{C:inactive} Chips)"
				}
			},
			j_jimbotomy_slot_machine = {
				name = "Slot Machine",
				text = {
					"Sell this Joker to immediately use a random",
					"{C:planet}Planet{}, {C:spectral}Spectral{}, or {C:tarot}Tarot{} card",
					"Will never pick cards that cannot be used"
				}
			}
		},
		Back = {
			b_jimbotomy_overflow = {
				name = "Totally Not Nuclear Deck",
				text = {
					"Blinds scale by the base",
					"{C:attention}to the power of{}",
					"the current {C:attention}Ante{}",
					"Scoring is {C:chips}Chips{} {C:attention}^{} {C:mult}Mult{}",
					"Can only make {C:attention}one{}",
					"purchase per shop",
				}
			},
			b_jimbotomy_underflow = {
				name = "Underflow Deck",
				text = {
					"+3 {C:blue}Hands{}",
					"Scoring is {C:chips}Chips{} {C:attention}+{} {C:mult}Mult{",
					"Blind requirements are {C:attention}halved{}"
				}
			},
			b_jimbotomy_criminal = {
				name = "Criminal Deck",
				text = {
					"Everything is {C:money}$0{}",
					"Rerolls are {C:red}disabled{}",
				}
			}
		}
	},
	misc = {
		dictionary = {
			k_jimbotomy_hourglass_done = "Time's Up!",
			k_jimbotomy_swapped = "Swapped!",
			k_jimbotomy_toppled = "Toppled!",
			k_jimbotomy_assembled = "Assembled!",
			k_jimbotomy_slugcat_starved = "Starved...",
			k_inactive = "inactive",
			k_jimbotomy_slugcat_eaten_true = "fed",
			k_jimbotomy_slugcat_eaten_false = "hungry",
			k_jimbotomy_baltdev_note = "Hello there :3",
			k_jimbotomy_baltdev_boop = "Boop!"
		}
	}
}
