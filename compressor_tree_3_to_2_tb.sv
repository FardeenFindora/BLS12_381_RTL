`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2021 12:22:20 PM
// Design Name: 
// Module Name: compressor_tree_3_to_2_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module compressor_tree_3_to_2_tb  #(
     parameter int NUM_ELEMENTS      = 9,
     parameter int BIT_LEN           = 16
    );

 reg [BIT_LEN-1:0]X[NUM_ELEMENTS];  
//   reg [18:0]Y[2];  
//   reg [18:0]A;  
//   reg [18:0]B;  
//   reg [18:0]Cin; 
//   reg [18:0]C1;
   reg [BIT_LEN-1:0]S;  
   reg [BIT_LEN-1:0]Cout;
   reg [BIT_LEN-1:0]S1;  
   reg [BIT_LEN-1:0]C1;   
   integer i;
  
    // 2. Instantiate the design and connect to testbench variables  
  compressor_tree_3_to_2  co1 ( .terms (X),  
                  .C (Cout), .S(S)  );
 

                 
                    initial begin  
   /*   assign X[0] = A[0];
      assign X[1] = B;
      assign X[2] = Cin;
      assign Y[0] = S;
      assign Y[1] = Cout;    */    
      X[0] <= 0 ;  
      X[1] <= 0 ;  
      X[2] <= 0 ; 
      X[3] <= 0 ;  
      X[4] <= 0 ;  
      X[5] <= 0 ;       
      X[6] <= 0 ;  
      X[7] <= 0 ;  
      X[8] <= 0 ; 
      S1   <= 0 ;
      C1   <= 0 ;          
//      A <= 0;  
//      B <= 0;  
//      Cin <= 0; 
  
     // $monitor ("A=0x%0h B=0x%0h Cin=0x%0h Cout=0x%0h S=0x%0h C1=0x%0h S1=0x%0h", A, B, Cin, Cout, S, C1, S1);   
  
        // Use a for loop to apply random values to the input  
     for (i = 0; i < 2; i = i+1)   begin
   
         #10 
 /*        X[0] <= 'h457ED ;  
         X[1] <= 'h5F78C ;  
         X[2] <='h5E9F9 ;
         A <= 'h457ED ;  
         B <= 'h5F78C ;  
         Cin <='h5E9F9 ; 
         C1 <='h3efdb;        
       //  S1 <= 'h44998;
       //  C1 <= 'h5F7ED;  
       */
      X[0] <= 'h1 ;  
      X[1] <= 'h3;  
      X[2] <= 'h7; 
      X[3] <= 'hF ;  
      X[4] <= 'h1F;  
      X[5] <= 'h3F ;       
      X[6] <= 'h7F ;  
      X[7] <= 'hFF;  
      X[8] <= 'h1FF ;
      S1   <= 'h0219 ;
      C1   <= 'h01DC ;        
         $monitor ("X[0]=0x%0h X[1]=0x%0h X[2]=0x%0h X[3]=0x%0h X[4]=0x%0h X[5]=0x% X[6]=0x%0h X[7]=0x%0h X[8]=0x% Cout=0x%0h S=0x%0h ", X[0], X[1],X[2],X[3], X[4],X[5] ,X[6], X[7],X[8], Cout, S,);  
         assert( Cout == C1  ) $display ("Carry Test Passed");
         else $error("Carry Test Failed");
         assert( S == S1 ) $display ("Sum Test Passed");
         else $error(" Sum Test Failed");
      //   #30 $finish ;
   end
   end 
   endmodule 
