# Zurly Hub

Scripts para Roblox com modelo Free + Premium (via KeyAuth), tema red/black.

## Jogos suportados

| Jogo | PlaceId | Status | BAC |
|---|---|---|---|
| **Grow a Garden** | `126884695634066` | Active | ❌ Sem |
| Steal An Egg (Roube um Ovo) | `107778070777162` | Hold | ⚠ BAC forte |

## Como usar

Cola no executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/srmatheus/robloxscripts/main/loader.lua"))()
```

O loader detecta o jogo pelo PlaceId e carrega o script certo.

### Grow a Garden — Free

- Auto Harvest crops
- Auto Sell inventory
- Auto Plant seed configurável
- Flight (WASD + Space/Ctrl) + WalkSpeed + JumpPower
- Teleport para Shop / Garden / Sell
- Anti-AFK

### Grow a Garden — Premium

- Auto Fuse Pets (combina pra mutations)
- Auto Equip Best Pet
- Auto Buy Rare Seeds (Dragon Fruit, Pumpkin, Mushroom, Pepper, Cactus)
- ESP Pets Raros (Rainbow / Golden / Rot / Warped)
- Webhook Discord (notifica drops raros)
- Config save/load persistente

### Ativar Premium

1. Executa o script
2. Vai na aba `Premium`
3. Cola sua key
4. Clica `ATIVAR PREMIUM`

Key fica cacheada localmente. Próximas injeções já abrem Premium automaticamente até expirar.

### Hotkey

`RightShift` toggla o menu.

## Estrutura

```
robloxscripts/
├── loader.lua              # entrypoint — routing por PlaceId
├── shared/                 # modulos reutilizados por todos os jogos
│   ├── Theme.lua           # paleta Zurly Hub red/black
│   ├── UIWidgets.lua       # toggle, slider, button, input (reusáveis)
│   ├── KeyAuth.lua         # client KeyAuth v1.3 + cache local
│   ├── Config.lua          # JSON persist (per-game)
│   ├── Webhook.lua         # Discord notifications
│   └── Player.lua          # flight, speed, jump, anti-AFK
├── grow-a-garden/
│   ├── main.lua            # bootstrap + load premium cache
│   └── modules/
│       ├── UI.lua          # tema red/black, tabs Free/Premium
│       ├── Plants.lua      # auto plant, harvest, water
│       ├── Shop.lua        # auto sell, auto buy seeds
│       ├── Pets.lua        # auto fuse, equip best, ESP
│       └── Teleport.lua    # TP shop/garden/sell
└── steal-an-egg/           # Hold — BAC kicks (aguardando bypass)
    └── ...
```

## Adicionar novo jogo

1. Em `loader.lua`, adiciona entry em `routes`:
   ```lua
   [SEU_PLACE_ID] = "pasta-do-jogo/main.lua",
   ```
2. Cria `pasta-do-jogo/main.lua` + `pasta-do-jogo/modules/UI.lua` + modulos específicos
3. Reusa shared/ pra Theme, UIWidgets, KeyAuth, Config, Webhook, Player
