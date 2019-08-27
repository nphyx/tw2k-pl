#!/bin/bash
./build.sh
./tw2k --map local -O 1 -W 3 --map-dir example_maps -o example_map.dot -i example_map.svg -R sfdp
./tw2k --map global --labels false --map-dir example_maps -o example_secret_map.dot -i example_secret_map.svg -R sfdp
rm example_maps/example_secret_map.dot
