module mult_tpgen_module(mult_bfm bfm);
import mult_pkg::*;

//---------------------------------
// Random data generation functions
//---------------------------------
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
//------------------------------------------------------------------------------
// get_input_parity - CAN RETURN WRONG VALUE FOR TESTS
//------------------------------------------------------------------------------
	function logic [3:0] check_parity(
		bit signed [15:0] arg_a,
		bit signed [15:0] arg_b
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
	
//------------------------------------------------------------------------------
initial begin
	bit					reset_n;
	bit signed 	[15:0] 	ia;
	bit               	iap;
	bit signed 	[15:0] 	ib;
	bit               	ibp;
	bit					erra;
	bit					errb;
	
//	logic signed 	[31:0] 	result;
//	logic               	result_parity;

    bfm.reset();
    repeat (1000) begin : random_loop
        ia = get_data();
        ib = get_data();
	    {iap, ibp, erra, errb} = check_parity(ia,ib);
        bfm.send_data(reset_n, ia, iap, ib, ibp, erra, errb);
	    bfm.wait_ready();	// wait until result is ready
    end : random_loop
    
    // reset until DUT finish processing data
    bfm.send_data(reset_n, ia, iap, ib, ibp, erra, errb);
    bfm.reset();
end // initial begin

endmodule : mult_tpgen_module