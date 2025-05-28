return {
	descriptions = {
		Other = {
			jimbotomy_programmer_art = {
				name = "Programmer Art",
				text = {
					"The art for this card is unfinished.",
					"It will change in a later update!"
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
					"{C:inactive}{C:mult}-0.1{C:inactive} Mult per second"
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
					"{C:mult}-#2#{} Mult when blind is selected",
					"{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)"
				}
			},
			j_jimbotomy_plasma_joker = {
				name = "Plasma Joker",
				text = {
					"Sets {C:chips}Chips{} and {C:mult}Mult#{} to",
					"the square root of their {C:attention}product{}"
				}
			}
		}
	},
	misc = {
		dictionary = {
			k_jimbotomy_hourglass_done = "Time's Up!",
			k_jimbotomy_swapped = "Swapped!",
			k_jimbotomy_toppled = "Toppled!",
			k_jimbotomy_assembled = "Assmebled!",
			k_jimbotomy_slugcat_starved = "Starved...",
			k_inactive = "inactive"
		}
	}
}