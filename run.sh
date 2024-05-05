#!/bin/sh

scriptdir="/home/OkaraAPI"
java -Xmx1024m -Xms256m -cp $scriptdir/OkaraAPI.jar:$scriptdir/lib/* mono.Main $scriptdir/ApplicationResources.properties >/dev/null 2>&1 &
