/* TODO: INSERT NAME AND PENNKEY HERE 
zlu15
Zhongyuan Lu*/
`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

      /*** YOUR CODE HERE ***/
     wire [15:0] o_dividend_temp_0, o_remainder_temp_0, o_quotient_temp_0, temp_0;
     
    assign temp_0 = 16'b0;
    lc4_divider_one_iter iter0(.i_dividend(i_dividend), .i_divisor(i_divisor), .i_remainder(temp_0), .i_quotient(temp_0), 
                               .o_dividend(o_dividend_temp_0), .o_remainder(o_remainder_temp_0), .o_quotient(o_quotient_temp_0));
                          
    wire [15:0] o_dividend_temp_1, o_remainder_temp_1, o_quotient_temp_1;
    lc4_divider_one_iter iter1(.i_dividend(o_dividend_temp_0), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_0), .i_quotient(o_quotient_temp_0), 
                               .o_dividend(o_dividend_temp_1), .o_remainder(o_remainder_temp_1), .o_quotient(o_quotient_temp_1));
    
    wire [15:0] o_dividend_temp_2, o_remainder_temp_2, o_quotient_temp_2;
    lc4_divider_one_iter iter2(.i_dividend(o_dividend_temp_1), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_1), .i_quotient(o_quotient_temp_1), 
                               .o_dividend(o_dividend_temp_2), .o_remainder(o_remainder_temp_2), .o_quotient(o_quotient_temp_2));
                               
    wire [15:0] o_dividend_temp_3, o_remainder_temp_3, o_quotient_temp_3;
    lc4_divider_one_iter iter3(.i_dividend(o_dividend_temp_2), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_2), .i_quotient(o_quotient_temp_2), 
                               .o_dividend(o_dividend_temp_3), .o_remainder(o_remainder_temp_3), .o_quotient(o_quotient_temp_3));
                           
    wire [15:0] o_dividend_temp_4, o_remainder_temp_4, o_quotient_temp_4;
    lc4_divider_one_iter iter4(.i_dividend(o_dividend_temp_3), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_3), .i_quotient(o_quotient_temp_3), 
                               .o_dividend(o_dividend_temp_4), .o_remainder(o_remainder_temp_4), .o_quotient(o_quotient_temp_4)); 

    wire [15:0] o_dividend_temp_5, o_remainder_temp_5, o_quotient_temp_5;
    lc4_divider_one_iter iter5(.i_dividend(o_dividend_temp_4), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_4), .i_quotient(o_quotient_temp_4), 
                               .o_dividend(o_dividend_temp_5), .o_remainder(o_remainder_temp_5), .o_quotient(o_quotient_temp_5));
    
    wire [15:0] o_dividend_temp_6, o_remainder_temp_6, o_quotient_temp_6;
    lc4_divider_one_iter iter6(.i_dividend(o_dividend_temp_5), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_5), .i_quotient(o_quotient_temp_5), 
                               .o_dividend(o_dividend_temp_6), .o_remainder(o_remainder_temp_6), .o_quotient(o_quotient_temp_6));
                               
   wire [15:0] o_dividend_temp_7, o_remainder_temp_7, o_quotient_temp_7;
    lc4_divider_one_iter iter7(.i_dividend(o_dividend_temp_6), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_6), .i_quotient(o_quotient_temp_6), 
                               .o_dividend(o_dividend_temp_7), .o_remainder(o_remainder_temp_7), .o_quotient(o_quotient_temp_7));
                           
    wire [15:0] o_dividend_temp_8, o_remainder_temp_8, o_quotient_temp_8;
    lc4_divider_one_iter iter8(.i_dividend(o_dividend_temp_7), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_7), .i_quotient(o_quotient_temp_7), 
                               .o_dividend(o_dividend_temp_8), .o_remainder(o_remainder_temp_8), .o_quotient(o_quotient_temp_8));
                             
                              
     wire [15:0] o_dividend_temp_9, o_remainder_temp_9, o_quotient_temp_9;
     lc4_divider_one_iter iter9(.i_dividend(o_dividend_temp_8), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_8), .i_quotient(o_quotient_temp_8), 
                                .o_dividend(o_dividend_temp_9), .o_remainder(o_remainder_temp_9), .o_quotient(o_quotient_temp_9));
     
     wire [15:0] o_dividend_temp_10, o_remainder_temp_10, o_quotient_temp_10;
     lc4_divider_one_iter iter10(.i_dividend(o_dividend_temp_9), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_9), .i_quotient(o_quotient_temp_9), 
                                .o_dividend(o_dividend_temp_10), .o_remainder(o_remainder_temp_10), .o_quotient(o_quotient_temp_10));
                                
     wire [15:0] o_dividend_temp_11, o_remainder_temp_11, o_quotient_temp_11;
     lc4_divider_one_iter iter11(.i_dividend(o_dividend_temp_10), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_10), .i_quotient(o_quotient_temp_10), 
                                .o_dividend(o_dividend_temp_11), .o_remainder(o_remainder_temp_11), .o_quotient(o_quotient_temp_11));
                            
     wire [15:0] o_dividend_temp_12, o_remainder_temp_12, o_quotient_temp_12;
     lc4_divider_one_iter iter12(.i_dividend(o_dividend_temp_11), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_11), .i_quotient(o_quotient_temp_11), 
                                .o_dividend(o_dividend_temp_12), .o_remainder(o_remainder_temp_12), .o_quotient(o_quotient_temp_12)); 
    
     wire [15:0] o_dividend_temp_13, o_remainder_temp_13, o_quotient_temp_13;
     lc4_divider_one_iter iter13(.i_dividend(o_dividend_temp_12), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_12), .i_quotient(o_quotient_temp_12), 
                                .o_dividend(o_dividend_temp_13), .o_remainder(o_remainder_temp_13), .o_quotient(o_quotient_temp_13));
     
     wire [15:0] o_dividend_temp_14, o_remainder_temp_14, o_quotient_temp_14;
     lc4_divider_one_iter iter14(.i_dividend(o_dividend_temp_13), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_13), .i_quotient(o_quotient_temp_13), 
                                .o_dividend(o_dividend_temp_14), .o_remainder(o_remainder_temp_14), .o_quotient(o_quotient_temp_14));
                                
     wire [15:0] o_dividend_temp_15, o_remainder_temp_15, o_quotient_temp_15;
     lc4_divider_one_iter iter15(.i_dividend(o_dividend_temp_14), .i_divisor(i_divisor), .i_remainder(o_remainder_temp_14), .i_quotient(o_quotient_temp_14), 
                                .o_dividend(o_dividend_temp_15), .o_remainder(o_remainder_temp_15), .o_quotient(o_quotient_temp_15));
   
     assign o_remainder = o_remainder_temp_15;
     assign o_quotient = o_quotient_temp_15;
                                                                             
endmodule // lc4_divider


module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire [15:0] o_remainder,
                            output wire [15:0] o_quotient);
      /*** YOUR CODE HERE ***/
      wire [15:0] tmp_remainder;      
      assign tmp_remainder = (i_remainder << 1)|(i_dividend >> 15)&16'b1;
      assign o_quotient = (i_divisor == 16'b0) ? 16'b0:((tmp_remainder < i_divisor)?(i_quotient<<1):((i_quotient<<1)|16'b1));
      assign o_remainder = (i_divisor == 16'b0) ? 16'b0 : ((tmp_remainder < i_divisor)?tmp_remainder:(tmp_remainder-i_divisor));
      assign o_dividend = i_dividend << 1;
      
   
endmodule
