`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Findora
// Engineer: Fardeen Hasan 
// 
// Create Date: 08/18/2021 03:31:09 PM
// Design Name: BLS12_381 
// Module Name: carry_save_adder_tree_level_tb
// Project Name: Plonk
// Target Devices: VCU128
// Tool Versions: Vivado 2021.1
// Description: Shifting the Carry output from carry save adder
// 
// Dependencies: full_adder - 1 bit , carry_save_adder , carry_save_adder_tree_level
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// This is the test vector that is being used.
// The MSB of Cout is padded to the LSB So it's 
// Y[0]=3efdb    011 | 1110 | 1111 | 1101 | 1011
//Cout= 5f7ed  01011 | 1110 | 1111 | 1101 | 101
//              ____ | ____ | ____ | ____ | ____
//  A= 457ed    0100 | 0101 | 0111 | 1110 | 1101
//  B= 5f78c    0101 | 1111 | 0111 | 1000 | 1100
//Cin= 5e9f9    0101 | 1110 | 1001 | 1111 | 1001
//              ____ | ____ | ____ | ____ | ____
//  S =44998    0100 | 0100 | 1001 | 1001 | 1000
//  Y[1] =S



module carry_save_adder_tree_level_tb #(
     parameter int BIT_LEN = 19
    );  
    
    
   reg [BIT_LEN-1:0]X[3];  
   reg [BIT_LEN-1:0]Y[2];  
   reg [BIT_LEN-1:0]A;
   reg [BIT_LEN-1:0]B;  
   reg [BIT_LEN-1:0]Cin; 
   reg [BIT_LEN-1:0]C1;
   reg [BIT_LEN-1:0]S;  
   reg [BIT_LEN-1:0]S1;
   reg [BIT_LEN-1:0]Cout;
   integer i;
  
    // 2. Instantiate the design and connect to testbench variables  
  carry_save_adder_tree_level  csat ( .terms (X),  
                  .results (Y)  );
                     carry_save_adder cs0 ( .A (A),  
                  .B (B),  
                  .Cin (Cin),  
                  .Cout (Cout),  
                  .S(S));  

                 
                    initial begin  
   /*   assign X[0] = A[0];
      assign X[1] = B;
      assign X[2] = Cin;
      assign Y[0] = S;
      assign Y[1] = Cout;    */    
      X[0] <= 0 ;  
      X[1] <= 0;  
      X[2] <= 0 ;      
      A <= 0;  
      B <= 0;  
      Cin <= 0; 
      C1 <=0;
      S1 <=0;
  

     for (i = 0; i < 2; i = i+1) 
       begin
   
         #10 
         X[0] <= 'h457ED ;  
         X[1] <= 'h5F78C ;  
         X[2] <='h5E9F9 ;
         A <= 'h457ED ;  
         B <= 'h5F78C ;  
         Cin <='h5E9F9 ; 
         C1 <='h3efdb;        
        S1 <= 'h44998;
       //  C1 <= 'h5F7ED;  
         $monitor ("A=0x%0h B=0x%0h Cin=0x%0h Cout=0x%0h X[0]=0x%0h X[1]=0x%0h X[2]=0x%0h Y[0]=0x%0h C1=0x%0h S=0x%0h Y[1]=0x%0h ", A, B, Cin, Cout, X[0], X[1],X[2],Y[0],C1,S,Y[1]);  
         assert( Y[0] == C1  ) $display ("Carry Test Passed");
         else $error("Carry Test Failed");
         assert( Y[1]== S1 ) $display ("Sum Test Passed");
         else $error(" Sum Test Failed");
      //   #30 $finish ;
   end
   end
                  
endmodule
