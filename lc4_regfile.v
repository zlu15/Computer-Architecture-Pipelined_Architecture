/* TODO: Names of all group members
 * TODO: PennKeys of all group members
 *
 * lc4_regfile.v
 * Implements an 8-register register file parameterized on word size.
 *
 */

`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

module lc4_regfile #(parameter n = 16)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,
    input  wire [  2:0] i_rs,      // rs selector
    output wire [n-1:0] o_rs_data, // rs contents
    input  wire [  2:0] i_rt,      // rt selector
    output wire [n-1:0] o_rt_data, // rt contents
    input  wire [  2:0] i_rd,      // rd selector
    input  wire [n-1:0] i_wdata,   // data to write
    input  wire         i_rd_we    // write enable
    );

   /***********************
    * TODO YOUR CODE HERE *
    ***********************/
    wire r0_we, r1_we, r2_we, r3_we, r4_we, r5_we, r6_we, r7_we;
    assign r0_we = i_rd_we;assign r1_we = i_rd_we;assign r2_we = i_rd_we;assign r3_we = i_rd_we;
    assign r4_we = i_rd_we;assign r5_we = i_rd_we;assign r6_we = i_rd_we;assign r7_we = i_rd_we;
    
    wire [15:0] r0_in,r0_out;
    Nbit_reg #(16,0) r0(.in(r0_in), .out(r0_out), .clk(clk), .we(r0_we), .gwe(gwe), .rst(rst));
    
    wire [15:0] r1_in,r1_out;
    Nbit_reg #(16,0) r1(.in(r1_in), .out(r1_out), .clk(clk), .we(r1_we), .gwe(gwe), .rst(rst));
    
    wire [15:0] r2_in,r2_out;
    Nbit_reg #(16,0) r2(.in(r2_in), .out(r2_out), .clk(clk), .we(r2_we), .gwe(gwe), .rst(rst));
    
    wire [15:0] r3_in,r3_out;
    Nbit_reg #(16,0) r3(.in(r3_in), .out(r3_out), .clk(clk), .we(r3_we), .gwe(gwe), .rst(rst));
    
    wire [15:0] r4_in,r4_out;
    Nbit_reg #(16,0) r4(.in(r4_in), .out(r4_out), .clk(clk), .we(r4_we), .gwe(gwe), .rst(rst));
    
    wire [15:0] r5_in,r5_out;
    Nbit_reg #(16,0) r5(.in(r5_in), .out(r5_out), .clk(clk), .we(r5_we), .gwe(gwe), .rst(rst));
    
    wire [15:0] r6_in,r6_out;
    Nbit_reg #(16,0) r6(.in(r6_in), .out(r6_out), .clk(clk), .we(r6_we), .gwe(gwe), .rst(rst));
    
    wire [15:0] r7_in,r7_out;
    Nbit_reg #(16,0) r7(.in(r7_in), .out(r7_out), .clk(clk), .we(r7_we), .gwe(gwe), .rst(rst));

    assign o_rs_data = ((i_rs == 3'b000) ) ? r0_out:
                       ((i_rs == 3'b001) ) ? r1_out:
                       ((i_rs == 3'b010) ) ? r2_out:
                       ((i_rs == 3'b011) ) ? r3_out:
                       ((i_rs == 3'b100) ) ? r4_out:
                       ((i_rs == 3'b101) ) ? r5_out:
                       ((i_rs == 3'b110) ) ? r6_out:
                       ((i_rs == 3'b111) ) ? r7_out:16'b0;

    assign o_rt_data = ((i_rt == 3'b000) ) ? r0_out:
                       ((i_rt == 3'b001) ) ? r1_out:
                       ((i_rt == 3'b010) ) ? r2_out:
                       ((i_rt == 3'b011) ) ? r3_out:
                       ((i_rt == 3'b100) ) ? r4_out:
                       ((i_rt == 3'b101) ) ? r5_out:
                       ((i_rt == 3'b110) ) ? r6_out:
                       ((i_rt == 3'b111) ) ? r7_out:16'b0;

                      
    assign r0_in  =   ((i_rd == 3'b000) & (r0_we == 1'b1)) ? i_wdata:r0_out;
    assign r1_in  =   ((i_rd == 3'b001) & (r1_we == 1'b1)) ? i_wdata:r1_out;
    assign r2_in  =   ((i_rd == 3'b010) & (r2_we == 1'b1)) ? i_wdata:r2_out;
    assign r3_in  =   ((i_rd == 3'b011) & (r3_we == 1'b1)) ? i_wdata:r3_out;
    assign r4_in  =   ((i_rd == 3'b100) & (r4_we == 1'b1)) ? i_wdata:r4_out;
    assign r5_in  =   ((i_rd == 3'b101) & (r5_we == 1'b1)) ? i_wdata:r5_out;
    assign r6_in  =   ((i_rd == 3'b110) & (r6_we == 1'b1)) ? i_wdata:r6_out;
    assign r7_in  =   ((i_rd == 3'b111) & (r7_we == 1'b1)) ? i_wdata:r7_out;
        
endmodule