# Bar end cap

A parametric 3D-printable end cap for a round bar or pipe, written in [OpenSCAD](https://openscad.org/).

It has a hollow, ribbed plug that fits inside the pipe, and a nose that sits outside the pipe end. The nose is straight at first and then tapers to a rounded-off tip.

## Usage

1. Open `bar-end-cap.scad` in OpenSCAD.
2. Edit the parameters at the top of the file to match your pipe.
3. Render (F6) and export as STL (F7). Exported STLs go in `stl/`, which is git-ignored.

Or from the command line:

```sh
openscad -o stl/bar-end-cap.stl bar-end-cap.scad
```

Rendering is slow because `$fn = 256`. That's deliberate.

## Parameters

| Group | Parameter | Meaning |
| --- | --- | --- |
| Pipe | `pipe_inner_diameter`, `pipe_outer_diameter` | Pipe dimensions in mm |
| Plug | `plug_depth_into_pipe`, `plug_wall_thickness`, `plug_fit_clearance` | How deep the plug goes, its wall, and the gap between rib tips and the pipe wall |
| Ribs | `rib_count`, `rib_width`, `rib_height` | Gripping ribs on the outside of the plug |
| Nose | `nose_straight_length`, `nose_taper_length`, `nose_tip_inset`, `nose_cap_thickness` | Shape of the part that sits outside the pipe |

Defaults are for a 28 mm OD / 21.9 mm ID pipe. Test-fit and adjust `plug_fit_clearance` for your printer.

## License

See [LICENSE](LICENSE).
