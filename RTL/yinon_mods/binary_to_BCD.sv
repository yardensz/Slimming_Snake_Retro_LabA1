module binary_to_BCD(
	input logic clk, resetN,
	input logic [15:0] in_num,
	
	output logic [19:0] out_num);
	
	


	logic [5: 0] count;
	logic [35: 0] tmp_num;
	
	always_ff@(posedge clk or negedge resetN)
		begin	
			if(!resetN) begin
				count <=	0;
				out_num <= 0;
				end
				
			else begin
			
					if (count == 6'd32) //loop
						begin
							out_num <= tmp_num[35:16];
							count <= 0;
							tmp_num <=  {20'h00000 ,in_num};
						end
					else
						begin //DABBLE:
						if(count[0] == 0) 
							begin
									for (int i = 0; i < 5; i++)
										begin
											if (tmp_num[16 + i*4 +: 4] > 4'h4) //+: means you start at 16 +i and than look at 4 bits
												begin
													tmp_num[16 + i*4 +: 4] <= tmp_num[16 + i*4 +: 4] + 4'h3;
												end
										end//for
							end// even
						else 		//DOUBLE
							begin
									tmp_num <= tmp_num << 1;					
							end
							
							count <= count +1;
							
						end //loop
				
			end // resetN else
		end// alwaysff
	
	
	
	
	endmodule
	
	