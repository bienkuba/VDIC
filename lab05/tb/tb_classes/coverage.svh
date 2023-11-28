class coverage extends uvm_component;
	`uvm_component_utils(coverage)
	
	protected virtual mult_bfm bfm;
	
	protected logic signed	[15:0]	arg_a;
	protected logic					arg_a_parity;
	protected logic signed	[15:0]	arg_b;
	protected logic					arg_b_parity;
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
// constructor
//------------------------------------------------------------------------------

function new (string name, uvm_component parent);
    super.new(name, parent);
    corner_values 	= new();
    Parity_error 	= new();
endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
	    forever begin : sample_cov
	        @(negedge bfm.clk);
		    
	    	arg_a = bfm.arg_a;
	    	arg_b = bfm.arg_b;
	    	arg_a_parity = bfm.arg_a_parity;
	    	arg_b_parity = bfm.arg_b_parity;
	        err_flag_a = bfm.err_flag_a;
	        err_flag_b = bfm.err_flag_b;
	
            corner_values.sample();
	        Parity_error.sample();
            
            /* #1step delay is necessary before checking for the coverage
             * as the .sample methods run in parallel threads
             */
//            #1step; 
//            if($get_coverage() == 100) break; //disable, if needed
	            
	            // you can print the coverage after each sample
				//$strobe("%0t coverage: %.4g\%",$time, $get_coverage());
	    end : sample_cov
    endtask : run_phase

endclass : coverage

