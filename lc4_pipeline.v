/* TODO: name and PennKeys of all group members here */

`timescale 1ns / 1ps

// disable implicit wire declaration
`default_nettype none

module lc4_processor
   (input  wire        clk,  // main clock
    input wire         rst, // global reset
    input wire         gwe, // global we for single-step clock
                                    
    output wire [15:0] o_cur_pc, // Address to read from instruction memory
    input wire [15:0]  i_cur_insn, // Output of instruction memory
    output wire [15:0] o_dmem_addr, // Address to read/write from/to data memory
    input wire [15:0]  i_cur_dmem_data, // Output of data memory
    output wire        o_dmem_we, // Data memory write enable
    output wire [15:0] o_dmem_towrite, // Value to write to data memory
   
    output wire [1:0]  test_stall, // Testbench: is this is stall cycle? (don't compare the test values)
    output wire [15:0] test_cur_pc, // Testbench: program counter
    output wire [15:0] test_cur_insn, // Testbench: instruction bits
    output wire        test_regfile_we, // Testbench: register file write enable
    output wire [2:0]  test_regfile_wsel, // Testbench: which register to write in the register file 
    output wire [15:0] test_regfile_data, // Testbench: value to write into the register file
    output wire        test_nzp_we, // Testbench: NZP condition codes write enable
    output wire [2:0]  test_nzp_new_bits, // Testbench: value to write to NZP bits
    output wire        test_dmem_we, // Testbench: data memory write enable
    output wire [15:0] test_dmem_addr, // Testbench: address to read/write memory
    output wire [15:0] test_dmem_data, // Testbench: value read/writen from/to memory

    input wire [7:0]   switch_data, // Current settings of the Zedboard switches
    output wire [7:0]  led_data // Which Zedboard LEDs should be turned on?
    );
   
   // By default, assign LEDs to display switch inputs to avoid warnings about
      // disconnected ports. Feel free to use this for debugging input/output if
      // you desire.
      assign led_data = switch_data;
   
      
      /* DO NOT MODIFY THIS CODE */

      // pc wires attached to the PC register's ports
      wire [15:0]   pc;      // Current program counter (read out from pc_reg)
      wire [15:0]   next_pc; // Next program counter (you compute this and feed it into next_pc)
   
      // Program counter register, starts at 8200h at bootup
      Nbit_reg #(16, 16'h8200) pc_reg (.in(next_pc), .out(pc), .clk(clk), .we(pc_enable), .gwe(gwe), .rst(rst));
   
      /* END DO NOT MODIFY THIS CODE */
      /*******************************
       * TODO: INSERT YOUR CODE HERE *
       *******************************/
       //assign o_cur_pc = pc;
       //decoder for the pipeline datapath
       wire [2:0] r1sel, r2sel, wsel;
       wire r1re, r2re, regfile_we, nzp_we, select_pc_plus_one, is_load, is_store, is_branch, is_control_insn;
       lc4_decoder decoder_0(.insn(i_cur_insn),                         // instruction
                            .r1sel(r1sel),                             // rs
                            .r1re(r1re),                               // does this instruction read from rs?
                            .r2sel(r2sel),                             // rt
                            .r2re(r2re),                               // does this instruction read from rt?
                            .wsel(wsel),                               // rd
                            .regfile_we(regfile_we),                   // does this instruction write to rd?
                            .nzp_we(nzp_we),                           // does this instruction write the NZP bits?
                            .select_pc_plus_one(select_pc_plus_one),   // write PC+1 to the regfile?
                            .is_load(is_load),                         // is this a load instruction?
                            .is_store(is_store),                       // is this a store instruction?
                            .is_branch(is_branch),                     // is this a branch instruction?
                            .is_control_insn(is_control_insn)          // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?
                            );
        //pc+1 for the singlecycle datapath                  
                    wire [15:0] pc_plus_one;                      
                    cla16 cla16_pc (.a(pc), 
                                    .b(16'b1),
                                    .cin(1'b0),
                                    .sum(pc_plus_one));                    
        //d stage registers after decoder (decoder_r1sel_reg, decoder_r2sel_reg, decoder_wsel_reg. decoder_data_hazard_reg, decoder_ins_reg, decoder_pc_reg
        wire [2:0] decoder_r1sel_reg_in, decoder_r1sel_reg_out; 
        Nbit_reg #(3, 0) decoder_r1sel_reg (.in(decoder_r1sel_reg_in), .out(decoder_r1sel_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));
        
        wire [2:0] decoder_r1re_reg_in, decoder_r1re_reg_out; 
        Nbit_reg #(3, 0) decoder_r1re_reg (.in(decoder_r1re_reg_in), .out(decoder_r1re_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));
           
        wire [2:0] decoder_r2sel_reg_in, decoder_r2sel_reg_out; 
        Nbit_reg #(3, 0) decoder_r2sel_reg (.in(decoder_r2sel_reg_in), .out(decoder_r2sel_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst)); 
        
        wire [2:0] decoder_r2re_reg_in, decoder_r2re_reg_out; 
        Nbit_reg #(3, 0) decoder_r2re_reg (.in(decoder_r2re_reg_in), .out(decoder_r2re_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));
                
        wire [2:0] decoder_wsel_reg_in, decoder_wsel_reg_out; 
        Nbit_reg #(3, 0) decoder_wsel_reg (.in(decoder_wsel_reg_in), .out(decoder_wsel_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));
                          
        wire [15:0] decoder_ins_reg_in, decoder_ins_reg_out; 
        Nbit_reg #(16, 0) decoder_ins_reg (.in(decoder_ins_reg_in), .out(decoder_ins_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));                                          
                                                  
        wire [15:0] decoder_pc_reg_in, decoder_pc_reg_out; 
        Nbit_reg #(16, 0) decoder_pc_reg (.in(decoder_pc_reg_in), .out(decoder_pc_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst)); 
        
        wire [15:0] decoder_pc_plus_one_reg_in, decoder_pc_plus_one_reg_out; 
        Nbit_reg #(16, 0) decoder_pc_plus_one_reg (.in(decoder_pc_plus_one_reg_in), .out(decoder_pc_plus_one_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst)); 

        wire decoder_regfile_we_reg_in, decoder_regfile_we_reg_out; 
        Nbit_reg #(1, 0) decoder_regfile_we_reg (.in(decoder_regfile_we_reg_in), .out(decoder_regfile_we_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));  
        
        wire decoder_nzp_we_reg_in, decoder_nzp_we_reg_out; 
        Nbit_reg #(1, 0) decoder_nzp_we_reg (.in(decoder_nzp_we_reg_in), .out(decoder_nzp_we_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));  
        
        wire decoder_select_pc_plus_one_reg_in, decoder_select_pc_plus_one_reg_out; 
        Nbit_reg #(1, 0) decoder_select_pc_plus_one_reg (.in(decoder_select_pc_plus_one_reg_in), .out(decoder_select_pc_plus_one_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));  
        
        wire decoder_is_load_reg_in, decoder_is_load_reg_out; 
        Nbit_reg #(1, 0) decoder_is_load_reg (.in(decoder_is_load_reg_in), .out(decoder_is_load_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));  
        
        wire decoder_is_store_reg_in, decoder_is_store_reg_out; 
        Nbit_reg #(1, 0) decoder_is_store_reg (.in(decoder_is_store_reg_in), .out(decoder_is_store_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));  
        
        wire decoder_is_branch_reg_in, decoder_is_branch_reg_out; 
        Nbit_reg #(1, 0) decoder_is_branch_reg (.in(decoder_is_branch_reg_in), .out(decoder_is_branch_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));  
        
        wire decoder_is_control_insn_reg_in, decoder_is_control_insn_reg_out; 
        Nbit_reg #(1, 0) decoder_is_control_insn_reg (.in(decoder_is_control_insn_reg_in), .out(decoder_is_control_insn_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));  
                 
             
                            
       //register file for the pipeline datapath                     
       wire [15:0] o_rs_data, o_rt_data;                 
       lc4_regfile #(16) regfile_0 (.clk(clk),
                                   .gwe(gwe),
                                   .rst(rst),
                                   .i_rs(decoder_r1sel_reg_out),         // rs selector
                                   .o_rs_data(o_rs_data),                // rs contents
                                   .i_rt(decoder_r2sel_reg_out),         // rt selector
                                   .o_rt_data(o_rt_data),                // rt contents
                                   .i_rd(w_wsel_reg_out),                // rd selector
                                   .i_wdata(alu_or_pc_plus_one_or_load), // data to write
                                   .i_rd_we(w_regfile_we_reg_out)                  // write enable
                                   );
        //two mux for WD bypass (has to be placed into the end of the code for some variables in memory stage registers)
        wire [15:0] regfile_r1data, regfile_r2data;
//        assign regfile_r1data = (w_wsel_reg_out == decoder_r1sel_reg_out) ? alu_or_pc_plus_one_or_load: o_rs_data;
//        assign regfile_r2data = (w_wsel_reg_out == decoder_r2sel_reg_out) ? alu_or_pc_plus_one_or_load: o_rt_data;  
                         
       //x stage registers after register file 
       //(x_r1sel_reg, x_r2sel_reg, x_wsel_reg, x_r1data_reg, x_r2data_reg, x_data_hazard_reg, x_ins_reg, x_pc_reg
       wire [2:0] x_r1sel_reg_in, x_r1sel_reg_out; 
       Nbit_reg #(3, 0) x_r1sel_reg (.in(x_r1sel_reg_in), .out(x_r1sel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
       
        wire [2:0] x_r1re_reg_in, x_r1re_reg_out; 
        Nbit_reg #(3, 0) x_r1re_reg (.in(x_r1re_reg_in), .out(x_r1re_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));
                 
       wire [2:0] x_r2sel_reg_in, x_r2sel_reg_out; 
       Nbit_reg #(3, 0) x_r2sel_reg (.in(x_r2sel_reg_in), .out(x_r2sel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
       
       wire [2:0] x_r2re_reg_in, x_r2re_reg_out; 
       Nbit_reg #(3, 0) x_r2re_reg (.in(x_r2re_reg_in), .out(x_r2re_reg_out), .clk(clk), .we(decoder_enable), .gwe(gwe), .rst(rst));
               
       wire [2:0] x_wsel_reg_in, x_wsel_reg_out; 
       Nbit_reg #(3, 0) x_wsel_reg (.in(x_wsel_reg_in), .out(x_wsel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
              
       wire [15:0] x_r1data_reg_in, x_r1data_reg_out; 
       Nbit_reg #(16, 0) x_r1data_reg (.in(x_r1data_reg_in), .out(x_r1data_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire [15:0] x_r2data_reg_in, x_r2data_reg_out; 
       Nbit_reg #(16, 0) x_r2data_reg (.in(x_r2data_reg_in), .out(x_r2data_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
            
       wire [15:0] x_ins_reg_in, x_ins_reg_out; 
       Nbit_reg #(16, 0) x_ins_reg (.in(x_ins_reg_in), .out(x_ins_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));                                          
                                                 
       wire [15:0] x_pc_reg_in, x_pc_reg_out; 
       Nbit_reg #(16, 0) x_pc_reg (.in(x_pc_reg_in), .out(x_pc_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
       
       wire [15:0] x_pc_plus_one_reg_in, x_pc_plus_one_reg_out; 
       Nbit_reg #(16, 0) x_pc_plus_one_reg (.in(x_pc_plus_one_reg_in), .out(x_pc_plus_one_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 

       wire x_regfile_we_reg_in, x_regfile_we_reg_out; 
       Nbit_reg #(1, 0) x_regfile_we_reg (.in(x_regfile_we_reg_in), .out(x_regfile_we_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire x_nzp_we_reg_in, x_nzp_we_reg_out; 
       Nbit_reg #(1, 0) x_nzp_we_reg (.in(x_nzp_we_reg_in), .out(x_nzp_we_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire x_select_pc_plus_one_reg_in, x_select_pc_plus_one_reg_out; 
       Nbit_reg #(1, 0) x_select_pc_plus_one_reg (.in(x_select_pc_plus_one_reg_in), .out(x_select_pc_plus_one_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire x_is_load_reg_in, x_is_load_reg_out; 
       Nbit_reg #(1, 0) x_is_load_reg (.in(x_is_load_reg_in), .out(x_is_load_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire x_is_store_reg_in, x_is_store_reg_out; 
       Nbit_reg #(1, 0) x_is_store_reg (.in(x_is_store_reg_in), .out(x_is_store_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire x_is_branch_reg_in, x_is_branch_reg_out; 
       Nbit_reg #(1, 0) x_is_branch_reg (.in(x_is_branch_reg_in), .out(x_is_branch_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire x_is_control_insn_reg_in, x_is_control_insn_reg_out; 
       Nbit_reg #(1, 0) x_is_control_insn_reg (.in(x_is_control_insn_reg_in), .out(x_is_control_insn_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire x_is_stall_reg_in,x_is_stall_reg_out; 
       Nbit_reg #(1, 0) x_is_stall_reg (.in(x_is_stall_reg_in), .out(x_is_stall_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));         
       //bypass data before ALU two mux (has to b placed into the end of the code for some variables in memory stage registers)
       wire [15:0] r1data_before_ALU;
       wire [15:0] r2data_before_ALU;
//       assign r1data_before_ALU = (mem_wsel_reg_out == x_r1sel_reg_out) ? mem_alu_result_reg_out:
//                                  (w_wsel_reg_out == x_r1sel_reg_out) ? alu_or_pc_plus_one_or_load: x_r1data_reg_out;
//       assign r2data_before_ALU = (mem_wsel_reg_out == x_r2sel_reg_out) ? mem_alu_result_reg_out:
//                                  (w_wsel_reg_out == x_r2sel_reg_out) ? alu_or_pc_plus_one_or_load: x_r2data_reg_out;     
       //ALU unit for the pipeline datapath
       wire [15:0] alu_result;                            
       lc4_alu alu_0 (.i_insn(x_ins_reg_out),
                     .i_pc(x_pc_reg_out),
                     .i_r1data(r1data_before_ALU),
                     .i_r2data(r2data_before_ALU),
                     .o_result(alu_result));  
       

                       
                     
       //select wether it should be pc+1 or alu result (the mux right after ALU)              
       wire [15:0] alu_or_pc_plus_one;
       assign alu_or_pc_plus_one = (x_select_pc_plus_one_reg_out == 1'b1) ? x_pc_plus_one_reg_out : alu_result;
       
       //NZP registers write in
       wire [2:0] x_nzp_reg_in, x_nzp_reg_out;
       assign x_nzp_reg_in = ($signed(alu_or_pc_plus_one) > $signed(16'b0) ) ? 3'b001:
                               ($signed(alu_or_pc_plus_one) == $signed(16'b0) ) ? 3'b010:
                               ($signed(alu_or_pc_plus_one) < $signed(16'b0) ) ? 3'b100:3'b000;
        Nbit_reg #(3) x_n_reg (.in(x_nzp_reg_in), .out(x_nzp_reg_out), .clk(clk), .we(x_nzp_we_reg_out), .gwe(gwe), .rst(rst));                        
                           
        //m stage registers after mux(ALU result or PC+1) 
       wire [2:0] mem_nzp_reg_out;                   
       Nbit_reg #(3) mem_n_reg (.in(x_nzp_reg_in), .out(mem_nzp_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
      
       wire [2:0] mem_r1sel_reg_out; 
       Nbit_reg #(3, 0) mem_r1sel_reg (.in(x_r1sel_reg_out), .out(mem_r1sel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
         
       wire [2:0] mem_r2sel_reg_out; 
       Nbit_reg #(3, 0) mem_r2sel_reg (.in(x_r2sel_reg_out), .out(mem_r2sel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
      
       wire [2:0] mem_wsel_reg_out; 
       Nbit_reg #(3, 0) mem_wsel_reg (.in(x_wsel_reg_out), .out(mem_wsel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
                                           
       wire [15:0] mem_alu_result_reg_out; 
       Nbit_reg #(16, 0) mem_alu_result_reg (.in(alu_or_pc_plus_one), .out(mem_alu_result_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
                                                
       wire [15:0] mem_r2data_reg_out; 
       Nbit_reg #(16, 0) mem_r2data_reg (.in(r2data_before_ALU), .out(mem_r2data_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
       
//       wire [1:0] mem_data_hazard_reg_out; 
//       Nbit_reg #(2, 0) mem_data_hazard_reg (.in(), .out(mem_data_hazard_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
                                         
       wire [15:0] mem_ins_reg_out; 
       Nbit_reg #(16, 0) mem_ins_reg (.in(x_ins_reg_out), .out(mem_ins_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));                                          
                                                
       wire [15:0] mem_pc_reg_out; 
       Nbit_reg #(16, 0) mem_pc_reg (.in(x_pc_reg_out), .out(mem_pc_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
       
       wire mem_regfile_we_reg_out; 
       Nbit_reg #(1, 0) mem_regfile_we_reg (.in(x_regfile_we_reg_out), .out(mem_regfile_we_reg_out ), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire mem_nzp_we_reg_out; 
       Nbit_reg #(1, 0) mem_nzp_we_reg (.in(x_nzp_we_reg_out), .out(mem_nzp_we_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
      
       wire mem_select_pc_plus_one_reg_out; 
       Nbit_reg #(1, 0) mem_select_pc_plus_one_reg (.in(x_select_pc_plus_one_reg_out), .out(mem_select_pc_plus_one_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
      
       wire mem_is_load_reg_out; 
       Nbit_reg #(1, 0) mem_is_load_reg (.in(x_is_load_reg_out), .out(mem_is_load_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
      
       wire mem_is_store_reg_out; 
       Nbit_reg #(1, 0) mem_is_store_reg (.in(x_is_store_reg_out), .out(mem_is_store_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
      
       wire mem_is_branch_reg_out; 
       Nbit_reg #(1, 0) mem_is_branch_reg (.in(x_is_branch_reg_out), .out(mem_is_branch_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
      
       wire mem_is_control_insn_reg_out; 
       Nbit_reg #(1, 0) mem_is_control_insn_reg (.in(x_is_control_insn_reg_out), .out(mem_is_control_insn_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
        wire mem_is_stall_reg_out; 
        Nbit_reg #(1, 0) mem_is_stall_reg (.in(x_is_stall_reg_out), .out(mem_is_stall_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
       //data memory logic part There will be two input: one is data from r2data after register file stage register, the other is the address
       //                       There will be on output: data memory output   
       assign o_dmem_addr = (mem_is_store_reg_out | mem_is_load_reg_out) ? mem_alu_result_reg_out : 16'b0; // Address to read/write from/to data memory; SET TO 0x0000 FOR NON LOAD/STORE INSNS
       // This is the logic part for store instruction. It enable the write function in memory and get the data from rt in register.
       // The write address has already determined above
       assign o_dmem_we = mem_is_store_reg_out;
//       //WD bypass
//       assign o_dmem_towrite = ((w_ins_reg_out == 4'b0110) & (w_wsel_reg_out == mem_r2sel_reg_out)) ? alu_or_pc_plus_one_or_load:mem_r2data_reg_out;

      
       //w stage registers after mux(ALU result or PC+1)
       wire w_is_stall_reg_out; 
       Nbit_reg #(1, 0) w_is_stall_reg (.in(mem_is_stall_reg_out), .out(w_is_stall_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
       
       wire [15:0] w_o_dmem_addr_reg_out; 
       Nbit_reg #(16, 0) w_o_dmem_addr_reg (.in(o_dmem_addr), .out(w_o_dmem_addr_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
       
       wire [15:0] w_o_dmem_towrite_reg_out; 
       Nbit_reg #(16, 0) w_o_dmem_towrite_reg (.in(o_dmem_towrite), .out(w_o_dmem_towrite_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 

       wire [2:0] w_nzp_reg_out_temp, w_nzp_reg_out;                  
       Nbit_reg #(3) w_n_reg (.in(mem_nzp_reg_out), .out(w_nzp_reg_out_temp), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
       
       wire [2:0] w_r1sel_reg_out; 
       Nbit_reg #(3, 0) w_r1sel_reg (.in(mem_r1sel_reg_out), .out(w_r1sel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
         
       wire [2:0] w_r2sel_reg_out; 
       Nbit_reg #(3, 0) w_r2sel_reg (.in(mem_r2sel_reg_out), .out(w_r2sel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
      
       wire [2:0] w_wsel_reg_out; 
       Nbit_reg #(3, 0) w_wsel_reg (.in(mem_wsel_reg_out), .out(w_wsel_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
                                           
       wire [15:0] w_alu_result_reg_out; 
       Nbit_reg #(16, 0) w_alu_result_reg (.in(mem_alu_result_reg_out), .out(w_alu_result_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
                                                       
       wire [15:0] w_d_mem_output_reg_out; 
       Nbit_reg #(16, 0) w_d_mem_output_reg (.in(i_cur_dmem_data), .out(w_d_mem_output_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst)); 
       
//       wire [1:0] w_data_hazard_reg_out; 
//       Nbit_reg #(2, 0) w_data_hazard_reg (.in(), .out(w_data_hazard_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));         
                                  
       wire [15:0] w_ins_reg_out; 
       Nbit_reg #(16, 0) w_ins_reg (.in(mem_ins_reg_out), .out(w_ins_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));                                          
                                                
       wire [15:0] w_pc_reg_out; 
       Nbit_reg #(16, 0) w_pc_reg (.in(mem_pc_reg_out), .out(w_pc_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));                                                                 
       
       wire w_regfile_we_reg_out; 
       Nbit_reg #(1, 0) w_regfile_we_reg (.in(mem_regfile_we_reg_out), .out(w_regfile_we_reg_out ), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       wire w_nzp_we_reg_out; 
       Nbit_reg #(1, 0) w_nzp_we_reg (.in(mem_nzp_we_reg_out), .out(w_nzp_we_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
     
       wire w_select_pc_plus_one_reg_out; 
       Nbit_reg #(1, 0) w_select_pc_plus_one_reg (.in(mem_select_pc_plus_one_reg_out), .out(w_select_pc_plus_one_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
     
       wire w_is_load_reg_out; 
       Nbit_reg #(1, 0) w_is_load_reg (.in(mem_is_load_reg_out), .out(w_is_load_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
     
       wire w_is_store_reg_out; 
       Nbit_reg #(1, 0) w_is_store_reg (.in(mem_is_store_reg_out), .out(w_is_store_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
     
       wire w_is_branch_reg_out; 
       Nbit_reg #(1, 0) w_is_branch_reg (.in(mem_is_branch_reg_out), .out(w_is_branch_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
     
       wire w_is_control_insn_reg_out; 
       Nbit_reg #(1, 0) w_is_control_insn_reg (.in(mem_is_control_insn_reg_out), .out(w_is_control_insn_reg_out), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
       
       //the mux after data memory (input: alu_or_pc_plus_one and data memory output)
       wire [15:0] alu_or_pc_plus_one_or_load ;  
       assign alu_or_pc_plus_one_or_load = ((w_is_load_reg_out == 1'b1)) ? w_d_mem_output_reg_out : w_alu_result_reg_out;
       
//       //NZP registers write in
//       wire [2:0] nzp_reg_in, nzp_reg_out;
//       assign nzp_reg_in = ($signed(alu_or_pc_plus_one_or_load) > $signed(16'b0) ) ? 3'b001:
//                           ($signed(alu_or_pc_plus_one_or_load) == $signed(16'b0) ) ? 3'b010:
//                           ($signed(alu_or_pc_plus_one_or_load) < $signed(16'b0) ) ? 3'b100:3'b000;
//       Nbit_reg #(3) n_reg (.in(nzp_reg_in), .out(nzp_reg_out), .clk(clk), .we(w_nzp_we_reg_out), .gwe(gwe), .rst(rst));                    
   
       wire br_logic_output, br_logic_output_temp;
       //branch logic    
       assign br_logic_output_temp = ((x_ins_reg_out[11:9] == 3'b001) & (x_nzp_reg_out == 3'b001)) |
                                     (((x_ins_reg_out[11:9] == 3'b010) & (x_nzp_reg_out == 3'b010))) |
                                     ((x_ins_reg_out[11:9] == 3'b011) & ((x_nzp_reg_out == 3'b001) | (x_nzp_reg_out == 3'b010))) |
                                     ((x_ins_reg_out[11:9] == 3'b100) & (x_nzp_reg_out == 3'b100)) |
                                     ((x_ins_reg_out[11:9] == 3'b101) & ((x_nzp_reg_out == 3'b100) | (x_nzp_reg_out == 3'b001))) |
                                     ((x_ins_reg_out[11:9] == 3'b110) & ((x_nzp_reg_out == 3'b100) | (x_nzp_reg_out == 3'b010))) |
                                     ((x_ins_reg_out[11:9] == 3'b111) &((x_nzp_reg_out == 3'b100) | (x_nzp_reg_out == 3'b010) | (x_nzp_reg_out == 1'b001))) |
                                     x_is_control_insn_reg_out;
       assign br_logic_output = (x_is_branch_reg_out == 1'b1 | x_is_control_insn_reg_out == 1'b1) ? br_logic_output_temp : 1'b0;                               
       assign next_pc = (br_logic_output == 1'b1) ? alu_result : pc_plus_one; 
       //assign next_pc = pc_plus_one; 
       //update PC address
       assign o_cur_pc = pc;
       
       //Detec load and use condition and frozen registers in decoder stage and x stage, as well as pc
       wire pc_enable, decoder_enable, x_enable, is_stall;
       assign pc_enable = ((x_ins_reg_out[15:12] == 4'b0110) & 
                       (((x_wsel_reg_out == decoder_r1sel_reg_out) & decoder_r1re_reg_out) | ((x_wsel_reg_out == decoder_r2sel_reg_out) & decoder_r2re_reg_out) & (!decoder_is_store_reg_out)) & 
                       x_regfile_we_reg_out) ? 1'b0:
                       ((x_ins_reg_out[15:12] == 4'b0110) & 
                       (decoder_is_branch_reg_out) & 
                       x_regfile_we_reg_out) ? 1'b0:1'b1;
                          
       assign decoder_enable = ((x_ins_reg_out[15:12] == 4'b0110) & 
                         (((x_wsel_reg_out == decoder_r1sel_reg_out) & decoder_r1re_reg_out) | ((x_wsel_reg_out == decoder_r2sel_reg_out) & decoder_r2re_reg_out) & (!decoder_is_store_reg_out)) & 
                         x_regfile_we_reg_out) ? 1'b0:
                         ((x_ins_reg_out[15:12] == 4'b0110) & 
                         (decoder_is_branch_reg_out) & 
                         x_regfile_we_reg_out) ? 1'b0:1'b1;
                          
       assign x_enable = ((x_ins_reg_out[15:12] == 4'b0110) & 
                       (((x_wsel_reg_out == decoder_r1sel_reg_out) & decoder_r1re_reg_out) | ((x_wsel_reg_out == decoder_r2sel_reg_out) & decoder_r2re_reg_out) & (!decoder_is_store_reg_out)) & 
                       x_regfile_we_reg_out) ? 1'b0:
                       ((x_ins_reg_out[15:12] == 4'b0110) & 
                       (decoder_is_branch_reg_out) & 
                       x_regfile_we_reg_out) ? 1'b0:1'b1;
       assign is_stall = ((x_ins_reg_out[15:12] == 4'b0110) & 
                       (((x_wsel_reg_out == decoder_r1sel_reg_out) & decoder_r1re_reg_out) | ((x_wsel_reg_out == decoder_r2sel_reg_out) & decoder_r2re_reg_out) & (!decoder_is_store_reg_out)) & 
                       x_regfile_we_reg_out) ? 1'b0:
                       ((x_ins_reg_out[15:12] == 4'b0110) & 
                       (decoder_is_branch_reg_out) & 
                       x_regfile_we_reg_out) ? 1'b0:1'b1;
       
       
       //flush the decoder stage registers if branch is taken
       assign decoder_r1sel_reg_in = (br_logic_output) ? 3'b0:r1sel;//decoder_r1re_reg_in
       assign decoder_r1re_reg_in = (br_logic_output) ? 3'b0:r1re;
       assign decoder_r2sel_reg_in = (br_logic_output) ? 3'b0:r2sel;
       assign decoder_r2re_reg_in = (br_logic_output) ? 3'b0:r2re;
       assign decoder_wsel_reg_in = (br_logic_output) ? 3'b0:wsel;
       assign decoder_ins_reg_in = (br_logic_output) ? 16'b0:i_cur_insn;
       assign decoder_pc_reg_in = (br_logic_output) ? 16'b0:pc;
       assign decoder_pc_plus_one_reg_in = (br_logic_output) ? 16'b0:pc_plus_one;
       assign decoder_regfile_we_reg_in = (br_logic_output) ? 1'b0:regfile_we;
       assign decoder_nzp_we_reg_in = (br_logic_output) ? 1'b0:nzp_we;
       assign decoder_select_pc_plus_one_reg_in = (br_logic_output) ? 1'b0:select_pc_plus_one;
       assign decoder_is_load_reg_in = (br_logic_output) ? 1'b0:is_load;
       assign decoder_is_store_reg_in = (br_logic_output) ? 1'b0:is_store;
       assign decoder_is_branch_reg_in = (br_logic_output) ? 1'b0:is_branch;
       assign decoder_is_control_insn_reg_in = (br_logic_output) ? 1'b0:is_control_insn;
       
       //flush the execution stage registers if branch is taken
//       assign x_is_stall_reg_in = (br_logic_output | (!x_enable)) ? 3'b0:is_stall;
       assign x_is_stall_reg_in = is_stall;
       assign x_r1sel_reg_in = (br_logic_output | (!x_enable)) ? 3'b0:decoder_r1sel_reg_out;
       assign x_r1re_reg_in = (br_logic_output | (!x_enable)) ? 3'b0:decoder_r1re_reg_out;
       assign x_r2sel_reg_in = (br_logic_output | (!x_enable)) ? 3'b0:decoder_r2sel_reg_out;
       assign x_r2re_reg_in = (br_logic_output | (!x_enable)) ? 3'b0:decoder_r2re_reg_out;
       assign x_wsel_reg_in = (br_logic_output | (!x_enable)) ? 3'b0:decoder_wsel_reg_out;
       assign x_r1data_reg_in = (br_logic_output | (!x_enable)) ? 16'b0:regfile_r1data;
       assign x_r2data_reg_in = (br_logic_output | (!x_enable)) ? 16'b0:regfile_r2data;
       assign x_ins_reg_in = (br_logic_output | (!x_enable)) ? 16'b0:decoder_ins_reg_out;
       assign x_pc_reg_in = (br_logic_output | (!x_enable)) ? 16'b0:decoder_pc_reg_out;
       assign x_pc_plus_one_reg_in = (br_logic_output | (!x_enable)) ? 16'b0:decoder_pc_plus_one_reg_out;
       assign x_regfile_we_reg_in = (br_logic_output | (!x_enable)) ? 1'b0:decoder_regfile_we_reg_out;
       assign x_nzp_we_reg_in = (br_logic_output | (!x_enable)) ? 1'b0:decoder_nzp_we_reg_out;
       assign x_select_pc_plus_one_reg_in = (br_logic_output | (!x_enable)) ? 1'b0:decoder_select_pc_plus_one_reg_out;
       assign x_is_load_reg_in = (br_logic_output | (!x_enable)) ? 1'b0:decoder_is_load_reg_out;
       assign x_is_store_reg_in = (br_logic_output | (!x_enable)) ? 1'b0:decoder_is_store_reg_out;
       assign x_is_branch_reg_in = (br_logic_output | (!x_enable)) ? 1'b0:decoder_is_branch_reg_out;
       assign x_is_control_insn_reg_in = (br_logic_output | (!x_enable)) ? 1'b0:decoder_is_control_insn_reg_out;

       
       //bypass data before ALU two mux MX and WX(has to be placed into the end of the code for some variables in memory stage registers)
       assign r1data_before_ALU = ((mem_wsel_reg_out == x_r1sel_reg_out) & mem_regfile_we_reg_out) ? mem_alu_result_reg_out:
                                  ((w_wsel_reg_out == x_r1sel_reg_out) & w_regfile_we_reg_out) ? alu_or_pc_plus_one_or_load: x_r1data_reg_out;
       assign r2data_before_ALU = ((mem_wsel_reg_out == x_r2sel_reg_out) & mem_regfile_we_reg_out) ? mem_alu_result_reg_out:
                                  ((w_wsel_reg_out == x_r2sel_reg_out) & w_regfile_we_reg_out) ? alu_or_pc_plus_one_or_load: x_r2data_reg_out; 
       //two mux for WD bypass (has to be placed into the end of the code for some variables in memory stage registers)
       assign regfile_r1data = ((w_wsel_reg_out == decoder_r1sel_reg_out)& w_regfile_we_reg_out) ? alu_or_pc_plus_one_or_load: o_rs_data;
       assign regfile_r2data = ((w_wsel_reg_out == decoder_r2sel_reg_out)& w_regfile_we_reg_out) ? alu_or_pc_plus_one_or_load: o_rt_data;                           
       
       //WM bypass (has to be placed into the end of the code for some variables in memory stage registers)
       assign o_dmem_towrite = ((w_ins_reg_out[15:12] == 4'b0110) & (w_wsel_reg_out == mem_r2sel_reg_out) & w_regfile_we_reg_out) ? alu_or_pc_plus_one_or_load:mem_r2data_reg_out;
       
       
       
       // Always execute one instruction each cycle (test_stall will get used in your pipelined processor)
       //has to be placed into the end of the code for some variables in memory stage registers
       assign test_stall = ((decoder_pc_reg_out == 16'h8200)&(x_pc_reg_out == 16'h0)&(mem_pc_reg_out == 16'h0)&(w_pc_reg_out == 16'h0)) ? 2'b10:
                           ((x_pc_reg_out == 16'h8200)&(mem_pc_reg_out == 16'h0)&(w_pc_reg_out == 16'h0)) ? 2'b10:
                           ((mem_pc_reg_out == 16'h8200)&(w_pc_reg_out == 16'h0)) ? 2'b10:
                           ((w_ins_reg_out == 16'h0)&(w_pc_reg_out == 16'h0)&(w_is_stall_reg_out != 1'h0)) ? 2'b10:         
                           (w_is_stall_reg_out == 1'h0) ? 2'b11:2'b00; 
                                                  
       assign test_cur_pc = w_pc_reg_out; 
       assign test_cur_insn = w_ins_reg_out;
       assign test_regfile_we = w_regfile_we_reg_out;
       assign test_regfile_wsel = w_wsel_reg_out;
       assign test_regfile_data = alu_or_pc_plus_one_or_load;
       assign test_nzp_we = w_nzp_we_reg_out;
       
       //NZP registers in W stage 
       wire [2:0] w_nzp_reg_extra;
       assign w_nzp_reg_extra = ($signed(alu_or_pc_plus_one_or_load) > $signed(16'b0) ) ? 3'b001:
                             ($signed(alu_or_pc_plus_one_or_load) == $signed(16'b0) ) ? 3'b010:
                             ($signed(alu_or_pc_plus_one_or_load) < $signed(16'b0) ) ? 3'b100:3'b000;
      assign w_nzp_reg_out = (w_ins_reg_out[15:12] == 4'b0110) ? w_nzp_reg_extra: w_nzp_reg_out_temp;
       
       
       assign test_nzp_new_bits = w_nzp_reg_out;    
       assign test_dmem_we = w_is_store_reg_out;
       assign test_dmem_addr = w_o_dmem_addr_reg_out;
       assign test_dmem_data = (w_is_load_reg_out) ? alu_or_pc_plus_one_or_load:
                               (w_is_store_reg_out) ? w_o_dmem_towrite_reg_out:16'b0;
       //select wether it should be pc+1 or other pc address for (jsrr, jsr, rti, jmpr,jmp,trap)   
      /* Add $display(...) calls in the always block below to
       * print out debug information at the end of every cycle.
       *
       * You may also use if statements inside the always block
       * to conditionally print out information.
       *
       * You do not need to resynthesize and re-implement if this is all you change;
       * just restart the simulation.
       * 
       * To disable the entire block add the statement
       * `define NDEBUG
       * to the top of your file.  We also define this symbol
       * when we run the grading scripts.
       */
   `ifndef NDEBUG
      always @(posedge gwe) begin
         // $display("%d %h %h %h %h %h", $time, f_pc, d_pc, e_pc, m_pc, test_cur_pc);
         // if (o_dmem_we)
         //   $display("%d STORE %h <= %h", $time, o_dmem_addr, o_dmem_towrite);
   
         // Start each $display() format string with a %d argument for time
         // it will make the output easier to read.  Use %b, %h, and %d
         // for binary, hex, and decimal output of additional variables.
         // You do not need to add a \n at the end of your format string.
         // $display("%d ...", $time);
   
         // Try adding a $display() call that prints out the PCs of
         // each pipeline stage in hex.  Then you can easily look up the
         // instructions in the .asm files in test_data.
   
         // basic if syntax:
         // if (cond) begin
         //    ...;
         //    ...;
         // end
   
         // Set a breakpoint on the empty $display() below
         // to step through your pipeline cycle-by-cycle.
         // You'll need to rewind the simulation to start
         // stepping from the beginning.
   
         // You can also simulate for XXX ns, then set the
         // breakpoint to start stepping midway through the
         // testbench.  Use the $time printouts you added above (!)
         // to figure out when your problem instruction first
         // enters the fetch stage.  Rewind your simulation,
         // run it for that many nano-seconds, then set
         // the breakpoint.
   
         // In the objects view, you can change the values to
         // hexadecimal by selecting all signals (Ctrl-A),
         // then right-click, and select Radix->Hexadecial.
   
         // To see the values of wires within a module, select
         // the module in the hierarchy in the "Scopes" pane.
         // The Objects pane will update to display the wires
         // in that module.
   
         $display();
      end
   `endif
   endmodule
