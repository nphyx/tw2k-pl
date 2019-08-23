#!/usr/bin/gawk -f
BEGIN { FS="," }
/^Sector/{
	gsub(/^[[:space:]]*Sector[^[:digit:]]*/,"");
	gsub(/in .*$/,"");
	sector = $1
	print "SECTOR: " sector
}

/^Planets/{
	for(i=1;i<=NF;++i) {
		gsub(/^Planets[[:space:]]+:[[:space:]]+/, "", $i)
		print $i
		gsub(/\(/,"", $i);
		print $i
		gsub(/\)/,", unknown,", $i);
		print $i
		printf("PLANET_RECORD: %.3d, %s, unknown\n", sector, $i);
	}
}
