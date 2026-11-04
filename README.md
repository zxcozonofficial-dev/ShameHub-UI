# ShameHub UI

UI-библиотека Luau для клиентских Roblox-скриптов. Белый акцент, Geist Sans, страницы, вкладки, контролы, фоны, конфиги и ватермарка.

## Быстрый запуск через loadstring

Полный пример с меню настроек:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zxcozonofficial-dev/ShameHub-UI/main/Example.lua"))()
```

Подключение библиотеки в свой проект:

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/zxcozonofficial-dev/ShameHub-UI/main/ShameHub.luau"))()
local window = UI.CreateWindow({Title = "My project", ConfigFolder = "MyProject/configs"})
local section = window:AddPage({Title = "General"}):AddTab("Main"):AddSection({Title = "Settings", Side = "Left"})
section:AddToggle({Title = "Enabled", Flag = "Enabled", Default = false, Callback = function(value)
    print("Enabled:", value)
end})
```

Библиотека возвращает API; окно и контролы создаёт подключающий скрипт. `Example.lua` — пример для клиента с loadstring/HTTP, `Example.client.luau` — вариант для Studio через ModuleScript. RightShift скрывает меню и показывает ватермарку.

---


Библиотека интерфейса для клиентских Roblox-скриптов, вдохновлённая приложенным референсом. Тёмная палитра, белый акцент по умолчанию, боковое меню, горизонтальные вкладки, секции на всю ширину и в две колонки.

Шрифт — Geist Sans Bold через `FontFace`. Основной текст 17 px, служебные подписи 12 px. Плоские поверхности, приглушённые контуры секций, акцент фокуса полей, маркер активной страницы и подсветка выбранного пункта dropdown. Ширина переливающейся полоски вычисляется по ширине названия через TextService.

