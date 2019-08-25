#!/bin/bash
./build.sh
./tw2k --map local -O 1 -H 3 -o example_maps/example_map.dot -i example_maps/example_map.svg -R sfdp
./tw2k --map global --labels=false -o maps/example_secret_map.dot -i example_maps/example_secret_map.svg -R sfdp
