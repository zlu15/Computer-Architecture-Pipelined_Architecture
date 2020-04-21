/* INSERT NAME AND PENNKEY HERE 

Zhongyuan Lu
zlu15*/

`timescale 1ns / 1ps

`default_nettype none

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);
//CLA module
      wire [3:0] op_code = i_insn[15:12];
      wire [2:0] br_code = i_insn[11:9]; 
      wire [2:0] cla_carryin_sel = i_insn[5:3];
      wire [15:0] sext_imm5 = {{11{i_insn[4]}},i_insn[4:0]};
      wire [15:0] sext_imm6 = {{10{i_insn[5]}},i_insn[5:0]};
      wire [15:0] sext_imm7 = {{9{i_insn[6]}},i_insn[6:0]};
      wire [15:0] sext_imm9 = {{7{i_insn[8]}},i_insn[8:0]};
      wire [15:0] sext_imm11 = {{5{i_insn[10]}},i_insn[10:0]};
      wire [15:0] cla_result;
      wire [15:0] cla_input1, cla_input2;
      wire cin;
      //pc is i_pc, Rs is i_r1data, Rt is i_r2data
      //determine input 1: it should either be i_pc or i_r1data
      assign cla_input1 = (op_code == 4'b0000) ? i_pc:
                          (op_code == 4'b1100) ? i_pc:
                          (op_code == 4'b0111) ? i_r1data:
                          (op_code == 4'b0110) ? i_r1data:
                          (op_code == 4'b0001) ? i_r1data : 16'b0;
      //determine input2: there will be a lot of conditons in it
           // follwoing are some pre-selects for input2
          //determine if it is NOP or other branch
          wire [15:0] nop_source;
          assign nop_source = (br_code == 3'b000) ? sext_imm9: sext_imm9;
          //determine if it is add or addi or subtraction
          wire [15:0] add_addi_sub_source;
          assign add_addi_sub_source = (cla_carryin_sel == 3'b000) ? i_r2data: 
                                       (cla_carryin_sel == 3'b010) ? (~i_r2data):
                                       (cla_carryin_sel == 3'b100) ? sext_imm5:
                                       (cla_carryin_sel == 3'b101) ? sext_imm5:
                                       (cla_carryin_sel == 3'b110) ? sext_imm5:
                                       (cla_carryin_sel == 3'b111) ? sext_imm5: 16'b0;                 
     assign cla_input2 = (op_code == 4'b0000) ? nop_source:
                         (op_code == 4'b0001) ? add_addi_sub_source:
                         (op_code == 4'b0110) ? sext_imm6:
                         (op_code == 4'b0111) ? sext_imm6:
                         (op_code == 4'b1100) ? sext_imm11: 16'b0;
     //determine carry-in bit for different operations
       //following is pre-select for carry-in for add, addi, subtraction
       wire add_addi_sub_carryin;
                 assign add_addi_sub_carryin = (cla_carryin_sel == 3'b000) ? 1'b0: 
                                              (cla_carryin_sel == 3'b010) ? 1'b1:
                                              (cla_carryin_sel == 3'b100) ? 1'b0:
                                              (cla_carryin_sel == 3'b101) ? 1'b0:
                                              (cla_carryin_sel == 3'b110) ? 1'b0:
                                              (cla_carryin_sel == 3'b111) ? 1'b0: 1'b0;  
         
      
     assign cin = (op_code == 4'b0000) ? 1'b1:
                  (op_code == 4'b1100) ? 1'b1:
                  (op_code == 4'b0111) ? 1'b0:
                  (op_code == 4'b0110) ? 1'b0:
                  (op_code == 4'b0001) ? add_addi_sub_carryin : 16'b0;
     //calculate the result for cla part
     cla16 cla_module_0(.a(cla_input1), .b(cla_input2), .cin(cin), .sum(cla_result));
      
    //division_moudle
    wire [15:0] module0_remainder, module0_quotient;
    lc4_divider divier_module0(.i_dividend(i_r1data), .i_divisor(i_r2data), .o_remainder(module0_remainder), .o_quotient(module0_quotient));
    //multiplication moduel
    wire [15:0] mul_result;
    assign mul_result = i_r1data * i_r2data;
     
     //comparator module
    wire [15:0] cmp_result, cmpu_result, cmpi_result, cmpiu_result, comparator_result;
    wire signed [15:0] signed_i_r1data, signed_i_r2data, signed_imm7;
    wire [15:0] uimm7;
    assign signed_i_r1data = i_r1data;
    assign signed_i_r2data = i_r2data;
    assign signed_imm7 = {{9{i_insn[6]}},{i_insn[6:0]}};
    assign uimm7 = {{9{1'b0}},i_insn[6:0]};

    assign cmp_result = (signed_i_r1data > signed_i_r2data) ? 16'b1:
                        (signed_i_r1data == signed_i_r2data) ? 16'b0:
                        (signed_i_r1data < signed_i_r2data) ? (~(16'b0)):16'b0;

    assign cmpu_result = (i_r1data > i_r2data) ? 16'b1:
                         (i_r1data == i_r2data) ? 16'b0:
                         (i_r1data < i_r2data) ? (~(16'b0)):16'b0;

    assign cmpi_result = (signed_i_r1data > signed_imm7) ? 16'b1:
                         (signed_i_r1data == signed_imm7) ? 16'b0:
                         (signed_i_r1data < signed_imm7) ? (~(16'b0)):16'b0;

    assign cmpiu_result = (i_r1data > uimm7) ? 16'b1:
                          (i_r1data == uimm7) ? 16'b0:
                          (i_r1data < uimm7) ? (~(16'b0)):16'b0;

    assign comparator_result = (i_insn[8:7] == 2'b00) ? cmp_result:
                               (i_insn[8:7] == 2'b01) ? cmpu_result:
                               (i_insn[8:7] == 2'b10) ? cmpi_result:
                               (i_insn[8:7] == 2'b11) ? cmpiu_result:16'b0;
     
     
     
     //&,|, ^, ~ moduel
        //determine if it is and or andi 
        wire [15:0] and_source, and_result, or_result, xor_result, not_result, logic_result;
        assign and_source = (i_insn[5] == 1'b0) ? i_r2data:
                            (i_insn[5] == 1'b1) ? sext_imm5: 1'b0;
      // & module                      
      assign and_result = i_r1data & and_source ;
      // ~ module
      assign not_result = ~ i_r1data;
      // | module
      assign or_result = i_r1data | i_r2data;
      // ^ module
      assign xor_result = i_r1data ^ i_r2data;
      
      assign logic_result = (cla_carryin_sel == 3'b000) ? and_result: 
                            (cla_carryin_sel == 3'b001) ? not_result:
                            (cla_carryin_sel == 3'b010) ? or_result:
                            (cla_carryin_sel == 3'b011) ? xor_result:
                            (cla_carryin_sel == 3'b100) ? and_result:
                            (cla_carryin_sel == 3'b101) ? and_result:
                            (cla_carryin_sel == 3'b110) ? and_result:and_result;

    //JSR <label> module
    wire [15:0] jsr_result;
    assign jsr_result = (i_pc & 16'b1000000000000000) | ({{5{1'b0}},{i_insn[10:0]}} << 4); 
    
    //shift modules
    wire [1:0] shift_sel = i_insn[5:4];
    wire [15:0] shift_result;
    wire [4:0] uimm4 = {{1'b0},{i_insn[3:0]}};
    wire [15:0] sll_result, srl_result, mod_result; 
    wire signed [15:0] sra_result, signed_uimm4;
    assign signed_uimm4 = {{11'b0},{i_insn[3:0]}};
    assign sll_result = i_r1data << uimm4; 
    assign sra_result = signed_i_r1data >>> signed_uimm4;
    assign srl_result = i_r1data >> uimm4;
    
    wire [15:0] module1_remainder, module1_quotient;
    lc4_divider divier_module1(.i_dividend(i_r1data), .i_divisor(i_r2data), .o_remainder(module1_remainder), .o_quotient(module1_quotient));
    assign mod_result = module1_remainder; 
    
    assign shift_result = (shift_sel == 2'b00) ? sll_result:
                          (shift_sel == 2'b01) ? sra_result:
                          (shift_sel == 2'b10) ? srl_result:mod_result;
    
    //HICONST module
    wire [15:0] hiconst_result, const_ff;
    assign const_ff = {{8{1'b0}},{8'b11111111}};
    wire [15:0] uimm8 = {{8{1'b0}},i_insn[7:0]};
    assign hiconst_result = ((i_r1data & 8'b11111111)) | (uimm8 << 8);
                          
    // TRAP module
    wire [15:0] trap_result;
    assign trap_result = (16'b1000000000000000 | uimm8);                       
               
        //integration all results from different modules
      //select if the cla unit is doing add, mul, sub, div or addi
      wire [15:0] cla_temp;
      assign cla_temp = (cla_carryin_sel == 3'b000) ? cla_result:
                        (cla_carryin_sel == 3'b010) ? cla_result:
                        (cla_carryin_sel == 3'b100) ? cla_result:
                        (cla_carryin_sel == 3'b101) ? cla_result:
                        (cla_carryin_sel == 3'b110) ? cla_result:
                        (cla_carryin_sel == 3'b111) ? cla_result:
                        (cla_carryin_sel == 3'b011) ? module0_quotient:
                        (cla_carryin_sel == 3'b001) ? mul_result: 16'b0;

      //select for JSRR or JSR
      wire [15:0] jsr_temp;
      assign jsr_temp = (i_insn[11] == 1'b0) ? i_r1data:
                        (i_insn[11] == 1'b1) ? jsr_result: 16'b0;

     //select for jmpr or jmp
     wire [15:0] jmpr_temp;
     assign jmpr_temp = (i_insn[11] == 1'b0) ? i_r1data:
                       (i_insn[11] == 1'b1) ? cla_result: 16'b0;


    assign o_result = (op_code == 4'b0000) ? cla_result:
                      (op_code == 4'b0110) ? cla_result:
                      (op_code == 4'b0111) ? cla_result:
                      (op_code == 4'b0001) ? cla_temp:
                      (op_code == 4'b0010) ? comparator_result:
                      (op_code == 4'b0100) ? jsr_temp:
                      (op_code == 4'b0101) ? logic_result:
                      (op_code == 4'b1000) ? i_r1data:
                      (op_code == 4'b1001) ? sext_imm9:
                      (op_code == 4'b1010) ? shift_result:
                      (op_code == 4'b1100) ? jmpr_temp:
                      (op_code == 4'b1101) ? hiconst_result:
                      (op_code == 4'b1111) ? trap_result: 16'b0;  

endmodule
