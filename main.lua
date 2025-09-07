JIMBOTOMY = SMODS.current_mod

assert(SMODS.current_mod.lovely, "Lovely patches were not loaded! Make sure your mod is in the right place.")

assert(SMODS.load_file("./modules/utils.lua"))()
assert(SMODS.load_file("./modules/assets.lua"))()
assert(SMODS.load_file("./modules/jokers.lua"))()
assert(SMODS.load_file("./modules/backs.lua"))()
