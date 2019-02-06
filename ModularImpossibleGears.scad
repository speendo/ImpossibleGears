use <Getriebe.scad>

/*[General Parameters]*/

// Part
part="Complete View"; // [Complete View, Layer View, Gears, Top Gears, Top Gears Handle, Bottom Layer, Standard Layer, Second Highest Layer, Top Layer]

// Number of Layers
layerNumber=10;

// Start Number of Viewed Layers (only for LayerView)
viewLayerNumberFrom=0;

// End Number of Viewed Layers
viewLayerNumberTo=0;

// Resolution
$fn = 50; // [0:1:200]

/*[Gear Parameters]*/

// Big Gear: Number of Teeth
bTeeth=60;

// Pinion: Number of Teeth
sTeeth=10;

// Modulus
mod=1;

// Gear Width
tHeight=4; // [0:0.01:50]

// Shaft Diameter
shaft=5; // [0:0.01:50]

// Pressure Angle (Standard is 20)
pAng=20; // [0:0.01:90]

// Helix Angle
ang=0; // [-90:0.1:90]

/* [Top Gear Parameter] */

// Offset from the Outer Border of the Gear
handleOffset = 5;

// Diameter of the Handle
handleDiameter = 3;

// Handle Height
handleHeight = 20;

/* [Material Parameters] */

// Horizontal Offset
hOffset=1; // [0:0.01:50]

// Vertical Offset on Moving Parts (e.g. Gear Shafts)
vMOffset=0.4; // [0:0.01:50]

// Vertical Offset on Static Parts (e.g. Connection Shafts)
vSOffset=0.2; // [0:0.01:50]

// Vertical Offset between Gear and Bezel
vGearOffset=1; // [0:0.01:50]

// Vertical Outer Thickness (added to calculations)
vOuterThickness=1; // [0:0.01:50]

// Radius of the Socket where the Gear Rests
gearSocketRadius=1;  // [0:0.01:50]

/*[Hidden]*/

centerOffset = (d(mod, sTeeth) + d(mod, bTeeth))/2;
transmissionHeight = 2*tHeight+3*hOffset;
layerHeight = tHeight+3*hOffset;

if (part == "Complete View") {
	for(i=[0:layerNumber]) {
		color("Thistle",0.5) {
			pBezel(i,layerNumber);
		}
		color("GreenYellow",1) {
			pTransmission(i, layerNumber);
		}
	}
} else if (part == "Layer View") {
	realViewLayerNumberTo = min(viewLayerNumberTo, layerNumber);
	for(i=[viewLayerNumberFrom:realViewLayerNumberTo]) {
		color("Thistle",0.5) {
			pBezel(i,layerNumber);
		}
		color("GreenYellow",1) {
			pTransmission(i, layerNumber);
		}
	}
} else if (part == "Gears") {
	transmission();
} else if (part == "Top Gears") {
	topGears();
} else if (part == "Top Gears Handle") {
	topGearsHandle();
} else if (part == "Bottom Layer") {
	standardBezel(0, layerNumber);
} else if (part == "Standard Layer") {
	standardBezel(1, layerNumber);
} else if (part == "Second Highest Layer") {
	standardBezel(layerNumber - 1, layerNumber);
} else if (part == "Top Layer") {
	standardBezel(layerNumber, layerNumber);
}

module pBezel(i, iMax) {
	translate([0,0,i*layerHeight]) {
		standardBezel(i, iMax);
	}
}


