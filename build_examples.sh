#!/bin/bash
./tw2k --map local -O 1 -W 3 --map-dir example_output -o example_map.dot -i example_map.svg -R sfdp
./tw2k --map global --labels false --map-dir example_output -o example_secret_map.dot -i example_secret_map.svg -R sfdp
rm example_output/example_secret_map.dot

echo "Building example pairs report..."
 ./tw2k -r pairs | tail -n +6 | head -n -1 | awk '{ gsub(/[[:digit:]]/, "0", $0); print }' > example_output/report_pairs.md

echo "Building example route report..."
./tw2k -r routes --holds 20 | tail -n +6 | head -n -1 | awk 'BEGIN { FS="|" }
$2 ~ /^ [[:digit:]|[:alpha:]]/{
	gsub(/[[:digit:]]/, "0", $2);
	gsub(/[[:digit:]]/, "0", $3);
	print "|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8"|"
}
$2 ~ /^\-/ { print $0 }
$2 !~ /^( [[:digit:]|[:alpha:]]|\-)/{ print $1 }' > example_output/report_routes.md

echo "Building example transroute report..."
./tw2k -r transroutes --holds 85 | tail -n +6 | head -n -1 | awk 'BEGIN { FS="|" }
$2 ~ /^ [[:digit:]|[:alpha:]]/{
	gsub(/[[:digit:]]/, "0", $2);
	gsub(/[[:digit:]]/, "0", $3);
	print "|"$2"|"$3"|"$4"|"$5"|"$6"|"
}
$2 ~ /^\-/ { print $0 }
$2 !~ /^( [[:digit:]|[:alpha:]]|\-)/{ print $1 }' > example_output/report_transroutes.md

echo '# Help Output from TW2K' > example_output/help.md
echo '```sh' >> example_output/help.md
./tw2k --help >> example_output/help.md
./tw2k --help options | tail -n +7 | head -n -1 >> example_output/help.md
./tw2k --help maps | tail -n +7 | head -n -1 >> example_output/help.md
./tw2k --help reports | tail -n +7 | head -n -1 >> example_output/help.md
echo '```' >> example_output/help.md
