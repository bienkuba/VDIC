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
class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

	rand bit signed 	[15:0] 	arg_a;
	rand bit               		arg_a_parity;
	rand bit signed 	[15:0] 	arg_b;    
	rand bit               		arg_b_parity;
	bit 						err_flag_a;
	bit 						err_flag_b;
	bit 						rst_n;

//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

`uvm_object_utils_begin(sequence_item)
	`uvm_field_int(arg_a, UVM_DEFAULT | UVM_ALL_ON | UVM_HEX)
	`uvm_field_int(arg_a_parity, UVM_DEFAULT | UVM_UNSIGNED)
	`uvm_field_int(arg_b, UVM_DEFAULT | UVM_ALL_ON | UVM_HEX)
	`uvm_field_int(arg_b_parity, UVM_DEFAULT | UVM_UNSIGNED)
	`uvm_field_int(err_flag_a, UVM_DEFAULT | UVM_UNSIGNED)
	`uvm_field_int(err_flag_b, UVM_DEFAULT | UVM_UNSIGNED)
	`uvm_field_int(rst_n, UVM_DEFAULT | UVM_UNSIGNED)
`uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint data {
//	    arg_a dist {[16'sh7FFF:16'sh8000]:= 1};
//	    arg_b dist {[16'sh7FFF:16'sh8000]:= 1};
	    arg_a dist {[16'sh8000:16'shFFFF]:/1, 16'sh0000:/1, [16'sh0001:16'sh7FFF]:/1};
	    arg_b dist {[16'sh8000:16'shFFFF]:/1, 16'sh0000:/1, [16'sh0001:16'sh7FFF]:/1};
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------

    function string convert2string();
        return {super.convert2string(),
            $sformatf("rst_n: %1h arg_a: %4h arg_b: %4h arg_a_parity: %1h arg_b_parity: %1h err_flag_a: %1h err_flag_b: %1h", rst_n, arg_a, arg_b, arg_a_parity, arg_b_parity, err_flag_a, err_flag_b)
        };
    endfunction : convert2string

endclass : sequence_item


