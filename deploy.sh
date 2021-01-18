#!/bin/bash

source env.sh

NODEBIN=$(pwd)/assets/node_modules/.bin
export NODEBIN
export PATH="$PATH:$NODEBIN"

mix deps.get
mix compile
(cd assets &&
     npm install &&
     npm run deploy)
mix phx.digest

mix release

