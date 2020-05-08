// test a combination of forwarding (EX->EX, MEM->EX, MEM->MEM) and stalling
lbi r1, 0 // L1: load 0 into r1
lbi r2, 4 // L2: load 4 into r2
st r2, r1, 0 // L3: store r2 (4) into M[0]; require MEM->EX forwarding of r1, EX->EX forwarding of r2 or MEM->MEM forwarding of r2 depending on implementation.
stu r1, r2, 4 // L4: store r1(0) into M[8], r2 = r2 + 4 = 8; require MEM->EX forwarding of r2; Bypassing is also tested here for r1
ld r3, r1, 0 // L5: load M[0] to r3(4)
st r3, r2, 4 // L6: store r3(4) into M[C]; require MEM->MEM forwarding of r3
ld r4, r2, 4 // L7: load M[C] to r4(4)
addi r4, r4, 4 // L8: r4 = r4 + 4 = 8; no possible forwarding, stalling required
halt
