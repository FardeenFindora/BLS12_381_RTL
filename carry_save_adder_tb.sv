`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Findora
// Engineer: Fardeen Hasan 
// 
// Create Date: 08/16/2021 06:56:30 PM
// Design Name: BLS12_381 
// Module Name: carry_save_adder_tb
// Project Name: Plonk
// Target Devices: VCU128
// Tool Versions: Vivado 2021.1
// Description:19 bit CSA using  1 bit full adder
// 
// Dependencies: full_adder - 1 bit , carry_save_adder
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// This is the test vector that is being used.
// The Cout will have a 0 at MSB if there is no carry at the final stage.
// So it's      0101 | 1111 | 0111 | 1110 | 1101


//Cout= 5f7ed   1011 | 1110 | 1111 | 1101 | 101
//              ____ | ____ | ____ | ____ | ____
//  A= 457ed    0100 | 0101 | 0111 | 1110 | 1101
//  B= 5f78c    0101 | 1111 | 0111 | 1000 | 1100
//Cin= 5e9f9    0101 | 1110 | 1001 | 1111 | 1001
//              ____ | ____ | ____ | ____ | ____
//  S =44998    0100 | 0100 | 1001 | 1001 | 1000
//



module carry_save_adder_tb    #(
     parameter int BIT_LEN = 19
    );  
    // 1. Declare testbench variables  
   reg [BIT_LEN-1:0]A;  
   reg [BIT_LEN-1:0]B;  
   reg [BIT_LEN-1:0]Cin; 
   wire [BIT_LEN-1:0]Cout; 
   wire [BIT_LEN-1:0]S; 
   reg [BIT_LEN-1:0]C1; 
   reg [BIT_LEN-1:0]S1; 
   integer i;  
  
    // 2. Instantiate the design and connect to testbench variables  
   carry_save_adder cs0 ( .A (A),  
                  .B (B),  
                  .Cin (Cin),  
                  .Cout (Cout),  
                  .S(S));  
  
    // 3. Provide stimulus to test the design  
   initial begin  
      A <= 0;  
      B <= 0;  
      Cin <= 0;
      S1 <=0;
      C1 <= 0;  
  
     // $monitor ("A=0x%0h B=0x%0h Cin=0x%0h Cout=0x%0h S=0x%0h C1=0x%0h S1=0x%0h", A, B, Cin, Cout, S, C1, S1);   
  
        // Use a for loop to apply random values to the input  
     for (i = 0; i < 2; i = i+1)   begin
   
         #10 
         A <= 'h457ED ;  
         B <= 'h5F78C ;  
         Cin <='h5E9F9 ;
         S1 <= 'h44998;
         C1 <= 'h5F7ED; 
         $monitor ("A=0x%0h B=0x%0h Cin=0x%0h Cout=0x%0h S=0x%0h C1=0x%0h S1=0x%0h", A, B, Cin, Cout, S, C1, S1);  
         assert( Cout == C1  ) $display ("Carry Test Passed");
         else $error("Carry Test Failed");
         assert( S == S1 ) $display ("Sum Test Passed");
         else $error(" Sum Test Failed");
      //   #30 $finish ;
   end
   end  
endmodule 
