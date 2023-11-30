interface mult_bfm;
	import mult_pkg::*;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

	bit                 clk;
	bit                 rst_n;
	bit signed  [15:0]  arg_a;
	bit                 arg_a_parity;
	bit signed  [15:0]  arg_b;
	bit                 arg_b_parity;
	bit                 req;

	logic                   ack;
	logic signed    [31:0]  result;
	logic                   result_parity;
	logic                   result_rdy;
	logic                   arg_parity_error;

	bit                     err_flag_a;
	bit                     err_flag_b;
	command_monitor command_monitor_h;
	result_monitor result_monitor_h;

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

	task wait_ready();
		wait(result_rdy);

	endtask : wait_ready

//------------------------------------------------------------------------------
// send data
//------------------------------------------------------------------------------

	task send_data(
			bit signed    [15:0]  ia,
			bit                   iap,
			bit signed    [15:0]  ib,
			bit                   ibp,
			bit                     erra,
			bit                     errb,
			bit                   reset_n
		);
		
		@(negedge clk);
		
		arg_a = ia;
		arg_b = ib;
		arg_a_parity = iap;
		arg_b_parity = ibp;
		err_flag_a = erra;
		err_flag_b = errb;
		rst_n = reset_n;

		
		if(rst_n == 1)begin
			req = 1'b1;
			
			@(posedge ack);
			@(negedge clk);
			req = 1'b0;
		end

//  wait(result_rdy);

	endtask : send_data

//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------
	bit prev=0;
	always @(posedge clk) begin
//    static bit in_command = 0;
		command_s command;
		if (req&&prev==0) begin : start_high
			command.arg_a           = arg_a;
			command.arg_a_parity    = arg_a_parity;
			command.arg_b           = arg_b;
			command.arg_b_parity    = arg_b_parity;
			command.err_flag_a      = err_flag_a;
			command.err_flag_b      = err_flag_b;
			command.rst_n           = rst_n;
			command_monitor_h.write_to_monitor(command);
		end : start_high
		prev = req;
	end

	always @(negedge rst_n) begin
		command_s command;
		command.rst_n = 0;
		if (command_monitor_h != null) //guard against VCS time 0 negedge
			command_monitor_h.write_to_monitor(command);
	end

//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------

	initial begin : result_monitor_thread
		result_s r;
		forever begin
			@(negedge clk) ;
			if (result_rdy)begin
				r.result = result;
				r.result_parity = result_parity;
				r.arg_parity_error = arg_parity_error;
				result_monitor_h.write_to_monitor(r);

			end
		end
	end : result_monitor_thread

endinterface : mult_bfm
