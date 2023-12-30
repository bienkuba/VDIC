class tpgen extends uvm_component;
	`uvm_component_utils (tpgen)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

    uvm_put_port #(command_transaction) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase
	
	
	
protected function logic [3:0] get_parity(
		logic signed [15:0] arg_a,
		logic signed [15:0] arg_b
		);
		bit  zero_ones;
		bit  zero_ones_2;
		bit flag_arg_a_parity;
		bit flag_arg_b_parity;
		logic arg_a_parity;
		logic arg_b_parity;

    	zero_ones = 1'($random);
		zero_ones_2 = 1'($random);
	
    	if (zero_ones == 1'b1)begin
	    	arg_a_parity=~^arg_a;
    		flag_arg_a_parity =1'b1;
		end
    	else if (zero_ones == 1'b0) begin
        	arg_a_parity=^arg_a;
	    	flag_arg_a_parity=1'b0;
		end
    	if (zero_ones_2 == 1'b1) begin
	    	arg_b_parity=~^arg_a;
    		flag_arg_b_parity =1'b1;
		end
    	else if (zero_ones_2 == 1'b0) begin
        	arg_b_parity=^arg_b;
	    	flag_arg_b_parity=1'b0;
    	end
    	return {arg_a_parity, arg_b_parity, flag_arg_a_parity,flag_arg_b_parity}; 
   
    endfunction : get_parity
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		command_transaction command;
	
		phase.raise_objection(this);
		command = new("command");
		command.rst_n = 1;
        command_port.put(command);
		
		command = command_transaction::type_id::create("command");
	    repeat (50) begin
            assert(command.randomize());
            {command.arg_a_parity, command.arg_b_parity, command.err_flag_a, command.err_flag_b} = get_parity(command.arg_a, command.arg_b); 
            command_port.put(command);
	    end
	    
	    command = new("command");
	    command.rst_n = 1;
        command_port.put(command);
	    command_port.put(command);	
	    
//	    #500;
	    phase.drop_objection(this);
	endtask : run_phase
	
endclass : tpgen