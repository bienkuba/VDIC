class coverage extends uvm_subscriber #(command_s);
	`uvm_component_utils(coverage)
	
	
	protected logic signed	[15:0]	arg_a;
	protected logic signed	[15:0]	arg_b;
	protected bit 					err_flag_a;
	protected bit    				err_flag_b;

//------------------------------------------------------------------------------
// cover groups
//------------------------------------------------------------------------------

covergroup corner_values;

    option.name = "cg_corner_values";


    arg_a_leg: coverpoint arg_a {
        bins min_value 	= {16'sh8000};
        bins neg_value = {[16'sh8001:16'shFFFF]};
//	    bins zeros 		= {'sh0000};
	    bins pos_value = {[16'sh0000:16'sh7FFE]}; //contain zeros case
        bins max_value	= {16'sh7FFF};
    }

    arg_b_leg: coverpoint arg_b {
        bins min_value 	= {16'sh8000};
        bins neg_value = {[16'sh8001:16'shFFFF]};
//	    bins zeros 		= {'sh0000};
	    bins pos_value = {[16'sh0000:16'sh7FFE]}; 
        bins max_value  = {16'sh7FFF};
    }
    
    
    Corner_arg: cross arg_a_leg, arg_b_leg {
	    
	    // Corner values multiplication
	    
	    bins a_max_mul_b_max	= (binsof (arg_a_leg.max_value) && binsof (arg_b_leg.max_value));
	    bins a_max_mul_b_min	= (binsof (arg_a_leg.max_value) && binsof (arg_b_leg.min_value));
	    bins a_min_mul_b_max	= (binsof (arg_a_leg.min_value) && binsof (arg_b_leg.max_value));
	    bins a_min_mul_b_min	= (binsof (arg_a_leg.min_value) && binsof (arg_b_leg.min_value));
	   
    }
    
endgroup

covergroup Parity_error;

    option.name = "cg_parity_error";
   
    err_flag_a_leg: coverpoint err_flag_a {
        bins error 	= {1'b1};
        bins noerr	= {1'b0};
    }

    err_flag_b_leg: coverpoint err_flag_b {
        bins error 	= {1'b1};
        bins noerr	= {1'b0};
    }
	
    Corner_arg: cross err_flag_a_leg, err_flag_b_leg {
        bins a_err_b_err 		= (binsof (err_flag_a_leg.error) && binsof (err_flag_b_leg.error));
        bins a_ok_b_err 		= (binsof (err_flag_a_leg.noerr) && binsof (err_flag_b_leg.error));
        bins a_err_b_ok 		= (binsof (err_flag_a_leg.error) && binsof (err_flag_b_leg.noerr));
        bins a_ok_b_ok 		    = (binsof (err_flag_a_leg.noerr) && binsof (err_flag_b_leg.noerr));
    }    
endgroup


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
	function new (string name, uvm_component parent);
        super.new(name, parent);
	    corner_values 	= new();
	    Parity_error 	= new();
	endfunction : new
	
//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(command_s t);
    	arg_a = t.arg_a;
    	arg_b = t.arg_b;
        err_flag_a = t.err_flag_a;
        err_flag_b = t.err_flag_b;

        corner_values.sample();
        Parity_error.sample();
    endfunction : write


endclass : coverage

