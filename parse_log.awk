#!/usr/bin/gawk -f
/^Sector/{
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
	#FS=" :,";
	ORS=" ";
	printf("PORT_RECORD: %.3d, ",sector)
	if($(NF-1) == "(Special)") { # special handling for stardock
		for(i=3;i<NF-3;i++) { last = i; print $i }
		ORS=","
		print $(NF-2)
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
