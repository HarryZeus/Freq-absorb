# Freq-absorb
Balancing key-value stores under write-intensive workloads

we present Freq-absorb, a novel key-value store architecture that appends a delayed-write mechanism in the switch data plane to absorb frequent write queries for hot items. It effectively balances load under write-intensive workloads without involving the controller. Moreover, Freq-absorb also includes an availability mechanism that ensures service availability when experiencing switch state transition or failure. We implement a prototype using an FPGA-integrated switch, which has an optimized packet-processing performance while maintaining enough memory to achieve in-switch cache and the write buffer simultaneously. Our testbed shows that Freq-absorb can achieve 3.6x system throughput gains compared to systems without in-network processing when handling a skewed workload consisting of 70% reads and 30% writes. Moreover, it can reduce the load on back-end servers to 30% in total.

We reuse the project of reference_switch in NetFPGA-SUME, add our hardware primitives into it.
