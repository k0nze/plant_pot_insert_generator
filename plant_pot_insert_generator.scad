$fa = 1;
$fs = 1;

top_diameter = 65;
bottom_diameter = 48;
pot_height = 61;

wall_thickness = 1;
bottom_height = 1;

hole_diameter = 8;
hole_ring_radii = [18, 30, ];
holes_per_rings = [8, 16, 16];

standoff_bottom_width = 6;
standoff_height = 6;
standoff_top_width = 10;
standoff_top_distance = 2;

num_cutouts = 8;

lip_width = 2;


bottom_radius = bottom_diameter / 2;
top_radius = top_diameter / 2;
hole_radius = hole_diameter / 2;

pot_height_wo_standoffs = pot_height - standoff_height;

standoff_overhang = (standoff_top_width - standoff_bottom_width) / 2;
num_standoffs = floor(bottom_radius / (standoff_top_width + standoff_top_distance));

cutout_rotation_degree_increment = 360 / num_cutouts;

wall_angle = atan( (top_radius - bottom_radius) / pot_height_wo_standoffs);

lip_height = (lip_width - wall_thickness) / tan(wall_angle);



module bottom_hole() {
    translate([0,0,-1]) {
        cylinder(h=standoff_height+bottom_height+2, r1=hole_radius, r2=hole_radius);
    }
}

difference() {
    union() {
        difference() {
            rotate_extrude(angle=360, convexity = 10) {
                // standoffs
                for(i = [0 : 1 : num_standoffs-1]) {
                    x_offset = i*(standoff_top_width+standoff_top_distance);
                    polygon(points=[
                        [x_offset + 0,standoff_height],
                        [x_offset + standoff_overhang, 0],
                        [x_offset + standoff_overhang+standoff_bottom_width, 0],
                        [x_offset + standoff_top_width, standoff_height]
                    ]);
                }

                // wall
                translate([0,standoff_height,0]) {
                    polygon(points=[
                        [0, 0],
                        [bottom_radius, 0],
                        //[bottom_radius, bottom_height],
                        [top_radius, pot_height_wo_standoffs],
                        [top_radius - wall_thickness, pot_height_wo_standoffs],
                        [top_radius - lip_width, pot_height_wo_standoffs],
                        [top_radius - lip_width, pot_height_wo_standoffs - lip_height],
                        [bottom_radius - wall_thickness, bottom_height],
                        [0, bottom_height]
                    ]);
                }
            }

            // center hole
            bottom_hole();

            // hole rings
            for(i = [0:1:len(hole_ring_radii)-1]) {

                hole_ringe_radius = hole_ring_radii[i];
                holes_per_ring = holes_per_rings[i];
                rotation_degree_increment = 360 / holes_per_ring;

                for(j = [0:1:holes_per_ring-1]) {
                    rotate([0,0,j*rotation_degree_increment]) {
                        translate([hole_ringe_radius,0,0]) {
                            bottom_hole();
                        }
                    }
                }
            }
        } // end difference

        // outer standoff
        difference() {
            cylinder(h=standoff_height, r1=bottom_radius, r2=bottom_radius);
            translate([0,0,-1]) {
                cylinder(h=standoff_height+2, r1=bottom_radius - wall_thickness, r2=bottom_radius - wall_thickness);
            }
        }

    }
    // bottom cutouts
    union() {
        for(i = [0:1:num_cutouts-1]) {
            rotate([0,0,i*cutout_rotation_degree_increment]) {
                translate([-standoff_top_width/2,-10,0]){
                    rotate([90,0,0]) {
                        linear_extrude(height=bottom_diameter+10) {
                            polygon(points=[
                                [0,-0.1],
                                [standoff_top_width,-0.1],
                                [standoff_top_width - standoff_overhang,standoff_height],
                                [standoff_overhang, standoff_height]
                            ]);
                        }
                    }
                }
            }
        }
    } // end union
} // end difference


