#!/bin/sh

BLANK='#00000000'
CLEAR='#ffffff22'
BASE='#191724ff'
SURFACE='#1f1d2eff'
OVERLAY='#26233aff'
MUTED='#6e6a86ff'
SUBTLE='#908caaff'
TEXT='#e0def4ff'
LOVE='#eb6f92ff'
GOLD='#f6c177ff'
ROSE='#ebbcbaff'
PINE='#31748fff'
FOAM='#9ccfd8ff'
IRIS='#c4a7e7ff'
HIGHLIGHTLOW='#21202eff'
HIGHLIGHTMED='#403d52ff'
HIGHLIGHTHIGH='#524f67ff'

i3lock -n --composite \
--no-modkey-text            \
--insidever-color=$BLANK    \
--ringver-color=$BLANK      \
\
--insidewrong-color=$BLANK   \
--ringwrong-color=$BLANK     \
\
--inside-color=$BLANK       \
--ring-color=$BLANK         \
--line-color=$BLANK         \
--separator-color=$PINE     \
\
--verif-color=$SUBTLE       \
--wrong-color=$LOVE         \
--time-color=$GOLD          \
--date-color=$GOLD          \
--keyhl-color=$PINE         \
--bshl-color=$ROSE          \
\
--blur 5                    \
--clock                     \
--indicator                 \
--time-str="%I:%M %p"       \
--date-str="%a, %b %d"      \
\
--verif-text "Verifying, please wait..."    \
--wrong-text "Invalid Password"             \
--noinput-text "Nothing to remove"          \
