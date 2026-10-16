# NXS Scripts

Scripts para Roblox com modelo Free + Premium (via KeyAuth).

## Jogos suportados

- Steal An Egg / Roube um Ovo (PlaceId `107778070777162`)

## Como usar

Cola isso no seu executor (Volt, Swift, Wave):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/srmatheus/robloxscripts/main/loader.lua"))()
```

- **Free**: Auto Collect, Flight, Teleport, Anti-AFK
- **Premium**: Auto Hatch, Auto Fuse, Auto Sell, ESP, Webhook Discord, Config save

Pra ativar Premium:
1. Executa o script
2. Vai na aba `Premium`
3. Cola sua key
4. Clica `ATIVAR PREMIUM`

A key fica salva localmente — nas próximas injeções já libera Premium automaticamente até expirar.

## Comprar key

Discord: _em breve_

## Estrutura

```
nxs-scripts/
├── loader.lua           # entrypoint (users colam no executor)
└── steal-an-egg/
    ├── main.lua         # bootstrap + KeyAuth check
    └── modules/
        ├── UI.lua       # custom black/green ImGui-style GUI
        ├── Eggs.lua     # auto collect, auto pickup, ESP (free + pro)
        ├── Player.lua   # flight, walkspeed, jumppower, anti-AFK (free)
        ├── Teleport.lua # TP seguro para ovos (free)
        ├── AutoHatch.lua# chocar automático (pro)
        ├── AutoFuse.lua # fundir pets (pro)
        ├── Webhook.lua  # Discord notifications (pro)
        ├── KeyAuth.lua  # KeyAuth v1.3 client + cache local
        └── Config.lua   # JSON save/load (pro)
```

## Adicionar novo jogo

Em `loader.lua`, adiciona entry em `routes`:

```lua
local routes = {
    [107778070777162] = "steal-an-egg/main.lua",
    [SEU_PLACE_ID]    = "pasta-do-novo-jogo/main.lua",
}
```

Depois cria `pasta-do-novo-jogo/main.lua` + `modules/`.
