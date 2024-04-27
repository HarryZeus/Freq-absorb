# Freq-absorb
Balancing key-value stores under write-intensive workloads

We reuse the project of reference_switch in NetFPGA-SUME, add our hardware primitives into it. 
Specifically, we embedded Freq-absorb into the datapath of the reference_switch. When using the code from this repository, it is necessary to replace the original nf_datapath.v in the reference_switch project.

After compiling the project and burning the bitstream into the FPGA, the testing programs for both the client and server can be started.
