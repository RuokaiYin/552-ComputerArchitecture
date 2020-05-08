// test MEM->EX forwarding
lbi r1, 1 // L1: load 1 into r1
lbi r2, 4 // L2: load 4 into r2
slli r3, r1, 1 // L3: r3 = r1*2 = 2; require MEM->EX forwarding of r1
srli r4, r2, 2 // L4: r4 = rightRotate r2 by 2 = 1; require MEM->EX forwarding of r2
addi r4, r3, 1 // L5: r4 = r3 + 1 = 3; require MEM->EX forwarding of r3
halt

