/**
 * @name parametric-pulley-generator
 * @category Printed
 * @using 1 x m3 nut, normal or nyloc
 * @using 1 x m3x10 set screw or 1 x m3x8 grub screw
 */

function calc_pulley_dia_tooth_spacing_curvefit(teeth, b,c,d) = ((c * pow(teeth,d)) / (b + pow(teeth,d))) * teeth ;

function calc_pulley_dia_tooth_spacing(teeth, tooth_pitch, pitch_line_offset) = (2*((teeth*tooth_pitch)/(3.14159265*2)-pitch_line_offset)) ;

// Main Module
//

// Some globals
NEMA17_SHAFT_DIA = 5.2;
M3_DIA       = 3.2;
M3_NUT_HEX       = 1 ;
M3_NUT_FLATS     = 5.7;
M3_NUT_DEPTH     = 2.7;
M3_NUT_POINTS    = 2*((M3_NUT_FLATS/2)/cos(30)); // This is needed for the nut tra

module pulley(
        belt_description
        ,pulley_OD
        ,teeth
        ,tooth_depth
        ,tooth_width
        ,additional_tooth_depth
        ,additional_tooth_width
        ,motor_shaft = NEMA17_SHAFT_DIA ) {

    echo (str( "Belt type = ",        belt_description
                ,"; Pulley Outside Diameter = ",pulley_OD,"mm "
                ,"; Number of teeth = ",    teeth
                ,"; Tooth Depth = ",        tooth_depth
                ,"; Tooth Width = ",        tooth_width
         ));

    // calculated constants
    nut_elevation = pulley_b_ht/2;

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
            // base
            if ( pulley_b_ht < 2 ) { echo ("CAN'T DRAW PULLEY BASE, HEIGHT LESS THAN 2!!!"); } else {
                rotate_extrude($fn=pulley_b_dia*2)
                {
                    square([pulley_b_dia/2-1,pulley_b_ht]);
                    square([pulley_b_dia/2,pulley_b_ht-1]);
                    translate([pulley_b_dia/2-1,pulley_b_ht-1]) circle(1);
                }
            }

            // we need to push the pulley and retainer "up" above the idler (if there is one)
            translate([0,0,idler_ht]) {
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
                                children();
                            }
                }

                //belt retainer / idler
                if ( retainer_ht > 0 ) {translate ([0,0, pulley_b_ht + pulley_t_ht ])
                    rotate_extrude($fn=teeth*4)
                        polygon([[0,0],[pulley_OD/2,0],[pulley_OD/2 + retainer_ht , retainer_ht],[0 , retainer_ht],[0,0]]);}
            }

            if ( idler_ht > 0 ) {translate ([0,0, pulley_b_ht])
                rotate_extrude($fn=teeth*4)
                    polygon([[0,0],[pulley_OD/2 + idler_ht,0],[pulley_OD/2 , idler_ht],[0 , idler_ht],[0,0]]);}

        }

        //hole for motor shaft
        translate([0,0,-1])cylinder(r=motor_shaft/2,h=pulley_b_ht + idler_ht + pulley_t_ht + retainer_ht + 2,$fn=motor_shaft*4);

        //captive nut and grub screw holes
        subtractive_captive_nut_and_grub_screw(pulley_b_ht, pulley_b_dia, motor_shaft , nut_elevation);

    }

}

// Captive nut and grub screw holes
module subtractive_captive_nut_and_grub_screw( pulley_b_ht, pulley_b_dia, motor_shaft , nut_elevation) {


    if ( pulley_b_ht < M3_NUT_FLATS ) {
        echo ("CAN'T DRAW CAPTIVE NUTS, HEIGHT LESS THAN NUT DIAMETER!!!");
    } else {
        if ( (pulley_b_dia - motor_shaft)/2 < M3_NUT_DEPTH + 3 ) {
            echo ("CAN'T DRAW CAPTIVE NUTS, DIAMETER TOO SMALL FOR NUT DEPTH!!!");
        } else {
            for(j=[1:no_of_nuts]) rotate([0,0,j*nut_angle])
                translate([0,0,nut_elevation])rotate([90,0,0]) union() {
                    //entrance
                    translate([0,-pulley_b_ht/4-0.5,motor_shaft/2+M3_NUT_DEPTH/2+nut_shaft_distance]) cube([M3_NUT_FLATS,pulley_b_ht/2+1,M3_NUT_DEPTH],center=true);

                    //nut
                    if ( M3_NUT_HEX > 0 )
                    {
                        // hex nut
                        translate([0,0.25,motor_shaft/2+M3_NUT_DEPTH/2+nut_shaft_distance]) rotate([0,0,30]) cylinder(r=M3_NUT_POINTS/2,h=M3_NUT_DEPTH,center=true,$fn=6);
                    } else {
                        // square nut
                        translate([0,0.25,motor_shaft/2+M3_NUT_DEPTH/2+nut_shaft_distance]) cube([M3_NUT_FLATS,M3_NUT_FLATS,M3_NUT_DEPTH],center=true);
                    }

                    //grub screw hole
                    rotate([0,0,22.5])cylinder(r=M3_DIA /2,h=pulley_b_dia/2+1,$fn=8);
                }
        }
    }
}
