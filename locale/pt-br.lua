local Translations = {
    error = {
        not_in_gang = 'Você não pertence a esta gang',
        insufficient_rank = 'Você não tem rank suficiente para usar este local',
        not_enough_materials = 'Você não tem materiais suficientes',
        already_crafting = 'Você já está fabricando algo',
        crafting_failed = 'O processo de fabricação falhou',
    },
    success = {
        crafted_item = 'Você fabricou com sucesso: %{item}'
    },
    info = {
        open_crafting = 'Abrir Mesa de Fabricação',
        crafting_item = 'Fabricando: %{item}',
        required_level = 'Nível Requerido: %{level}',
        craft_item = 'Fabricar %{item}',
    },
    menu = {
        required_items = 'Itens Necessários:',
        close_menu = 'Fechar Menu',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
