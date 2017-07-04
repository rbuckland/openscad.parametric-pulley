/**
 * @name Pulley
 * @category Printed
 * @using 1 x m3 nut, normal or nyloc
 * @using 1 x m3x10 set screw or 1 x m3x8 grub screw
 */

function tooth_spaceing_curvefit (b,c,d)
    = ((c * pow(teeth,d)) / (b + pow(teeth,d))) * teeth ;

function tooth_spacing(tooth_pitch,pitch_line_offset)
    = (2*((teeth*tooth_pitch)/(3.14159265*2)-pitch_line_offset)) ;

    // Main Module

module pulley( belt_type , pulley_OD , tooth_depth , tooth_width )
{
    echo (str("Belt type = ",belt_type,"; Number of teeth = ",teeth,"; Pulley Outside Diameter = ",pulley_OD,"mm "));
    tooth_distance_from_centre = sqrt( pow(pulley_OD/2,2) - pow((tooth_width+additional_tooth_width)/2,2));
    tooth_width_scale = (tooth_width + additional_tooth_width ) / tooth_width;
    tooth_depth_scale = ((tooth_depth + additional_tooth_depth ) / tooth_depth) ;


    //    ************************************************************************
    //    *** uncomment the following line if pulley is wider than puller base ***
    //    ************************************************************************

    //    translate ([0,0, pulley_b_ht + pulley_t_ht + retainer_ht ]) rotate ([0,180,0])

    difference()
    {     
	union()
	{
	    //base

	    if ( pulley_b_ht < 2 ) { echo ("CAN'T DRAW PULLEY BASE, HEIGHT LESS THAN 2!!!"); } else {
		rotate_extrude($fn=pulley_b_dia*2)
		{
		    square([pulley_b_dia/2-1,pulley_b_ht]);
		    square([pulley_b_dia/2,pulley_b_ht-1]);
		    translate([pulley_b_dia/2-1,pulley_b_ht-1]) circle(1);
		}
	    }

	    difference()
	    {
		//shaft - diameter is outside diameter of pulley

		translate([0,0,pulley_b_ht]) 
		    rotate ([0,0,360/(teeth*4)]) 
		    cylinder(r=pulley_OD/2,h=pulley_t_ht, $fn=teeth*4);

		//teeth - cut out of shaft

		for(i=[1:teeth]) 
		    rotate([0,0,i*(360/teeth)])
			translate([0,-tooth_distance_from_centre,pulley_b_ht -1]) 
			scale ([ tooth_width_scale , tooth_depth_scale , 1 ]) 
			{
			    //children is the "tooth_profile"
			    children()
			}

	    }

	    //belt retainer / idler
	    if ( retainer > 0 ) {translate ([0,0, pulley_b_ht + pulley_t_ht ]) 
		rotate_extrude($fn=teeth*4)  
		    polygon([[0,0],[pulley_OD/2,0],[pulley_OD/2 + retainer_ht , retainer_ht],[0 , retainer_ht],[0,0]]);}

	    if ( idler > 0 ) {translate ([0,0, pulley_b_ht - idler_ht ]) 
		rotate_extrude($fn=teeth*4)  
		    polygon([[0,0],[pulley_OD/2 + idler_ht,0],[pulley_OD/2 , idler_ht],[0 , idler_ht],[0,0]]);}

	}

	//hole for motor shaft
	translate([0,0,-1])cylinder(r=motor_shaft/2,h=pulley_b_ht + pulley_t_ht + retainer_ht + 2,$fn=motor_shaft*4);

	//captive nut and grub screw holes

	if ( pulley_b_ht < m3_nut_flats ) { 
	    echo ("CAN'T DRAW CAPTIVE NUTS, HEIGHT LESS THAN NUT DIAMETER!!!"); 
	} else {
	    if ( (pulley_b_dia - motor_shaft)/2 < m3_nut_depth + 3 ) { 
                echo ("CAN'T DRAW CAPTIVE NUTS, DIAMETER TOO SMALL FOR NUT DEPTH!!!"); 
            } else {
		for(j=[1:no_of_nuts]) rotate([0,0,j*nut_angle])
		    translate([0,0,nut_elevation])rotate([90,0,0]) union() {
			//entrance
			translate([0,-pulley_b_ht/4-0.5,motor_shaft/2+m3_nut_depth/2+nut_shaft_distance]) cube([m3_nut_flats,pulley_b_ht/2+1,m3_nut_depth],center=true);

			//nut
			if ( m3_nut_hex > 0 )
			{
			    // hex nut
			    translate([0,0.25,motor_shaft/2+m3_nut_depth/2+nut_shaft_distance]) rotate([0,0,30]) cylinder(r=m3_nut_points/2,h=m3_nut_depth,center=true,$fn=6);
			} else {
			    // square nut
			    translate([0,0.25,motor_shaft/2+m3_nut_depth/2+nut_shaft_distance]) cube([m3_nut_flats,m3_nut_flats,m3_nut_depth],center=true);
			}

			//grub screw hole
			rotate([0,0,22.5])cylinder(r=m3_dia/2,h=pulley_b_dia/2+1,$fn=8);
		    }
	    }
	}
    }

}
