module stimulus ();

   logic  clock;
   logic 	we3;
   logic [4:0]	ra1;
   logic [4:0]	ra2;
   logic [4:0]	wa3;
   logic [31:0] wd3;
   
   logic [31:0] rd1;
   logic [31:0] rd2;
   
   integer handle3;
   integer desc3;
   
   // Instantiate DUT
   regfile dut (clock, we3, ra1, ra2, wa3, wd3, rd1, rd2);

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
	#5 $fdisplay(desc3, "%b %b %b %b %b %b %b", 
		     we3, ra1, ra2, wa3, wd3, rd1, rd2);
     end   
   
   initial 
     begin  	 
	#1 we3 = 1'b0;
     #0 ra1 = 5'b0;
     #0 ra2 = 5'b0;
	#0 wa3 = 5'b0;
     
	#20 we3 = 1'b1;
     #10 wa3 = 5'b00111;
	#10 wd3 = $urandom;
	
	#10 ra1 = 5'b00111;
	#10 ra2 = 5'b00111;
	#20 ra1 = 5'b0;
	#0  ra2 = 5'b0;

     #10 wa3 = 5'b0;
     #0  wd3 = $urandom;

     #10 we3 = 1'b0;
     #0  ra1 = 5'b00101;
     #0  ra2 = 5'b00101;
     #0  wa3 = 5'b00101;
     #0  wd3 = $urandom;

     #20 we3 = 1'b1;
     #0  ra1 = 5'b10010;
     #10 ra2 = 5'b01101;
     #0  wa3 = 5'b01101;
     #10 wd3 = $urandom;

     #5  wd3 = $urandom;
     #10 wa3 = 5'b10010;
     

     #10 we3 = 1'b0;
     #30 ra1 = 5'b0;
     #0  ra2 = 5'b0;
     #0  wa3 = 5'b0;



     end

endmodule // stimulus


