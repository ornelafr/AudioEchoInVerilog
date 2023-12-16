/*
 Fernando Romero Ornelas, Matthew William Page (2023)
*/

module Echo(input clk,
	input rst,
	input en,
	input process_en,
	input Play_en,
	output reg rec_done,
	output reg process_done,
	output reg play_done,
	input AUD_ADCDAT,
	output reg AUD_ADCDAT_Out
	);
// Memory variable instantiation
	reg write_normal;
	reg write_echo;
	reg [6:0] addy_normal;
	reg [6:0] addy_echo_write;
	reg [6:0] addy_echo_read;
	reg [255:0] AUD_Data_normal;
	reg [255:0] AUD_Data_echo;
	wire [255:0] AUD_Data_Fetch_normal;
	wire [255:0] AUD_Data_Fetch_echo;
	
// FSM variable instantiation
	reg [4:0] S;
	reg [4:0] NS;
	
// Counter variable instantiations
	reg [6:0] j;
	reg [8:0] i;
	reg [16:0] t;
	reg [4:0] k;
	reg w;
/*
module AUD_Mem (
	address,
	clock,
	data,
	wren,
	q);
*/

/*
module AUD_Mem_2 (
	clock,
	data,
	rdaddress,
	wraddress,
	wren,
	q);
*/

// Calling the memory with regs
AUD_Mem DUT_1(addy_normal, clk, AUD_Data_normal, write_normal, AUD_Data_Fetch_normal);
AUD_Mem_2 DUT_2(clk, AUD_Data_echo, addy_echo_read, addy_echo_write, write_echo, AUD_Data_Fetch_echo);


// FSM States 
parameter Start = 5'd0;
parameter Start_Rec = 5'd1;
parameter i_Counter = 5'd2;
parameter Addy_Counter = 5'd3;
parameter Done_Rec = 5'd4;
parameter Process = 5'd5;
parameter Addy_normal = 5'd6;
parameter Addy_echo = 5'd7;
parameter New_mem = 5'd8;
parameter i_Counter_1 = 5'd9;
parameter j_Counter = 5'd10;
parameter k_Counter = 5'd11;
parameter Done_Process = 5'd12;
parameter i_j_rst = 5'd13;
parameter Start_Read = 5'd14;
parameter i_Counter_2 = 5'd15;
parameter Addy_Counter_2 = 5'd16;
parameter Done_Play = 5'd17;
parameter Write_buffer = 5'd18;

