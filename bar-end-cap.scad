// Bar end cap: hollow ribbed plug that goes into the pipe, with a
// straight-then-tapered nose that sits outside. Axis along Z, the pipe
// end face is at z = 0.

// --- Pipe ---
pipe_inner_diameter = 21.9;   // mm
pipe_outer_diameter = 28;   // mm

// --- Plug (goes into the pipe) ---
plug_depth_into_pipe = 20;  // mm
plug_wall_thickness = 3;    // mm
plug_fit_clearance = 0.2;   // mm, gap between rib tips and the pipe wall

// --- Ribs (on the outside of the plug, gripping the pipe wall) ---
rib_count = 6;
rib_width = 2;              // mm, tangential; width well over 2x rib_height gives a soft curve
rib_height = 1;             // mm, radial, how far the ribs stand out from the plug body

// --- Nose (outside the pipe) ---
nose_straight_length = 3;  // mm, at pipe_outer_diameter
nose_taper_length = 10;     // mm, shrinks down to the tip
nose_tip_inset = 4;         // mm, how far the tip's edge sits in from the pipe's outer edge (one side, radial)
nose_wall_thickness = 3;    // mm, must be less than nose_taper_length

// ============================================================
// Parameters end here. Nothing below this line is meant to be edited.
// ============================================================

$fn = 256;  // high accuracy; slow renders are fine

rib_tip_radius = pipe_inner_diameter / 2 - plug_fit_clearance;
plug_outer_radius = rib_tip_radius - rib_height;
plug_inner_radius = plug_outer_radius - plug_wall_thickness;
// radius of the arc that is rib_width wide at the base and rib_height tall
rib_arc_radius = (pow(rib_width / 2, 2) + pow(rib_height, 2)) / (2 * rib_height);
overlap = 0.01;             // avoids coincident faces in the union

nose_outer_radius = pipe_outer_diameter / 2;
nose_tip_radius = nose_outer_radius - nose_tip_inset;
nose_cavity_radius = nose_outer_radius - nose_wall_thickness;
nose_cavity_taper_length = nose_taper_length - nose_wall_thickness;
// outside radius where the cavity stops, less the wall
nose_cavity_tip_radius = nose_outer_radius
    + (nose_tip_radius - nose_outer_radius) * nose_cavity_taper_length / nose_taper_length
    - nose_wall_thickness;

module plug_body() {
    translate([0, 0, -plug_depth_into_pipe])
        cylinder(h = plug_depth_into_pipe + overlap, r = plug_outer_radius);
}

// One continuous cavity through the plug and the nose, open at the bottom.
module cavity() {
    translate([0, 0, -plug_depth_into_pipe - overlap])
        cylinder(h = plug_depth_into_pipe + nose_straight_length + 2 * overlap,
                 r = plug_inner_radius);
    // nose straight section, widened to the nose wall
    cylinder(h = nose_straight_length, r = nose_cavity_radius);
    // nose taper, same slope as the outside, stopping nose_wall_thickness short of the tip
    translate([0, 0, nose_straight_length - overlap])
        cylinder(h = nose_cavity_taper_length + overlap,
                 r1 = nose_cavity_radius,
                 r2 = nose_cavity_tip_radius);
}

module plug_ribs() {
    for (rib_index = [0 : rib_count - 1])
        rotate([0, 0, rib_index * 360 / rib_count])
            translate([0, 0, -plug_depth_into_pipe])
                // circular arc through the base corners and the tip: a soft curve, not a semicircle
                intersection() {
                    translate([rib_tip_radius - rib_arc_radius, 0, 0])
                        cylinder(h = plug_depth_into_pipe, r = rib_arc_radius);
                    translate([plug_outer_radius - overlap, -rib_width / 2, 0])
                        cube([rib_height + overlap, rib_width, plug_depth_into_pipe]);
                }
}

module nose() {
    cylinder(h = nose_straight_length, r = pipe_outer_diameter / 2);
    translate([0, 0, nose_straight_length - overlap])
        cylinder(h = nose_taper_length + overlap,
                 r1 = pipe_outer_diameter / 2,
                 r2 = nose_tip_radius);
}

difference() {
    union() {
        plug_body();
        plug_ribs();
        nose();
    }
    cavity();
}
