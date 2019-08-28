#!/usr/bin/gawk -f
BEGIN {
	sector = 1
	last_planet_name = "Terra"
	in_registry = 0
	planet[1]["Terra"]["sector"] = 1
	planet[1]["Terra"]["number"] = 1
	planet[1]["Terra"]["name"] = "Terra"
	planet[1]["Terra"]["citadel"] = "None"
	planet[1]["Terra"]["rlevel"] = 0
	planet[1]["Terra"]["fighters"] = 6000
	planet[1]["Terra"]["qcanlevel"] = "None"
	planet[1]["Terra"]["class"] = "M"
	planet[1]["Terra"]["creator"] = "unknown"
}

/^Sector/{
	gsub(/^[[:space:]]*Sector[^[:digit:]]*/,"");
	gsub(/in .*$/,"");
	sector = $1
}

/^Planets/{
	# print "DEBUG PLANET SUMMARY BEGIN: "$0
	for(i=3; i + 1 <=NF; i+=1) {
		gsub(/\(|\)/, "", $(i))
		planet_class = tolower($i)
		i += 1
		if($i ~ /,$/ || i == NF) {
			gsub(/,/, "", $i)
			last_planet_name = $i
		} else {
			last_planet_name = ""
			while(($i !~ /^\(/) && $i) {
				gsub(/,/, "", $i)
				last_planet_name = last_planet_name ? last_planet_name" "$i : $i
				i += 1
			}
		}
		planet[sector][last_planet_name]["sector"] = sector
		planet[sector][last_planet_name]["class"] = planet_class
		planet[sector][last_planet_name]["name"] = last_planet_name
		print "DEBUG PLANET SUMMARY LINE: "planet_class", '"last_planet_name"'"
	}
}
#
#	for(i=1;i <=NF;++i) {
#		gsub(/^Planets[[:space:]]+:[[:space:]]+/, "", $i)
#		# print $i
#		gsub(/\(/,"", $i);
#		# print $i
#		gsub(/\)/,", unknown,", $i);
#		# print $i
#		# printf("PLANET_RECORD: %.3d, %s, unknown\n", sector, $i);
#		last_planet_name = $i
#		planet[sector, last_planet_name, "sector"] = sector
#		planet[sector, last_planet_name, "number"] = $2
#		planet[sector, last_planet_name, "name"] = last_planet_name
#		planet[sector, last_planet_name, "citadel"] = $5
#		planet[sector, last_planet_name, "rlevel"] = $6
#		planet[sector, last_planet_name, "fighters"] = $6
#		planet[sector, last_planet_name, "qcanlevel"] = $7
#		planet[sector, last_planet_name, "class"] = $i
#	}
#}
/^<Atmospheric maneuvering system/ {
	in_registry = 1
	print "DEBUG IN REGISTRY"
}

/^    </ {
	if(in_registry) {
		print "DEBUG PLANET REGISTRY LINE"
		gsub(/\%/, "", $5)
		gsub(/\T/, "000", $6)
		gsub(/>/, "", $2)
		last_planet_name = $3
		planet[sector][last_planet_name]["sector"] = sector
		planet[sector][last_planet_name]["number"] = $2
		planet[sector][last_planet_name]["name"] = last_planet_name
		planet[sector][last_planet_name]["citadel"] = $4
		planet[sector][last_planet_name]["rlevel"] = $5
		planet[sector][last_planet_name]["fighters"] = $6
		planet[sector][last_planet_name]["qcanlevel"] = $7
		planet[sector][last_planet_name]["class"] = $8
	}
}

/^Planet #[[:digit:]]+ in sector [[:digit:]]+: [[:alpha:]]+/ {
	if(in_registry) {
		gsub(/#/, "", $2)
		gsub(/:/, "", $5)
		sector = $5
		last_planet_name = $6
		planet[sector][last_planet_name]["sector"] = sector
		planet[sector][last_planet_name]["number"] = $2
		planet[sector][last_planet_name]["name"] = last_planet_name 
		print "DEBUG PLANET BLOCK NUMBER, SECTOR, NAME: "$2", "$5", "$6
	}
}

/^Class [[:alpha:]], [[:alpha:]]+/ {
	if(in_registry) {
		print "DEBUG PLANET BLOCK CLASS"
		gsub(",", "", $2)
		planet[sector][last_planet_name]["class"] = $2

	}
}

/^Created by:/ {
	if(in_registry) {
		gsub(/<|>/, "", $3)
		planet[sector][last_planet_name]["creator"] = $3 == "UNKNOWN" ? "unknown" : $3
		print "DEBUG PLANET BLOCK CREATOR " $3
	}
}

/^          Owned by:/ {
	if(in_registry) {
		planet[sector][last_planet_name]["owner"] = $3
		print "DEBUG PLANET REGISTRY OWNER: " $3
	}
}

/^Claimed by:/ {
	if(in_registry) {
		planet[sector][last_planet_name]["owner"] = $3
		print "DEBUG PLANET BLOCK OWNER " $3
	}
}

/^Land on which planet/ {
	in_registry = 0
	print "DEBUG OUT OF REGISTRY"
}

/^There isn't a planet in this sector/ {
	in_registry = 0
	print "DEBUG OUT OF REGISTRY"
}

/^Blasting off from/ {
	in_registry = 0
	print "DEBUG OUT OF REGISTRY"
}

END {
	ORS=""
	for(i in planet) {
		for(j in planet[i]) {
			if(!(planet[i][j]["sector"] || !planet[i][j]["name"] || !planet[i][j]["class"])) { continue }
			cur_sector = planet[i][j]["sector"] ? planet[i][j]["sector"] : "unknown"
			cur_number = planet[i][j]["number"] ? planet[i][j]["number"] : 0 
			cur_name = planet[i][j]["name"] ? planet[i][j]["name"] : "unknown" 
			cur_citadel = planet[i][j]["citadel"] ? planet[i][j]["citadel"] : "unknown"
			cur_rlevel = planet[i][j]["rlevel"] ? planet[i][j]["rlevel"] : "unknown"
			cur_fighters = planet[i][j]["fighters"] ? planet[i][j]["fighters"] : "unknown"
			cur_qcanlevel = planet[i][j]["qcanlevel"] ? planet[i][j]["qcanlevel"] : "unknown"
			cur_class = planet[i][j]["class"] ? planet[i][j]["class"] : "unknown"
			cur_owner = planet[i][j]["owner"] ? planet[i][j]["owner"] : "unknown"
			cur_creator = planet[i][j]["creator"] ? planet[i][j]["creator"] : "unknown"
			printf("PLANET_RECORD: %.3d, %.3d, ", cur_sector, cur_number)
			print cur_class", "cur_name", "cur_owner", "cur_creator", "cur_citadel", "cur_rlevel", "cur_fighters", "cur_qcanlevel"\n"
		}
	}
}
