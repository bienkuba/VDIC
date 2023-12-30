class coverage extends uvm_subscriber #(command_transaction);
	`uvm_component_utils(coverage)
	
	
	protected bit signed	[15:0]	arg_a;
	protected bit signed	[15:0]	arg_b;
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
    function void write(command_transaction t);
    	arg_a = t.arg_a;
    	arg_b = t.arg_b;
        err_flag_a = t.err_flag_a;
        err_flag_b = t.err_flag_b;
//$display("%h",arg_a);
        corner_values.sample();
        Parity_error.sample();
    endfunction : write
    
    
endclass : coverage

//class coverage extends uvm_subscriber #(command_transaction);
//    `uvm_component_utils(coverage)
//	
////------------------------------------------------------------------------------
//// local variables
////------------------------------------------------------------------------------
//	protected logic signed 	[15:0] 	arg_a;
//	protected bit               	arg_a_parity;
//	protected logic signed 	[15:0] 	arg_b;        
//	protected bit               	arg_b_parity;
//
////------------------------------------------------------------------------------
//// Coverblock
////------------------------------------------------------------------------------
//	covergroup edge_cases;	// Covergroup checking for min and max arguments of the MULT
//	    option.name = "cg_edge_cases";
//	
//	    a_leg_min_max: coverpoint arg_a {
//	        bins min = {16'sh8000};		// signed int MIN
//	        bins max  = {16'sh7FFF};	// signed int MAX
//	    }
//	    b_leg_min_max: coverpoint arg_b {
//	        bins min = {16'sh8000};		// signed int MIN
//	        bins max  = {16'sh7FFF};	// signed int MAX
//	    }
//	    
//		a_leg: coverpoint arg_a {
//		    bins zeros = {16'sh0000};
//	        bins negative = {[16'sh8001:16'shFFFF]};	// [MIN+1:-1]
//	        bins positive = {[16'sh0001:16'sh7FFE]};	// [1:MAX-1]   
//	    }
//	    b_leg: coverpoint arg_b {
//		    bins zeros = {16'sh0000};
//	        bins negative = {[16'sh8001:16'shFFFF]};	// [MIN+1:-1]
//	        bins positive = {[16'sh0001:16'sh7FFE]};	// [1:MAX-1] 
//	    }
//	
//	    mult_min_max_cases: cross a_leg_min_max, b_leg_min_max {
//	        // min * max
//	        bins min_max = binsof (a_leg_min_max.min) && binsof (b_leg_min_max.max);
//	        // min * min
//	        bins min_min = binsof (a_leg_min_max.min) && binsof (b_leg_min_max.min);    
//		    // max * max
//	        bins max_max = binsof (a_leg_min_max.max) && binsof (b_leg_min_max.max);  
//	    }
//	    
//	    mult_zero: cross a_leg, b_leg {
//		    // zero * anything
//	        bins zero_any = binsof (a_leg.zeros) && binsof (b_leg.positive);
//		}
//	    
//	    a_par: coverpoint arg_a_parity {
//		    bins zero = {0};
//		    bins one = {1};
//	    }
//	    b_par: coverpoint arg_b_parity {
//		    bins zero = {0};
//		    bins one = {1};
//	    }  
//	    
//	    a_parity_edge_cases: cross a_leg_min_max, a_par {
//		    bins max_par_correct = binsof(a_leg_min_max.max) && binsof(a_par.one);	// checks MAX with correct parity (par = 1)
//			bins max_par_wrong = binsof(a_leg_min_max.max) && binsof(a_par.zero);	// checks MAX with wrong parity (par = 0)
//	    }
//	    
//	    b_parity_edge_cases: cross b_leg_min_max, b_par {
//		    bins max_par_correct = binsof(b_leg_min_max.max) && binsof(b_par.one);	// checks MAX with correct parity (par = 1)
//			bins max_par_wrong = binsof(b_leg_min_max.max) && binsof(b_par.zero);	// checks MAX with wrong parity (par = 0)
//	    }
//	    
//	    a_parity_zero_cases: cross a_leg, a_par {
//		    bins zero_par_correct = binsof(a_leg.zeros) && binsof(a_par.zero);	// checks ZERO with correct parity (par = 0)
//			bins zero_par_wrong = binsof(a_leg.zeros) && binsof(a_par.one);	// checks ZERO with wrong parity (par = 1)
//	    }
//	    
//	    b_parity_zero_cases: cross b_leg, b_par {
//		    bins zero_par_correct = binsof(b_leg.zeros) && binsof(b_par.zero);	// checks ZERO with correct parity (par = 0)
//			bins zero_par_wrong = binsof(b_leg.zeros) && binsof(b_par.one);	// checks ZERO with wrong parity (par = 1)
//	    }
//	
//	endgroup
//
////------------------------------------------------------------------------------
//// Constructor
////------------------------------------------------------------------------------
//	function new (string name, uvm_component parent);
//        super.new(name, parent);
//        edge_cases = new();
//	endfunction : new
//	
////------------------------------------------------------------------------------
//// subscriber write function
////------------------------------------------------------------------------------
//    function void write(command_transaction t);
//        arg_a = t.arg_a;
//		arg_a_parity = t.arg_a_parity;
//		arg_b = t.arg_b;        
//		arg_b_parity = t.arg_b_parity;
//        edge_cases.sample();
//    endfunction : write
//
//
//endclass : coverage