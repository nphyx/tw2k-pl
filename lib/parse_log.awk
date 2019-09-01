#!/usr/bin/gawk -f
BEGIN {
	sector = "";
	trade_sector = "";
	docking = false;
	query = "F";
	quantity = "F";
	price = "F";
	mode = "F";
	in_cit = 0;
}

/^Sector [[:digit:]]+ has warps to sector/{
	ORS=""
	sector = $2
	printf("SECTOR_RECORD: %.3d, ",sector)
	ORS=", ";
	for(i=8;i<NF;i+=2) {
		gsub(/(\(|\))/,"")
		print $i
	}
	ORS="\n";
	print $NF;
}
/^Sector  : [[:digit:]]+ in/{
	gsub(/\.$/,"");
	ORS=""
	print "REGION_RECORD: "
	sector = $3
	for(i=5;i<NF;i++){if($i != "(unexplored)") print $i" "}
	if($NF != "(unexplored)") print $NF
	ORS="\n"
	printf(", %.3d\n",sector)
}

/^Warps to Sector/{
	ORS="";
	printf("SECTOR_RECORD: %.3d, ",sector)
	ORS=", ";
	for(i=5;i<NF;i+=2) {
		gsub(/(\(|\))/,"")
		print $i
	}
	ORS="\n";
	print $NF;
}

/^Ports/{
	ORS=" ";
	printf("PORT_RECORD: %.3d, ",sector)
	if($(NF-1) == "(Special)") { # special handling for StarDock
		for(i=3;i<NF-3;i++) { last = i; print $i }
		ORS=","
		print $(NF-2)
		ORS="\n"
		print " s, s, s"
	} else if($(NF) == "(Special)") { # special handling for Sol
		for(i=3;i<NF-2;i++) { last = i; print $i }
		ORS=","
		print $(NF-1)
		ORS="\n"
		print " s, s, s"
	} else {
		for(i=3;i<NF-2;i++) { last = i; print $i }
		ORS=", ";
		print $(NF-1); #class
		gsub(/(\(|\))/,"", $NF);
		gsub(/./, "&, ", $NF);
		gsub(/, $/, "", $NF);
		ORS="\n"
		print tolower($NF)
	}
}
/^Sector  : [[:digit:]]+ in/{
	trade_sector = $3
}

/^-=-=-[[:space:]]+Docking Log[[:space:]]+-=-=-/{
	docking = 1
}
/^Command/{
	docking = 0
}

/^How many holds of Fuel Ore do you want to/{
	if(docking) {
		product = "fuel"
		mode = $11
	}
}

/^How many holds of Organics do you want to/{
	if(docking) {
		product = "organics"
		mode = $10
	}
}

/^How many holds of Equipment do you want to/{
	if(docking) {
		product = "equipment"
		mode = $10
	}
}

/^Agreed, [[:digit:]]+ units./{
	if(docking) {
		quantity = $2
	}
}

/^We'll [[:alpha:]]+ them for/{
	if(docking && trade_sector && product && mode && quantity) {
		gsub(/,/, "", $5)
		price = $5
		printf("TRADE_RECORD: %.3d, ", trade_sector)
		print substr(mode, 1, 1)", "product", "quantity", "price"\n"
	}
	product = ""
	mode = ""
	quantity = ""
	price = ""
}

/^\:[[:space:]]+$/{
	in_cit = 1
}

/^: ENDINTERROG/{
	in_cit = 0
}

/^([[:space:]]+[[:digit:]]+)+$/{
	if(in_cit) {
		old_ors = ORS
		ORS = ""
		printf("SECTOR_RECORD: %.3d, ", $1)
		ORS = ", "
		for (i = 2; i < NF; i++) {
			print $i
		}
		ORS = olrd_ors
		print $i"\n"
	}
}
