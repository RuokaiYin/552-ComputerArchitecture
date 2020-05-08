// While loop five times, where predict not taken better
lbi r1, 5 // L1 load 5 into r1
beqz r1, 4 // L2 branch to L5 if r1 == 0
addi r1, r1, -1 // L3 r1 = r1-1
j -6 // L4 jump to L2
halt // L5 r1 should be 0
