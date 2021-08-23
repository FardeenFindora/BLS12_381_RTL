`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Findora
// Engineer: Fardeen Hasan 
// 
// Create Date: 08/16/2021 04:52:32 PM
// Design Name: BLS12_381
// Module Name: full_adder
// Project Name: Plonk
// Target Devices: VCU128
// Tool Versions: Vivado 2021.1
// Description: 1 bit full adder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************
  Copyright 2021 Findora
*******************************************************************************/

/*
  A basic 1-bit full adder
              -------
             | FA    |
    A    --> |       | --> S
    B    --> |       |
    Cin  --> |       | --> Cout
              -------
*/

module full_adder
   (
    input  logic A,
    input  logic B,
    input  logic Cin,
    output logic Cout,
    output logic S
   );
   reg x1;

   always_comb begin
      x1 = A^B;
      S    =  x1 ^ Cin ;
      Cout = (A & B) | (Cin & (x1));
   end
endmodule