always@(posedge clk or negedge rst)
	if(rst == 1'b0)
		S <= Start;
	else
		S <= NS;
		
always@(*)
	case(S)
	Start:
		if(en == 1'b1)
			NS = Start_Rec;
		else
			NS = Start;
	Start_Rec:
		if( t == 16'd800)  // Recording timer
			NS = i_Counter;
		else
			NS = Start_Rec;
	i_Counter:
		if(i < 9'd255)  // Cycling through bits of memory 
			NS = Start_Rec;
		else
			NS = Addy_Counter;
	Addy_Counter:
		if(addy_normal < 7'd122)  //  Cycling through addresses of memory
			NS = Start_Rec;
		else
			NS = Done_Rec;
	Done_Rec:
		if(process_en == 1'b1)
			NS = Process;
		else
			NS = Done_Rec;
	Process: 
		if(k <= 5'd12)  // Echo delay time period for deciding address of reading
			NS = Addy_normal;
		else
			NS = Addy_echo;
	Addy_normal: 
		NS = Write_buffer;
	Addy_echo:
		NS = Write_buffer;
	Write_buffer:
		if(w < 1'd1) // Buffer
			NS = Write_buffer;
		else
			NS = New_mem;
	New_mem:
		NS = i_Counter_1;
	i_Counter_1:
		if(i < 9'd255)  // Cycling through bits of memory for making echo
			NS = Process;
		else
			NS = j_Counter;
	j_Counter: 
		if(k >= 5'd24) // For reseting k
			NS = k_Counter;
		else
			NS = Process;
	k_Counter:
		if(addy_echo_write < 7'd122) // Checking if all addresses have been used
			NS = Process;
		else
			NS = Done_Process;
	Done_Process: 
		if(Play_en == 1'b1)
			NS = i_j_rst;
		else
			NS = Done_Process;
	i_j_rst: 
			NS = Start_Read;
	Start_Read: 
		if (t >= 16'd800)  // Same timer but for playing
			NS = i_Counter_2;
		else
			NS = Start_Read;
	i_Counter_2:
		if(i < 9'd255) // Cycling through bits of memory
			NS = Start_Read;
		else
			NS = Addy_Counter_2;
	Addy_Counter_2:
		if(addy_echo_read < 7'd122) // Checking if all addresses have been used
			NS = Start_Read;
		else
			NS = Done_Play;
	Done_Play:
		if(Play_en == 1'b0)
			NS = Done_Process;
		else
			NS = Done_Play;
	endcase
		
always@(posedge clk or negedge rst)
	if(rst == 1'b0)
	begin  // initial states
		write_normal <= 1'b1;
		write_echo <= 1'b0;
		addy_normal <= 7'd0;
		addy_echo_write <= 7'd0;
		addy_echo_read <= 7'd0;
		i <= 9'd0;
		j <= 7'd0;
		rec_done <= 1'b1;
		process_done <= 1'b1;
		play_done <= 1'b1;
		t <= 16'd0;
		AUD_Data_normal <= 256'd0;
		AUD_Data_echo <= 256'd0;
	end
	else
		case(S)
	Start:
		begin
		end
	Start_Rec:
		begin
		if (t == 16'd800) // When timer is done, record one bit
		begin
			write_normal <= 1'b1;
			AUD_Data_normal[i] <= AUD_ADCDAT; // Recording bit from MIC
		end
		else
			t <= t + 1;
		end
	i_Counter:
		begin
			i <= i + 1;
			t <= 16'd0;
		end
	Addy_Counter:
		begin
			addy_normal <= addy_normal + 1;
			t <= 16'd0;
			i <= 9'd0;
		end
	Done_Rec:
		begin  // Reseting variables for next phase
			rec_done <= 1'b0;
			write_normal <= 1'b0;
			addy_normal <= 7'd0;
			addy_echo_write <= 7'd0;
			addy_echo_read <= 7'd0;
			i <= 9'd0;
			t <= 16'd0;
			k <= 5'd0;
		end
	Process: 
		begin
		end
	Addy_normal: 
		begin
			addy_normal <= addy_echo_write;  // normal recording
		end
	Addy_echo:
		begin
			addy_normal <= addy_echo_write - 7'd12;  // recording previous addresses for a echo effect
		end
	Write_buffer:
		begin
			write_echo <= 1'b1;
			if (w < 1'd1)
				w <= w + 1'd1;
			else
				w <= 1'd0;
		end		
	New_mem:
		begin
			AUD_Data_echo[i] <= AUD_Data_Fetch_normal[i];  // Recording new audio file with echo 
		end
	i_Counter_1:
		begin
			i <= i + 1;
			write_echo <= 1'b0;
		end
	j_Counter: 
		begin
			addy_echo_write <= addy_echo_write + 1;
			k <= k + 1;
			write_echo <= 1'b0;
			i <= 9'd0;
		end
	k_Counter:
		begin
			k <= 5'd0;
		end
	Done_Process: 
		begin  // reseting variables
			process_done <= 1'b0;
			write_echo <= 1'b0;
			t <= 16'd0;
		end
	i_j_rst: 
		begin  // Also reseting variables
			j <= 7'd0;
			i <= 9'd0;
			addy_echo_write <= 7'd0;
			addy_echo_read <= 7'd0;
			addy_normal <= 7'd0;
		end
	Start_Read: 
		begin
			if(t >= 16'd800) // When timer is done, play one bit
			begin
				AUD_ADCDAT_Out <= AUD_Data_Fetch_echo[i]; // Send data to visualizer
			end
			else
				t = t + 1'd1;
		end
	i_Counter_2:
		begin
			i <= i + 1;
			t <= 16'd0;
		end
	Addy_Counter_2:
		begin
			addy_echo_read <= addy_echo_read + 1;
			t <= 16'd0;
			i <= 9'd0;
		end
	Done_Play:
		begin
			play_done <= 1'b0;
			t <= 16'd0;
		end
	endcase

endmodule 