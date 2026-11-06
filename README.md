# PlayerBot Control

Аддон для World of Warcraft 3.3.5a (WotLK) для упрощения управления ботами
[mod-playerbots](https://github.com/liyunfan1223/mod-playerbots/wiki/Playerbot-Commands).

## Возможности (v1.0.0)

- Кнопка у миникарты (иконка «Командирский оклик»), которую можно перетаскивать по кругу миникарты.
- По клику ЛКМ открывает/скрывает окно управления на самом высоком уровне оверлея
  (`FrameStrata: TOOLTIP`) в близардовском стиле с тёмным фоном.
- Окно перетаскивается за фон, позиция сохраняется между сессиями, закрывается по Escape.
- Кнопка **Follow** отправляет в чат группы (`/p`) или рейда (`/r`) команду `follow` —
  все боты последуют за вами (см. [мануал команд](https://github.com/liyunfan1223/mod-playerbots/wiki/Playerbot-Commands#partyraid-general-commands)).

## Установка

1. Скопируйте папку `PlayerBotControl` в
   `C:\Games\World of Warcraft Lich King\Interface\AddOns\`.
2. Перезапустите игру или выполните `/reload`.

## Использование

- `/pbc` или `/playerbotcontrol` — открыть/скрыть окно управления.
- `/pbc follow` — сразу отправить команду `follow` ботам.
- Левый клик по кнопке у миникарты — открыть/скрыть окно.

## Версионирование

Версия хранится в `PlayerBotControl.toc` (`## Version`) и в заголовке `PlayerBotControl.lua`.
Каждая версия помечается тегом в git (`v1.0.0` и далее).

## Планы на будущие версии

- Кнопки `stay`, `attack`, `summon`, `release`, `revive`.
- Переключение стратегий (`co +tank`, `nc +loot` и т.д.).
- Управление лутом (`ll all`, `ll normal`, ...).
