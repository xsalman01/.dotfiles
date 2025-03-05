#!/bin/bash

# Read from stdin, clean ANSI and OSC escape sequences, then pass to Neovim
sed -E "s/\x1B\[[0-9;]*[a-zA-Z]//g; \
    s/\x1B\][0-9;]*.*?\x07//g; \
    s/\x1B\][0-9;]*.*?\x1B\\\\//g" | \
nvim -c "set ft=man" \
    -c "normal! G" -