Geist загружается из закреплённого npm-пакета `geist@1.9.0` и кэшируется в файловой системе клиента. Нужны функции `getcustomasset`, `writefile`, `isfile`, `makefolder`, `isfolder` и доступ к HTTP. В обычном Roblox Studio этих функций нет: автоматически используется Builder Sans Bold; фактический шрифт доступен как `window.Typeface`. Файл Geist и лицензия включены в `fonts/`. Исходный шрифт: [vercel/geist-font](https://github.com/vercel/geist-font).

## Установка в Studio

1. Создай ModuleScript `ShameHub` в `ReplicatedStorage`, вставь содержимое `ShameHub.luau`.
2. Создай LocalScript `ShameHubExample` в `StarterPlayer > StarterPlayerScripts`, вставь `Example.client.luau`.
3. Нажми Play. Перетаскивай окно за любую точку верхней полосы, включая область вкладок; обычный клик переключает вкладку. RightShift скрывает/показывает окно;

С Rojo: `rojo build default.project.json -o ShameHub.rbxlx`, затем открой созданный place в Studio и нажми Play. Или `rojo serve default.project.json` и подключись плагином Studio.

## API

```lua
local UI = require(game.ReplicatedStorage.ShameHub)
local window = UI.CreateWindow({Title = "My UI", ToggleKey = Enum.KeyCode.RightShift})
local page = window:AddPage({Title = "General"})
local tab = page:AddTab("Main")
local section = tab:AddSection({Title = "Settings", Side = "Left"})
local toggle = section:AddToggle({Title = "Enabled", Flag = "Enabled", Default = false, Callback = print})
toggle:Set(true) -- вызывает callback при изменении
toggle:Set(false, true) -- silent
print(toggle:Get(), window.Flags.Enabled)
```

`Side`: `Left`, `Right`, `Full`. Секции `Full` располагаются над колонками. Страницы и вкладки имеют `Select()`.

| Метод Section | Параметры |
| --- | --- |
| `AddParagraph(title, body)` | Возвращает объект с `Set(title, body)` |
| `AddToggle(options)` | Title, Flag, Default:boolean, Callback |
| `AddSlider(options)` | Title, Flag, Min, Max, Step, Default, Suffix, Callback |
| `AddDropdown(options)` | Title, Flag, Values: массив строк, Default, Callback |
| `AddInput(options)` | Title, Flag, Default:string, Placeholder, Callback |
| `AddKeybind(options)` | Title, Flag, Default:Enum.KeyCode, Callback при смене, OnPressed при нажатии |
| `AddButton(options)` | Title, Callback |

Контролы, кроме Paragraph/Button, возвращают `Get()` и `Set(value, silent?)`. Callbacks не вызываются при создании. Input фиксирует значение при потере фокуса. Keybind хранится в конфиге как строка имени клавиши. Escape отменяет захват. Флаги должны быть уникальными.

`window:ExportConfig()` и `window:ImportConfig(json, silent?)` остаются низкоуровневым API сериализации. В интерфейсе используются именованные файловые конфиги, без поля JSON.

`CreateWindow` принимает Title, Subtitle, Footer, Name, Parent, DisplayOrder, ToggleKey, Version, Theme, OnStatus. `Theme` переопределяет Color3-поля: Background, Sidebar, Panel, Raised, Border, Text, Muted, Accent. Тема задаётся при создании окна.

`window:SetVisible(boolean)`, `window:SetStatus(string)`, `window:Destroy()`. Размер 680×440, автоматически уменьшается под доступный экран. На маленьком экране две колонки сохраняются. Перетаскивание и slider поддерживают мышь и touch.

## Цвет и фон

В примере открой Settings → Appearance. Accent открывает HSV-палитру с полосой оттенка, полем насыщенности/яркости и вводом HEX. Изменение применяется к названию, активным элементам, slider и полоске под логотипом.

`section:AddColorPicker({Title="Accent", Flag="AccentColor", Default="#FFFFFF", Callback=function(color, hex) window:SetAccent(color) end})` возвращает `Get()` (HEX), `GetColor()` (Color3), `Set(hexOrColor3, silent?)`. Настройка сохраняется в JSON.

`window:SetAccent(colorOrHex)` меняет акцент. `window:SetBackground(source)` возвращает `ok, storedPathOrError`. Принимает пустую строку для удаления, `rbxassetid://...`, путь внутри файловой системы клиента или HTTP(S)-ссылку на PNG/JPG/WebP. Картинки кэшируются в `ShameHub/images/`, предел 12 МБ. `window:SetBackgroundOpacity(0..1)` задаёт видимость картинки.

Предоставленная картинка включена как фон по умолчанию: оригинал лежит в `assets/DefaultBackground.png`, копия встроена в модуль и при первом запуске сохраняется в кэш клиента. `window:SetBackground("default")` или кнопка Default background восстанавливают её. `CreateWindow({Background=""})` создаёт окно без фоновой картинки. Нижняя панель непрозрачная, поэтому статус и подсказка клавиши не зависят от выбранного фона.

Для локального изображения с любого диска запусти `StartLocalBackground.cmd` (нужен Python 3 с tkinter), затем нажми Choose local file. Помощник `LocalBackground.py` слушает только `127.0.0.1:8767` и передаёт только выбранную через системный диалог картинку; содержимое папок не публикуется. Для остановки закрой соответствующий процесс pythonw. Прямой ввод пути работает только для файлов, доступных файловому API клиента; произвольный путь C:\\... используй через диалог.

Для Pinterest предпочтительна прямая ссылка `https://i.pinimg.com/...`. Для обычной страницы pin библиотека пытается извлечь `og:image`; если Pinterest требует вход или блокирует запрос, используй прямую ссылку на картинку. Локальный помощник не нужен для URL. Загрузка происходит только после Apply image или Choose local file. После импорта JSON пример также применяет сохранённый фон.

Интерфейс и callbacks работают локально. Демонстрация меняет состояние UI, а не поведение персонажа. При уничтожении отключаются все зарегистрированные соединения.

Активная страница и вкладка отмечаются кружком 6 px; текст вынесен в отдельную область с отступом. Скругление окна 12 px применяется ко всем слоям через CanvasGroup, включая фон и нижнюю панель. Боковая панель уменьшена до 132 px.

Библиотека самостоятельная: ShameHub.luau возвращает таблицу API, пример не требуется. Модуль не привязан к PlaceId, именам персонажей или объектам конкретной игры. Акцент по умолчанию #FFFFFF; Reset color возвращает белый.

## Ватермарка

При скрытом меню появляется отдельная панель: название интерфейса, FPS, ping в миллисекундах и название текущего place. FPS усредняется за секунду по RenderStepped, ping берётся из Stats/Data Ping. Название игры загружается через MarketplaceService; при ошибке отображается PlaceId. Панель не зависит от фоновой картинки меню. При открытии меню она скрывается; Destroy отключает обработчик метрик вместе с остальными соединениями.

`CreateWindow` дополнительно принимает `Watermark=false` для отключения, `WatermarkTitle="My script"` для собственного названия и `WatermarkPosition` для положения и `WatermarkAnchorPoint` для точки привязки. По умолчанию панель находится сверху по центру: Position=UDim2.new(0.5,0,0,8), AnchorPoint=Vector2.new(0.5,0). По умолчанию берётся Title окна или ShameHub. Размер панели вычисляется по тексту и ограничивается шириной экрана.

В ватермарке используются иконки Lucide: монитор для FPS, Wi-Fi для ping, геймпад для игры. Верхней декоративной полоски нет; PNG загружаются один раз и затем читаются из кэша.

Ватермарка находится в отдельном ScreenGui без верхнего inset: 8 px от верхнего края экрана. Прозрачность фона 18%; иконки и текст выровнены по вертикальному центру одной строки.

## Прозрачность всего меню

Settings → Appearance, под колор пикером: Enable transparency включает эффект, Strength регулирует силу от 0 до 70%. По умолчанию выключено, сохранённая сила — 25%. Эффект применяется к CanvasGroup целиком: фоновой картинке, секциям, нижней панели, тексту и контролам. Выключение восстанавливает обычную видимость, не сбрасывая выбранную силу. Оба значения входят в JSON-конфиг примера.

API: `window:SetMenuTransparency(0..0.7)` задаёт силу, `window:SetMenuTransparencyEnabled(boolean)` включает эффект. Значения выше 0.7 ограничиваются. Параметры CreateWindow: MenuTransparency и MenuTransparencyEnabled.

## Файловые конфиги

Settings → Config: выбери сохранённое имя в списке или введи новое, затем Save config. Load config загружает выделенный конфиг, Set autoload config назначает его для следующего запуска примера. Refresh list перечитывает файлы. Повторное сохранение с тем же именем обновляет файл.

По умолчанию данные лежат в `ShameHub/configs` внутри файловой папки клиента. Чтобы хранить их около своего скрипта, укажи его относительную папку: `CreateWindow({ScriptFolder="scripts/MyScript"})` → `scripts/MyScript/configs`, либо задай `ConfigFolder="scripts/MyScript/configs"`. У клиента нет API получения каталога выполняемого исходника, поэтому он не определяется автоматически. Абсолютные Windows-пути не поддерживаются файловой песочницей клиента.

Файлы имеют расширение `.config`; `.autoload` хранит выбранное имя. Содержимое сериализуется библиотекой, редактировать его вручную не нужно. В конфиг попадают только контролы с Flag. Имена защищены от перехода в родительские каталоги и запрещённых символов Windows.

API: `ListConfigs()` → names, error; `SaveConfig(name)`, `LoadConfig(name)`, `SetAutoloadConfig(name)`, `LoadAutoloadConfig()` → ok, result/error; `GetAutoloadConfig()` → name или nil. После загрузки вызывается `window.ConfigLoaded(name)`. Автозагрузку запускай после создания всех контролов — как в Example.client.luau. Стандартный Roblox Studio не предоставляет произвольное файловое хранилище: эти методы требуют файловых функций клиента.

`section:AddList({Title="Configurations",Values={},Height=140,Callback=...})` возвращает Get/Set и SetValues(values, preferred?). Полностью округлые переключатели используют один UICorner с радиусом 50%.
Список конфигов подстраивает высоту под число строк (30 px на строку, отступ 4 px) до заданного Height; затем включается прокрутка. Имена выровнены влево, выбранная строка отмечена кружком, рядом с заголовком отображается количество конфигов.

## Версия и клавиша меню

Нижняя подпись всегда показывает `ShameHub / Version Dev`. Версия задаётся параметром `CreateWindow({Version="1.0"})` или методом `window:SetVersion("1.0")`. Операционные сообщения не заменяют эту строку: SetStatus сохраняет LastStatus и вызывает необязательный OnStatus callback.

В примере General содержит один пустой таб Interface. Настройки интерфейса остаются в Settings. В Settings → Controls нажми Menu key и затем нужную клавишу; Escape отменяет назначение. По умолчанию RightShift. Назначение сохраняется в конфиге. API: `window:SetToggleKey(Enum.KeyCode.Insert)` или `window:SetToggleKey("Insert")`; подсказка в нижней панели обновляется автоматически. При вводе текста меню на клавишу не реагирует.
## Иконки меню

Страницы и вкладки автоматически получают встроенные иконки по названию: General — Grid, Settings — Settings, About — Info, Interface — Layout, Appearance — Palette, Controls — Keyboard, Config — Folder, Library — Book. Основной набор — PNG Lucide, загружаемый в локальный кэш при первом запуске. Активная иконка использует цвет акцента; отступы для значка, кружка выбора и текста разделены.

Своя иконка: `window:AddPage({Title="Custom", Icon="Settings"})` или `page:AddTab("Main", {Icon="Layout"})`. Также доступны Monitor, Network, Gamepad. Можно передать `Icon="rbxassetid://..."` для ImageLabel или `Icon=false`, чтобы оставить только текст и индикатор выбора. Неизвестное встроенное имя отображается как Grid.
## Загрузка иконок и кэш

Иконки — Lucide 0.468.0, PNG 96×96 с прозрачным фоном. Исходные SVG, лицензия и манифест находятся в `assets/icons/`. `manifest.json` содержит имена, файлы, размеры и SHA-256. Таблица соответствий для загрузчика находится в `UI.Assets.Files` внутри библиотеки, чтобы loadstring не требовал отдельных Lua-модулей.

При первом подключении библиотека параллельно скачивает 11 PNG с GitHub и сохраняет их в `ShameHub/assets/icons/lucide-0.468.0-v2`. Следующие подключения читают существующие файлы без повторной загрузки. Неверный размер/заголовок PNG вызывает повторное скачивание. Изображения меняют цвет через ImageColor3.

Диагностика: `UI.Assets.DownloadCount`, `UI.Assets.CacheHits`, `UI.Assets.Errors`. `UI.PreloadIcons()` ожидает текущую очередь загрузки. В клиенте без файлового API или при недоступной сети для незакэшированных иконок используются резервные UI-фигуры.
Иконки меню: 20×20 px, неактивный цвет IconMuted = RGB(190,190,202), штрих SVG 2.5. Текущий набор — assets/icons/v2; новая версия кэша загружается автоматически, старые файлы не перезаписываются.

## Карточка профиля

Внизу боковой панели отображаются аватар Roblox, имя игрока, индикатор статуса, Subscription и Expires at. По умолчанию Subscription=Free, ExpiresIn=0, Online=true. Это отображаемые данные интерфейса, а не проверка лицензии или подписки.

Параметры: `CreateWindow({Profile={Name="Player",Subscription="Free",ExpiresIn=0,Online=true}})`. Имя без переопределения берётся из LocalPlayer.Name, аватар строится из текущего наряда Roblox. Данные можно обновить через `window:SetProfile({Subscription="Pro",ExpiresIn=3600})`. `Profile=false` отключает карточку. Список страниц заканчивается выше карточки и не перекрывает её.
Карточка профиля без отдельного фона и обводки; увеличенное 3D-превью размещено рядом с ником. Ник 14 px, подписи 12 px; фон совпадает с боковой панелью.

## Анимированный аватар

Аватар увеличен до 48×54 px и отображается как отдельная R15-модель в ViewportFrame/WorldModel. Наряд берётся из HumanoidDescription текущего пользователя. По умолчанию воспроизводится эмоция из первого экипированного слота; если её нет, используется idle аватара. Конкретный выбор позы для снимка профиля не доступен через публичный пользовательский API и не запрашивается через cookies.

Явный выбор: `Profile={Emote="Zombie Idle"}` (имя экипированной эмоции), `Profile={Emote=111326198240592}` (catalog asset ID) или `Profile={AnimationId="rbxassetid://138503654818181"}` (готовый animation ID). `Profile={Animated=false}` оставляет статичную миниатюру. У клона свой Animator; персонаж в игре не меняется. Если анимация недоступна, остаётся обычная миниатюра Roblox.

При скрытии меню анимация приостанавливается. Прозрачность меню применяется и к 3D-превью. ViewportFrame размещён вне CanvasGroup и следует за аватарным слотом, чтобы избежать зависания анимации внутри CanvasGroup. Диагностика: window.ProfileAnimationState, ProfileAnimationError, ProfileEmote. Destroy удаляет модель и останавливает трек. Получение catalog animation использует GetObjects в поддерживающих его клиентах; для других окружений можно передать прямой AnimationId.