`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2021 06:27:56 PM
// Design Name: 
// Module Name: accum_mult_mod
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


/*
  This does a BITS multiplication using adder tree and parameterizable
  DSP sizes. A python script generates the accum_gen.sv file.

  Does modulus reduction using RAM tables. Multiplication and reduction has
  latency of 5 clock cycles and a throughput of 1 clock cycle per result.

  Copyright (C) 2019  Benjamin Devlin and Zcash Foundation

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

module accum_mult_mod #(
  parameter DAT_BITS,
  parameter MODULUS,
  parameter CTL_BITS,
  parameter A_DSP_W,
  parameter B_DSP_W,
  parameter GRID_BIT,
  parameter RAM_A_W,
  parameter RAM_D_W
)(
  input i_clk,
  input i_rst,
  if_axi_stream.sink   i_mul,
  if_axi_stream.source o_mul,
  input [RAM_D_W-1:0] i_ram_d,
  input               i_ram_we,
  input               i_ram_se
);

localparam int TOT_DSP_W = A_DSP_W+B_DSP_W;
localparam int NUM_COL = (DAT_BITS+A_DSP_W-1)/A_DSP_W;
localparam int NUM_ROW = (DAT_BITS+B_DSP_W-1)/B_DSP_W;
localparam int MAX_COEF = (2*DAT_BITS+GRID_BIT-1)/GRID_BIT;
localparam int PIPE = 9;

logic [A_DSP_W*NUM_COL-1:0]             dat_a;
logic [B_DSP_W*NUM_ROW-1:0]             dat_b;
(* DONT_TOUCH = "yes" *) logic [A_DSP_W+B_DSP_W-1:0] mul_grid [NUM_COL][NUM_ROW];
logic [2*DAT_BITS:0] res0_c, res0_r, res0_rr;
logic [DAT_BITS:0]   res1_c, res1_m_c, res1_m_c_;

// Most of the code is generated
//`include "accum_mult_mod_generated.inc"


logic [76:0]                  accum_grid_o [12];
logic [76:0]                  accum_grid_o_r [6];
logic [76:0]                  accum_grid_o_rr [6];
logic [76:0]                  accum2_grid_o [6];


