use <Getriebe.scad>

$fn = 50;

bTeeth=60;
sTeeth=10;

layerNumber=10;

mod=1;
bevel=60;
tHeight=4;
shaft=5;
pAng=20;
ang=0;

hOffset=0.5;
vMOffset=1;
vSOffset=0.2;
vOuterThickness=1;

gearSocketRadius=1;

centerOffset = (d(mod, sTeeth) + d(mod, bTeeth))/2;
transmissionHeight = 2*tHeight+3*hOffset;
layerHeight = tHeight+3*hOffset;

for(i=[0:layerNumber]) {
	color("Thistle",0.5) {
		standardBezel(i,layerNumber);
	}
	color("GreenYellow",1) {
		pTransmission(i);
	}
}

module standardBezel(i, iMax) {
	translate([0,0,i*layerHeight]) {
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
						makeShaft(i+1, layerHeight-hOffset+1, do(mod, sTeeth)+2*vMOffset, zOffset=hOffset);
						makeShaft(i+1, hOffset, shaft+vMOffset+2*gearSocketRadius, zOffset=hOffset);
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
			makeShaft(i+1,2*layerHeight, shaft);
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
}

module pTransmission(i) {
	if (i > 0) {
		rotate([0,0,i*60]) {
			translate([centerOffset,0,i*layerHeight]) {
				rotate([0,0,180/sTeeth]) {
					rTransmission();
				}
			}
		}
	} else {
		// don't make a gear on the first layer
	}
}

module rTransmission() {
	translate([0,0,tHeight+2*hOffset]) {
		rotate([180,0,0]) {
			transmission();
		}
	}
}

module transmission() {
	standardGear(bTeeth, tHeight);
	standardGear(sTeeth, transmissionHeight);
}


module standardGear(teeth, height) {
	hole = shaft + 2 * vMOffset;
	stirnrad(modul=mod, zahnzahl=teeth, breite=height, bohrung=hole, eingriffswinkel=pAng, schraegungswinkel=ang, optimiert=true);
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
