`timescale 1ns / 1ps

module clock(
    input reset, //reset button resets clock to midnight, or 00:00:00
    input clock, //100 MHz clock from FPGA hardware
    output reg [7:0] AN, //Nexys A7 has 8 common anode 7 Segment displays. they are inverted, so if AN[n] is 0 the nth ssd is on, and off if 1
    output reg [6:0] ssd, //ssd segments. decimal point not used in this project
    output [2:0] LED, //test outputs for SSD select register
    output kilo //test output for 1 kHz clock
    );   
    
    reg [3:0] h1, h2, m1, m2, s1, s2; //2 hour digits from 1 to 2 and 1 to 9, minutes from 1 to 9, seconds from 1 to 9
    reg [2:0] select; //selects which of the 8 7 segments (representing one of the digits is showing at a given time)
    
    //Clock divider #1 - 1 Hz. Divides 1 MHz. triggers once every 100 million pulses, essentially converting 100 MHz to 1 Hz
    reg [27:0] count_reg = 0; //
    reg out_1Hz = 0;
    always @(posedge clock) begin
     begin
        if (count_reg < 10000000) 
        begin
            count_reg <= count_reg + 1;
        end 
        else begin
            count_reg <= 0;
            out_1Hz <= ~out_1Hz;
            end	
        end
    end
    
    //1 khz clock divider same as above, just divides by 1000 less to create a 1 khz signal
    reg [16:0] count_reg2 = 0;
    reg out_1kHz = 0;
    always @(posedge clock) begin
     begin
        if (count_reg2 < 100000) 
        begin
            count_reg2 <= count_reg2 + 1;
        end 
        else begin
            count_reg2 <= 0;
            out_1kHz <= ~out_1kHz;
            end	
        end
    end

//core program logic. if reset, go to 0. otherwise, increment by 1s. as digits hit their max, adjust later digits
always@(posedge out_1Hz or posedge reset)
if(reset)
    begin
        h1 <= 0;
        h2 <= 0;
        m1 <= 0;
        m2 <= 0;
        s1 <= 0;
        s2 <= 0; 
    end
else
    begin
    if(s2 >= 9)
        begin
            s2 <= 0;
            if(s1 >= 5)
                begin
                    s1 <= 0;
                    if(m2 >= 9)
                        begin
                            m2 <= 0;
                            if(m1 >= 5)
                                begin
                                    m1 <= 0;
                                    if(h2 >= 9 && h1 < 2)
                                        begin
                                            h2 <= 0;
                                            h1 <= h1 + 1;
                                        end
                                    else if(h2 >= 4 && h1 >= 2)
                                        begin
                                            h2 <= 0;
                                            h1 <= 0;
                                        end
                                    else
                                        h2 <= h2 + 1;        
                                end
                            else
                                m1 <= m1 + 1;    
                        end
                    else
                        m2 <= m2 + 1;
                end
            else
                s1 <= s1 + 1; 
        end
    else
        s2 <= s2 + 1;    
    end
      
reg [3:0]  digit; //digit displayed on SSD
    
    always@(posedge out_1kHz) //change which ssd is used @1khz pulse as well as which digit is displayed
begin 
if (reset)
select <= 0;
else
select <= select + 1;
end

    always@(*) //state machine selecting digit value and ssd display when select changes @1khz
case(select)
3'b000:
begin
digit = s2;
AN = 8'b11111110;
end

3'b001:
begin
digit = s1;
AN = 8'b11111101;
end

3'b010:
begin
digit = m2;
AN = 8'b11111011;
end

3'b011:
begin
digit = m1;
AN = 8'b11110111;
end

3'b100:
begin
digit = h2;
AN = 8'b11101111;
end

3'b101:
begin
digit = h1;
AN = 8'b11011111;
end

3'b110:
begin
digit = 0;
AN = 8'b11111111;
end

3'b111:
begin
digit = 0;
AN = 8'b11111111;
end
endcase

 //displaying digit on screen
    always @(*)
    case (digit)
      0: ssd <= 7'b0000001;
      1: ssd <= 7'b1001111;
      2: ssd <= 7'b0010010;
      3: ssd <= 7'b0000110;
      4: ssd <= 7'b1001100;
      5: ssd <= 7'b0100100;
      6: ssd <= 7'b0100000;
      7: ssd <= 7'b0001111;
      8: ssd <= 7'b0000000;
      9: ssd <= 7'b0000100;
      10: ssd <= 7'b0001000;
      11: ssd <= 7'b1100000;
      12: ssd <= 7'b0110001;
      13: ssd <= 7'b1000010;
      14: ssd <= 7'b0110000;
      15: ssd <= 7'b0111000;
endcase   

assign LED = select;
assign kilo = out_1kHz;
endmodule
