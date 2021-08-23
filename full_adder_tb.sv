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


module full_adder_tb;  
    // 1. Declare testbench variables  
   reg A;  
   reg B;  
   reg Cin;
   reg C1;
   reg S1; 
   wire Cout; 
   wire S;  
   integer i;  
  
    // 2. Instantiate the design and connect to testbench variables  
   full_adder  fa0 ( .A (A),  
                  .B (B),  
                  .Cin (Cin),  
                  .Cout (Cout),  
                  .S(S));  
  
    // 3. Provide stimulus to test the design  
   initial begin  
      A <= 0;  
      B <= 0;  
      Cin <= 0;  
  
      $monitor ("A=0x%0h B=0x%0h Cin=0x%0h Cout=0x%0h S=0x%0h C1=0x%0h S1=0x%0h", A, B, Cin, Cout, S, C1, S1);  
  
        // Use a for loop to apply random values to the input  
      for (i = 0; i < 5; i = i+1) begin  
         #10 A <= $random;  
             B <= $random;  
             Cin <= $random;
             assign {C1,S1} =  A+B+Cin;
             assert( C1==Cout && S1==S) $display ("Test Passed");
                else $error("Test Failed");// monitor logic.
               // $monitor(" *ERROR* "); 
               
      end  
   end  
endmodule  