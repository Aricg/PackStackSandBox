#!/bin/bash

#Add vagrant to path
if test -r /vagrant; then
  declare -x PATH="$PATH"":/vagrant/bin"
  echo "bash rc loaded, and paths properly set"
fi
