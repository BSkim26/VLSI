`timescale 1ns / 1ps

module Maincontroller (
    input CLK,
    input [10:0] Inst,
    input EN,
    input RST,
    input OV,
    output reg WR,
    output reg [2:0] ADDR,
    output reg [3:0] Data,
    output reg DIR_SRAM,
    output reg [1:0] DIR_EXE,
    output reg OP_ALU
);

    reg [3:0] state;
    reg [2:0] addr_0, addr_2;

    parameter [3:0] IDLE = 4'b0000,
                    DECODED_RD = 4'b0001,
                    EXECUTED_RD = 4'b0010,
                    EXECUTED_WR = 4'b0011,
                    DECODED_ADDSUB = 4'b0100,
                    LOADED_SRC1 = 4'b0101,
                    LOADED_SRC2 = 4'b0110,
                    EXECUTED = 4'b0111,
                    SAVED = 4'b1000;

    initial begin
        state = IDLE;
        DIR_EXE = 2'b11;
        DIR_SRAM = 1'b0;
        WR = 0;
        ADDR = 3'b0;
        Data = 4'b0;
        OP_ALU = 0;
    end

    always @(posedge CLK) begin
        if (RST)
            state <= IDLE;
        else begin
            case (state)
                IDLE: 
                begin
                    DIR_EXE = 2'b11;
                    DIR_SRAM = 1'b0;
                    WR = 0;
                    ADDR = 3'b0;
                    Data = 4'b0;
                    OP_ALU = 0;
                    if (EN && (Inst[10:9] == 2'b00)) begin
                        WR = 0;
                        ADDR = Inst[8:6];
                                            state = DECODED_RD;
                    end 
                    else if (EN && (Inst[10:9] == 2'b01)) begin
                        WR = 1;
                        DIR_EXE = 2'b11;
                        ADDR = Inst[8:6];
                        Data = Inst[3:0];
                                            state = EXECUTED_WR;
                    end 
                    else if (EN && Inst[10]) begin
                        ADDR = Inst[5:3];
                        addr_0 = Inst[8:6];
                        addr_2 = Inst[2:0];
                        OP_ALU = ~Inst[9];
                                            state = DECODED_ADDSUB;
                    end 
                    else
                                            state = IDLE;
                    end
                DECODED_RD: begin
                    DIR_EXE = 2'b00;
                                            state = EXECUTED_RD;
                end
                EXECUTED_RD: begin
                    WR = 0;
                    DIR_EXE = 2'b11;
                                            state = IDLE;
                end
                EXECUTED_WR: begin
                    WR = 0;
                                            state = IDLE;
                end
                DECODED_ADDSUB: begin
                    DIR_EXE = 2'b01;
                    ADDR = addr_2;
                                            state = LOADED_SRC1;
                end
                LOADED_SRC1: begin
                    DIR_EXE = 2'b10;
                                            state = LOADED_SRC2;
                end
                LOADED_SRC2: begin
                    DIR_EXE = 2'b11;
                                            state = EXECUTED;
                end
                EXECUTED: begin
                    if (!OV) begin
                        ADDR = addr_0;
                        WR = 1;
                        DIR_SRAM = 1'b1;
                    end
                                            state = SAVED;
                end
                SAVED: begin
                    WR = 0;
                    DIR_SRAM = 1'b0;
                                            state = IDLE;
                end
                default: begin
                                            state = IDLE;
                end
            endcase
        end
    end

endmodule
