class tpgen;

protected virtual mult_bfm bfm;

function new (virtual mult_bfm b);
	bfm = b;
endfunction : new

//---------------------------------
// Random data generation functions
//---------------------------------

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

//------------------------

protected function logic err_flag(
	logic signed [15:0] arg,
	logic 				arg_parity);
	bit flag;
	
	if(arg_parity === ^arg)
		flag = 1'b0;
	else
		flag = 1'b1;
endfunction : err_flag

//------------------------

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

task execute();
	logic signed 	[15:0] 	ia;
	logic               	iap;
	logic signed 	[15:0] 	ib;        
	logic               	ibp;
	bit 					erra;
	bit    					errb;
	logic signed 	[31:0] 	result;
	logic               	result_parity;

    bfm.reset();
    repeat (1000) begin : random_loop
        ia = get_data();
        ib = get_data();
	    {iap, ibp, erra, errb} = check_parity(ia,ib);
	    //erra = err_flag(ia, iap);
	    //errb = err_flag(ib, ibp);
        bfm.send_data(ia, iap, ib, ibp, erra, errb);
	    bfm.wait_ready();	// wait until result is ready
    end : random_loop
    
    // reset until DUT finish processing data
    bfm.send_data(ia, iap, ib, ibp, erra, errb);
    bfm.reset();
    
    
endtask

endclass : tpgen