// Coef 0
logic [66:0] accum_i_0 [8];
logic [66:0] accum_o_c_0, accum_o_s_0;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(8),
  .BIT_LEN(67)
)
ct_0 (
  .terms(accum_i_0),
  .C(accum_o_c_0),
  .S(accum_o_s_0)
);
always_comb accum_i_0 = {{{24{1'd0}},mul_grid[0][0][0+:43],{0{1'd0}}},{{7{1'd0}},mul_grid[0][1][0+:43],{17{1'd0}}},{{3{1'd0}},mul_grid[0][2][0+:30],{34{1'd0}}},{{3{1'd0}},mul_grid[0][3][0+:13],{51{1'd0}}},{{3{1'd0}},mul_grid[1][0][0+:38],{26{1'd0}}},{{3{1'd0}},mul_grid[1][1][0+:21],{43{1'd0}}},{{3{1'd0}},mul_grid[1][2][0+:4],{60{1'd0}}},{{3{1'd0}},mul_grid[2][0][0+:12],{52{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[0] <= accum_o_c_0 + accum_o_s_0;

// Coef 1
logic [68:0] accum_i_1 [22];
logic [68:0] accum_o_c_1, accum_o_s_1;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(22),
  .BIT_LEN(69)
)
ct_1 (
  .terms(accum_i_1),
  .C(accum_o_c_1),
  .S(accum_o_s_1)
);
always_comb accum_i_1 = {{{56{1'd0}},mul_grid[0][2][30+:13],{0{1'd0}}},{{39{1'd0}},mul_grid[0][3][13+:30],{0{1'd0}}},{{22{1'd0}},mul_grid[0][4][0+:43],{4{1'd0}}},{{5{1'd0}},mul_grid[0][5][0+:43],{21{1'd0}}},{{5{1'd0}},mul_grid[0][6][0+:26],{38{1'd0}}},{{5{1'd0}},mul_grid[0][7][0+:9],{55{1'd0}}},{{64{1'd0}},mul_grid[1][0][38+:5],{0{1'd0}}},{{47{1'd0}},mul_grid[1][1][21+:22],{0{1'd0}}},{{30{1'd0}},mul_grid[1][2][4+:39],{0{1'd0}}},{{13{1'd0}},mul_grid[1][3][0+:43],{13{1'd0}}},{{5{1'd0}},mul_grid[1][4][0+:34],{30{1'd0}}},{{5{1'd0}},mul_grid[1][5][0+:17],{47{1'd0}}},{{38{1'd0}},mul_grid[2][0][12+:31],{0{1'd0}}},{{21{1'd0}},mul_grid[2][1][0+:43],{5{1'd0}}},{{5{1'd0}},mul_grid[2][2][0+:42],{22{1'd0}}},{{5{1'd0}},mul_grid[2][3][0+:25],{39{1'd0}}},{{5{1'd0}},mul_grid[2][4][0+:8],{56{1'd0}}},{{12{1'd0}},mul_grid[3][0][0+:43],{14{1'd0}}},{{5{1'd0}},mul_grid[3][1][0+:33],{31{1'd0}}},{{5{1'd0}},mul_grid[3][2][0+:16],{48{1'd0}}},{{5{1'd0}},mul_grid[4][0][0+:24],{40{1'd0}}},{{5{1'd0}},mul_grid[4][1][0+:7],{57{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[1] <= accum_o_c_1 + accum_o_s_1;

// Coef 2
logic [69:0] accum_i_2 [39];
logic [69:0] accum_o_c_2, accum_o_s_2;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(39),
  .BIT_LEN(70)
)
ct_2 (
  .terms(accum_i_2),
  .C(accum_o_c_2),
  .S(accum_o_s_2)
);
always_comb accum_i_2 = {{{53{1'd0}},mul_grid[0][6][26+:17],{0{1'd0}}},{{36{1'd0}},mul_grid[0][7][9+:34],{0{1'd0}}},{{19{1'd0}},mul_grid[0][8][0+:43],{8{1'd0}}},{{6{1'd0}},mul_grid[0][9][0+:39],{25{1'd0}}},{{6{1'd0}},mul_grid[0][10][0+:22],{42{1'd0}}},{{6{1'd0}},mul_grid[0][11][0+:5],{59{1'd0}}},{{61{1'd0}},mul_grid[1][4][34+:9],{0{1'd0}}},{{44{1'd0}},mul_grid[1][5][17+:26],{0{1'd0}}},{{27{1'd0}},mul_grid[1][6][0+:43],{0{1'd0}}},{{10{1'd0}},mul_grid[1][7][0+:43],{17{1'd0}}},{{6{1'd0}},mul_grid[1][8][0+:30],{34{1'd0}}},{{6{1'd0}},mul_grid[1][9][0+:13],{51{1'd0}}},{{69{1'd0}},mul_grid[2][2][42+:1],{0{1'd0}}},{{52{1'd0}},mul_grid[2][3][25+:18],{0{1'd0}}},{{35{1'd0}},mul_grid[2][4][8+:35],{0{1'd0}}},{{18{1'd0}},mul_grid[2][5][0+:43],{9{1'd0}}},{{6{1'd0}},mul_grid[2][6][0+:38],{26{1'd0}}},{{6{1'd0}},mul_grid[2][7][0+:21],{43{1'd0}}},{{6{1'd0}},mul_grid[2][8][0+:4],{60{1'd0}}},{{60{1'd0}},mul_grid[3][1][33+:10],{0{1'd0}}},{{43{1'd0}},mul_grid[3][2][16+:27],{0{1'd0}}},{{26{1'd0}},mul_grid[3][3][0+:43],{1{1'd0}}},{{9{1'd0}},mul_grid[3][4][0+:43],{18{1'd0}}},{{6{1'd0}},mul_grid[3][5][0+:29],{35{1'd0}}},{{6{1'd0}},mul_grid[3][6][0+:12],{52{1'd0}}},{{51{1'd0}},mul_grid[4][0][24+:19],{0{1'd0}}},{{34{1'd0}},mul_grid[4][1][7+:36],{0{1'd0}}},{{17{1'd0}},mul_grid[4][2][0+:43],{10{1'd0}}},{{6{1'd0}},mul_grid[4][3][0+:37],{27{1'd0}}},{{6{1'd0}},mul_grid[4][4][0+:20],{44{1'd0}}},{{6{1'd0}},mul_grid[4][5][0+:3],{61{1'd0}}},{{25{1'd0}},mul_grid[5][0][0+:43],{2{1'd0}}},{{8{1'd0}},mul_grid[5][1][0+:43],{19{1'd0}}},{{6{1'd0}},mul_grid[5][2][0+:28],{36{1'd0}}},{{6{1'd0}},mul_grid[5][3][0+:11],{53{1'd0}}},{{6{1'd0}},mul_grid[6][0][0+:36],{28{1'd0}}},{{6{1'd0}},mul_grid[6][1][0+:19],{45{1'd0}}},{{6{1'd0}},mul_grid[6][2][0+:2],{62{1'd0}}},{{6{1'd0}},mul_grid[7][0][0+:10],{54{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[2] <= accum_o_c_2 + accum_o_s_2;

// Coef 3
logic [69:0] accum_i_3 [53];
logic [69:0] accum_o_c_3, accum_o_s_3;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(53),
  .BIT_LEN(70)
)
ct_3 (
  .terms(accum_i_3),
  .C(accum_o_c_3),
  .S(accum_o_s_3)
);
always_comb accum_i_3 = {{{66{1'd0}},mul_grid[0][9][39+:4],{0{1'd0}}},{{49{1'd0}},mul_grid[0][10][22+:21],{0{1'd0}}},{{32{1'd0}},mul_grid[0][11][5+:38],{0{1'd0}}},{{15{1'd0}},mul_grid[0][12][0+:43],{12{1'd0}}},{{6{1'd0}},mul_grid[0][13][0+:35],{29{1'd0}}},{{6{1'd0}},mul_grid[0][14][0+:18],{46{1'd0}}},{{6{1'd0}},mul_grid[0][15][0+:1],{63{1'd0}}},{{57{1'd0}},mul_grid[1][8][30+:13],{0{1'd0}}},{{40{1'd0}},mul_grid[1][9][13+:30],{0{1'd0}}},{{23{1'd0}},mul_grid[1][10][0+:43],{4{1'd0}}},{{6{1'd0}},mul_grid[1][11][0+:43],{21{1'd0}}},{{6{1'd0}},mul_grid[1][12][0+:26],{38{1'd0}}},{{6{1'd0}},mul_grid[1][13][0+:9],{55{1'd0}}},{{65{1'd0}},mul_grid[2][6][38+:5],{0{1'd0}}},{{48{1'd0}},mul_grid[2][7][21+:22],{0{1'd0}}},{{31{1'd0}},mul_grid[2][8][4+:39],{0{1'd0}}},{{14{1'd0}},mul_grid[2][9][0+:43],{13{1'd0}}},{{6{1'd0}},mul_grid[2][10][0+:34],{30{1'd0}}},{{6{1'd0}},mul_grid[2][11][0+:17],{47{1'd0}}},{{56{1'd0}},mul_grid[3][5][29+:14],{0{1'd0}}},{{39{1'd0}},mul_grid[3][6][12+:31],{0{1'd0}}},{{22{1'd0}},mul_grid[3][7][0+:43],{5{1'd0}}},{{6{1'd0}},mul_grid[3][8][0+:42],{22{1'd0}}},{{6{1'd0}},mul_grid[3][9][0+:25],{39{1'd0}}},{{6{1'd0}},mul_grid[3][10][0+:8],{56{1'd0}}},{{64{1'd0}},mul_grid[4][3][37+:6],{0{1'd0}}},{{47{1'd0}},mul_grid[4][4][20+:23],{0{1'd0}}},{{30{1'd0}},mul_grid[4][5][3+:40],{0{1'd0}}},{{13{1'd0}},mul_grid[4][6][0+:43],{14{1'd0}}},{{6{1'd0}},mul_grid[4][7][0+:33],{31{1'd0}}},{{6{1'd0}},mul_grid[4][8][0+:16],{48{1'd0}}},{{55{1'd0}},mul_grid[5][2][28+:15],{0{1'd0}}},{{38{1'd0}},mul_grid[5][3][11+:32],{0{1'd0}}},{{21{1'd0}},mul_grid[5][4][0+:43],{6{1'd0}}},{{6{1'd0}},mul_grid[5][5][0+:41],{23{1'd0}}},{{6{1'd0}},mul_grid[5][6][0+:24],{40{1'd0}}},{{6{1'd0}},mul_grid[5][7][0+:7],{57{1'd0}}},{{63{1'd0}},mul_grid[6][0][36+:7],{0{1'd0}}},{{46{1'd0}},mul_grid[6][1][19+:24],{0{1'd0}}},{{29{1'd0}},mul_grid[6][2][2+:41],{0{1'd0}}},{{12{1'd0}},mul_grid[6][3][0+:43],{15{1'd0}}},{{6{1'd0}},mul_grid[6][4][0+:32],{32{1'd0}}},{{6{1'd0}},mul_grid[6][5][0+:15],{49{1'd0}}},{{37{1'd0}},mul_grid[7][0][10+:33],{0{1'd0}}},{{20{1'd0}},mul_grid[7][1][0+:43],{7{1'd0}}},{{6{1'd0}},mul_grid[7][2][0+:40],{24{1'd0}}},{{6{1'd0}},mul_grid[7][3][0+:23],{41{1'd0}}},{{6{1'd0}},mul_grid[7][4][0+:6],{58{1'd0}}},{{11{1'd0}},mul_grid[8][0][0+:43],{16{1'd0}}},{{6{1'd0}},mul_grid[8][1][0+:31],{33{1'd0}}},{{6{1'd0}},mul_grid[8][2][0+:14],{50{1'd0}}},{{6{1'd0}},mul_grid[9][0][0+:22],{42{1'd0}}},{{6{1'd0}},mul_grid[9][1][0+:5],{59{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[3] <= accum_o_c_3 + accum_o_s_3;

// Coef 4
logic [70:0] accum_i_4 [70];
logic [70:0] accum_o_c_4, accum_o_s_4;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(70),
  .BIT_LEN(71)
)
ct_4 (
  .terms(accum_i_4),
  .C(accum_o_c_4),
  .S(accum_o_s_4)
);
always_comb accum_i_4 = {{{63{1'd0}},mul_grid[0][13][35+:8],{0{1'd0}}},{{46{1'd0}},mul_grid[0][14][18+:25],{0{1'd0}}},{{29{1'd0}},mul_grid[0][15][1+:42],{0{1'd0}}},{{12{1'd0}},mul_grid[0][16][0+:43],{16{1'd0}}},{{7{1'd0}},mul_grid[0][17][0+:31],{33{1'd0}}},{{7{1'd0}},mul_grid[0][18][0+:14],{50{1'd0}}},{{54{1'd0}},mul_grid[1][12][26+:17],{0{1'd0}}},{{37{1'd0}},mul_grid[1][13][9+:34],{0{1'd0}}},{{20{1'd0}},mul_grid[1][14][0+:43],{8{1'd0}}},{{7{1'd0}},mul_grid[1][15][0+:39],{25{1'd0}}},{{7{1'd0}},mul_grid[1][16][0+:22],{42{1'd0}}},{{7{1'd0}},mul_grid[1][17][0+:5],{59{1'd0}}},{{62{1'd0}},mul_grid[2][10][34+:9],{0{1'd0}}},{{45{1'd0}},mul_grid[2][11][17+:26],{0{1'd0}}},{{28{1'd0}},mul_grid[2][12][0+:43],{0{1'd0}}},{{11{1'd0}},mul_grid[2][13][0+:43],{17{1'd0}}},{{7{1'd0}},mul_grid[2][14][0+:30],{34{1'd0}}},{{7{1'd0}},mul_grid[2][15][0+:13],{51{1'd0}}},{{70{1'd0}},mul_grid[3][8][42+:1],{0{1'd0}}},{{53{1'd0}},mul_grid[3][9][25+:18],{0{1'd0}}},{{36{1'd0}},mul_grid[3][10][8+:35],{0{1'd0}}},{{19{1'd0}},mul_grid[3][11][0+:43],{9{1'd0}}},{{7{1'd0}},mul_grid[3][12][0+:38],{26{1'd0}}},{{7{1'd0}},mul_grid[3][13][0+:21],{43{1'd0}}},{{7{1'd0}},mul_grid[3][14][0+:4],{60{1'd0}}},{{61{1'd0}},mul_grid[4][7][33+:10],{0{1'd0}}},{{44{1'd0}},mul_grid[4][8][16+:27],{0{1'd0}}},{{27{1'd0}},mul_grid[4][9][0+:43],{1{1'd0}}},{{10{1'd0}},mul_grid[4][10][0+:43],{18{1'd0}}},{{7{1'd0}},mul_grid[4][11][0+:29],{35{1'd0}}},{{7{1'd0}},mul_grid[4][12][0+:12],{52{1'd0}}},{{69{1'd0}},mul_grid[5][5][41+:2],{0{1'd0}}},{{52{1'd0}},mul_grid[5][6][24+:19],{0{1'd0}}},{{35{1'd0}},mul_grid[5][7][7+:36],{0{1'd0}}},{{18{1'd0}},mul_grid[5][8][0+:43],{10{1'd0}}},{{7{1'd0}},mul_grid[5][9][0+:37],{27{1'd0}}},{{7{1'd0}},mul_grid[5][10][0+:20],{44{1'd0}}},{{7{1'd0}},mul_grid[5][11][0+:3],{61{1'd0}}},{{60{1'd0}},mul_grid[6][4][32+:11],{0{1'd0}}},{{43{1'd0}},mul_grid[6][5][15+:28],{0{1'd0}}},{{26{1'd0}},mul_grid[6][6][0+:43],{2{1'd0}}},{{9{1'd0}},mul_grid[6][7][0+:43],{19{1'd0}}},{{7{1'd0}},mul_grid[6][8][0+:28],{36{1'd0}}},{{7{1'd0}},mul_grid[6][9][0+:11],{53{1'd0}}},{{68{1'd0}},mul_grid[7][2][40+:3],{0{1'd0}}},{{51{1'd0}},mul_grid[7][3][23+:20],{0{1'd0}}},{{34{1'd0}},mul_grid[7][4][6+:37],{0{1'd0}}},{{17{1'd0}},mul_grid[7][5][0+:43],{11{1'd0}}},{{7{1'd0}},mul_grid[7][6][0+:36],{28{1'd0}}},{{7{1'd0}},mul_grid[7][7][0+:19],{45{1'd0}}},{{7{1'd0}},mul_grid[7][8][0+:2],{62{1'd0}}},{{59{1'd0}},mul_grid[8][1][31+:12],{0{1'd0}}},{{42{1'd0}},mul_grid[8][2][14+:29],{0{1'd0}}},{{25{1'd0}},mul_grid[8][3][0+:43],{3{1'd0}}},{{8{1'd0}},mul_grid[8][4][0+:43],{20{1'd0}}},{{7{1'd0}},mul_grid[8][5][0+:27],{37{1'd0}}},{{7{1'd0}},mul_grid[8][6][0+:10],{54{1'd0}}},{{50{1'd0}},mul_grid[9][0][22+:21],{0{1'd0}}},{{33{1'd0}},mul_grid[9][1][5+:38],{0{1'd0}}},{{16{1'd0}},mul_grid[9][2][0+:43],{12{1'd0}}},{{7{1'd0}},mul_grid[9][3][0+:35],{29{1'd0}}},{{7{1'd0}},mul_grid[9][4][0+:18],{46{1'd0}}},{{7{1'd0}},mul_grid[9][5][0+:1],{63{1'd0}}},{{24{1'd0}},mul_grid[10][0][0+:43],{4{1'd0}}},{{7{1'd0}},mul_grid[10][1][0+:43],{21{1'd0}}},{{7{1'd0}},mul_grid[10][2][0+:26],{38{1'd0}}},{{7{1'd0}},mul_grid[10][3][0+:9],{55{1'd0}}},{{7{1'd0}},mul_grid[11][0][0+:34],{30{1'd0}}},{{7{1'd0}},mul_grid[11][1][0+:17],{47{1'd0}}},{{7{1'd0}},mul_grid[12][0][0+:8],{56{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[4] <= accum_o_c_4 + accum_o_s_4;

// Coef 5
logic [70:0] accum_i_5 [83];
logic [70:0] accum_o_c_5, accum_o_s_5;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(83),
  .BIT_LEN(71)
)
ct_5 (
  .terms(accum_i_5),
  .C(accum_o_c_5),
  .S(accum_o_s_5)
);
always_comb accum_i_5 = {{{59{1'd0}},mul_grid[0][17][31+:12],{0{1'd0}}},{{42{1'd0}},mul_grid[0][18][14+:29],{0{1'd0}}},{{25{1'd0}},mul_grid[0][19][0+:43],{3{1'd0}}},{{8{1'd0}},mul_grid[0][20][0+:43],{20{1'd0}}},{{7{1'd0}},mul_grid[0][21][0+:27],{37{1'd0}}},{{7{1'd0}},mul_grid[0][22][0+:10],{54{1'd0}}},{{67{1'd0}},mul_grid[1][15][39+:4],{0{1'd0}}},{{50{1'd0}},mul_grid[1][16][22+:21],{0{1'd0}}},{{33{1'd0}},mul_grid[1][17][5+:38],{0{1'd0}}},{{16{1'd0}},mul_grid[1][18][0+:43],{12{1'd0}}},{{7{1'd0}},mul_grid[1][19][0+:35],{29{1'd0}}},{{7{1'd0}},mul_grid[1][20][0+:18],{46{1'd0}}},{{7{1'd0}},mul_grid[1][21][0+:1],{63{1'd0}}},{{58{1'd0}},mul_grid[2][14][30+:13],{0{1'd0}}},{{41{1'd0}},mul_grid[2][15][13+:30],{0{1'd0}}},{{24{1'd0}},mul_grid[2][16][0+:43],{4{1'd0}}},{{7{1'd0}},mul_grid[2][17][0+:43],{21{1'd0}}},{{7{1'd0}},mul_grid[2][18][0+:26],{38{1'd0}}},{{7{1'd0}},mul_grid[2][19][0+:9],{55{1'd0}}},{{66{1'd0}},mul_grid[3][12][38+:5],{0{1'd0}}},{{49{1'd0}},mul_grid[3][13][21+:22],{0{1'd0}}},{{32{1'd0}},mul_grid[3][14][4+:39],{0{1'd0}}},{{15{1'd0}},mul_grid[3][15][0+:43],{13{1'd0}}},{{7{1'd0}},mul_grid[3][16][0+:34],{30{1'd0}}},{{7{1'd0}},mul_grid[3][17][0+:17],{47{1'd0}}},{{57{1'd0}},mul_grid[4][11][29+:14],{0{1'd0}}},{{40{1'd0}},mul_grid[4][12][12+:31],{0{1'd0}}},{{23{1'd0}},mul_grid[4][13][0+:43],{5{1'd0}}},{{7{1'd0}},mul_grid[4][14][0+:42],{22{1'd0}}},{{7{1'd0}},mul_grid[4][15][0+:25],{39{1'd0}}},{{7{1'd0}},mul_grid[4][16][0+:8],{56{1'd0}}},{{65{1'd0}},mul_grid[5][9][37+:6],{0{1'd0}}},{{48{1'd0}},mul_grid[5][10][20+:23],{0{1'd0}}},{{31{1'd0}},mul_grid[5][11][3+:40],{0{1'd0}}},{{14{1'd0}},mul_grid[5][12][0+:43],{14{1'd0}}},{{7{1'd0}},mul_grid[5][13][0+:33],{31{1'd0}}},{{7{1'd0}},mul_grid[5][14][0+:16],{48{1'd0}}},{{56{1'd0}},mul_grid[6][8][28+:15],{0{1'd0}}},{{39{1'd0}},mul_grid[6][9][11+:32],{0{1'd0}}},{{22{1'd0}},mul_grid[6][10][0+:43],{6{1'd0}}},{{7{1'd0}},mul_grid[6][11][0+:41],{23{1'd0}}},{{7{1'd0}},mul_grid[6][12][0+:24],{40{1'd0}}},{{7{1'd0}},mul_grid[6][13][0+:7],{57{1'd0}}},{{64{1'd0}},mul_grid[7][6][36+:7],{0{1'd0}}},{{47{1'd0}},mul_grid[7][7][19+:24],{0{1'd0}}},{{30{1'd0}},mul_grid[7][8][2+:41],{0{1'd0}}},{{13{1'd0}},mul_grid[7][9][0+:43],{15{1'd0}}},{{7{1'd0}},mul_grid[7][10][0+:32],{32{1'd0}}},{{7{1'd0}},mul_grid[7][11][0+:15],{49{1'd0}}},{{55{1'd0}},mul_grid[8][5][27+:16],{0{1'd0}}},{{38{1'd0}},mul_grid[8][6][10+:33],{0{1'd0}}},{{21{1'd0}},mul_grid[8][7][0+:43],{7{1'd0}}},{{7{1'd0}},mul_grid[8][8][0+:40],{24{1'd0}}},{{7{1'd0}},mul_grid[8][9][0+:23],{41{1'd0}}},{{7{1'd0}},mul_grid[8][10][0+:6],{58{1'd0}}},{{63{1'd0}},mul_grid[9][3][35+:8],{0{1'd0}}},{{46{1'd0}},mul_grid[9][4][18+:25],{0{1'd0}}},{{29{1'd0}},mul_grid[9][5][1+:42],{0{1'd0}}},{{12{1'd0}},mul_grid[9][6][0+:43],{16{1'd0}}},{{7{1'd0}},mul_grid[9][7][0+:31],{33{1'd0}}},{{7{1'd0}},mul_grid[9][8][0+:14],{50{1'd0}}},{{54{1'd0}},mul_grid[10][2][26+:17],{0{1'd0}}},{{37{1'd0}},mul_grid[10][3][9+:34],{0{1'd0}}},{{20{1'd0}},mul_grid[10][4][0+:43],{8{1'd0}}},{{7{1'd0}},mul_grid[10][5][0+:39],{25{1'd0}}},{{7{1'd0}},mul_grid[10][6][0+:22],{42{1'd0}}},{{7{1'd0}},mul_grid[10][7][0+:5],{59{1'd0}}},{{62{1'd0}},mul_grid[11][0][34+:9],{0{1'd0}}},{{45{1'd0}},mul_grid[11][1][17+:26],{0{1'd0}}},{{28{1'd0}},mul_grid[11][2][0+:43],{0{1'd0}}},{{11{1'd0}},mul_grid[11][3][0+:43],{17{1'd0}}},{{7{1'd0}},mul_grid[11][4][0+:30],{34{1'd0}}},{{7{1'd0}},mul_grid[11][5][0+:13],{51{1'd0}}},{{36{1'd0}},mul_grid[12][0][8+:35],{0{1'd0}}},{{19{1'd0}},mul_grid[12][1][0+:43],{9{1'd0}}},{{7{1'd0}},mul_grid[12][2][0+:38],{26{1'd0}}},{{7{1'd0}},mul_grid[12][3][0+:21],{43{1'd0}}},{{7{1'd0}},mul_grid[12][4][0+:4],{60{1'd0}}},{{10{1'd0}},mul_grid[13][0][0+:43],{18{1'd0}}},{{7{1'd0}},mul_grid[13][1][0+:29],{35{1'd0}}},{{7{1'd0}},mul_grid[13][2][0+:12],{52{1'd0}}},{{7{1'd0}},mul_grid[14][0][0+:20],{44{1'd0}}},{{7{1'd0}},mul_grid[14][1][0+:3],{61{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[5] <= accum_o_c_5 + accum_o_s_5;

// Coef 6
logic [70:0] accum_i_6 [86];
logic [70:0] accum_o_c_6, accum_o_s_6;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(86),
  .BIT_LEN(71)
)
ct_6 (
  .terms(accum_i_6),
  .C(accum_o_c_6),
  .S(accum_o_s_6)
);
always_comb accum_i_6 = {{{55{1'd0}},mul_grid[0][21][27+:16],{0{1'd0}}},{{38{1'd0}},mul_grid[0][22][10+:33],{0{1'd0}}},{{63{1'd0}},mul_grid[1][19][35+:8],{0{1'd0}}},{{46{1'd0}},mul_grid[1][20][18+:25],{0{1'd0}}},{{29{1'd0}},mul_grid[1][21][1+:42],{0{1'd0}}},{{12{1'd0}},mul_grid[1][22][0+:43],{16{1'd0}}},{{54{1'd0}},mul_grid[2][18][26+:17],{0{1'd0}}},{{37{1'd0}},mul_grid[2][19][9+:34],{0{1'd0}}},{{20{1'd0}},mul_grid[2][20][0+:43],{8{1'd0}}},{{7{1'd0}},mul_grid[2][21][0+:39],{25{1'd0}}},{{7{1'd0}},mul_grid[2][22][0+:22],{42{1'd0}}},{{62{1'd0}},mul_grid[3][16][34+:9],{0{1'd0}}},{{45{1'd0}},mul_grid[3][17][17+:26],{0{1'd0}}},{{28{1'd0}},mul_grid[3][18][0+:43],{0{1'd0}}},{{11{1'd0}},mul_grid[3][19][0+:43],{17{1'd0}}},{{7{1'd0}},mul_grid[3][20][0+:30],{34{1'd0}}},{{7{1'd0}},mul_grid[3][21][0+:13],{51{1'd0}}},{{70{1'd0}},mul_grid[4][14][42+:1],{0{1'd0}}},{{53{1'd0}},mul_grid[4][15][25+:18],{0{1'd0}}},{{36{1'd0}},mul_grid[4][16][8+:35],{0{1'd0}}},{{19{1'd0}},mul_grid[4][17][0+:43],{9{1'd0}}},{{7{1'd0}},mul_grid[4][18][0+:38],{26{1'd0}}},{{7{1'd0}},mul_grid[4][19][0+:21],{43{1'd0}}},{{7{1'd0}},mul_grid[4][20][0+:4],{60{1'd0}}},{{61{1'd0}},mul_grid[5][13][33+:10],{0{1'd0}}},{{44{1'd0}},mul_grid[5][14][16+:27],{0{1'd0}}},{{27{1'd0}},mul_grid[5][15][0+:43],{1{1'd0}}},{{10{1'd0}},mul_grid[5][16][0+:43],{18{1'd0}}},{{7{1'd0}},mul_grid[5][17][0+:29],{35{1'd0}}},{{7{1'd0}},mul_grid[5][18][0+:12],{52{1'd0}}},{{69{1'd0}},mul_grid[6][11][41+:2],{0{1'd0}}},{{52{1'd0}},mul_grid[6][12][24+:19],{0{1'd0}}},{{35{1'd0}},mul_grid[6][13][7+:36],{0{1'd0}}},{{18{1'd0}},mul_grid[6][14][0+:43],{10{1'd0}}},{{7{1'd0}},mul_grid[6][15][0+:37],{27{1'd0}}},{{7{1'd0}},mul_grid[6][16][0+:20],{44{1'd0}}},{{7{1'd0}},mul_grid[6][17][0+:3],{61{1'd0}}},{{60{1'd0}},mul_grid[7][10][32+:11],{0{1'd0}}},{{43{1'd0}},mul_grid[7][11][15+:28],{0{1'd0}}},{{26{1'd0}},mul_grid[7][12][0+:43],{2{1'd0}}},{{9{1'd0}},mul_grid[7][13][0+:43],{19{1'd0}}},{{7{1'd0}},mul_grid[7][14][0+:28],{36{1'd0}}},{{7{1'd0}},mul_grid[7][15][0+:11],{53{1'd0}}},{{68{1'd0}},mul_grid[8][8][40+:3],{0{1'd0}}},{{51{1'd0}},mul_grid[8][9][23+:20],{0{1'd0}}},{{34{1'd0}},mul_grid[8][10][6+:37],{0{1'd0}}},{{17{1'd0}},mul_grid[8][11][0+:43],{11{1'd0}}},{{7{1'd0}},mul_grid[8][12][0+:36],{28{1'd0}}},{{7{1'd0}},mul_grid[8][13][0+:19],{45{1'd0}}},{{7{1'd0}},mul_grid[8][14][0+:2],{62{1'd0}}},{{59{1'd0}},mul_grid[9][7][31+:12],{0{1'd0}}},{{42{1'd0}},mul_grid[9][8][14+:29],{0{1'd0}}},{{25{1'd0}},mul_grid[9][9][0+:43],{3{1'd0}}},{{8{1'd0}},mul_grid[9][10][0+:43],{20{1'd0}}},{{7{1'd0}},mul_grid[9][11][0+:27],{37{1'd0}}},{{7{1'd0}},mul_grid[9][12][0+:10],{54{1'd0}}},{{67{1'd0}},mul_grid[10][5][39+:4],{0{1'd0}}},{{50{1'd0}},mul_grid[10][6][22+:21],{0{1'd0}}},{{33{1'd0}},mul_grid[10][7][5+:38],{0{1'd0}}},{{16{1'd0}},mul_grid[10][8][0+:43],{12{1'd0}}},{{7{1'd0}},mul_grid[10][9][0+:35],{29{1'd0}}},{{7{1'd0}},mul_grid[10][10][0+:18],{46{1'd0}}},{{7{1'd0}},mul_grid[10][11][0+:1],{63{1'd0}}},{{58{1'd0}},mul_grid[11][4][30+:13],{0{1'd0}}},{{41{1'd0}},mul_grid[11][5][13+:30],{0{1'd0}}},{{24{1'd0}},mul_grid[11][6][0+:43],{4{1'd0}}},{{7{1'd0}},mul_grid[11][7][0+:43],{21{1'd0}}},{{7{1'd0}},mul_grid[11][8][0+:26],{38{1'd0}}},{{7{1'd0}},mul_grid[11][9][0+:9],{55{1'd0}}},{{66{1'd0}},mul_grid[12][2][38+:5],{0{1'd0}}},{{49{1'd0}},mul_grid[12][3][21+:22],{0{1'd0}}},{{32{1'd0}},mul_grid[12][4][4+:39],{0{1'd0}}},{{15{1'd0}},mul_grid[12][5][0+:43],{13{1'd0}}},{{7{1'd0}},mul_grid[12][6][0+:34],{30{1'd0}}},{{7{1'd0}},mul_grid[12][7][0+:17],{47{1'd0}}},{{57{1'd0}},mul_grid[13][1][29+:14],{0{1'd0}}},{{40{1'd0}},mul_grid[13][2][12+:31],{0{1'd0}}},{{23{1'd0}},mul_grid[13][3][0+:43],{5{1'd0}}},{{7{1'd0}},mul_grid[13][4][0+:42],{22{1'd0}}},{{7{1'd0}},mul_grid[13][5][0+:25],{39{1'd0}}},{{7{1'd0}},mul_grid[13][6][0+:8],{56{1'd0}}},{{48{1'd0}},mul_grid[14][0][20+:23],{0{1'd0}}},{{31{1'd0}},mul_grid[14][1][3+:40],{0{1'd0}}},{{14{1'd0}},mul_grid[14][2][0+:43],{14{1'd0}}},{{7{1'd0}},mul_grid[14][3][0+:33],{31{1'd0}}},{{7{1'd0}},mul_grid[14][4][0+:16],{48{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[6] <= accum_o_c_6 + accum_o_s_6;

// Coef 7
logic [70:0] accum_i_7 [71];
logic [70:0] accum_o_c_7, accum_o_s_7;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(71),
  .BIT_LEN(71)
)
ct_7 (
  .terms(accum_i_7),
  .C(accum_o_c_7),
  .S(accum_o_s_7)
);
always_comb accum_i_7 = {{{67{1'd0}},mul_grid[2][21][39+:4],{0{1'd0}}},{{50{1'd0}},mul_grid[2][22][22+:21],{0{1'd0}}},{{58{1'd0}},mul_grid[3][20][30+:13],{0{1'd0}}},{{41{1'd0}},mul_grid[3][21][13+:30],{0{1'd0}}},{{24{1'd0}},mul_grid[3][22][0+:43],{4{1'd0}}},{{66{1'd0}},mul_grid[4][18][38+:5],{0{1'd0}}},{{49{1'd0}},mul_grid[4][19][21+:22],{0{1'd0}}},{{32{1'd0}},mul_grid[4][20][4+:39],{0{1'd0}}},{{15{1'd0}},mul_grid[4][21][0+:43],{13{1'd0}}},{{7{1'd0}},mul_grid[4][22][0+:34],{30{1'd0}}},{{57{1'd0}},mul_grid[5][17][29+:14],{0{1'd0}}},{{40{1'd0}},mul_grid[5][18][12+:31],{0{1'd0}}},{{23{1'd0}},mul_grid[5][19][0+:43],{5{1'd0}}},{{7{1'd0}},mul_grid[5][20][0+:42],{22{1'd0}}},{{7{1'd0}},mul_grid[5][21][0+:25],{39{1'd0}}},{{7{1'd0}},mul_grid[5][22][0+:8],{56{1'd0}}},{{65{1'd0}},mul_grid[6][15][37+:6],{0{1'd0}}},{{48{1'd0}},mul_grid[6][16][20+:23],{0{1'd0}}},{{31{1'd0}},mul_grid[6][17][3+:40],{0{1'd0}}},{{14{1'd0}},mul_grid[6][18][0+:43],{14{1'd0}}},{{7{1'd0}},mul_grid[6][19][0+:33],{31{1'd0}}},{{7{1'd0}},mul_grid[6][20][0+:16],{48{1'd0}}},{{56{1'd0}},mul_grid[7][14][28+:15],{0{1'd0}}},{{39{1'd0}},mul_grid[7][15][11+:32],{0{1'd0}}},{{22{1'd0}},mul_grid[7][16][0+:43],{6{1'd0}}},{{7{1'd0}},mul_grid[7][17][0+:41],{23{1'd0}}},{{7{1'd0}},mul_grid[7][18][0+:24],{40{1'd0}}},{{7{1'd0}},mul_grid[7][19][0+:7],{57{1'd0}}},{{64{1'd0}},mul_grid[8][12][36+:7],{0{1'd0}}},{{47{1'd0}},mul_grid[8][13][19+:24],{0{1'd0}}},{{30{1'd0}},mul_grid[8][14][2+:41],{0{1'd0}}},{{13{1'd0}},mul_grid[8][15][0+:43],{15{1'd0}}},{{7{1'd0}},mul_grid[8][16][0+:32],{32{1'd0}}},{{7{1'd0}},mul_grid[8][17][0+:15],{49{1'd0}}},{{55{1'd0}},mul_grid[9][11][27+:16],{0{1'd0}}},{{38{1'd0}},mul_grid[9][12][10+:33],{0{1'd0}}},{{21{1'd0}},mul_grid[9][13][0+:43],{7{1'd0}}},{{7{1'd0}},mul_grid[9][14][0+:40],{24{1'd0}}},{{7{1'd0}},mul_grid[9][15][0+:23],{41{1'd0}}},{{7{1'd0}},mul_grid[9][16][0+:6],{58{1'd0}}},{{63{1'd0}},mul_grid[10][9][35+:8],{0{1'd0}}},{{46{1'd0}},mul_grid[10][10][18+:25],{0{1'd0}}},{{29{1'd0}},mul_grid[10][11][1+:42],{0{1'd0}}},{{12{1'd0}},mul_grid[10][12][0+:43],{16{1'd0}}},{{7{1'd0}},mul_grid[10][13][0+:31],{33{1'd0}}},{{7{1'd0}},mul_grid[10][14][0+:14],{50{1'd0}}},{{54{1'd0}},mul_grid[11][8][26+:17],{0{1'd0}}},{{37{1'd0}},mul_grid[11][9][9+:34],{0{1'd0}}},{{20{1'd0}},mul_grid[11][10][0+:43],{8{1'd0}}},{{7{1'd0}},mul_grid[11][11][0+:39],{25{1'd0}}},{{7{1'd0}},mul_grid[11][12][0+:22],{42{1'd0}}},{{7{1'd0}},mul_grid[11][13][0+:5],{59{1'd0}}},{{62{1'd0}},mul_grid[12][6][34+:9],{0{1'd0}}},{{45{1'd0}},mul_grid[12][7][17+:26],{0{1'd0}}},{{28{1'd0}},mul_grid[12][8][0+:43],{0{1'd0}}},{{11{1'd0}},mul_grid[12][9][0+:43],{17{1'd0}}},{{7{1'd0}},mul_grid[12][10][0+:30],{34{1'd0}}},{{7{1'd0}},mul_grid[12][11][0+:13],{51{1'd0}}},{{70{1'd0}},mul_grid[13][4][42+:1],{0{1'd0}}},{{53{1'd0}},mul_grid[13][5][25+:18],{0{1'd0}}},{{36{1'd0}},mul_grid[13][6][8+:35],{0{1'd0}}},{{19{1'd0}},mul_grid[13][7][0+:43],{9{1'd0}}},{{7{1'd0}},mul_grid[13][8][0+:38],{26{1'd0}}},{{7{1'd0}},mul_grid[13][9][0+:21],{43{1'd0}}},{{7{1'd0}},mul_grid[13][10][0+:4],{60{1'd0}}},{{61{1'd0}},mul_grid[14][3][33+:10],{0{1'd0}}},{{44{1'd0}},mul_grid[14][4][16+:27],{0{1'd0}}},{{27{1'd0}},mul_grid[14][5][0+:43],{1{1'd0}}},{{10{1'd0}},mul_grid[14][6][0+:43],{18{1'd0}}},{{7{1'd0}},mul_grid[14][7][0+:29],{35{1'd0}}},{{7{1'd0}},mul_grid[14][8][0+:12],{52{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[7] <= accum_o_c_7 + accum_o_s_7;

// Coef 8
logic [69:0] accum_i_8 [58];
logic [69:0] accum_o_c_8, accum_o_s_8;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(58),
  .BIT_LEN(70)
)
ct_8 (
  .terms(accum_i_8),
  .C(accum_o_c_8),
  .S(accum_o_s_8)
);
always_comb accum_i_8 = {{{61{1'd0}},mul_grid[4][22][34+:9],{0{1'd0}}},{{69{1'd0}},mul_grid[5][20][42+:1],{0{1'd0}}},{{52{1'd0}},mul_grid[5][21][25+:18],{0{1'd0}}},{{35{1'd0}},mul_grid[5][22][8+:35],{0{1'd0}}},{{60{1'd0}},mul_grid[6][19][33+:10],{0{1'd0}}},{{43{1'd0}},mul_grid[6][20][16+:27],{0{1'd0}}},{{26{1'd0}},mul_grid[6][21][0+:43],{1{1'd0}}},{{9{1'd0}},mul_grid[6][22][0+:43],{18{1'd0}}},{{68{1'd0}},mul_grid[7][17][41+:2],{0{1'd0}}},{{51{1'd0}},mul_grid[7][18][24+:19],{0{1'd0}}},{{34{1'd0}},mul_grid[7][19][7+:36],{0{1'd0}}},{{17{1'd0}},mul_grid[7][20][0+:43],{10{1'd0}}},{{6{1'd0}},mul_grid[7][21][0+:37],{27{1'd0}}},{{6{1'd0}},mul_grid[7][22][0+:20],{44{1'd0}}},{{59{1'd0}},mul_grid[8][16][32+:11],{0{1'd0}}},{{42{1'd0}},mul_grid[8][17][15+:28],{0{1'd0}}},{{25{1'd0}},mul_grid[8][18][0+:43],{2{1'd0}}},{{8{1'd0}},mul_grid[8][19][0+:43],{19{1'd0}}},{{6{1'd0}},mul_grid[8][20][0+:28],{36{1'd0}}},{{6{1'd0}},mul_grid[8][21][0+:11],{53{1'd0}}},{{67{1'd0}},mul_grid[9][14][40+:3],{0{1'd0}}},{{50{1'd0}},mul_grid[9][15][23+:20],{0{1'd0}}},{{33{1'd0}},mul_grid[9][16][6+:37],{0{1'd0}}},{{16{1'd0}},mul_grid[9][17][0+:43],{11{1'd0}}},{{6{1'd0}},mul_grid[9][18][0+:36],{28{1'd0}}},{{6{1'd0}},mul_grid[9][19][0+:19],{45{1'd0}}},{{6{1'd0}},mul_grid[9][20][0+:2],{62{1'd0}}},{{58{1'd0}},mul_grid[10][13][31+:12],{0{1'd0}}},{{41{1'd0}},mul_grid[10][14][14+:29],{0{1'd0}}},{{24{1'd0}},mul_grid[10][15][0+:43],{3{1'd0}}},{{7{1'd0}},mul_grid[10][16][0+:43],{20{1'd0}}},{{6{1'd0}},mul_grid[10][17][0+:27],{37{1'd0}}},{{6{1'd0}},mul_grid[10][18][0+:10],{54{1'd0}}},{{66{1'd0}},mul_grid[11][11][39+:4],{0{1'd0}}},{{49{1'd0}},mul_grid[11][12][22+:21],{0{1'd0}}},{{32{1'd0}},mul_grid[11][13][5+:38],{0{1'd0}}},{{15{1'd0}},mul_grid[11][14][0+:43],{12{1'd0}}},{{6{1'd0}},mul_grid[11][15][0+:35],{29{1'd0}}},{{6{1'd0}},mul_grid[11][16][0+:18],{46{1'd0}}},{{6{1'd0}},mul_grid[11][17][0+:1],{63{1'd0}}},{{57{1'd0}},mul_grid[12][10][30+:13],{0{1'd0}}},{{40{1'd0}},mul_grid[12][11][13+:30],{0{1'd0}}},{{23{1'd0}},mul_grid[12][12][0+:43],{4{1'd0}}},{{6{1'd0}},mul_grid[12][13][0+:43],{21{1'd0}}},{{6{1'd0}},mul_grid[12][14][0+:26],{38{1'd0}}},{{6{1'd0}},mul_grid[12][15][0+:9],{55{1'd0}}},{{65{1'd0}},mul_grid[13][8][38+:5],{0{1'd0}}},{{48{1'd0}},mul_grid[13][9][21+:22],{0{1'd0}}},{{31{1'd0}},mul_grid[13][10][4+:39],{0{1'd0}}},{{14{1'd0}},mul_grid[13][11][0+:43],{13{1'd0}}},{{6{1'd0}},mul_grid[13][12][0+:34],{30{1'd0}}},{{6{1'd0}},mul_grid[13][13][0+:17],{47{1'd0}}},{{56{1'd0}},mul_grid[14][7][29+:14],{0{1'd0}}},{{39{1'd0}},mul_grid[14][8][12+:31],{0{1'd0}}},{{22{1'd0}},mul_grid[14][9][0+:43],{5{1'd0}}},{{6{1'd0}},mul_grid[14][10][0+:42],{22{1'd0}}},{{6{1'd0}},mul_grid[14][11][0+:25],{39{1'd0}}},{{6{1'd0}},mul_grid[14][12][0+:8],{56{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[8] <= accum_o_c_8 + accum_o_s_8;

// Coef 9
logic [69:0] accum_i_9 [41];
logic [69:0] accum_o_c_9, accum_o_s_9;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(41),
  .BIT_LEN(70)
)
ct_9 (
  .terms(accum_i_9),
  .C(accum_o_c_9),
  .S(accum_o_s_9)
);
always_comb accum_i_9 = {{{64{1'd0}},mul_grid[7][21][37+:6],{0{1'd0}}},{{47{1'd0}},mul_grid[7][22][20+:23],{0{1'd0}}},{{55{1'd0}},mul_grid[8][20][28+:15],{0{1'd0}}},{{38{1'd0}},mul_grid[8][21][11+:32],{0{1'd0}}},{{21{1'd0}},mul_grid[8][22][0+:43],{6{1'd0}}},{{63{1'd0}},mul_grid[9][18][36+:7],{0{1'd0}}},{{46{1'd0}},mul_grid[9][19][19+:24],{0{1'd0}}},{{29{1'd0}},mul_grid[9][20][2+:41],{0{1'd0}}},{{12{1'd0}},mul_grid[9][21][0+:43],{15{1'd0}}},{{6{1'd0}},mul_grid[9][22][0+:32],{32{1'd0}}},{{54{1'd0}},mul_grid[10][17][27+:16],{0{1'd0}}},{{37{1'd0}},mul_grid[10][18][10+:33],{0{1'd0}}},{{20{1'd0}},mul_grid[10][19][0+:43],{7{1'd0}}},{{6{1'd0}},mul_grid[10][20][0+:40],{24{1'd0}}},{{6{1'd0}},mul_grid[10][21][0+:23],{41{1'd0}}},{{6{1'd0}},mul_grid[10][22][0+:6],{58{1'd0}}},{{62{1'd0}},mul_grid[11][15][35+:8],{0{1'd0}}},{{45{1'd0}},mul_grid[11][16][18+:25],{0{1'd0}}},{{28{1'd0}},mul_grid[11][17][1+:42],{0{1'd0}}},{{11{1'd0}},mul_grid[11][18][0+:43],{16{1'd0}}},{{6{1'd0}},mul_grid[11][19][0+:31],{33{1'd0}}},{{6{1'd0}},mul_grid[11][20][0+:14],{50{1'd0}}},{{53{1'd0}},mul_grid[12][14][26+:17],{0{1'd0}}},{{36{1'd0}},mul_grid[12][15][9+:34],{0{1'd0}}},{{19{1'd0}},mul_grid[12][16][0+:43],{8{1'd0}}},{{6{1'd0}},mul_grid[12][17][0+:39],{25{1'd0}}},{{6{1'd0}},mul_grid[12][18][0+:22],{42{1'd0}}},{{6{1'd0}},mul_grid[12][19][0+:5],{59{1'd0}}},{{61{1'd0}},mul_grid[13][12][34+:9],{0{1'd0}}},{{44{1'd0}},mul_grid[13][13][17+:26],{0{1'd0}}},{{27{1'd0}},mul_grid[13][14][0+:43],{0{1'd0}}},{{10{1'd0}},mul_grid[13][15][0+:43],{17{1'd0}}},{{6{1'd0}},mul_grid[13][16][0+:30],{34{1'd0}}},{{6{1'd0}},mul_grid[13][17][0+:13],{51{1'd0}}},{{69{1'd0}},mul_grid[14][10][42+:1],{0{1'd0}}},{{52{1'd0}},mul_grid[14][11][25+:18],{0{1'd0}}},{{35{1'd0}},mul_grid[14][12][8+:35],{0{1'd0}}},{{18{1'd0}},mul_grid[14][13][0+:43],{9{1'd0}}},{{6{1'd0}},mul_grid[14][14][0+:38],{26{1'd0}}},{{6{1'd0}},mul_grid[14][15][0+:21],{43{1'd0}}},{{6{1'd0}},mul_grid[14][16][0+:4],{60{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[9] <= accum_o_c_9 + accum_o_s_9;

// Coef 10
logic [68:0] accum_i_10 [26];
logic [68:0] accum_o_c_10, accum_o_s_10;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(26),
  .BIT_LEN(69)
)
ct_10 (
  .terms(accum_i_10),
  .C(accum_o_c_10),
  .S(accum_o_s_10)
);
always_comb accum_i_10 = {{{58{1'd0}},mul_grid[9][22][32+:11],{0{1'd0}}},{{66{1'd0}},mul_grid[10][20][40+:3],{0{1'd0}}},{{49{1'd0}},mul_grid[10][21][23+:20],{0{1'd0}}},{{32{1'd0}},mul_grid[10][22][6+:37],{0{1'd0}}},{{57{1'd0}},mul_grid[11][19][31+:12],{0{1'd0}}},{{40{1'd0}},mul_grid[11][20][14+:29],{0{1'd0}}},{{23{1'd0}},mul_grid[11][21][0+:43],{3{1'd0}}},{{6{1'd0}},mul_grid[11][22][0+:43],{20{1'd0}}},{{65{1'd0}},mul_grid[12][17][39+:4],{0{1'd0}}},{{48{1'd0}},mul_grid[12][18][22+:21],{0{1'd0}}},{{31{1'd0}},mul_grid[12][19][5+:38],{0{1'd0}}},{{14{1'd0}},mul_grid[12][20][0+:43],{12{1'd0}}},{{5{1'd0}},mul_grid[12][21][0+:35],{29{1'd0}}},{{5{1'd0}},mul_grid[12][22][0+:18],{46{1'd0}}},{{56{1'd0}},mul_grid[13][16][30+:13],{0{1'd0}}},{{39{1'd0}},mul_grid[13][17][13+:30],{0{1'd0}}},{{22{1'd0}},mul_grid[13][18][0+:43],{4{1'd0}}},{{5{1'd0}},mul_grid[13][19][0+:43],{21{1'd0}}},{{5{1'd0}},mul_grid[13][20][0+:26],{38{1'd0}}},{{5{1'd0}},mul_grid[13][21][0+:9],{55{1'd0}}},{{64{1'd0}},mul_grid[14][14][38+:5],{0{1'd0}}},{{47{1'd0}},mul_grid[14][15][21+:22],{0{1'd0}}},{{30{1'd0}},mul_grid[14][16][4+:39],{0{1'd0}}},{{13{1'd0}},mul_grid[14][17][0+:43],{13{1'd0}}},{{5{1'd0}},mul_grid[14][18][0+:34],{30{1'd0}}},{{5{1'd0}},mul_grid[14][19][0+:17],{47{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[10] <= accum_o_c_10 + accum_o_s_10;

// Coef 11
logic [67:0] accum_i_11 [10];
logic [67:0] accum_o_c_11, accum_o_s_11;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(10),
  .BIT_LEN(68)
)
ct_11 (
  .terms(accum_i_11),
  .C(accum_o_c_11),
  .S(accum_o_s_11)
);
always_comb accum_i_11 = {{{60{1'd0}},mul_grid[12][21][35+:8],{0{1'd0}}},{{43{1'd0}},mul_grid[12][22][18+:25],{0{1'd0}}},{{51{1'd0}},mul_grid[13][20][26+:17],{0{1'd0}}},{{34{1'd0}},mul_grid[13][21][9+:34],{0{1'd0}}},{{17{1'd0}},mul_grid[13][22][0+:43],{8{1'd0}}},{{59{1'd0}},mul_grid[14][18][34+:9],{0{1'd0}}},{{42{1'd0}},mul_grid[14][19][17+:26],{0{1'd0}}},{{25{1'd0}},mul_grid[14][20][0+:43],{0{1'd0}}},{{8{1'd0}},mul_grid[14][21][0+:43],{17{1'd0}}},{{4{1'd0}},mul_grid[14][22][0+:30],{34{1'd0}}}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[11] <= accum_o_c_11 + accum_o_s_11;

logic [9:0]    mod_ram_0_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_0_q;
logic [380:0]    mod_ram_0_d;
logic [380:0]    mod_ram_0_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_0_q <= mod_ram_0_ram[mod_ram_0_a];
end
initial $readmemh( "mod_ram_0.mem", mod_ram_0_ram);

logic [9:0]    mod_ram_1_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_1_q;
logic [380:0]    mod_ram_1_d;
logic [380:0]    mod_ram_1_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_1_q <= mod_ram_1_ram[mod_ram_1_a];
end
initial $readmemh( "mod_ram_1.mem", mod_ram_1_ram);

logic [9:0]    mod_ram_2_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_2_q;
logic [380:0]    mod_ram_2_d;
logic [380:0]    mod_ram_2_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_2_q <= mod_ram_2_ram[mod_ram_2_a];
end
initial $readmemh( "mod_ram_2.mem", mod_ram_2_ram);

logic [9:0]    mod_ram_3_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_3_q;
logic [380:0]    mod_ram_3_d;
logic [380:0]    mod_ram_3_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_3_q <= mod_ram_3_ram[mod_ram_3_a];
end
initial $readmemh( "mod_ram_3.mem", mod_ram_3_ram);

logic [9:0]    mod_ram_4_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_4_q;
logic [380:0]    mod_ram_4_d;
logic [380:0]    mod_ram_4_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_4_q <= mod_ram_4_ram[mod_ram_4_a];
end
initial $readmemh( "mod_ram_4.mem", mod_ram_4_ram);

logic [9:0]    mod_ram_5_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_5_q;
logic [380:0]    mod_ram_5_d;
logic [380:0]    mod_ram_5_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_5_q <= mod_ram_5_ram[mod_ram_5_a];
end
initial $readmemh( "mod_ram_5.mem", mod_ram_5_ram);

logic [9:0]    mod_ram_6_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_6_q;
logic [380:0]    mod_ram_6_d;
logic [380:0]    mod_ram_6_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_6_q <= mod_ram_6_ram[mod_ram_6_a];
end
initial $readmemh( "mod_ram_6.mem", mod_ram_6_ram);

logic [9:0]    mod_ram_7_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_7_q;
logic [380:0]    mod_ram_7_d;
logic [380:0]    mod_ram_7_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_7_q <= mod_ram_7_ram[mod_ram_7_a];
end
initial $readmemh( "mod_ram_7.mem", mod_ram_7_ram);

logic [9:0]    mod_ram_8_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_8_q;
logic [380:0]    mod_ram_8_d;
logic [380:0]    mod_ram_8_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_8_q <= mod_ram_8_ram[mod_ram_8_a];
end
initial $readmemh( "mod_ram_8.mem", mod_ram_8_ram);

logic [9:0]    mod_ram_9_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_9_q;
logic [380:0]    mod_ram_9_d;
logic [380:0]    mod_ram_9_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_9_q <= mod_ram_9_ram[mod_ram_9_a];
end
initial $readmemh( "mod_ram_9.mem", mod_ram_9_ram);

logic [9:0]    mod_ram_10_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_10_q;
logic [380:0]    mod_ram_10_d;
logic [380:0]    mod_ram_10_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_10_q <= mod_ram_10_ram[mod_ram_10_a];
end
initial $readmemh( "mod_ram_10.mem", mod_ram_10_ram);

logic [9:0]    mod_ram_11_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_11_q;
logic [380:0]    mod_ram_11_d;
logic [380:0]    mod_ram_11_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_11_q <= mod_ram_11_ram[mod_ram_11_a];
end
initial $readmemh( "mod_ram_11.mem", mod_ram_11_ram);

logic [9:0]    mod_ram_12_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_12_q;
logic [380:0]    mod_ram_12_d;
logic [380:0]    mod_ram_12_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_12_q <= mod_ram_12_ram[mod_ram_12_a];
end
initial $readmemh( "mod_ram_12.mem", mod_ram_12_ram);

logic [9:0]    mod_ram_13_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_13_q;
logic [380:0]    mod_ram_13_d;
logic [380:0]    mod_ram_13_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_13_q <= mod_ram_13_ram[mod_ram_13_a];
end
initial $readmemh( "mod_ram_13.mem", mod_ram_13_ram);

logic [9:0]    mod_ram_14_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_14_q;
logic [380:0]    mod_ram_14_d;
logic [380:0]    mod_ram_14_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_14_q <= mod_ram_14_ram[mod_ram_14_a];
end
initial $readmemh( "mod_ram_14.mem", mod_ram_14_ram);

logic [9:0]    mod_ram_15_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_15_q;
logic [380:0]    mod_ram_15_d;
logic [380:0]    mod_ram_15_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_15_q <= mod_ram_15_ram[mod_ram_15_a];
end
initial $readmemh( "mod_ram_15.mem", mod_ram_15_ram);

logic [9:0]    mod_ram_16_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_16_q;
logic [380:0]    mod_ram_16_d;
logic [380:0]    mod_ram_16_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_16_q <= mod_ram_16_ram[mod_ram_16_a];
end
initial $readmemh( "mod_ram_16.mem", mod_ram_16_ram);

logic [9:0]    mod_ram_17_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_17_q;
logic [380:0]    mod_ram_17_d;
logic [380:0]    mod_ram_17_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_17_q <= mod_ram_17_ram[mod_ram_17_a];
end
initial $readmemh( "mod_ram_17.mem", mod_ram_17_ram);

logic [9:0]    mod_ram_18_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_18_q;
logic [380:0]    mod_ram_18_d;
logic [380:0]    mod_ram_18_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_18_q <= mod_ram_18_ram[mod_ram_18_a];
end
initial $readmemh( "mod_ram_18.mem", mod_ram_18_ram);

logic [9:0]    mod_ram_19_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_19_q;
logic [380:0]    mod_ram_19_d;
logic [380:0]    mod_ram_19_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_19_q <= mod_ram_19_ram[mod_ram_19_a];
end
initial $readmemh( "mod_ram_19.mem", mod_ram_19_ram);

logic [9:0]    mod_ram_20_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_20_q;
logic [380:0]    mod_ram_20_d;
logic [380:0]    mod_ram_20_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_20_q <= mod_ram_20_ram[mod_ram_20_a];
end
initial $readmemh( "mod_ram_20.mem", mod_ram_20_ram);

logic [9:0]    mod_ram_21_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_21_q;
logic [380:0]    mod_ram_21_d;
logic [380:0]    mod_ram_21_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_21_q <= mod_ram_21_ram[mod_ram_21_a];
end
initial $readmemh( "mod_ram_21.mem", mod_ram_21_ram);

logic [9:0]    mod_ram_22_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_22_q;
logic [380:0]    mod_ram_22_d;
logic [380:0]    mod_ram_22_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_22_q <= mod_ram_22_ram[mod_ram_22_a];
end
initial $readmemh( "mod_ram_22.mem", mod_ram_22_ram);

logic [9:0]    mod_ram_23_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_23_q;
logic [380:0]    mod_ram_23_d;
logic [380:0]    mod_ram_23_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_23_q <= mod_ram_23_ram[mod_ram_23_a];
end
initial $readmemh( "mod_ram_23.mem", mod_ram_23_ram);

logic [9:0]    mod_ram_24_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_24_q;
logic [380:0]    mod_ram_24_d;
logic [380:0]    mod_ram_24_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_24_q <= mod_ram_24_ram[mod_ram_24_a];
end
initial $readmemh( "mod_ram_24.mem", mod_ram_24_ram);

logic [9:0]    mod_ram_25_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_25_q;
logic [380:0]    mod_ram_25_d;
logic [380:0]    mod_ram_25_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_25_q <= mod_ram_25_ram[mod_ram_25_a];
end
initial $readmemh( "mod_ram_25.mem", mod_ram_25_ram);

logic [9:0]    mod_ram_26_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_26_q;
logic [380:0]    mod_ram_26_d;
logic [380:0]    mod_ram_26_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_26_q <= mod_ram_26_ram[mod_ram_26_a];
end
initial $readmemh( "mod_ram_26.mem", mod_ram_26_ram);

logic [9:0]    mod_ram_27_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_27_q;
logic [380:0]    mod_ram_27_d;
logic [380:0]    mod_ram_27_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_27_q <= mod_ram_27_ram[mod_ram_27_a];
end
initial $readmemh( "mod_ram_27.mem", mod_ram_27_ram);

logic [9:0]    mod_ram_28_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_28_q;
logic [380:0]    mod_ram_28_d;
logic [380:0]    mod_ram_28_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_28_q <= mod_ram_28_ram[mod_ram_28_a];
end
initial $readmemh( "mod_ram_28.mem", mod_ram_28_ram);

logic [9:0]    mod_ram_29_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_29_q;
logic [380:0]    mod_ram_29_d;
logic [380:0]    mod_ram_29_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_29_q <= mod_ram_29_ram[mod_ram_29_a];
end
initial $readmemh( "mod_ram_29.mem", mod_ram_29_ram);

logic [9:0]    mod_ram_30_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_30_q;
logic [380:0]    mod_ram_30_d;
logic [380:0]    mod_ram_30_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_30_q <= mod_ram_30_ram[mod_ram_30_a];
end
initial $readmemh( "mod_ram_30.mem", mod_ram_30_ram);

logic [9:0]    mod_ram_31_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_31_q;
logic [380:0]    mod_ram_31_d;
logic [380:0]    mod_ram_31_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_31_q <= mod_ram_31_ram[mod_ram_31_a];
end
initial $readmemh( "mod_ram_31.mem", mod_ram_31_ram);

logic [9:0]    mod_ram_32_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_32_q;
logic [380:0]    mod_ram_32_d;
logic [380:0]    mod_ram_32_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_32_q <= mod_ram_32_ram[mod_ram_32_a];
end
initial $readmemh( "mod_ram_32.mem", mod_ram_32_ram);

logic [9:0]    mod_ram_33_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_33_q;
logic [380:0]    mod_ram_33_d;
logic [380:0]    mod_ram_33_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_33_q <= mod_ram_33_ram[mod_ram_33_a];
end
initial $readmemh( "mod_ram_33.mem", mod_ram_33_ram);

logic [9:0]    mod_ram_34_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_34_q;
logic [380:0]    mod_ram_34_d;
logic [380:0]    mod_ram_34_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_34_q <= mod_ram_34_ram[mod_ram_34_a];
end
initial $readmemh( "mod_ram_34.mem", mod_ram_34_ram);

logic [9:0]    mod_ram_35_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_35_q;
logic [380:0]    mod_ram_35_d;
logic [380:0]    mod_ram_35_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_35_q <= mod_ram_35_ram[mod_ram_35_a];
end
initial $readmemh( "mod_ram_35.mem", mod_ram_35_ram);

logic [9:0]    mod_ram_36_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_36_q;
logic [380:0]    mod_ram_36_d;
logic [380:0]    mod_ram_36_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_36_q <= mod_ram_36_ram[mod_ram_36_a];
end
initial $readmemh( "mod_ram_36.mem", mod_ram_36_ram);

logic [9:0]    mod_ram_37_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_37_q;
logic [380:0]    mod_ram_37_d;
logic [380:0]    mod_ram_37_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_37_q <= mod_ram_37_ram[mod_ram_37_a];
end
initial $readmemh( "mod_ram_37.mem", mod_ram_37_ram);

logic [9:0]    mod_ram_38_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_38_q;
logic [380:0]    mod_ram_38_d;
logic [380:0]    mod_ram_38_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_38_q <= mod_ram_38_ram[mod_ram_38_a];
end
initial $readmemh( "mod_ram_38.mem", mod_ram_38_ram);

logic [9:0]    mod_ram_39_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_39_q;
logic [380:0]    mod_ram_39_d;
logic [380:0]    mod_ram_39_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_39_q <= mod_ram_39_ram[mod_ram_39_a];
end
initial $readmemh( "mod_ram_39.mem", mod_ram_39_ram);

logic [9:0]    mod_ram_40_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_40_q;
logic [380:0]    mod_ram_40_d;
logic [380:0]    mod_ram_40_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_40_q <= mod_ram_40_ram[mod_ram_40_a];
end
initial $readmemh( "mod_ram_40.mem", mod_ram_40_ram);

logic [9:0]    mod_ram_41_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_41_q;
logic [380:0]    mod_ram_41_d;
logic [380:0]    mod_ram_41_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_41_q <= mod_ram_41_ram[mod_ram_41_a];
end
initial $readmemh( "mod_ram_41.mem", mod_ram_41_ram);

logic [9:0]    mod_ram_42_a;
(* DONT_TOUCH = "yes" *) logic [380:0]    mod_ram_42_q;
logic [380:0]    mod_ram_42_d;
logic [380:0]    mod_ram_42_ram [1024];
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_42_q <= mod_ram_42_ram[mod_ram_42_a];
end
initial $readmemh( "mod_ram_42.mem", mod_ram_42_ram);

always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram_0_a[0+:10] <= accum_grid_o[5][61+:10];
  mod_ram_1_a[0+:10] <= accum_grid_o[6][0+:10];
  mod_ram_2_a[0+:10] <= accum_grid_o[6][10+:10];
  mod_ram_3_a[0+:10] <= accum_grid_o[6][20+:10];
  mod_ram_4_a[0+:10] <= accum_grid_o[6][30+:10];
  mod_ram_5_a[0+:10] <= accum_grid_o[6][40+:10];
  mod_ram_6_a[0+:10] <= accum_grid_o[6][50+:10];
  mod_ram_7_a[0+:10] <= accum_grid_o[6][60+:10];
  mod_ram_8_a[0+:1] <= accum_grid_o[6][70+:1];
  mod_ram_8_a[1+:9] <= accum_grid_o[7][0+:9];
  mod_ram_9_a[0+:10] <= accum_grid_o[7][9+:10];
  mod_ram_10_a[0+:10] <= accum_grid_o[7][19+:10];
  mod_ram_11_a[0+:10] <= accum_grid_o[7][29+:10];
  mod_ram_12_a[0+:10] <= accum_grid_o[7][39+:10];
  mod_ram_13_a[0+:10] <= accum_grid_o[7][49+:10];
  mod_ram_14_a[0+:10] <= accum_grid_o[7][59+:10];
  mod_ram_15_a[0+:2] <= accum_grid_o[7][69+:2];
  mod_ram_15_a[2+:8] <= accum_grid_o[8][0+:8];
  mod_ram_16_a[0+:10] <= accum_grid_o[8][8+:10];
  mod_ram_17_a[0+:10] <= accum_grid_o[8][18+:10];
  mod_ram_18_a[0+:10] <= accum_grid_o[8][28+:10];
  mod_ram_19_a[0+:10] <= accum_grid_o[8][38+:10];
  mod_ram_20_a[0+:10] <= accum_grid_o[8][48+:10];
  mod_ram_21_a[0+:10] <= accum_grid_o[8][58+:10];
  mod_ram_22_a[0+:2] <= accum_grid_o[8][68+:2];
  mod_ram_22_a[2+:8] <= accum_grid_o[9][0+:8];
  mod_ram_23_a[0+:10] <= accum_grid_o[9][8+:10];
  mod_ram_24_a[0+:10] <= accum_grid_o[9][18+:10];
  mod_ram_25_a[0+:10] <= accum_grid_o[9][28+:10];
  mod_ram_26_a[0+:10] <= accum_grid_o[9][38+:10];
  mod_ram_27_a[0+:10] <= accum_grid_o[9][48+:10];
  mod_ram_28_a[0+:10] <= accum_grid_o[9][58+:10];
  mod_ram_29_a[0+:2] <= accum_grid_o[9][68+:2];
  mod_ram_29_a[2+:8] <= accum_grid_o[10][0+:8];
  mod_ram_30_a[0+:10] <= accum_grid_o[10][8+:10];
  mod_ram_31_a[0+:10] <= accum_grid_o[10][18+:10];
  mod_ram_32_a[0+:10] <= accum_grid_o[10][28+:10];
  mod_ram_33_a[0+:10] <= accum_grid_o[10][38+:10];
  mod_ram_34_a[0+:10] <= accum_grid_o[10][48+:10];
  mod_ram_35_a[0+:10] <= accum_grid_o[10][58+:10];
  mod_ram_36_a[0+:1] <= accum_grid_o[10][68+:1];
  mod_ram_36_a[1+:9] <= accum_grid_o[11][0+:9];
  mod_ram_37_a[0+:10] <= accum_grid_o[11][9+:10];
  mod_ram_38_a[0+:10] <= accum_grid_o[11][19+:10];
  mod_ram_39_a[0+:10] <= accum_grid_o[11][29+:10];
  mod_ram_40_a[0+:10] <= accum_grid_o[11][39+:10];
  mod_ram_41_a[0+:10] <= accum_grid_o[11][49+:10];
  mod_ram_42_a[0+:9] <= accum_grid_o[11][59+:9];
  mod_ram_42_a[9+:1] <= 0;
end


// Coef 0 accum 2 stage
logic [72:0] accum2_i_0 [44];
logic [72:0] accum2_o_c_0, accum2_o_s_0;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(44),
  .BIT_LEN(73)
)
ct2_0 (
  .terms(accum2_i_0),
  .C(accum2_o_c_0),
  .S(accum2_o_s_0)
);
always_comb accum2_i_0 = {{{9{1'd0}}, mod_ram_0_q[0+:64]},{{9{1'd0}}, mod_ram_1_q[0+:64]},{{9{1'd0}}, mod_ram_2_q[0+:64]},{{9{1'd0}}, mod_ram_3_q[0+:64]},{{9{1'd0}}, mod_ram_4_q[0+:64]},{{9{1'd0}}, mod_ram_5_q[0+:64]},{{9{1'd0}}, mod_ram_6_q[0+:64]},{{9{1'd0}}, mod_ram_7_q[0+:64]},{{9{1'd0}}, mod_ram_8_q[0+:64]},{{9{1'd0}}, mod_ram_9_q[0+:64]},{{9{1'd0}}, mod_ram_10_q[0+:64]},{{9{1'd0}}, mod_ram_11_q[0+:64]},{{9{1'd0}}, mod_ram_12_q[0+:64]},{{9{1'd0}}, mod_ram_13_q[0+:64]},{{9{1'd0}}, mod_ram_14_q[0+:64]},{{9{1'd0}}, mod_ram_15_q[0+:64]},{{9{1'd0}}, mod_ram_16_q[0+:64]},{{9{1'd0}}, mod_ram_17_q[0+:64]},{{9{1'd0}}, mod_ram_18_q[0+:64]},{{9{1'd0}}, mod_ram_19_q[0+:64]},{{9{1'd0}}, mod_ram_20_q[0+:64]},{{9{1'd0}}, mod_ram_21_q[0+:64]},{{9{1'd0}}, mod_ram_22_q[0+:64]},{{9{1'd0}}, mod_ram_23_q[0+:64]},{{9{1'd0}}, mod_ram_24_q[0+:64]},{{9{1'd0}}, mod_ram_25_q[0+:64]},{{9{1'd0}}, mod_ram_26_q[0+:64]},{{9{1'd0}}, mod_ram_27_q[0+:64]},{{9{1'd0}}, mod_ram_28_q[0+:64]},{{9{1'd0}}, mod_ram_29_q[0+:64]},{{9{1'd0}}, mod_ram_30_q[0+:64]},{{9{1'd0}}, mod_ram_31_q[0+:64]},{{9{1'd0}}, mod_ram_32_q[0+:64]},{{9{1'd0}}, mod_ram_33_q[0+:64]},{{9{1'd0}}, mod_ram_34_q[0+:64]},{{9{1'd0}}, mod_ram_35_q[0+:64]},{{9{1'd0}}, mod_ram_36_q[0+:64]},{{9{1'd0}}, mod_ram_37_q[0+:64]},{{9{1'd0}}, mod_ram_38_q[0+:64]},{{9{1'd0}}, mod_ram_39_q[0+:64]},{{9{1'd0}}, mod_ram_40_q[0+:64]},{{9{1'd0}}, mod_ram_41_q[0+:64]},{{9{1'd0}}, mod_ram_42_q[0+:64]},{{0{1'd0}}, accum_grid_o_rr[0][72:0]}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum2_grid_o[0] <= accum2_o_c_0 + accum2_o_s_0;

// Coef 1 accum 2 stage
logic [74:0] accum2_i_1 [44];
logic [74:0] accum2_o_c_1, accum2_o_s_1;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(44),
  .BIT_LEN(75)
)
ct2_1 (
  .terms(accum2_i_1),
  .C(accum2_o_c_1),
  .S(accum2_o_s_1)
);
always_comb accum2_i_1 = {{{11{1'd0}}, mod_ram_0_q[64+:64]},{{11{1'd0}}, mod_ram_1_q[64+:64]},{{11{1'd0}}, mod_ram_2_q[64+:64]},{{11{1'd0}}, mod_ram_3_q[64+:64]},{{11{1'd0}}, mod_ram_4_q[64+:64]},{{11{1'd0}}, mod_ram_5_q[64+:64]},{{11{1'd0}}, mod_ram_6_q[64+:64]},{{11{1'd0}}, mod_ram_7_q[64+:64]},{{11{1'd0}}, mod_ram_8_q[64+:64]},{{11{1'd0}}, mod_ram_9_q[64+:64]},{{11{1'd0}}, mod_ram_10_q[64+:64]},{{11{1'd0}}, mod_ram_11_q[64+:64]},{{11{1'd0}}, mod_ram_12_q[64+:64]},{{11{1'd0}}, mod_ram_13_q[64+:64]},{{11{1'd0}}, mod_ram_14_q[64+:64]},{{11{1'd0}}, mod_ram_15_q[64+:64]},{{11{1'd0}}, mod_ram_16_q[64+:64]},{{11{1'd0}}, mod_ram_17_q[64+:64]},{{11{1'd0}}, mod_ram_18_q[64+:64]},{{11{1'd0}}, mod_ram_19_q[64+:64]},{{11{1'd0}}, mod_ram_20_q[64+:64]},{{11{1'd0}}, mod_ram_21_q[64+:64]},{{11{1'd0}}, mod_ram_22_q[64+:64]},{{11{1'd0}}, mod_ram_23_q[64+:64]},{{11{1'd0}}, mod_ram_24_q[64+:64]},{{11{1'd0}}, mod_ram_25_q[64+:64]},{{11{1'd0}}, mod_ram_26_q[64+:64]},{{11{1'd0}}, mod_ram_27_q[64+:64]},{{11{1'd0}}, mod_ram_28_q[64+:64]},{{11{1'd0}}, mod_ram_29_q[64+:64]},{{11{1'd0}}, mod_ram_30_q[64+:64]},{{11{1'd0}}, mod_ram_31_q[64+:64]},{{11{1'd0}}, mod_ram_32_q[64+:64]},{{11{1'd0}}, mod_ram_33_q[64+:64]},{{11{1'd0}}, mod_ram_34_q[64+:64]},{{11{1'd0}}, mod_ram_35_q[64+:64]},{{11{1'd0}}, mod_ram_36_q[64+:64]},{{11{1'd0}}, mod_ram_37_q[64+:64]},{{11{1'd0}}, mod_ram_38_q[64+:64]},{{11{1'd0}}, mod_ram_39_q[64+:64]},{{11{1'd0}}, mod_ram_40_q[64+:64]},{{11{1'd0}}, mod_ram_41_q[64+:64]},{{11{1'd0}}, mod_ram_42_q[64+:64]},{{0{1'd0}}, accum_grid_o_rr[1][74:0]}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum2_grid_o[1] <= accum2_o_c_1 + accum2_o_s_1;

// Coef 2 accum 2 stage
logic [75:0] accum2_i_2 [44];
logic [75:0] accum2_o_c_2, accum2_o_s_2;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(44),
  .BIT_LEN(76)
)
ct2_2 (
  .terms(accum2_i_2),
  .C(accum2_o_c_2),
  .S(accum2_o_s_2)
);
always_comb accum2_i_2 = {{{12{1'd0}}, mod_ram_0_q[128+:64]},{{12{1'd0}}, mod_ram_1_q[128+:64]},{{12{1'd0}}, mod_ram_2_q[128+:64]},{{12{1'd0}}, mod_ram_3_q[128+:64]},{{12{1'd0}}, mod_ram_4_q[128+:64]},{{12{1'd0}}, mod_ram_5_q[128+:64]},{{12{1'd0}}, mod_ram_6_q[128+:64]},{{12{1'd0}}, mod_ram_7_q[128+:64]},{{12{1'd0}}, mod_ram_8_q[128+:64]},{{12{1'd0}}, mod_ram_9_q[128+:64]},{{12{1'd0}}, mod_ram_10_q[128+:64]},{{12{1'd0}}, mod_ram_11_q[128+:64]},{{12{1'd0}}, mod_ram_12_q[128+:64]},{{12{1'd0}}, mod_ram_13_q[128+:64]},{{12{1'd0}}, mod_ram_14_q[128+:64]},{{12{1'd0}}, mod_ram_15_q[128+:64]},{{12{1'd0}}, mod_ram_16_q[128+:64]},{{12{1'd0}}, mod_ram_17_q[128+:64]},{{12{1'd0}}, mod_ram_18_q[128+:64]},{{12{1'd0}}, mod_ram_19_q[128+:64]},{{12{1'd0}}, mod_ram_20_q[128+:64]},{{12{1'd0}}, mod_ram_21_q[128+:64]},{{12{1'd0}}, mod_ram_22_q[128+:64]},{{12{1'd0}}, mod_ram_23_q[128+:64]},{{12{1'd0}}, mod_ram_24_q[128+:64]},{{12{1'd0}}, mod_ram_25_q[128+:64]},{{12{1'd0}}, mod_ram_26_q[128+:64]},{{12{1'd0}}, mod_ram_27_q[128+:64]},{{12{1'd0}}, mod_ram_28_q[128+:64]},{{12{1'd0}}, mod_ram_29_q[128+:64]},{{12{1'd0}}, mod_ram_30_q[128+:64]},{{12{1'd0}}, mod_ram_31_q[128+:64]},{{12{1'd0}}, mod_ram_32_q[128+:64]},{{12{1'd0}}, mod_ram_33_q[128+:64]},{{12{1'd0}}, mod_ram_34_q[128+:64]},{{12{1'd0}}, mod_ram_35_q[128+:64]},{{12{1'd0}}, mod_ram_36_q[128+:64]},{{12{1'd0}}, mod_ram_37_q[128+:64]},{{12{1'd0}}, mod_ram_38_q[128+:64]},{{12{1'd0}}, mod_ram_39_q[128+:64]},{{12{1'd0}}, mod_ram_40_q[128+:64]},{{12{1'd0}}, mod_ram_41_q[128+:64]},{{12{1'd0}}, mod_ram_42_q[128+:64]},{{0{1'd0}}, accum_grid_o_rr[2][75:0]}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum2_grid_o[2] <= accum2_o_c_2 + accum2_o_s_2;

// Coef 3 accum 2 stage
logic [75:0] accum2_i_3 [44];
logic [75:0] accum2_o_c_3, accum2_o_s_3;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(44),
  .BIT_LEN(76)
)
ct2_3 (
  .terms(accum2_i_3),
  .C(accum2_o_c_3),
  .S(accum2_o_s_3)
);
always_comb accum2_i_3 = {{{12{1'd0}}, mod_ram_0_q[192+:64]},{{12{1'd0}}, mod_ram_1_q[192+:64]},{{12{1'd0}}, mod_ram_2_q[192+:64]},{{12{1'd0}}, mod_ram_3_q[192+:64]},{{12{1'd0}}, mod_ram_4_q[192+:64]},{{12{1'd0}}, mod_ram_5_q[192+:64]},{{12{1'd0}}, mod_ram_6_q[192+:64]},{{12{1'd0}}, mod_ram_7_q[192+:64]},{{12{1'd0}}, mod_ram_8_q[192+:64]},{{12{1'd0}}, mod_ram_9_q[192+:64]},{{12{1'd0}}, mod_ram_10_q[192+:64]},{{12{1'd0}}, mod_ram_11_q[192+:64]},{{12{1'd0}}, mod_ram_12_q[192+:64]},{{12{1'd0}}, mod_ram_13_q[192+:64]},{{12{1'd0}}, mod_ram_14_q[192+:64]},{{12{1'd0}}, mod_ram_15_q[192+:64]},{{12{1'd0}}, mod_ram_16_q[192+:64]},{{12{1'd0}}, mod_ram_17_q[192+:64]},{{12{1'd0}}, mod_ram_18_q[192+:64]},{{12{1'd0}}, mod_ram_19_q[192+:64]},{{12{1'd0}}, mod_ram_20_q[192+:64]},{{12{1'd0}}, mod_ram_21_q[192+:64]},{{12{1'd0}}, mod_ram_22_q[192+:64]},{{12{1'd0}}, mod_ram_23_q[192+:64]},{{12{1'd0}}, mod_ram_24_q[192+:64]},{{12{1'd0}}, mod_ram_25_q[192+:64]},{{12{1'd0}}, mod_ram_26_q[192+:64]},{{12{1'd0}}, mod_ram_27_q[192+:64]},{{12{1'd0}}, mod_ram_28_q[192+:64]},{{12{1'd0}}, mod_ram_29_q[192+:64]},{{12{1'd0}}, mod_ram_30_q[192+:64]},{{12{1'd0}}, mod_ram_31_q[192+:64]},{{12{1'd0}}, mod_ram_32_q[192+:64]},{{12{1'd0}}, mod_ram_33_q[192+:64]},{{12{1'd0}}, mod_ram_34_q[192+:64]},{{12{1'd0}}, mod_ram_35_q[192+:64]},{{12{1'd0}}, mod_ram_36_q[192+:64]},{{12{1'd0}}, mod_ram_37_q[192+:64]},{{12{1'd0}}, mod_ram_38_q[192+:64]},{{12{1'd0}}, mod_ram_39_q[192+:64]},{{12{1'd0}}, mod_ram_40_q[192+:64]},{{12{1'd0}}, mod_ram_41_q[192+:64]},{{12{1'd0}}, mod_ram_42_q[192+:64]},{{0{1'd0}}, accum_grid_o_rr[3][75:0]}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum2_grid_o[3] <= accum2_o_c_3 + accum2_o_s_3;

// Coef 4 accum 2 stage
logic [76:0] accum2_i_4 [44];
logic [76:0] accum2_o_c_4, accum2_o_s_4;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(44),
  .BIT_LEN(77)
)
ct2_4 (
  .terms(accum2_i_4),
  .C(accum2_o_c_4),
  .S(accum2_o_s_4)
);
always_comb accum2_i_4 = {{{13{1'd0}}, mod_ram_0_q[256+:64]},{{13{1'd0}}, mod_ram_1_q[256+:64]},{{13{1'd0}}, mod_ram_2_q[256+:64]},{{13{1'd0}}, mod_ram_3_q[256+:64]},{{13{1'd0}}, mod_ram_4_q[256+:64]},{{13{1'd0}}, mod_ram_5_q[256+:64]},{{13{1'd0}}, mod_ram_6_q[256+:64]},{{13{1'd0}}, mod_ram_7_q[256+:64]},{{13{1'd0}}, mod_ram_8_q[256+:64]},{{13{1'd0}}, mod_ram_9_q[256+:64]},{{13{1'd0}}, mod_ram_10_q[256+:64]},{{13{1'd0}}, mod_ram_11_q[256+:64]},{{13{1'd0}}, mod_ram_12_q[256+:64]},{{13{1'd0}}, mod_ram_13_q[256+:64]},{{13{1'd0}}, mod_ram_14_q[256+:64]},{{13{1'd0}}, mod_ram_15_q[256+:64]},{{13{1'd0}}, mod_ram_16_q[256+:64]},{{13{1'd0}}, mod_ram_17_q[256+:64]},{{13{1'd0}}, mod_ram_18_q[256+:64]},{{13{1'd0}}, mod_ram_19_q[256+:64]},{{13{1'd0}}, mod_ram_20_q[256+:64]},{{13{1'd0}}, mod_ram_21_q[256+:64]},{{13{1'd0}}, mod_ram_22_q[256+:64]},{{13{1'd0}}, mod_ram_23_q[256+:64]},{{13{1'd0}}, mod_ram_24_q[256+:64]},{{13{1'd0}}, mod_ram_25_q[256+:64]},{{13{1'd0}}, mod_ram_26_q[256+:64]},{{13{1'd0}}, mod_ram_27_q[256+:64]},{{13{1'd0}}, mod_ram_28_q[256+:64]},{{13{1'd0}}, mod_ram_29_q[256+:64]},{{13{1'd0}}, mod_ram_30_q[256+:64]},{{13{1'd0}}, mod_ram_31_q[256+:64]},{{13{1'd0}}, mod_ram_32_q[256+:64]},{{13{1'd0}}, mod_ram_33_q[256+:64]},{{13{1'd0}}, mod_ram_34_q[256+:64]},{{13{1'd0}}, mod_ram_35_q[256+:64]},{{13{1'd0}}, mod_ram_36_q[256+:64]},{{13{1'd0}}, mod_ram_37_q[256+:64]},{{13{1'd0}}, mod_ram_38_q[256+:64]},{{13{1'd0}}, mod_ram_39_q[256+:64]},{{13{1'd0}}, mod_ram_40_q[256+:64]},{{13{1'd0}}, mod_ram_41_q[256+:64]},{{13{1'd0}}, mod_ram_42_q[256+:64]},{{0{1'd0}}, accum_grid_o_rr[4][76:0]}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum2_grid_o[4] <= accum2_o_c_4 + accum2_o_s_4;

// Coef 5 accum 2 stage
logic [76:0] accum2_i_5 [44];
logic [76:0] accum2_o_c_5, accum2_o_s_5;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(44),
  .BIT_LEN(77)
)
ct2_5 (
  .terms(accum2_i_5),
  .C(accum2_o_c_5),
  .S(accum2_o_s_5)
);
always_comb accum2_i_5 = {{{16{1'd0}}, mod_ram_0_q[320+:61]},{{16{1'd0}}, mod_ram_1_q[320+:61]},{{16{1'd0}}, mod_ram_2_q[320+:61]},{{16{1'd0}}, mod_ram_3_q[320+:61]},{{16{1'd0}}, mod_ram_4_q[320+:61]},{{16{1'd0}}, mod_ram_5_q[320+:61]},{{16{1'd0}}, mod_ram_6_q[320+:61]},{{16{1'd0}}, mod_ram_7_q[320+:61]},{{16{1'd0}}, mod_ram_8_q[320+:61]},{{16{1'd0}}, mod_ram_9_q[320+:61]},{{16{1'd0}}, mod_ram_10_q[320+:61]},{{16{1'd0}}, mod_ram_11_q[320+:61]},{{16{1'd0}}, mod_ram_12_q[320+:61]},{{16{1'd0}}, mod_ram_13_q[320+:61]},{{16{1'd0}}, mod_ram_14_q[320+:61]},{{16{1'd0}}, mod_ram_15_q[320+:61]},{{16{1'd0}}, mod_ram_16_q[320+:61]},{{16{1'd0}}, mod_ram_17_q[320+:61]},{{16{1'd0}}, mod_ram_18_q[320+:61]},{{16{1'd0}}, mod_ram_19_q[320+:61]},{{16{1'd0}}, mod_ram_20_q[320+:61]},{{16{1'd0}}, mod_ram_21_q[320+:61]},{{16{1'd0}}, mod_ram_22_q[320+:61]},{{16{1'd0}}, mod_ram_23_q[320+:61]},{{16{1'd0}}, mod_ram_24_q[320+:61]},{{16{1'd0}}, mod_ram_25_q[320+:61]},{{16{1'd0}}, mod_ram_26_q[320+:61]},{{16{1'd0}}, mod_ram_27_q[320+:61]},{{16{1'd0}}, mod_ram_28_q[320+:61]},{{16{1'd0}}, mod_ram_29_q[320+:61]},{{16{1'd0}}, mod_ram_30_q[320+:61]},{{16{1'd0}}, mod_ram_31_q[320+:61]},{{16{1'd0}}, mod_ram_32_q[320+:61]},{{16{1'd0}}, mod_ram_33_q[320+:61]},{{16{1'd0}}, mod_ram_34_q[320+:61]},{{16{1'd0}}, mod_ram_35_q[320+:61]},{{16{1'd0}}, mod_ram_36_q[320+:61]},{{16{1'd0}}, mod_ram_37_q[320+:61]},{{16{1'd0}}, mod_ram_38_q[320+:61]},{{16{1'd0}}, mod_ram_39_q[320+:61]},{{16{1'd0}}, mod_ram_40_q[320+:61]},{{16{1'd0}}, mod_ram_41_q[320+:61]},{{16{1'd0}}, mod_ram_42_q[320+:61]},{{15{1'd0}}, accum_grid_o_rr[5][60:0]}};
always_ff @ (posedge i_clk) if (o_mul.rdy) accum2_grid_o[5] <= accum2_o_c_5 + accum2_o_s_5;

logic [9:0]    mod_ram2_0_a;
logic [380:0]    mod_ram2_0_q;
always_comb begin
  mod_ram2_0_a = res0_r[381+:10];
end
always_ff @ (posedge i_clk) if (o_mul.rdy) begin
  mod_ram2_0_q <= mod_ram_0_ram[mod_ram2_0_a];
end

always_comb begin
  res1_c = res0_rr[380:0] + mod_ram2_0_q;
  res1_m_c = res0_rr[380:0] + mod_ram2_0_q - MODULUS;
  res1_m_c_ = res0_rr[380:0] + mod_ram2_0_q - 2*MODULUS;
end

localparam int RAM_PIPE = 4;
logic [RAM_PIPE:0][RAM_A_W-1:0] addr;
logic [RAM_PIPE:0][RAM_D_W-1:0] ram_d;
logic [RAM_PIPE:0]              ram_we;
logic [RAM_PIPE:0]              ram_se;

always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    addr <= 0;
    ram_we <= 0;
    ram_se <= 0;
    ram_d <= 0;
  end else begin
    ram_we <= {ram_we, i_ram_we};
    ram_d  <= {ram_d, i_ram_d};
    ram_se <= {ram_se, i_ram_se};
    for (int i = 1; i <= RAM_PIPE; i++)
      addr[i] <= addr[i-1];
    if (ram_we[RAM_PIPE]) begin
      addr[0] <= addr[0] + 1;
      mod_ram_0_ram[addr[RAM_PIPE]] <= mod_ram_0_d;
      mod_ram_1_ram[addr[RAM_PIPE]] <= mod_ram_1_d;
      mod_ram_2_ram[addr[RAM_PIPE]] <= mod_ram_2_d;
      mod_ram_3_ram[addr[RAM_PIPE]] <= mod_ram_3_d;
      mod_ram_4_ram[addr[RAM_PIPE]] <= mod_ram_4_d;
      mod_ram_5_ram[addr[RAM_PIPE]] <= mod_ram_5_d;
      mod_ram_6_ram[addr[RAM_PIPE]] <= mod_ram_6_d;
      mod_ram_7_ram[addr[RAM_PIPE]] <= mod_ram_7_d;
      mod_ram_8_ram[addr[RAM_PIPE]] <= mod_ram_8_d;
      mod_ram_9_ram[addr[RAM_PIPE]] <= mod_ram_9_d;
      mod_ram_10_ram[addr[RAM_PIPE]] <= mod_ram_10_d;
      mod_ram_11_ram[addr[RAM_PIPE]] <= mod_ram_11_d;
      mod_ram_12_ram[addr[RAM_PIPE]] <= mod_ram_12_d;
      mod_ram_13_ram[addr[RAM_PIPE]] <= mod_ram_13_d;
      mod_ram_14_ram[addr[RAM_PIPE]] <= mod_ram_14_d;
      mod_ram_15_ram[addr[RAM_PIPE]] <= mod_ram_15_d;
      mod_ram_16_ram[addr[RAM_PIPE]] <= mod_ram_16_d;
      mod_ram_17_ram[addr[RAM_PIPE]] <= mod_ram_17_d;
      mod_ram_18_ram[addr[RAM_PIPE]] <= mod_ram_18_d;
      mod_ram_19_ram[addr[RAM_PIPE]] <= mod_ram_19_d;
      mod_ram_20_ram[addr[RAM_PIPE]] <= mod_ram_20_d;
      mod_ram_21_ram[addr[RAM_PIPE]] <= mod_ram_21_d;
      mod_ram_22_ram[addr[RAM_PIPE]] <= mod_ram_22_d;
      mod_ram_23_ram[addr[RAM_PIPE]] <= mod_ram_23_d;
      mod_ram_24_ram[addr[RAM_PIPE]] <= mod_ram_24_d;
      mod_ram_25_ram[addr[RAM_PIPE]] <= mod_ram_25_d;
      mod_ram_26_ram[addr[RAM_PIPE]] <= mod_ram_26_d;
      mod_ram_27_ram[addr[RAM_PIPE]] <= mod_ram_27_d;
      mod_ram_28_ram[addr[RAM_PIPE]] <= mod_ram_28_d;
      mod_ram_29_ram[addr[RAM_PIPE]] <= mod_ram_29_d;
      mod_ram_30_ram[addr[RAM_PIPE]] <= mod_ram_30_d;
      mod_ram_31_ram[addr[RAM_PIPE]] <= mod_ram_31_d;
      mod_ram_32_ram[addr[RAM_PIPE]] <= mod_ram_32_d;
      mod_ram_33_ram[addr[RAM_PIPE]] <= mod_ram_33_d;
      mod_ram_34_ram[addr[RAM_PIPE]] <= mod_ram_34_d;
      mod_ram_35_ram[addr[RAM_PIPE]] <= mod_ram_35_d;
      mod_ram_36_ram[addr[RAM_PIPE]] <= mod_ram_36_d;
      mod_ram_37_ram[addr[RAM_PIPE]] <= mod_ram_37_d;
      mod_ram_38_ram[addr[RAM_PIPE]] <= mod_ram_38_d;
      mod_ram_39_ram[addr[RAM_PIPE]] <= mod_ram_39_d;
      mod_ram_40_ram[addr[RAM_PIPE]] <= mod_ram_40_d;
      mod_ram_41_ram[addr[RAM_PIPE]] <= mod_ram_41_d;
      mod_ram_42_ram[addr[RAM_PIPE]] <= mod_ram_42_d;
    end

    if (ram_se[RAM_PIPE]) begin
      mod_ram_0_d <= {mod_ram_0_d, ram_d[RAM_PIPE]};
      mod_ram_1_d <= {mod_ram_1_d, mod_ram_0_d[380:349]};
      mod_ram_2_d <= {mod_ram_2_d, mod_ram_1_d[380:349]};
      mod_ram_3_d <= {mod_ram_3_d, mod_ram_2_d[380:349]};
      mod_ram_4_d <= {mod_ram_4_d, mod_ram_3_d[380:349]};
      mod_ram_5_d <= {mod_ram_5_d, mod_ram_4_d[380:349]};
      mod_ram_6_d <= {mod_ram_6_d, mod_ram_5_d[380:349]};
      mod_ram_7_d <= {mod_ram_7_d, mod_ram_6_d[380:349]};
      mod_ram_8_d <= {mod_ram_8_d, mod_ram_7_d[380:349]};
      mod_ram_9_d <= {mod_ram_9_d, mod_ram_8_d[380:349]};
      mod_ram_10_d <= {mod_ram_10_d, mod_ram_9_d[380:349]};
      mod_ram_11_d <= {mod_ram_11_d, mod_ram_10_d[380:349]};
      mod_ram_12_d <= {mod_ram_12_d, mod_ram_11_d[380:349]};
      mod_ram_13_d <= {mod_ram_13_d, mod_ram_12_d[380:349]};
      mod_ram_14_d <= {mod_ram_14_d, mod_ram_13_d[380:349]};
      mod_ram_15_d <= {mod_ram_15_d, mod_ram_14_d[380:349]};
      mod_ram_16_d <= {mod_ram_16_d, mod_ram_15_d[380:349]};
      mod_ram_17_d <= {mod_ram_17_d, mod_ram_16_d[380:349]};
      mod_ram_18_d <= {mod_ram_18_d, mod_ram_17_d[380:349]};
      mod_ram_19_d <= {mod_ram_19_d, mod_ram_18_d[380:349]};
      mod_ram_20_d <= {mod_ram_20_d, mod_ram_19_d[380:349]};
      mod_ram_21_d <= {mod_ram_21_d, mod_ram_20_d[380:349]};
      mod_ram_22_d <= {mod_ram_22_d, mod_ram_21_d[380:349]};
      mod_ram_23_d <= {mod_ram_23_d, mod_ram_22_d[380:349]};
      mod_ram_24_d <= {mod_ram_24_d, mod_ram_23_d[380:349]};
      mod_ram_25_d <= {mod_ram_25_d, mod_ram_24_d[380:349]};
      mod_ram_26_d <= {mod_ram_26_d, mod_ram_25_d[380:349]};
      mod_ram_27_d <= {mod_ram_27_d, mod_ram_26_d[380:349]};
      mod_ram_28_d <= {mod_ram_28_d, mod_ram_27_d[380:349]};
      mod_ram_29_d <= {mod_ram_29_d, mod_ram_28_d[380:349]};
      mod_ram_30_d <= {mod_ram_30_d, mod_ram_29_d[380:349]};
      mod_ram_31_d <= {mod_ram_31_d, mod_ram_30_d[380:349]};
      mod_ram_32_d <= {mod_ram_32_d, mod_ram_31_d[380:349]};
      mod_ram_33_d <= {mod_ram_33_d, mod_ram_32_d[380:349]};
      mod_ram_34_d <= {mod_ram_34_d, mod_ram_33_d[380:349]};
      mod_ram_35_d <= {mod_ram_35_d, mod_ram_34_d[380:349]};
      mod_ram_36_d <= {mod_ram_36_d, mod_ram_35_d[380:349]};
      mod_ram_37_d <= {mod_ram_37_d, mod_ram_36_d[380:349]};
      mod_ram_38_d <= {mod_ram_38_d, mod_ram_37_d[380:349]};
      mod_ram_39_d <= {mod_ram_39_d, mod_ram_38_d[380:349]};
      mod_ram_40_d <= {mod_ram_40_d, mod_ram_39_d[380:349]};
      mod_ram_41_d <= {mod_ram_41_d, mod_ram_40_d[380:349]};
      mod_ram_42_d <= {mod_ram_42_d, mod_ram_41_d[380:349]};
    end
  end
end
//`include "accum_mult_mod_generated.inc"

logic [PIPE-1:0] val, sop, eop;
logic [PIPE-1:0][CTL_BITS-1:0] ctl;

genvar gx, gy;

// Flow control
always_comb begin
  i_mul.rdy = o_mul.rdy;
  o_mul.val = val[PIPE-1];
  o_mul.sop = sop[PIPE-1];
  o_mul.eop = eop[PIPE-1];
  o_mul.ctl = ctl[PIPE-1];
  o_mul.err = 0;
  o_mul.mod = 0;
end

always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    val <= 0;
    sop <= 0;
    eop <= 0;
    ctl <= 0;
  end else begin
    if (o_mul.rdy) begin
      val <= {val, i_mul.val};
      sop <= {sop, i_mul.sop};
      eop <= {eop, i_mul.eop};
      ctl <= {ctl, i_mul.ctl};
    end
  end
end

// Logic for handling multiple pipelines
always_ff @ (posedge i_clk) begin
  if (o_mul.rdy) begin
    for (int i = 0; i < NUM_COL; i++)
      dat_a <= 0;
      dat_b <= 0;
      dat_a <= i_mul.dat[0+:DAT_BITS];
      dat_b <= i_mul.dat[DAT_BITS+:DAT_BITS];
  end
end


always_ff @ (posedge i_clk) begin
  for (int i = 0; i < NUM_COL; i++)
    for (int j = 0; j < NUM_ROW; j++) begin
      if (o_mul.rdy)
        mul_grid[i][j] <= dat_a[i*A_DSP_W +: A_DSP_W] * dat_b[j*B_DSP_W +: B_DSP_W];
    end
end

// Register lower half accumulator output while we lookup BRAM
always_ff @ (posedge i_clk)
  for (int i = 0; i < MAX_COEF/2; i++) begin
    if (o_mul.rdy) begin
      accum_grid_o_r[i] <= accum_grid_o[i];
      accum_grid_o_rr[i] <= accum_grid_o_r[i];
    end
  end

// Two paths to make sure we are < MODULUS
always_comb begin
  res0_c = 0;
  for (int i = 0; i < MAX_COEF/2; i++)
      res0_c += accum2_grid_o[i] << (i*GRID_BIT);
end

// We do a second level reduction to get back within MODULUS bits

always_ff @ (posedge i_clk) begin
  if (o_mul.rdy) begin
    res0_r <= res0_c;
    res0_rr <= res0_r;
    // Do final adjustment
    o_mul.dat <= res1_m_c_ < res1_c ? res1_m_c_ : res1_c < res1_m_c ? res1_c : res1_m_c;
  end
end

endmodule