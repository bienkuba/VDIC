class scoreboard extends uvm_subscriber #(result_s);
	`uvm_component_utils(scoreboard)
	
//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------

typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------
    uvm_tlm_analysis_fifo #(command_s) cmd_f;

    protected test_result_t test_result = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
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
// build phase
//------------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    
    function void write(result_s t);
	    
        logic signed [31:0] predicted_result;
		logic predicted_result_parity;
	    logic predicted_parity_error;

        command_s cmd;
	    cmd.rst_n = 0;
        cmd.arg_a = 0;
        cmd.arg_b = 0;
	    cmd.arg_a_parity = 0;
	    cmd.arg_b_parity = 0;
	    
        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.rst_n == 0);

        predicted_result = get_expected(cmd.arg_a, cmd.arg_b);
	    predicted_result_parity = get_expected_parity(predicted_result);
	    predicted_parity_error = get_expected_parity_error(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);

        `ifdef DEBUG
        $display("COMMAND MONITOR: arg_a=%0h, arg_b=%0h, arg_a_parity=%0d, arg_b_parity=%0d, err_flag_a=%0d, err_flag_b=%0d", cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity, cmd.err_flag_a, cmd.err_flag_b);
        `endif
	    	CHK_ARG_PARITY_ERROR: assert(t.arg_parity_error == predicted_parity_error) begin
	           `ifdef DEBUG
			        $display("%0t Parity_ERR_Test passed", $time);
		    	`endif
	        end
	        else begin
	            test_result = TEST_FAILED;
	            $error("%0t Parity_ERR_Test FAILED \nExpected: %h  received: %h", $time, predicted_parity_error, t.arg_parity_error);
	        end
	        
	        if(predicted_parity_error == 0)begin
		        CHK_RESULT: assert(t.result == predicted_result) begin
		           `ifdef DEBUG
		            $display("%0t MUL_Test passed for A=%0h B=%0h P_A=%0b P_B=%0b", $time, cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);
		           `endif
		        end
		        else begin
		            test_result = TEST_FAILED;
		            $error("%0t MUL_Test FAILED for A=%0h B=%0h P_A=%0b P_B=%0b \nExpected: %h  received: %h", $time, cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity, predicted_result, t.result);
		        end
	        
		        CHK_RESULT_PARITY: assert(t.result_parity == predicted_result_parity) begin 
		           `ifdef DEBUG
		            $display("%0t Parity_Test passed for A=%0h B=%0h P_A=%0b P_B=%0b", $time, cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);
		           `endif
		        end
		        else begin
		            test_result = TEST_FAILED;
		            $error("%0t Parity_Test FAILED for A=%0h B=%0h P_A=%0b P_B=%0b \nExpected: %h  received: %h", $time, cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity, predicted_result_parity, t.result_parity);
		        end
		    end
    endfunction: write
    
//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(test_result);
    endfunction : report_phase

endclass : scoreboard
