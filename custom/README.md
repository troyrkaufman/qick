# Custom Directory Update

## Overview

I have created a new wrapper module within the `custom` directory. This wrapper integrates open-source AXI4 and AXIS asynchronous FIFO interfaces to replace the proprietary Xilinx IP blocks originally used in the design.

## Important User Actions

- **XPR Project Settings**:  
  Users need to update their XPR project settings by **adding two include paths** pointing to the new FIFO wrapper and related source files. Without these include paths, the project will fail to find the custom modules.

* set_property include_dirs [list "../../../submodules/path/to/common_cells/include/" "../../../submodules/axi/include/" \ ] [current_fileset]

## Current Issues

While elaborating the design, I am encountering **enum warnings** and **timescale warnings**. These warnings occur during elaboration and currently prevent the simulation from running.

- I do **not** believe these warnings should stop the simulation entirely.
- However, it might be an indicator of a deeper issue that needs further investigation.

## Next Steps

- Investigate the cause of the enum and timescale warnings more thoroughly.
- Work on resolving these warnings to enable successful simulation.
- Continue improving and testing the custom wrapper modules.
