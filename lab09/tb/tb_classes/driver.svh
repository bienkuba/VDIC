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
class driver extends uvm_driver #(sequence_item);
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    
    protected virtual mult_bfm bfm;
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*", "bfm", bfm))
            `uvm_fatal("DRIVER", "Failed to get BFM");
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
        task run_phase(uvm_phase phase);
        sequence_item cmd;

        void'(begin_tr(cmd));

        forever begin : cmd_loop
            seq_item_port.get_next_item(cmd);
            bfm.send_data(cmd.arg_a, cmd.arg_a_parity, cmd.arg_b, cmd.arg_b_parity, cmd.err_flag_a, cmd.err_flag_b, cmd.rst_n);
            seq_item_port.item_done();
        end : cmd_loop

        end_tr(cmd);

    endtask : run_phase
    

endclass : driver