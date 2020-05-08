// to test the EX->EX forwarding
lbi r1, 0 // L1: load 0 into r1
lbi r2, 4 // L2: load 4 into r2
addi r1, r2, 4 // L3: r1 = r2 + 4 = 8; require EX->EX forwarding of r2
subi r2, r1, 8 // L4: r2 = r1 - 8 = 0; require EX->EX forwarding of r1
xori r3, r2, 31 // L5: r3 = r2 ^ 31 = 31(0x1f); require EX->EX forwarding of r2
halt
