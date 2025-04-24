local Translations = {
    error = {
        no_gang = 'You are not in a gang',
        not_enough_rank = 'You do not have the required rank',
        insufficient_rank = 'Your rank is too low to craft any items',
        already_crafting = 'You are already crafting something',
        notenoughMaterials = 'You don\'t have enough materials',
        crafting_failed = 'Crafting has failed',
        invalid_amount = 'Invalid amount',
        invalidInput = 'Invalid Input',
        wrong_gang = 'You are not in the right gang',
        no_crafting_access = 'You cannot access this crafting table'
    },
    info = {
        crafting_item = 'Crafting: %{item}',
        required_level = 'Required Level: %{level}',
        open_crafting = 'Access Gang Crafting',
        craft_item = 'Craft %{item}',
    },
    menu = {
        header = 'Gang Crafting',
        required_items = 'Required Materials:',
        close_menu = 'Close Menu',
        entercraftAmount = 'Enter craft amount',
        pickupworkBench = 'Pickup Workbench',
    },
    notifications = {
        tablePlace = 'You have placed the crafting table.',
        notenoughMaterials = 'Not enough materials for crafting ',
        craftMessage = 'You crafted %{crafted}',
        pickupBench = 'You picked up the crafting table',
        xpGain = 'You gained %{xp} reputation in %{type}',
        invalidAmount = 'Invalid amount specified',
        invalidInput = 'Invalid input provided',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
