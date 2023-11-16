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
virtual class shape_c;
   protected string name;
   protected real points[$][0:1];

   function new(string n, real point_n[$][0:1]);
      name = n;
	  points = points_n; 
   endfunction : new

   function real get_points();
      return points;
   endfunction : get_points

   function string get_name();
      return name;
   endfunction : get_name

   pure virtual function void get_area();

endclass : shape_c

class circle_c extends shape_c;

   function new(string n, points[$][0:1]);
      super.new(n, points);
   endfunction : new

   function real get_area();
      $display ("Area is: ???");  //TO DO-----------------------------------
   endfunction : get_area
   
   function void print();
      $display ("This is: %0s", get_name());
	  foreach (points[$][0:1])
		  $display("%0s", get_points())
      $display ("Area is: %0s", get_area());
   endfunction : get_area  
   
endclass : circle_c

class triangle_c extends shape_c;

   function new(string n, points[$][0:1]);
      super.new(n, points);
   endfunction : new

   function real get_area();
      $display ("Area is: ???");  //TO DO-----------------------------------
   endfunction : get_area
   
   function void print();
      $display ("This is: %0s", get_name());
	  foreach (points[$])
		  $display("%0s", get_points())
      $display ("Area is: %0s", get_area());
   endfunction : get_area  
   
endclass : triangle_c

class rectangle_c extends shape_c;

   function new(string n, points[$][0:1]);
      super.new(n, points);
   endfunction : new

   function real get_area();
      $display ("Area is: ???");  //TO DO-----------------------------------
   endfunction : get_area
   
   function void print();
      $display ("This is: %0s", get_name());
	  foreach (points[$])
		  $display("%0s", get_points())
      $display ("Area is: %0s", get_area());
   endfunction : get_area  
   
endclass : rectangle_c

class polygon_c extends shape_c;

   function new(string n, points[$][0:1]);
      super.new(n, points);
   endfunction : new

   function real get_area();
      $display ("Area is: can not be calculated for generic polygon");
   endfunction : get_area
   
   function void print();
      $display ("This is: %0s", get_name());
	  foreach (points[$])
		  $display("%0s", get_points())
      $display ("Area is: %0s", get_area());
   endfunction : print  
   
endclass : polygon_c

class shape_factory;

   	static function shape_c make_shape(string shape, real points_f[$][0:1]);

	   	circle_c circle_h;
	   	triangle_c triangle_h;
	   	rectangle_c rectangle_h;
	   	polygon_c polygon_h;
	   	
      case (shape)
        
        "circle" : begin
           circle_h = new(shape, points_f);
           return circle_h;
        end

        "triagle" : begin
           triangle_h = new(shape, points_f);
           return triangle_h;
        end
        
        "rectangle" : begin
           rectangle_h = new(shape, points_f);
           return rectangle_h;
        end
        
        "polygon" : begin
           polygon_h = new(shape, points_f);
           return polygon_h;
        end
        
        default : begin
           $fatal (1, {"Not a shape"});
        end
      endcase 
      
   	endfunction : make_shape
   
endclass : shape_factory



class shape_reporter #(type T=shape_c);

   	protected static T storage[$];

   	static function void store_shape(T shape);
	   	storage.push_back(shape);
   	endfunction : store_shape

   	static function void report_shapes();
      	foreach (storage[i])
	      	storage[i].print();
   	endfunction : report_shapes

endclass : shape_reporter


module top;

   	initial begin
	   	
	   	shape_c shape_h;
	   	circle_c circle_h;
	   	triangle_c triangle_h;
	   	rectangle_c rectangle_h;
	   	polygon_c polygon_h;
	   	
	   	bit cast_ok;
	      
	    shape_h = shape_factory::make_shape("rectangle", );
	    shape_h.make_shape();
	
//	    cast_ok = $cast(lion_h, animal_h);
//	    if ( ! cast_ok) 
//	    	$fatal(1, "Failed to cast animal_h to lion_h");
//	     
//	    if (lion_h.thorn_in_paw) $display("He looks angry!");
//	    animal_cage#(lion)::cage_animal(lion_h);
//	      
//	    if (!$cast(lion_h, animal_factory::make_animal("lion", 2, "Simba")))
//	        $fatal(1, "Failed to cast animal from factory to lion_h");
//	      
//	    animal_cage#(lion)::cage_animal(lion_h);
//	      
//	    if(!$cast(chicken_h ,animal_factory::make_animal("chicken", 1, "Clucker")))
//	        $fatal(1, "Failed to cast animal factory result to chicken_h");
//	      
//	    animal_cage #(chicken)::cage_animal(chicken_h);
//	
//	    if(!$cast(chicken_h, animal_factory::make_animal("chicken", 1, "Boomer")))
//	        $fatal(1, "Failed to cast animal factory result to chicken_h");
//	
//	    animal_cage #(chicken)::cage_animal(chicken_h);
//	
//	    $display("-- Lions --");
//	    animal_cage #(lion)::list_animals();
//	    $display("-- Chickens --");
//	    animal_cage #(chicken)::list_animals();
	end

endmodule : top




