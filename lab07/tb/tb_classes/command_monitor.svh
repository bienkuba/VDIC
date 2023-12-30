/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_analysis_port #(command_transaction) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction
    
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
        bfm.command_monitor_h = this;
        ap                    = new("ap",this);
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// access function for BMF
//------------------------------------------------------------------------------
    function void write_to_monitor(
		logic signed 	[15:0] 	arg_a,
		logic signed 	[15:0] 	arg_b, 
		bit               		arg_a_parity,
		bit               		arg_b_parity,
		bit               		err_flag_a,
		bit               		err_flag_b,
	    bit 					rst_n
	    );
	    
        command_transaction cmd;
        `uvm_info("COMMAND MONITOR",$sformatf("COMMAND MONITOR: arg_a=%0d, arg_b=%0d, arg_a_parity=%0d, arg_b_parity=%0d, flag_arg_a_parity=%0d, flag_arg_b_parity=%0d", cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity, cmd.err_flag_a, cmd.err_flag_b), UVM_HIGH);
        cmd = new("cmd");
        cmd.rst_n = rst_n;
        cmd.arg_a = arg_a;
        cmd.arg_b = arg_b;
        cmd.arg_a_parity = arg_a_parity;
        cmd.arg_b_parity = arg_b_parity;
	    cmd.err_flag_a = err_flag_a;
        cmd.err_flag_b = err_flag_b;
       
        ap.write(cmd);
    endfunction : write_to_monitor
    

endclass : command_monitor