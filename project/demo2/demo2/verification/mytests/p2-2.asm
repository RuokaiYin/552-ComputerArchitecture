// While loop four times, where predict taken better
lbi r1, 5 // L1 load 5 into r1
addi r1, r1, -1 // L2 r1 = r1-1
bnez r1, -4 // L3 branch to L2 if r1 != 0
halt // r1 should be 0
