elm-make src/Main.elm --output dist/sprintpoker.js &&
scp dist/sprintpoker.js woot:/home/michiel/woot/web/www/sp.msvos.nl/ &&
scp dist/index.js woot:/home/michiel/woot/web/www/sp.msvos.nl/ &&
rm dist/sprintpoker.js
