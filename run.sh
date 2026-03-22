#!/bin/bash
set -a
source .env
set +a

flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=$GOOGLE_SERVER_CLIENT_ID "$@"
