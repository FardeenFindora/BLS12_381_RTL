`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Findora
// Engineer: Fardeen Hasan 
// 
// Create Date: 08/18/2021 11:37:16 AM
// Design Name: BLS12_381 
// Module Name: carry_save_adder_tree_level
// Project Name: Plonk
// Target Devices: VCU128
// Tool Versions: Vivado 2021.1
// Description: Shifting the Carry output from carry save adder
// 
// Dependencies: full_adder - 1 bit , carry_save_adder 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module carry_save_adder_tree_level
   #(
     parameter int NUM_ELEMENTS = 3,
     parameter int BIT_LEN      = 19,

     parameter int NUM_RESULTS  = (integer'(NUM_ELEMENTS/3) * 2) + 
                                   (NUM_ELEMENTS%3)
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] results[NUM_RESULTS]
   );

   genvar i;
   generate
      for (i=0; i<(NUM_ELEMENTS / 3); i++) begin : csa_insts
         // Add three consecutive terms 
         carry_save_adder #(.BIT_LEN(BIT_LEN))
            carry_save_adder (
                              .A(terms[i*3]),
                              .B(terms[(i*3)+1]),
                              .Cin(terms[(i*3)+2]),
                              .Cout({results[i*2][0],
                                     results[i*2][BIT_LEN-1:1]}),
                              .S(results[(i*2)+1][BIT_LEN-1:0])
                             );
      end

      // Save any unused terms for the next level 
      for (i=0; i<(NUM_ELEMENTS % 3); i++) begin : csa_level_extras
         always_comb begin
            results[(NUM_RESULTS - 1) - i][BIT_LEN-1:0] = 
               terms[(NUM_ELEMENTS- 1) - i][BIT_LEN-1:0];
         end
      end
   endgenerate
endmodule
