
CONFDIR="$HOME/.config/draw"
SECRET="$CONFDIR/secret"

mkdir -p "$CONFDIR"

if [ ! -f "$SECRET" ]; then
    MIX_ENV="" mix phx.gen.secret > "$SECRET"
fi

export MIX_ENV=prod
export PORT=4780

SECRET_KEY_BASE=$(cat "$SECRET")
export SECRET_KEY_BASE
