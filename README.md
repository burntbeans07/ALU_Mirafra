ALU Design and Verification

Overview:

This project implements a parameterizable N-bit Arithmetic Logic Unit (ALU) in Verilog along with a self-checking testbench for functional verification.
The ALU supports logical, shift, rotate, and comparison operations. The testbench verifies correctness across valid and invalid input conditions.

The ALU takes the following inputs:
CLK
RST - Asynchronous
CE - CLK Enable
OPA – Operand A (N-bit)
OPB – Operand B (N-bit)
cmd – 4-bit command selector
input_valid – 2-bit validity signal

Outputs:

res – Result (2*N-bit)
err – Error flag
OFLOW – Signed overflow flag
cout – Carry out
G – Greater flag
E – Equal flag
L – Less flag

Supported Operations

•	Mode = 1 - Arithmetic Operations: 

1.	CMD=0, Unsigned Addition
2.	CMD=1, Unsigned Subtraction
3.	CMD=2, Unsigned Addition with Cin
4.	CMD=3, Unsigned Subtraction with Cin
5.	CMD=4, Increment A
6.	CMD=5, Decrement A
7.	CMD=6, Increment B
8.	CMD=7, Decrement B
9.	CMD=8. Unsigned Compare
10.	CMD=9, Increment and Multiply
11.	CMD=10, Shift Left and Multiply
12.	CMD=11, Signed Addition and Compare
13.	CMD=12, Signed Subtraction and Compare

•	Mode = 2: Logical Operations:

1.	CMD=0, Bitwise AND
2.	CMD=1, Bitwise NAND
3.	CMD=2, Bitwise OR
4.	CMD=3, Bitwise NOR
5.	CMD=4, Bitwise XOR
6.	CMD=5, Bitwise XNOR
7.	CMD=6, NOT A
8.	CMD=7, NOT B
9.	CMD=8. Shift Right A
10.	CMD=9, Shift Left A
11.	CMD=10, Shift Right B
12.	CMD=11, Shift Left B
13.	CMD=12, Rotate A right by B bits
14.	CMD=13, Rotate A left by B bits


Input Valid Handling

For binary operations, input_valid must be 2'b11.
For single operand A operations, input_valid[0] must be 1.
For single operand B operations, input_valid[1] must be 1.
If an operation is attempted with invalid inputs: an error is thrown and the previous outputs are held.

Multiply Operations follow a 2-cycle latency. If inputs are given at N clock edge then the output will be received at N+2 clock edge and new input can be received at N+2 clock edge, it’s output will be shown at N+4 clock edge. If new inputs are given in the processing cycle (N+1) clock edge, then they will be discarded. However, if CMD or mode are changed, then they take priority and the new CMD will be evaluated at the next clock edge. 

All non-multiply operations follow a 1 cycle latency. If the inputs are driven at N clock edge, the output will be shown at N+1 clock edge. If a new input is given at the N+1 clock edge, it will be accepted and evaluated at the next clock edge.


Testbench Architecture

The verification environment is a self-checking testbench developed in Verilog. The architecture consists of a stimulus driver, the DUT (ALU_design1), a reference model, and a scoreboard logic. The driver applies input combinations to the DUT and simultaneously invokes the reference model to compute expected results. The DUT outputs are captured and compared against expected values, and mismatches are reported automatically. 

Verification Strategy

The testbench verifies All logical operations, Shift operations. Rotate operations, Comparison flags (G, E, L), Invalid input conditions, Corner cases.

For each test case:

1. Inputs are applied to the DUT.
2. Expected results are computed inside the testbench.
3. DUT outputs are compared with expected results.
4. PASS or FAIL is displayed.

The testbench ensures:
All command values are exercised.
Valid and invalid input combinations are tested.
Edge cases such as zero and maximum values are checked.
Rotation is tested with multiple shift amounts.

