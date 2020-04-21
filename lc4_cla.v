/* TODO: INSERT NAME AND PENNKEY HERE 
zhongyuan Lu
zlu15*/

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);
           
    wire p_1_0, g_1_0,p_3_2, g_3_2;
    assign p_1_0 = pin[0] & pin[1]; 
    assign g_1_0 = gin[1] | (pin[1] & gin[0]);
    assign cout[0] = gin[0] | (pin[0] & cin); 
    assign p_3_2 = pin[3] & pin[2];
    assign g_3_2 = gin[3] | (pin[3] & gin[2]);   

    
    wire p_3_0, g_3_0;
    assign p_3_0 = p_3_2 & p_1_0;
    assign g_3_0 = g_3_2 | (p_3_2 & g_1_0);
    assign cout[1] = g_1_0 | (p_1_0 & cin);
    
    assign cout[2] = gin[2] | (pin[2] & cout[1]);
    assign gout = g_3_0;
    assign pout = p_3_0;
       
endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);
   
   wire g[15:0], p[15:0];
   genvar i;
   generate
       for (i=0; i<16; i=i+1) begin: gen_loop
            gp1 model(.a(a[i]), .b(b[i]), .g(g[i]), .p(p[i]));
       end 
   endgenerate
   

   
   wire [3:0] gin_3_0, pin_3_0, gin_7_4, pin_7_4, gin_11_8, pin_11_8, gin_15_12, pin_15_12;
   
   assign gin_3_0 = {g[3], g[2], g[1], g[0]};
   assign pin_3_0 = {p[3], p[2], p[1], p[0]};
   assign gin_7_4 = {g[7], g[6], g[5], g[4]};
   assign pin_7_4 = {p[7], p[6], p[5], p[4]};
   assign gin_11_8 = {g[11], g[10], g[9], g[8]};
   assign pin_11_8 = {p[11], p[10], p[9], p[8]};
   assign gin_15_12 = {g[15], g[14], g[13], g[12]};
   assign pin_15_12 = {p[15], p[14], p[13], p[12]};
   
   wire G[3:0],P[3:0];
   wire [2:0] Cout[3:0];
   wire c4, c8, c12, c16;
   gp4 module1(.gin(gin_3_0), .pin(pin_3_0), .cin(cin), .gout(G[0]), .pout(P[0]), .cout(Cout[0]));
   assign c4 = G[0] | (P[0] & cin) ;
   gp4 module2(.gin(gin_7_4), .pin(pin_7_4), .cin(c4), .gout(G[1]), .pout(P[1]), .cout(Cout[1]));
   assign c8 = G[1] | (P[1] & c4) ;
   gp4 module3(.gin(gin_11_8), .pin(pin_11_8), .cin(c8), .gout(G[2]), .pout(P[2]), .cout(Cout[2]));
   assign c12 = G[2] | (P[2] & c8) ;
   gp4 module4(.gin(gin_15_12), .pin(pin_15_12), .cin(c12), .gout(G[3]), .pout(P[3]), .cout(Cout[3]));
   assign c16 = G[3] | (P[3] & c12) ;

   assign sum[0] = a[0] ^ b[0] ^ cin;
   assign sum[1] = a[1] ^ b[1] ^ Cout[0][0];
   assign sum[2] = a[2] ^ b[2] ^ Cout[0][1];
   assign sum[3] = a[3] ^ b[3] ^ Cout[0][2];
   
   assign sum[4] = a[4] ^ b[4] ^ c4;
   assign sum[5] = a[5] ^ b[5] ^ Cout[1][0];
   assign sum[6] = a[6] ^ b[6] ^ Cout[1][1];
   assign sum[7] = a[7] ^ b[7] ^ Cout[1][2];
   
   assign sum[8] = a[8] ^ b[8] ^ c8;
   assign sum[9] = a[9] ^ b[9] ^ Cout[2][0];
   assign sum[10] = a[10] ^ b[10] ^ Cout[2][1];
   assign sum[11] = a[11] ^ b[11] ^ Cout[2][2];
   
   assign sum[12] = a[12] ^ b[12] ^ c12;
   assign sum[13] = a[13] ^ b[13] ^ Cout[3][0];
   assign sum[14] = a[14] ^ b[14] ^ Cout[3][1];
   assign sum[15] = a[15] ^ b[15] ^ Cout[3][2];
   
   
   

   

endmodule
