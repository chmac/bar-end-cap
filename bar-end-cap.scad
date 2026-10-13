// Bar end cap: hollow ribbed plug that goes into the pipe, with a
// straight-then-tapered nose that sits outside. Modelled with the axis along
// Z and the pipe end face at z = 0, then flipped at the bottom of the file
// into print orientation (nose tip on the bed, plug pointing up).

// --- Pipe ---
pipe_inner_diameter = 21.9;   // mm
pipe_outer_diameter = 28;   // mm

// --- Plug (goes into the pipe) ---
plug_depth_into_pipe = 20;  // mm
plug_wall_thickness = 3;    // mm
plug_fit_interference = 0.3;   // mm, how much larger the rib tips are than the pipe bore (per side)

// --- Ribs (on the outside of the plug, gripping the pipe wall) ---
rib_count = 6;
rib_width = 2;              // mm, tangential; width well over 2x rib_height gives a soft curve
rib_height = 0.65;             // mm, radial, how far the ribs stand out from the plug body
rib_lead_in_length = 4;     // mm, ribs taper down to the plug body over this length at the insertion end

// --- Nose (outside the pipe) ---
nose_straight_length = 3;  // mm, at pipe_outer_diameter
nose_taper_length = 10;     // mm, shrinks down to the tip
nose_tip_inset = 4;         // mm, how far the tip's edge sits in from the pipe's outer edge (one side, radial)
nose_cap_thickness = 3;     // mm, solid material above the hollow at the tip

// ============================================================
// Parameters end here. Nothing below this line is meant to be edited.
// ============================================================

$fn = 256;  // high accuracy; slow renders are fine

rib_tip_radius = pipe_inner_diameter / 2 + plug_fit_interference;
plug_outer_radius = rib_tip_radius - rib_height;
plug_inner_radius = plug_outer_radius - plug_wall_thickness;
// radius of the arc that is rib_width wide at the base and rib_height tall
rib_arc_radius = (pow(rib_width / 2, 2) + pow(rib_height, 2)) / (2 * rib_height);
overlap = 0.01;             // avoids coincident faces in the union

nose_outer_radius = pipe_outer_diameter / 2;
nose_tip_radius = nose_outer_radius - nose_tip_inset;
nose_length = nose_straight_length + nose_taper_length;

module plug_body() {
    translate([0, 0, -plug_depth_into_pipe])
        cylinder(h = plug_depth_into_pipe + overlap, r = plug_outer_radius);
}

// One straight bore at the plug's inner radius, from the open bottom of the
// plug up through the nose, stopping nose_cap_thickness short of the tip.
module cavity() {
    translate([0, 0, -plug_depth_into_pipe - overlap])
        cylinder(h = plug_depth_into_pipe + nose_length - nose_cap_thickness + overlap,
                 r = plug_inner_radius);
}

module plug_ribs() {
    for (rib_index = [0 : rib_count - 1])
        rotate([0, 0, rib_index * 360 / rib_count])
            translate([0, 0, -plug_depth_into_pipe])
                if (rib_height <= rib_width / 2) {
                    // circular arc through the base corners and the tip: a soft curve, not a semicircle
                    intersection() {
                        translate([rib_tip_radius - rib_arc_radius, 0, 0])
                            cylinder(h = plug_depth_into_pipe, r = rib_arc_radius);
                        translate([plug_outer_radius - overlap, -rib_width / 2, 0])
                            cube([rib_height + overlap, rib_width, plug_depth_into_pipe]);
                    }
                } else {
                    // taller than half the width: a semicircular tip on straight sides
                    hull() {
                        translate([rib_tip_radius - rib_width / 2, 0, 0])
                            cylinder(h = plug_depth_into_pipe, r = rib_width / 2);
                        translate([plug_outer_radius - overlap, -rib_width / 2, 0])
                            cube([overlap, rib_width, plug_depth_into_pipe]);
                    }
                }
}

// Trims the ribs so they taper down to the plug body at the insertion end
// (z = -plug_depth_into_pipe), making the cap easier to push in.
module rib_lead_in_envelope() {
    translate([0, 0, -plug_depth_into_pipe]) {
        cylinder(h = rib_lead_in_length, r1 = plug_outer_radius, r2 = rib_tip_radius);
        translate([0, 0, rib_lead_in_length - overlap])
            cylinder(h = plug_depth_into_pipe - rib_lead_in_length + overlap, r = rib_tip_radius);
    }
}

module nose() {
    cylinder(h = nose_straight_length, r = pipe_outer_diameter / 2);
    translate([0, 0, nose_straight_length - overlap])
        cylinder(h = nose_taper_length + overlap,
                 r1 = pipe_outer_diameter / 2,
                 r2 = nose_tip_radius);
}

// Flipped for printing: the flat nose tip sits on the bed (z = 0) and the
// open end of the plug points up.
translate([0, 0, nose_length])
    rotate([180, 0, 0])
        difference() {
            union() {
                plug_body();
                intersection() {
                    plug_ribs();
                    rib_lead_in_envelope();
                }
                nose();
            }
            cavity();
        }
