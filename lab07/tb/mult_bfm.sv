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
import mult_pkg::*;
interface mult_bfm;

//------------------------------------------------------------------------------
// DUT connections
//------------------------------------------------------------------------------
bit               		clk;
bit 					rst_n;
bit signed 		[15:0] 	arg_a;
bit               		arg_a_parity;
bit               		err_flag_a;
bit signed 		[15:0] 	arg_b;      
bit               		arg_b_parity;
bit               		err_flag_b;
bit               		req;
	
logic               	ack;
logic signed 	[31:0] 	result;
logic               	result_parity;
logic               	result_rdy;
logic               	arg_parity_error; 
	
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
	req = 1'b0;
	rst_n = 1'b0;
	@(negedge clk);
	rst_n = 1'b1;
endtask: reset


//------------------------------------------------------------------------------
// send_data
//------------------------------------------------------------------------------
task send_data(
	input	bit signed    [15:0]  ia,
	input	bit                   iap,
	input	bit signed    [15:0]  ib,
	input	bit                   ibp,
			bit                   erra,
			bit                   errb,
	input	bit                   reset_n
	);
	
	if(reset_n) begin
		reset();
	end
	else begin
        			arg_a = ia;
			arg_b = ib;
			arg_a_parity = iap;
			arg_b_parity = ibp;
			err_flag_a = erra;
			err_flag_b = errb;
		
//	    req = 1'b1;
//		wait(ack);	// wait until ack == 1
//		req = 1'b0;
//		wait(result_rdy);
		
		if(rst_n == 1)begin
			req = 1'b1;

			@(posedge ack);
			@(negedge clk);
			req = 1'b0;
			wait(result_rdy);
		end
	enendndtask : send_data


//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------
always @(posedge clk) begin
    if (req) begin
        command_monitor_h.write_to_monitor(arg_a, arg_b, arg_a_parity, arg_b_parity, err_flag_a, err_flag_b, rst_n);
    end
end

always @(negedge rst_n) begin : rst_monitor
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(arg_a, arg_b, arg_a_parity, arg_b_parity, err_flag_a, err_flag_b, 0);
end : rst_monitor

//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------
initial begin : result_monitor_thread
    forever begin
        @(posedge clk) ;
        if (result_rdy) begin
            result_monitor_h.write_to_monitor(result,result_parity, arg_parity_error);
	    end
    end
end : result_monitor_thread


endinterface : mult_bfm