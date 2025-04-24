local Translations = {
    error = {
        not_in_gang = "You are not in the right gang for this",
        insufficient_rank = "You don't have the required gang rank",
        not_enough_materials = "You don't have all the required materials",
        crafting_failed = "Crafting failed!",
        no_items_to_craft = "No items available to craft"
    },
    success = {
        crafted_item = "You crafted: %{item}"
    },
    info = {
        crafting_menu = "Gang Crafting",
        craft_item = "Craft %{item}",
        craft_button = "Craft",
        crafting_in_progress = "Crafting in progress...",
        required_materials = "Required Materials:",
        required_gang_rank = "Required Gang Rank: %{rank}",
        gang_crafting_bench = "Gang Crafting Bench"
    },
    menu = {
        close = "Close",
        back = "Back"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
