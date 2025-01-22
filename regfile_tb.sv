module stimulus ();

   logic   clock;
   logic	we3;
   logic	ra1;
   logic	ra2;
   logic	wa3;
   logic	wd3;
   
   logic rd1;
   logic rd2;
   
   integer handle3;
   integer desc3;
   
   // Instantiate DUT
   fsm dut (clock, we3, ra1, ra2, wa3, wd3, rd1, rd2);

   // Setup the clock to toggle every 1 time units 
   initial 
     begin	
	clock = 1'b1;
	forever #5 clock = ~clock;
     end

   initial
     begin
	// Gives output file name
	handle3 = $fopen("regfile_test.out");
	// Tells when to finish simulation
	#500 $finish;		
     end

   always 
     begin
	desc3 = handle3;
	#5 $fdisplay(desc3, "%b %b || %b", 
		     reset, In, Out);
     end   
   
   initial 
     begin  	 
	#0  we3 = 1'b0;
	#0	wd3 = 32'b0;
	#0 	wa3 = 5'b0;
	#10 wd3 = 32'b1;
	#20 we3 = 1'b1;
	#10 wd3 = 32'b0;
	
	#20 rd1 = 32'b0;
	#0  rd2 = 32'b0;
	#10 ra1 = 5'b10110;
	#10 ra2 = 5'b00111;
	#20 ra1 = 5'b0;
	#0  ra2 = 5'b0;
     end

endmodule // stimulus


