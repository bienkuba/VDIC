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
class corner_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(corner_sequence)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

// not necessary, req is inherited
//    sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "corner_sequence");
        super.new(name);
    endfunction : new
    
//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_CORNER", "", UVM_MEDIUM)
        
        `uvm_create(req);
//      req = sequence_item::type_id::create("req");
//      start_item(req);
//      req.op = mul_op;
//      req.A = 8'hFF;
//      req.B = 8'hFF;
//      finish_item(req);
        repeat (50) begin
	        `uvm_rand_send_with(req, {arg_a dist {16'sh8000:=1, 16'sh7FFF:=1}; arg_b dist {16'sh8000:=1, 16'sh7FFF:=1};})
//	        `uvm_rand_send_with(req, {arg_a == 16'sh8000; arg_b == 16'sh8000;)
        end
    
    	req.rst_n = 1;
        `uvm_rand_send(req)
        
    endtask : body
    

endclass : corner_sequence
