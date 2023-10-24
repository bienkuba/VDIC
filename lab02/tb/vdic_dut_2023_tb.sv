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

 History:
 2021-10-05 RSz, AGH UST - test modified to send all the data on negedge clk
 and check the data on the correct clock edge (covergroup on posedge
 and scoreboard on negedge). Scoreboard and coverage removed.
 */
module top;

//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------



typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

logic                	clk;
logic                	rst_n;
logic signed	[15:0]	arg_a;
logic					arg_a_parity;
logic signed	[15:0]	arg_b;
logic					arg_b_parity;
logic					req;

logic					ack;
logic signed	[31:0]	result;
logic					result_parity;
logic               	result_rdy;
logic					arg_parity_error;

	
test_result_t        test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

vdic_dut_2023 DUT (
	.clk, 
	.rst_n,
	.arg_a,
	.arg_a_parity,
	.arg_b,
	.arg_b_parity,
	.req,
	.ack,
	.result,
	.result_parity,
	.result_rdy,
	.arg_parity_error);
	
//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

covergroup Multiplication;

    option.name = "cg_corner_values_of_arguments";


    arg_a_leg: coverpoint arg_a {
        bins min_value 	= {16'sh8000};
        bins neg_value = {[16'sh8001:16'shFFFF]};
//	    bins zeros 		= {'sh0000};
	    bins pos_value = {[16'sh0000:16'sh7FFE]};
        bins max_value	= {16'sh7FFF};
    }

    arg_b_leg: coverpoint arg_b {
        bins min_value 	= {16'sh8000};
        bins neg_value = {[16'sh8001:16'shFFFF]};
//	    bins zeros 		= {'sh0000};
	    bins pos_value = {[16'sh0000:16'sh7FFE]};
        bins max_value  = {16'sh7FFF};
    }

    Corner_arg: cross arg_a_leg, arg_b_leg {
	    
	    // Corner values multiplication
	    
	    bins a_max_mul_b_max	= (binsof (arg_a_leg.max_value) && binsof (arg_b_leg.max_value));
	    bins a_max_mul_b_min	= (binsof (arg_a_leg.max_value) && binsof (arg_b_leg.min_value));
	    bins a_min_mul_b_max	= (binsof (arg_a_leg.min_value) && binsof (arg_b_leg.max_value));
	    bins a_min_mul_b_min	= (binsof (arg_a_leg.min_value) && binsof (arg_b_leg.min_value));
	   
	   // zeros multiplication
	   
//	    bins a_max_mul_b_zeros	= (binsof (arg_a_leg.max_value) || binsof (arg_b_leg.zeros));
//	    bins a_min_mul_b_zeros	= (binsof (arg_a_leg.min_value) || binsof (arg_b_leg.zeros));
//	    bins a_zeros_mul_b_max	= (binsof (arg_a_leg.zeros) || binsof (arg_b_leg.max_value));
//	    bins a_zeros_mul_b_min	= (binsof (arg_a_leg.zeros) || binsof (arg_b_leg.min_value));
    }

endgroup

covergroup Parity;

    option.name = "cg_parity";


    parity_a_leg: coverpoint arg_a_parity {
        bins even 	= {'b0};
        bins odd	= {'b1};
    }

    parity_b_leg: coverpoint arg_b_parity {
        bins even 	= {'b0};
        bins odd	= {'b1};
    }
    
    Corner_arg: cross parity_a_leg, parity_b_leg {
	    
	    // Parity permutations
	    
		bins even_even 	= (binsof (parity_a_leg.even) && binsof (parity_b_leg.even));
		bins even_odd 	= (binsof (parity_a_leg.even) && binsof (parity_b_leg.odd));
		bins odd_even 	= (binsof (parity_a_leg.odd) && binsof (parity_b_leg.even));
		bins odd_odd 	= (binsof (parity_a_leg.odd) && binsof (parity_b_leg.odd));
    }
    
endgroup

Multiplication 			c_min_max;
Parity 					c_parity;
initial begin : coverage
    c_min_max 	= new();
	c_parity 	= new();
    forever begin : sample_cov
        @(posedge clk);
        if(req || !rst_n) begin
            c_min_max.sample();
	        c_parity.sample();
            
            /* #1step delay is necessary before checking for the coverage
             * as the .sample methods run in parallel threads
             */
            #1step; 
            if($get_coverage() == 100) break; //disable, if needed
            
            // you can print the coverage after each sample
//            $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
        end
    end
end : coverage


//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

// timestamp monitor
initial begin
    longint clk_counter;
    clk_counter = 0;
    forever begin
        @(posedge clk) clk_counter++;
        if(clk_counter % 1000 == 0) begin
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
        end
    end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------


//---------------------------------
// Random data generation functions


function logic signed [15:0] get_data();

    bit [1:0] zero_ones;

    zero_ones = 2'($random);

    if (zero_ones == 2'b00)
        return 16'sh8000;
    else if (zero_ones == 2'b11)
        return 16'sh7FFF;
    else
        return 16'($random);
endfunction : get_data

//------------------------

function logic check_parity(logic signed [15:0] arg);
	
	logic 		ret;
	logic		ret_wrong;
	logic [1:0] zero_ones;
	
	zero_ones 	= 2'($random);
	ret 		= ^arg; 
	ret_wrong 	= !ret;
	
	if (zero_ones == 2'b00)
        return(ret_wrong);
    else
        return(ret);
endfunction : check_parity

//------------------------
// Tester main

initial begin : tester
	logic signed 	[31:0] 	expected;
	logic 		 			expected_parity;
	logic			[31:0]	counter;
    reset();
    repeat (100) begin : tester_main_blk
        @(negedge clk);
        arg_a			= get_data();
        arg_b			= get_data();
	    arg_a_parity 	= check_parity(arg_a);
	    arg_b_parity 	= check_parity(arg_b);
	    
        req  	= 1'b1;
	    
	    counter = counter + 1;
//	    `ifdef DEBUG
//	    $display("TEST_ %0d", counter);
//	    `endif
	    
             begin : case_default_blk
//	            wait(ack);
//	            wait(result_rdy);
	            while(!ack)@(negedge clk);
	            while(!result_rdy)@(negedge clk);
	            
                req = 1'b0;
                //------------------------------------------------------------------------------
                // temporary data check - scoreboard will do the job later
                begin
	                expected = get_expected(arg_a, arg_b);
	                expected_parity = get_expected_parity(expected);
		            if(arg_parity_error == 0)begin //expected_parity == result_parity & 
			            
			            
		                if(result != expected) begin
			                test_result = TEST_FAILED;
//			                `ifdef DEBUG
//						    $display("___MUL test FAILED for arg_a=%0d arg_b=%0d a_P=%0d b_P=%0d", arg_a, arg_b, arg_a_parity, arg_b_parity);
//						    `endif
		                end 
		                else begin
//			                `ifdef DEBUG
//						    $display("___mul_test_PASSED");
//						    `endif
		                end
		                    
		                if(result_parity != expected_parity) begin
		                    test_result = TEST_FAILED;
			                  
//			                `ifdef DEBUG
//						    $display("parity test FAILED for arg_a=%0d arg_b=%0d a_P=%0d b_P=%0d result_parity=%0d expected=%0d", arg_a, arg_b, arg_a_parity, arg_b_parity, result_parity, expected_parity);
//						    `endif
		                end
		                else begin
//			                `ifdef DEBUG
//						    $display("parity_test_PASSED");
//						    `endif
		                end
		            end
		            else begin
			            if(arg_parity_error != 1 || result != 0)begin
				            test_result = TEST_FAILED;
//				            `ifdef DEBUG
//						    $display("error_parity_test_FAILED for arg_a=%0d arg_b=%0d a_P=%0d b_P=%0d", arg_a, arg_b, arg_a_parity, arg_b_parity);
//						    `endif
			            end
			            else begin
//				            `ifdef DEBUG
//						    $display("parity_error_test_PASSED");
//						    `endif
						end
				    end
                    
                end

            end : case_default_blk
        
    // print coverage after each loop
    // $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
    // if($get_coverage() == 100) break;
    end : tester_main_blk
    $finish;
end : tester

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset();
    `ifdef DEBUG
    $display("%0t DEBUG: reset", $time);
    `endif
    req   = 1'b0;
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
endtask : reset

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function logic [31:0] get_expected(
	logic signed [15:0] arg_a,
	logic signed [15:0]	arg_b
    );
    logic signed [31:0] ret;

    ret = arg_a * arg_b;
    return(ret);
endfunction : get_expected

//--------------------------------------

function logic get_expected_parity(
	logic signed [31:0] mul_result
	);
	logic 				ret;
	
	ret = ^(mul_result);
	
    return(ret);
endfunction : get_expected_parity

//--------------------------------------

function logic get_expected_parity_error(
	logic signed [15:0] arg_a,
	logic signed [15:0]	arg_b,
	logic				arg_a_parity,
	logic				arg_b_parity
	);
	logic 				proper_arg_a_parity;
	logic 				proper_arg_b_parity;
	logic 				ret;
	
	proper_arg_a_parity = ^arg_a;
	proper_arg_b_parity = ^arg_b;
	
	if(proper_arg_a_parity == arg_a_parity && proper_arg_b_parity == arg_b_parity) begin
		ret = 0;
	end
	else begin
		ret = 1;
	end
	
    return(ret);
endfunction : get_expected_parity_error


//------------------------------------------------------------------------------
// Temporary. The scoreboard will be later used for checking the data
final begin : finish_of_the_test
    print_test_result(test_result);
end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
endfunction

function void print_test_result (test_result_t r);
    if(r == TEST_PASSED) begin
        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
        $write ("-----------------------------------\n");
        $write ("----------- Test PASSED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
    else begin
        set_print_color(COLOR_BOLD_BLACK_ON_RED);
        $write ("-----------------------------------\n");
        $write ("----------- Test FAILED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
endfunction

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
logic                         start_prev;
typedef struct packed {
    logic signed 	[15:0] 	arg_a;
    logic signed 	[15:0] 	arg_b;
	logic					arg_a_parity;
	logic					arg_b_parity;
    logic signed 	[31:0] 	result;
    logic 					result_parity;
	logic					arg_parity_error;
} data_packet_t;

data_packet_t               sb_data_q   [$];

always @(posedge clk) begin : scoreboard_fe_blk
    if(req == 1 && start_prev == 0)begin
        sb_data_q.push_front(data_packet_t'({
	        arg_a, 
	        arg_b, 
	        arg_a_parity, 
	        arg_b_parity, 
	        get_expected(arg_a, arg_b), 
	        get_expected_parity(get_expected(arg_a, arg_b)), 
	        get_expected_parity_error(arg_a, arg_b, arg_a_parity, arg_b_parity)
	    }));
    end
    start_prev = req;
end

always @(negedge clk) begin : scoreboard_be_blk
    if(result_rdy == 1) begin : verify_result
        data_packet_t dp;

        dp = sb_data_q.pop_back();

    	CHK_ARG_PARITY_ERROR: assert(arg_parity_error === dp.arg_parity_error) begin
           `ifdef DEBUG
		        $display("%0t Parity_ERR_Test passed", $time);
	    	`endif
        end
        else begin
            test_result = TEST_FAILED;
            $error("%0t Parity_ERR_Test FAILED \nExpected: %h  received: %h", $time, dp.arg_parity_error, arg_parity_error);
        end
        
        if(dp.arg_parity_error == 0)begin
	        CHK_RESULT: assert(result === dp.result) begin // && result_parity === dp.result_parity
	           `ifdef DEBUG
	            $display("%0t MUL_Test passed for A=%0h B=%0h P_A=%0b P_B=%0b", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity);
	           `endif
	        end
	        else begin
	            test_result = TEST_FAILED;
	            $error("%0t MUL_Test FAILED for A=%0h B=%0h P_A=%0b P_B=%0b \nExpected: %h  received: %h", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity, dp.result, result);
	        end
        
	        CHK_RESULT_PARITY: assert(result_parity === dp.result_parity) begin 
	           `ifdef DEBUG
	            $display("%0t Parity_Test passed for A=%0h B=%0h P_A=%0b P_B=%0b", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity);
	           `endif
	        end
	        else begin
	            test_result = TEST_FAILED;
	            $error("%0t Parity_Test FAILED for A=%0h B=%0h P_A=%0b P_B=%0b \nExpected: %h  received: %h", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity, dp.result, result);
	        end
	    end
    end
end : scoreboard_be_blk

endmodule : top
