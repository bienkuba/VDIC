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
//		if (zero_ones == 2'b00)begin
		else begin
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
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		command_transaction command;
	
		phase.raise_objection(this);
		command = new("command");
		command.rst_n = 1;
        command_port.put(command);
		
		command = command_transaction::type_id::create("command");
		 
		        set_print_color(COLOR_BOLD_BLACK_ON_YELLOW);
        `uvm_info("TPGEN", $sformatf("*** Created transaction type: %s",command.get_type_name()), UVM_MEDIUM);
        set_print_color(COLOR_DEFAULT);
		
	    repeat (5000) begin
            assert(command.randomize());
            {command.arg_a_parity, command.arg_b_parity, command.err_flag_a, command.err_flag_b} = check_parity(command.arg_a, command.arg_b); 
            command_port.put(command);
	    end
	    
	    command = new("command");
	    command.rst_n = 1;
        command_port.put(command);
	    
//	    #500;
	    phase.drop_objection(this);
	endtask : run_phase
	
endclass : tpgen