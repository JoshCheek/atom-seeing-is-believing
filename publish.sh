#!/usr/bin/env bash
# Doing this b/c apm's publishing process has repeatedly confounded me:
# https://github.com/atom/apm/issues/756

VERSION="$(jq -r  '"v"+.version'  package.json)"

read -p "Enter version to publish (Return for default: $VERSION) " entered
if [[ -n "$entered" ]]; then
  VERSION="$entered"
fi

read -s -p 'Enter Atom token (https://atom.io/account): ' ATOM_TOKEN

echo
echo ----------
echo

curl -i \
     -H "authorization: $ATOM_TOKEN" \
     -H "accept: application/json" \
     -H "content-type: application/json" \
     -X POST -d "{\"tag\":\"$VERSION\"}" \
    'https://atom.io/api/packages/seeing-is-believing/versions'

# -----  Logged from within apm  -----
# Publishing seeing-is-believing@v13.0.0 { packageName: 'seeing-is-believing',
#   tag: 'v13.0.0',
#   options: { rename: undefined },
#   error: null,
#   token: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx',
#   requestSettings:
#    { url: 'https://atom.io/api/packages/seeing-is-believing/versions',   <-- that's a bug, wrong protocol
#      json: true,
#      body: { tag: 'v13.0.0', rename: undefined },
#      headers: { authorization: '_YzKoVEZDCoLPQhdQL6nAmg' } } }


# -----  Should ultimately do this  -----

# POST /packages/seeing-is-believing/versions HTTP/1.1
# authorization: xxxxxxxxxxxxxxxxxxxxxxxxxxxx
# User-Agent: npm/3.10.10 node/v6.9.5 darwin x64
# host: localhost:3004
# accept: application/json
# content-type: application/json
# content-length: 17
# Connection: close
#
# {"tag":"v14.0.0"}
