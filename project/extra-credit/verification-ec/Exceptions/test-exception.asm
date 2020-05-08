j .realstart
lbi r1, 1
lbi r2, 1
add r3, r1, r2
rti
halt


.realstart:
lbi r3,5
lbi r0,0
siic r6
lbi r4, 44
halt