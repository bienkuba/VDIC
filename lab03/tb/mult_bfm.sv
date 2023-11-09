interface mult_bfm;

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

bit						err_flag_a;
bit						err_flag_b;

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


//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset();
    `ifdef DEBUG
    $display("%0t DEBUG: reset", $time);
    `endif
    req   = 1'b0;
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset

//------------------------------------------------------------------------------
// send data
//------------------------------------------------------------------------------

task send_data(
	logic signed	[15:0]	ia,
	logic					iap,
	logic signed	[15:0]	ib,
	logic					ibp,
	bit 					erra,
	bit 					errb
	);
	
	arg_a = ia;
	arg_b = ib;
	arg_a_parity = iap;
	arg_b_parity = ibp;
	err_flag_a = erra;
	err_flag_b = errb;

endtask : send_data

task wait_ready();

	req = 1'b1;
		
	wait(ack);
	req = 1'b0;
	wait(result_rdy);

endtask : wait_ready

endinterface : mult_bfm
	
	
	
	
	
	
	
