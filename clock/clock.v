`timescale 1ns / 1ps

module clock(
    input reset,
    input clock,
    output reg [7:0] AN,
    output reg [6:0] ssd,
    output [2:0] LED,
    output kilo
    );   
    
    reg [3:0] h1, h2, m1, m2, s1, s2;
    reg [2:0] select;
    
    //Clock divider #1 - 1 Hz. Divides 1 MHz 
    reg [29:0] count_reg = 0;
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
    
    //1 khz clock divider 
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
      
reg [3:0]  digit;

always@(posedge out_1kHz)
begin
if (reset)
select <= 0;
else
select <= select + 1;
end

always@(*)
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

always @(posedge clock)
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
