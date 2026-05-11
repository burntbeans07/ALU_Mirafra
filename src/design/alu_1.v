`default_nettype none
module ALU_design1 #(parameter WIDTH = 8,parameter CMD_W = 4)(
    input  wire CLK,RST,CE,MODE,
    input  wire [CMD_W-1:0]CMD,
    input  wire [1:0]INP_VALID,
    input  wire [WIDTH-1:0]OPA,OPB,
    input  wire CIN,

    output reg [2*WIDTH-1:0]RES,
    output reg COUT,OFLOW,G,L,E,ERR);


reg [WIDTH-1:0] A_reg, B_reg;
reg [CMD_W-1:0] CMD_reg;
reg MODE_reg,CIN_reg;
reg [2*WIDTH-1:0]mul_result;
reg mul_busy;
wire is_mul = MODE_reg && (CMD_reg==4'd9 || CMD_reg==4'd10);

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        A_reg <= 0;
        B_reg <= 0;
        CMD_reg <= 0;
        MODE_reg <= 0;
        CIN_reg <= 0;
        ERR <= 0;
    end
    else if (CE) begin
        ERR <= 0;
        if (INP_VALID == 2'b00)
            ERR <= 1; 
        else if (MODE && ((CMD <= 4'd3) || (CMD >= 4'd8 && CMD <= 4'd12)) && INP_VALID != 2'b11)
            ERR <= 1;
        else if (!MODE && (CMD <= 4'd5 || CMD == 4'd12 || CMD == 4'd13)  && INP_VALID != 2'b11)
            ERR <= 1;
        else if(!MODE && (CMD == 4'd12 || CMD == 4'd13) && OPB[WIDTH-1:$clog2(WIDTH)+1])begin
            ERR<=1;
        end
        else if((MODE && CMD>12) || (!MODE && CMD>13))
            ERR<=1;   
        else if (!mul_busy) begin
            A_reg <= OPA;
            B_reg <= OPB;
            CMD_reg <= CMD;
            MODE_reg <= MODE;
            CIN_reg <= CIN;
            
        end
    end
end

reg [2*WIDTH-1:0] result_comb;
reg cout_temp,oflow_temp,g_temp,l_temp,e_temp;

always @(*) begin
    result_comb = 0;
    cout_temp=0;
    oflow_temp=0;
    g_temp=0;
    l_temp=0;
    e_temp=0;

    if (MODE_reg) begin
        case (CMD_reg)
        
        4'd0: begin
            result_comb = A_reg + B_reg;
            cout_temp = result_comb[WIDTH];
        end

        4'd1: begin
            result_comb = A_reg - B_reg;
            oflow_temp= (B_reg>A_reg);  
        end
        
        4'd2: begin 
            result_comb = A_reg + B_reg + CIN_reg;
            cout_temp = result_comb[WIDTH];
        end
        
        4'd3: begin
            result_comb = A_reg - B_reg - CIN_reg;
            oflow_temp= (B_reg+CIN_reg>A_reg);  
        end
        
        4'd4: result_comb = {{WIDTH{1'b0}},A_reg + 1};   
        4'd5: result_comb = {{WIDTH{1'b0}},A_reg - 1};   
        4'd6: result_comb = {{WIDTH{1'b0}},B_reg + 1};  
        4'd7: result_comb = {{WIDTH{1'b0}},B_reg - 1};
        
        4'd8: begin 
        result_comb = 0;
        g_temp = (A_reg > B_reg);
        e_temp = (A_reg == B_reg);
        l_temp = (A_reg < B_reg);
        end  
        
        4'd9:  result_comb = (A_reg+1) * (B_reg+1);
        4'd10: result_comb = (A_reg << 1) * B_reg;

        4'd11: begin
            result_comb = $signed(A_reg) + $signed(B_reg);
            oflow_temp = (A_reg[WIDTH-1] == B_reg[WIDTH-1]) && (result_comb[WIDTH-1] != A_reg[WIDTH-1]);
            g_temp = ($signed(A_reg) > $signed(B_reg));
            l_temp = ($signed(A_reg) < $signed(B_reg));
            e_temp = ($signed(A_reg) == $signed(B_reg));
        end

        4'd12: begin
            result_comb = $signed(A_reg) - $signed(B_reg);
            oflow_temp = (A_reg[WIDTH-1] != B_reg[WIDTH-1]) && (result_comb[WIDTH-1] != A_reg[WIDTH-1]);
            g_temp = ($signed(A_reg) > $signed(B_reg));
            l_temp = ($signed(A_reg) < $signed(B_reg));
            e_temp = ($signed(A_reg) == $signed(B_reg));
        end
        
        default: result_comb = 0;
        endcase
    end
    else begin
        case (CMD_reg)

            4'd0: result_comb = {{WIDTH{1'b0}}, A_reg & B_reg};
            4'd1: result_comb = {{WIDTH{1'b0}}, A_reg | B_reg};
            4'd2: result_comb = {{WIDTH{1'b0}}, A_reg ^ B_reg};
            4'd3: result_comb = {{WIDTH{1'b0}}, ~(A_reg & B_reg)};
            4'd4: result_comb = {{WIDTH{1'b0}}, ~(A_reg | B_reg)};
            4'd5: result_comb = {{WIDTH{1'b0}}, ~(A_reg ^ B_reg)};
            
            4'd6: result_comb = {{WIDTH{1'b0}}, ~A_reg};
            4'd7: result_comb = {{WIDTH{1'b0}}, ~B_reg};
            
            4'd8:  result_comb = {{WIDTH{1'b0}}, A_reg >> 1};
            4'd9:  result_comb = {{WIDTH{1'b0}}, A_reg << 1};
            4'd10: result_comb = {{WIDTH{1'b0}}, B_reg >> 1};
            4'd11: result_comb = {{WIDTH{1'b0}}, B_reg << 1};
            
            4'd12: begin
                if(B_reg[WIDTH-1:$clog2(WIDTH)+1])
                    result_comb=0;
                else
                    result_comb = {{WIDTH{1'b0}}, (A_reg << B_reg[$clog2(WIDTH)-1:0]) | (A_reg >> (WIDTH-B_reg[$clog2(WIDTH)-1:0]))};
            end
                
            4'd13: begin
                if(B_reg[WIDTH-1:$clog2(WIDTH)+1])
                    result_comb=0;
                else
                    result_comb = {{WIDTH{1'b0}}, (A_reg >> B_reg[$clog2(WIDTH)-1:0]) | (A_reg << (WIDTH-B_reg[$clog2(WIDTH)-1:0]))};
            end
            default: result_comb=0;
        endcase
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        RES <= 0;
        COUT <= 0;
        OFLOW <= 0;
        G <= 0;
        L <= 0;
        E <= 0;
        mul_busy <= 1'd0;
        mul_result<= 0;
    end
    else if (CE) begin
        COUT <= cout_temp;
        OFLOW <= oflow_temp;
        G <= g_temp;
        L <= l_temp;
        E <= e_temp;
        
        if (mul_busy)begin
            mul_busy <= 1'b0;
            RES <= mul_result;
        end
        else if (!mul_busy && is_mul) begin
            mul_result <= result_comb;   
            mul_busy   <= 1'b1;          
        end
        else begin
            RES <= result_comb;
        end
    end
end
endmodule
