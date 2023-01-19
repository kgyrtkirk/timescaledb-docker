#!/bin/bash

set -e

echo "waiting for db"
/wait

psql -l