module standardBezel(i, iMax) {
	difference() {
		if (i == 0) {
			cylinder(h=layerHeight, r=centerOffset+shaft/2);
		} else {
			cylinder(h=layerHeight, r=centerOffset+shaft/2+vSOffset+vOuterThickness);
		}
		union() {
			if (i > 0) {
				makeShaft(i,layerHeight+2,do(mod, bTeeth)+2*vMOffset,zOffset=-1);
			}
			if (i < iMax) {
				difference() {
					makeShaft(i+1, layerHeight-hOffset+1, do(mod, sTeeth)+2*vGearOffset, zOffset=hOffset);
					makeShaft(i+1, hOffset, shaft+vGearOffset+2*gearSocketRadius, zOffset=hOffset);
				}
			}
			if (i > 0) {
				// Main Shaft Hole
				makeShaft(i-1, layerHeight+2, shaft+vSOffset, zOffset=-1);
				// Connection Shaft Holes
				makeShaft(i+2, layerHeight+2, shaft+vSOffset, zOffset=-1);
				makeShaft(i+3.5, layerHeight+2, shaft+vSOffset, zOffset=-1);
			}
		}
	}
	if (i < iMax - 1) { // until last 3 layers
		// Main Shaft
		makeShaft(i+1,3*layerHeight, shaft);
		// Connection Shafts
		makeShaft(i+3,2*layerHeight, shaft);
		makeShaft(i+4.5,2*layerHeight, shaft);
	} else if (i == iMax - 1) { // on pre ultimate layer
		// Main Shaft
		// This one should hold the gear
		difference() {
			union() {
				makeShaft(i+1,2*layerHeight, shaft);
				rotate([0,0,(i+1)*60]) {
					translate([centerOffset,0,2*layerHeight]) {
						cylinder(d1=shaft+4*vMOffset, d2=shaft, h=2*hOffset);
					}
				}
			}
			rotate([0,0,(i+1)*60]) {
				translate([-(shaft+4*vMOffset)/2+centerOffset-1, -2.5*vMOffset, layerHeight]) {
					cube([shaft+4*vMOffset+2, 5*vMOffset, layerHeight+2*hOffset+1]);
				}
			}
		}
		// Connection Shafts
		makeShaft(i+3,2*layerHeight, shaft);
		makeShaft(i+4.5,2*layerHeight, shaft);
	} else { // last layer
		// Don't make shafts
	}
	// first layer should have a ring gear
	if (i == 0) {
		rotate([0,0,180/(2 * sTeeth + bTeeth)]) {
			cylinder(h=hOffset, r=do(mod, sTeeth + bTeeth/2));
			hohlrad(modul=mod, zahnzahl=2 * sTeeth + bTeeth, breite=layerHeight, randbreite=vOuterThickness, eingriffswinkel=pAng, schraegungswinkel=ang);
		}
	}
}

module pTransmission(i, iMax) {
	top = i == iMax ? true : false;
	
	if (i > 0) {
		rotate([0,0,i*60]) {
			translate([centerOffset,0,i*layerHeight]) {
				rotate([0,0,180/sTeeth]) {
					rTransmission(top=top);
				}
			}
		}
	} else {
		// don't make a gear on the first layer
	}
}

module rTransmission(top=false) {
	translate([0,0,tHeight+2*hOffset]) {
		rotate([180,0,0]) {
			if (top) {
				topGears();
				translate([dr(mod, bTeeth)/2-handleOffset, 0, -handleHeight]) {
					topGearsHandle();
				}
			} else {
				transmission();
			}
		}
	}
}

module topGearsHandle() {
	cylinder(h=handleHeight, d=handleDiameter);
	translate([0,0,handleHeight]) {
		cylinder(h=tHeight - hOffset, d=handleDiameter-2*vSOffset);

	}
}

module topGears() {
	difference() {
		transmission(opt=false);
		translate([dr(mod, bTeeth)/2-handleOffset,0,-1]) {
			cylinder(h=tHeight+2, d=handleDiameter-vSOffset);
		}
	}
}

module transmission(opt=true) {
	standardGear(bTeeth, tHeight, opt=opt);
	standardGear(sTeeth, transmissionHeight, opt=opt);
}


module standardGear(teeth, height, opt=true) {
	hole = shaft + 2 * vMOffset;
	stirnrad(modul=mod, zahnzahl=teeth, breite=height, bohrung=hole, eingriffswinkel=pAng, schraegungswinkel=ang, optimiert=opt);
}

module makeShaft(i, h, d, zOffset=0) {
	rotate([0,0,i*60]) {
		translate([centerOffset,0,zOffset]) {
			cylinder(h=h, d=d);
		}
	}
}

function d(mod, teeth)= teeth * mod;
function do(mod, teeth) = (teeth + 2) * mod;
function dr(mod, teeth) = (teeth - 2.5) * mod;
