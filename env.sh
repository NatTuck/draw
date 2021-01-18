
CONFDIR="$HOME/.config/draw"
SECRET="$CONFDIR/secret"

mkdir -p "$CONFDIR"

if [ ! -f "$SECRET" ]; then
    dd if=/dev/urandom of=/tmp/secret.$$ bs=1 count=48
    xxd -p -c96 /tmp/secret.$$ > "$SECRET"
fi

export MIX_ENV=prod
export PORT=4780

SECRET_KEY_BASE=$(cat "$SECRET")
export SECRET_KEY_BASE
