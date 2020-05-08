lbi r1, 0
lbi r3, 0
st r3, r1, 2
ld r2, r1, 2
st r2, r1, 4 // MEM-MEM fowarding should increase CPI here.
addi r2, r2, 1
halt 
