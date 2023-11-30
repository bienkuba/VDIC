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
class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tpgen
//------------------------------------------------------------------------------

	protected function logic signed [15:0] get_data();
	
	    bit [1:0] zero_ones;
	
	    zero_ones = 2'($random);
	
	    if (zero_ones == 2'b00)
	        return 16'sh8000;
	    else if (zero_ones == 2'b11)
	        return 16'sh7FFF;
	    else
	        return 16'($random);
	endfunction : get_data

//------------------------------------------------------------------------------
	
//	protected function logic err_flag(
//		logic signed [15:0] arg,
//		logic 				arg_parity);
//		bit flag;
//		
//		if(arg_parity === ^arg)
//			flag = 1'b0;
//		else
//			flag = 1'b1;
//	endfunction : err_flag

//------------------------------------------------------------------------------

	protected function logic [3:0] check_parity(
		logic signed [15:0] arg_a,
		logic signed [15:0] arg_b
		);
		
		logic 		ret_a;
		logic 		ret_b;
		logic [1:0] zero_ones;
		bit			err_flag_a;
		bit			err_flag_b;
		
		zero_ones 	= 2'($random);
		ret_a = ^arg_a;
		ret_b = ^arg_b;
		err_flag_a = 1'b0;
		err_flag_b = 1'b0;
		
		if (zero_ones == 2'b01)begin
			ret_a = !(ret_a);
			err_flag_a = 1'b1;
		end
		if (zero_ones == 2'b10)begin
			ret_b = !(ret_b);
			err_flag_b = 1'b1;
		end
		if (zero_ones == 2'b00)begin
			ret_a = !(ret_a);
			ret_b = !(ret_b);
			err_flag_a = 1'b1;
			err_flag_b = 1'b1;
		end
		// else begin//(zero_ones == 2'b10)
		// end
	        return{ret_a, ret_b, err_flag_a, err_flag_b};
	endfunction : check_parity


endclass : random_tpgen






