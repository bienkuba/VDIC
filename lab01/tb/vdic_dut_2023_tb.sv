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
    forever begins
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

    bit [2:0] zero_ones;

    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'sh8000;
    else if (zero_ones == 3'b111)
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
    repeat (1000) begin : tester_main_blk
        @(negedge clk);
        arg_a			= get_data();
        arg_b			= get_data();
	    arg_a_parity 	= check_parity(arg_a);
	    arg_b_parity 	= check_parity(arg_b);
	    
        req  	= 1'b1;
	    
	    counter = counter + 1;
	    `ifdef DEBUG
	    $display("TEST_ %0d", counter);
	    `endif
	    
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
			                `ifdef DEBUG
						    $display("___MUL test FAILED for arg_a=%0d arg_b=%0d a_P=%0d b_P=%0d", arg_a, arg_b, arg_a_parity, arg_b_parity);
						    `endif
		                end 
		                else begin
			                `ifdef DEBUG
						    $display("___mul_test_PASSED");
						    `endif
		                end
		                    
		                if(result_parity != expected_parity) begin
		                    test_result = TEST_FAILED;
			                  
			                `ifdef DEBUG
						    $display("parity test FAILED for arg_a=%0d arg_b=%0d a_P=%0d b_P=%0d result_parity=%0d expected=%0d", arg_a, arg_b, arg_a_parity, arg_b_parity, result_parity, expected_parity);
						    `endif
		                end
		                else begin
			                `ifdef DEBUG
						    $display("parity_test_PASSED");
						    `endif
		                end
		            end
		            else begin
			            if(arg_parity_error != 1 || result != 0)begin
				            test_result = TEST_FAILED;
				            `ifdef DEBUG
						    $display("error_parity_test_FAILED for arg_a=%0d arg_b=%0d a_P=%0d b_P=%0d", arg_a, arg_b, arg_a_parity, arg_b_parity);
						    `endif
			            end
			            else begin
				            `ifdef DEBUG
						    $display("parity_error_test_PASSED");
						    `endif
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


endmodule : top
