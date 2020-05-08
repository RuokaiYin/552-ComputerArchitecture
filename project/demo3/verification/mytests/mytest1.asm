lbi r3, 0
lbi r2, 0
lbi r4, 0
st r3, r2, 10
beqz r4, 2
lbi r1, 0
andni r2, r2, 1
ld r4, r2, 10
lbi r7, 6
halt
