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
class add_tpgen extends random_tpgen;
    `uvm_component_utils(add_tpgen)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// functions
//------------------------------------------------------------------------------

protected function logic signed [15:0] get_data();

    bit zero_ones;
    zero_ones = 1'($random);

    if (zero_ones == 1'b1)
        return 16'sh8000;
    else
        return 16'sh7FFF;
endfunction : get_data


endclass : add_tpgen
