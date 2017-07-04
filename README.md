# openscad.parametric-pulley


This is a generic version of [thingiverse.com/thing:16627](thingiverse.com/thing:16627)

I had a need to produce a timing pulley for a real car timing belt.
The original author's design was spot on, I just needed to modularise it a bit and do some minor cleanup.

Enjoy!

## Usage

You will need to create a "tooth profile". This is the "negative" cut out on the pulley, eg: the Positive profile of a tooth on the belt.

```
// Tooth profile modules

module tooth_profile_MXL()
        {
        linear_extrude(height=pulley_t_ht+2) polygon([[-0.660421,-0.5],[-0.660421,0],[-0.621898,0.006033],[-0.587714,0.023037],[-0.560056,0.049424],[-0.541182,0.083609],[-0.417357,0.424392],[-0.398413,0.458752],[-0.370649,0.48514],[-0.336324,0.502074],[-0.297744,0.508035],[0.297744,0.508035],[0.336268,0.502074],[0.370452,0.48514],[0.39811,0.458752],[0.416983,0.424392],[0.540808,0.083609],[0.559752,0.049424],[0.587516,0.023037],[0.621841,0.006033],[0.660421,0],[0.660421,-0.5]]);
        }
```

Take a look at 

* [Pulley_T-MXL-XL-HTD-GT2_N-tooth.scad](Pulley_T-MXL-XL-HTD-GT2_N-tooth.scad) for inspiration.
