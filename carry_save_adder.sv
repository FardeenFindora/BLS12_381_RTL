`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Findora
// Engineer: Fardeen Hasan 
// 
// Create Date: 08/16/2021 04:52:32 PM
// Design Name: BLS12_381
// Module Name: carry_save_adder
// Project Name: Plonk
// Target Devices: VCU128
// Tool Versions: Vivado 2021.1
// Description:19 bit CSA using  1 bit full adder
// 
// Dependencies: full_adder - 1 bit
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************
  Copyright 2021 Findora

/    
  A parameterized carry save adder (CSA)
  Loops through each input bit and feeds a full adder (FA)
             --------------------------------
            | CSA                            |
            |         for each i in BIT_LEN  |
            |            -------             |
            |           | FA    |            |
  A[]   --> |  Ai   --> |       | --> Si     | --> S[]
  B[]   --> |  Bi   --> |       |            |
  Cin[] --> |  Cini --> |       | --> Couti  | --> Cout[]
            |            -------             |
             --------------------------------
*/

module carry_save_adder
   #(
     parameter int BIT_LEN = 19
    )
   (
    input  logic [BIT_LEN-1:0] A,
    input  logic [BIT_LEN-1:0] B,
    input  logic [BIT_LEN-1:0] Cin,
    output logic [BIT_LEN-1:0] Cout,
    output logic [BIT_LEN-1:0] S
   );

   genvar i;
   generate
      for (i=0; i<BIT_LEN; i++) begin : csa_fas
         full_adder full_adder(
                               .A(A[i]),
                               .B(B[i]),
                               .Cin(Cin[i]),
                               .Cout(Cout[i]),
                               .S(S[i])
                              );
      end
   endgenerate
endmodule
