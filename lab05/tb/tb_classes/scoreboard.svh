class scoreboard extends uvm_component;
	`uvm_component_utils(scoreboard)
	
//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------

typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

protected typedef struct packed {
    logic signed 	[15:0] 	arg_a;
    logic signed 	[15:0] 	arg_b;
	logic					arg_a_parity;
	logic					arg_b_parity;
    logic signed 	[31:0] 	result;
    logic 					result_parity;
	logic					arg_parity_error;
} data_packet_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

	protected virtual 	mult_bfm 			bfm;
	protected 			test_result_t   	test_result = TEST_PASSED;

	protected 			data_packet_t		sb_data_q   [$];

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

protected function logic [31:0] get_expected(
	logic signed [15:0] arg_a,
	logic signed [15:0]	arg_b
    );
    logic signed [31:0] ret;

    ret = arg_a * arg_b;
    return(ret);
endfunction : get_expected

//--------------------------------------

protected function logic get_expected_parity(
	logic signed [31:0] mul_result
	);
	logic 				ret;
	
	ret = ^(mul_result);
	
    return(ret);
endfunction : get_expected_parity

//--------------------------------------

protected function logic get_expected_parity_error(
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
// Scoreboard
//------------------------------------------------------------------------------
protected task store_cmd();
	forever begin : scoreboard_fe_blk
		@(posedge bfm.clk)
	    if(bfm.req == 1'b1)begin
	        sb_data_q.push_front(data_packet_t'({
		        bfm.arg_a, 
		        bfm.arg_b, 
		        bfm.arg_a_parity, 
		        bfm.arg_b_parity, 
		        get_expected(bfm.arg_a, bfm.arg_b), 
		        get_expected_parity(get_expected(bfm.arg_a, bfm.arg_b)), 
		        get_expected_parity_error(bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity)
		    }));
	    end
	end : scoreboard_fe_blk
endtask : store_cmd


protected task process_data_from_dut();
	forever begin : scoreboard_be_blk
		@(negedge bfm.clk)
	    if(bfm.result_rdy == 1) begin : verify_result
	        data_packet_t dp;
	
	        dp = sb_data_q.pop_back();
	
	    	CHK_ARG_PARITY_ERROR: assert(bfm.arg_parity_error === dp.arg_parity_error) begin
	           `ifdef DEBUG
			        $display("%0t Parity_ERR_Test passed", $time);
		    	`endif
	        end
	        else begin
	            test_result = TEST_FAILED;
	            $error("%0t Parity_ERR_Test FAILED \nExpected: %h  received: %h", $time, dp.arg_parity_error, bfm.arg_parity_error);
	        end
	        
	        if(dp.arg_parity_error == 0)begin
		        CHK_RESULT: assert(bfm.result === dp.result) begin // && result_parity === dp.result_parity
		           `ifdef DEBUG
		            $display("%0t MUL_Test passed for A=%0h B=%0h P_A=%0b P_B=%0b", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity);
		           `endif
		        end
		        else begin
		            test_result = TEST_FAILED;
		            $error("%0t MUL_Test FAILED for A=%0h B=%0h P_A=%0b P_B=%0b \nExpected: %h  received: %h", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity, dp.result, bfm.result);
		        end
	        
		        CHK_RESULT_PARITY: assert(bfm.result_parity === dp.result_parity) begin 
		           `ifdef DEBUG
		            $display("%0t Parity_Test passed for A=%0h B=%0h P_A=%0b P_B=%0b", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity);
		           `endif
		        end
		        else begin
		            test_result = TEST_FAILED;
		            $error("%0t Parity_Test FAILED for A=%0h B=%0h P_A=%0b P_B=%0b \nExpected: %h  received: %h", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity, dp.result, bfm.result);
		        end
		    end
	    end
	end : scoreboard_be_blk
endtask : process_data_from_dut

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase
    
//------------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        fork
            store_cmd();
            process_data_from_dut();
        join_none
    endtask : run_phase
//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

protected function void print_test_result (test_result_t r);
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

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(test_result);
    endfunction : report_phase

endclass : scoreboard
