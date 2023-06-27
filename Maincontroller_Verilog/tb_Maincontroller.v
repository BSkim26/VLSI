`timescale 1ns / 1ps
module tb_Maincontroller;
    reg CLK;
    reg [10:0] Inst;
    reg EN;
    reg RST;
    reg OV;
    wire  WR;
    wire  [2:0]ADDR;
    wire  [3:0]Data;
    wire  DIR_SRAM;
    wire  [1:0] DIR_EXE;
    wire  OP_ALU;
     
     Maincontroller UUT(CLK,Inst, EN, RST, OV, WR, ADDR, Data, DIR_SRAM, DIR_EXE, OP_ALU);
     always #20 CLK=~CLK;
     initial begin 
           Inst=11'b00_000_000_000;   EN=0;   RST=0;   OV=0;  CLK=0;
        #5 RST = 1'b1; EN = 1'b0; Inst = 11'b00000000000;   // Reset
        #140 RST = 1'b0; EN = 1'b1; Inst = 11'b00001000000; // Read Data of ADDR 001
        #20 RST = 1'b1;
        #20 RST = 1'b0;
        #100 RST = 1'b0; EN = 1'b1; Inst = 11'b01001001111; // Write 1111 at ADDR 010
        #100 RST = 1'b0; EN = 1'b1; Inst = 11'b10101001011; // SRC1(ADDR 001) + SRC2(ADDR 011) = DEST(ADDR 101)
        #20 RST = 1'b1;
        #20 RST = 1'b0;
        #250 RST = 1'b0; EN = 1'b1; Inst = 11'b11111011101;  // SRC1(ADDR 011) - SRC2(ADDR 101) = DEST(ADDR 111)
        #20 RST = 1'b1;
        #20 RST = 1'b0;
        #220 RST = 1'b0; EN = 1'b1; OV=1; Inst = 11'b10101001011;  // SRC1(ADDR 001) + SRC2(ADDR 011) = DEST(ADDR 101) Overflow
        #20 RST = 1'b1;
        #20 RST = 1'b0;
        #220 Inst=11'b00_000_000_000;   EN=0;   RST=0;   OV=0;
        #20 RST = 1'b1;
        #20 RST = 1'b0;
        #80 $finish;                       
     end
endmodule
