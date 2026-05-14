
`timescale 1ns/1ps

module tb_1;

parameter N=8;
parameter W=4;

reg clk,rst,CE,mode,cin;
reg [W-1:0] cmd;
reg [1:0] input_valid;
reg [N-1:0] OPA,OPB;

wire err;
wire [2*N-1:0] res;
wire OFLOW,cout,G,L,E;

alu #(N,W) DUT(
    .clk(clk), .rst(rst), .input_valid(input_valid),
    .mode(mode), .cmd(cmd), .CE(CE),
    .OPA(OPA), .OPB(OPB), .cin(cin),
    .err(err), .res(res), .OFLOW(OFLOW),
    .cout(cout), .G(G), .L(L), .E(E)
);

initial clk=0;
always #5 clk=~clk;

reg [9:0] cycle;
always @(posedge clk or posedge rst)
begin
    if(rst) cycle <= 0;
    else    cycle <= cycle + 1;
end

reg [2*N-1:0] exp_res;
reg exp_err, exp_OFLOW, exp_cout, exp_G, exp_L, exp_E;
reg [2*N-1:0] prev_res;
reg prev_OFLOW, prev_cout, prev_G, prev_L, prev_E;

initial begin
    exp_res=0; exp_err=0; exp_OFLOW=0; exp_cout=0;
    exp_G=0; exp_L=0; exp_E=0;
    prev_res=0; prev_OFLOW=0; prev_cout=0;
    prev_G=0; prev_L=0; prev_E=0;
end

task reference_model;
begin
    if(!CE) begin
    end else if(input_valid==2'b00) begin
        exp_err=1;
    end else if(mode) begin
        prev_res=exp_res; prev_OFLOW=exp_OFLOW; prev_cout=exp_cout;
        prev_G=exp_G; prev_L=exp_L; prev_E=exp_E;
        exp_err=0; exp_OFLOW=0; exp_cout=0;
        exp_G=0; exp_L=0; exp_E=0; exp_res=0;
        case(cmd)
        4'd0: if(input_valid==2'b11) begin
                exp_res=OPA+OPB;
		exp_cout=exp_res[N]
                exp_OFLOW=0; {exp_G,exp_L,exp_E}=0;
              end else exp_err=1;
        4'd1: if(input_valid==2'b11) begin
                exp_res=OPA-OPB; exp_OFLOW=(OPA<OPB);
                {exp_G,exp_L,exp_E,exp_cout}=0;
              end else exp_err=1;
        4'd2: if(input_valid==2'b11) begin
                exp_res=OPA+OPB+cin;
		exp_cout=exp_res[N]
                exp_OFLOW=0; {exp_G,exp_L,exp_E}=0;
              end else exp_err=1;
        4'd3: if(input_valid==2'b11) begin
                exp_res=OPA-OPB-cin;
                exp_OFLOW=({1'b0,OPA}<({1'b0,OPB}+cin));
                {exp_G,exp_L,exp_E,exp_cout}=0;
              end else exp_err=1;
        4'd4: if(input_valid[0]) begin
                exp_res={{N{1'b0}},OPA+1};
                {exp_G,exp_L,exp_E,exp_cout,exp_OFLOW}=0;
              end else exp_err=1;
        4'd5: if(input_valid[0]) begin
                exp_res={{N{1'b0}},OPA-1};
                {exp_G,exp_L,exp_E,exp_cout,exp_OFLOW}=0;
              end else exp_err=1;
        4'd6: if(input_valid[1]) begin
                exp_res={{N{1'b0}},OPB+1};
                {exp_G,exp_L,exp_E,exp_cout,exp_OFLOW}=0;
              end else exp_err=1;
        4'd7: if(input_valid[1]) begin
                exp_res={{N{1'b0}},OPB-1};
                {exp_G,exp_L,exp_E,exp_cout,exp_OFLOW}=0;
              end else exp_err=1;
        4'd8: if(input_valid==2'b11) begin
                exp_G=(OPA>OPB); exp_L=(OPA<OPB); exp_E=(OPA==OPB);
                {exp_res,exp_cout,exp_OFLOW}=0;
              end else exp_err=1;
        4'd9: if(input_valid==2'b11) begin
                exp_res=(OPA+1)*(OPB+1);
                {exp_G,exp_L,exp_E,exp_cout,exp_OFLOW}=0;
              end else exp_err=1;
        4'd10: if(input_valid==2'b11) begin
                exp_res=(OPA<<1)*OPB;
                {exp_G,exp_L,exp_E,exp_cout,exp_OFLOW}=0;
               end else exp_err=1;
        4'd11: if(input_valid==2'b11) begin
                exp_res=$signed(OPA)+$signed(OPB);
                exp_OFLOW=(OPA[N-1]==OPB[N-1])&&(exp_res[N-1]!=OPA[N-1]);
                exp_cout=0;
                exp_G=($signed(OPA)>$signed(OPB));
                exp_L=($signed(OPA)<$signed(OPB));
                exp_E=($signed(OPA)==$signed(OPB));
               end else exp_err=1;
        4'd12: if(input_valid==2'b11) begin
                exp_res=$signed(OPA)-$signed(OPB);
                exp_OFLOW=(OPA[N-1]!=OPB[N-1])&&(exp_res[N-1]!=OPA[N-1]);
                exp_cout=0;
                exp_G=($signed(OPA)>$signed(OPB));
                exp_L=($signed(OPA)<$signed(OPB));
                exp_E=($signed(OPA)==$signed(OPB));
               end else exp_err=1;
        default: exp_err=1;
        endcase
        if(exp_err) begin
            exp_res=prev_res; exp_OFLOW=prev_OFLOW; exp_cout=prev_cout;
            exp_G=prev_G; exp_L=prev_L; exp_E=prev_E;
        end
    end else begin
        prev_res=exp_res; prev_OFLOW=exp_OFLOW; prev_cout=exp_cout;
        prev_G=exp_G; prev_L=exp_L; prev_E=exp_E;
        exp_err=0; exp_OFLOW=0; exp_cout=0;
        exp_G=0; exp_L=0; exp_E=0; exp_res=0;
        case(cmd)
        4'd0:  if(input_valid==2'b11) exp_res=OPA&OPB;            else exp_err=1;
        4'd1:  if(input_valid==2'b11) exp_res=~(OPA&OPB);         else exp_err=1;
        4'd2:  if(input_valid==2'b11) exp_res=OPA|OPB;            else exp_err=1;
        4'd3:  if(input_valid==2'b11) exp_res=~(OPA|OPB);         else exp_err=1;
        4'd4:  if(input_valid==2'b11) exp_res=OPA^OPB;            else exp_err=1;
        4'd5:  if(input_valid==2'b11) exp_res=~(OPA^OPB);         else exp_err=1;
        4'd6:  if(input_valid[0])     exp_res={{N{1'b0}},~OPA};   else exp_err=1;
        4'd7:  if(input_valid[1])     exp_res={{N{1'b0}},~OPB};   else exp_err=1;
        4'd8:  if(input_valid[0])     exp_res={{N{1'b0}},OPA>>1}; else exp_err=1;
        4'd9:  if(input_valid[0])     exp_res={{N{1'b0}},OPA<<1}; else exp_err=1;
        4'd10: if(input_valid[1])     exp_res={{N{1'b0}},OPB>>1}; else exp_err=1;
        4'd11: if(input_valid[1])     exp_res={{N{1'b0}},OPB<<1}; else exp_err=1;
        4'd12: if((input_valid==2'b11)&&(!OPB[N-1:$clog2(N)+1]))
                   exp_res={{N{1'b0}},(OPA<<OPB[$clog2(N)-1:0])|(OPA>>(N-OPB[$clog2(N)-1:0]))};
               else exp_err=1;
        4'd13: if((input_valid==2'b11)&&(!OPB[N-1:$clog2(N)+1]))
                   exp_res={{N{1'b0}},(OPA>>OPB[$clog2(N)-1:0])|(OPA<<(N-OPB[$clog2(N)-1:0]))};
               else exp_err=1;
        default: exp_err=1;
        endcase
        if(exp_err) begin
            exp_res=prev_res; exp_OFLOW=prev_OFLOW; exp_cout=prev_cout;
            exp_G=prev_G; exp_L=prev_L; exp_E=prev_E;
        end
    end
end
endtask

reg [7:0] pass_cnt;
reg [6:0] fail_cnt;

task check_outputs;
	input [9:0] tc;
    begin
        if(res!==exp_res || err!==exp_err || OFLOW!==exp_OFLOW ||
           cout!==exp_cout || G!==exp_G || L!==exp_L || E!==exp_E) begin
            $display("FAIL TC%0d @ cycle%0d | res=%h err=%b OFLOW=%b cout=%b G=%b L=%b E=%b | exp_res=%h exp_err=%b exp_OFLOW=%b exp_cout=%b exp_G=%b exp_L=%b exp_E=%b",
                tc,cycle,res,err,OFLOW,cout,G,L,E,
                exp_res,exp_err,exp_OFLOW,exp_cout,exp_G,exp_L,exp_E);
            fail_cnt=fail_cnt+1;
        end else begin
            $display("PASS TC%0d @ cycle%0d",tc,cycle);
            pass_cnt=pass_cnt+1;
        end
    end
endtask

task apply_and_check;
    input [N-1:0] a,b;
    input         m;
    input [W-1:0] c;
    input [1:0]   iv;
    input         ci;
    input         is_mul;
	input [9:0]  tc;
    begin
        OPA=a; OPB=b; mode=m; cmd=c; input_valid=iv; cin=ci; CE=1;
        reference_model;
        if(is_mul) begin
            @(posedge clk); @(posedge clk); @(posedge clk);
        end else begin
            @(posedge clk); @(posedge clk);
        end
        check_outputs(tc);
    end
endtask


initial begin
    pass_cnt=0; fail_cnt=0;
    rst=1; CE=1; mode=0; cmd=0; cin=0; input_valid=2'b11; OPA=0; OPB=0;
    @(posedge clk); @(posedge clk); rst=0;
    @(posedge clk);

    @(posedge clk); pass_cnt=pass_cnt+1; $display("PASS TC0 clk_toggle");

    rst=1; #1;
    if(res!==0||err!==0||OFLOW!==0||cout!==0||G!==0||L!==0||E!==0)
        begin $display("FAIL TC1 async_rst_idle"); fail_cnt=fail_cnt+1; end
    else begin $display("PASS TC1 async_rst_idle"); pass_cnt=pass_cnt+1; end
    @(posedge clk); rst=0; @(posedge clk);

    OPA=8'h05; OPB=8'h03; mode=1; cmd=4'd0; input_valid=2'b11; CE=1;
    @(posedge clk); rst=1; #1;
    if(res!==0||err!==0||OFLOW!==0||cout!==0||G!==0||L!==0||E!==0)
        begin $display("FAIL TC2 async_rst_active"); fail_cnt=fail_cnt+1; end
    else begin $display("PASS TC2 async_rst_active"); pass_cnt=pass_cnt+1; end
    @(posedge clk); rst=0; @(posedge clk);

    OPA=8'h03; OPB=8'h03; mode=1; cmd=4'd9; input_valid=2'b11; CE=1;
    @(posedge clk); rst=1; #1;
    if(res!==0||err!==0||OFLOW!==0||cout!==0||G!==0||L!==0||E!==0)
        begin $display("FAIL TC3 rst_during_mul"); fail_cnt=fail_cnt+1; end
    else begin $display("PASS TC3 rst_during_mul"); pass_cnt=pass_cnt+1; end
    @(posedge clk); rst=0; @(posedge clk);



    
    apply_and_check(8'h02,8'h01,1,4'd0,2'b11,0,0,64'd4);

    CE=0; reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd5); CE=1;

    apply_and_check(8'h04,8'h02,1,4'd0,2'b11,0,0,64'd6);

    OPA=8'h0A; OPB=8'h05; mode=1; cmd=4'd0; input_valid=2'b11; CE=1;
    reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd7);
    CE=0; reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd7);
    CE=1; reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd7);

    apply_and_check(8'h04,8'h02,1,4'd0,2'b11,0,0,64'd8);
    OPA=8'h04; OPB=8'h04; mode=1; cmd=4'd9; input_valid=2'b11; CE=1;
    @(posedge clk); CE=0;
    reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd8);
    CE=1;

    OPA=0; OPB=0; mode=1; cmd=4'd0; input_valid=2'b00; CE=1;
    reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd9);
    CE=0; reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd9);
    CE=1; input_valid=2'b11; exp_err=0;

    apply_and_check(8'h05,8'h03,1,4'd0, 2'b00,0,0,64'd10);
    apply_and_check(8'h05,8'h03,1,4'd0, 2'b01,0,0,64'd11);
    apply_and_check(8'h00,8'h05,1,4'd4, 2'b10,0,0,64'd12);
    apply_and_check(8'h05,8'h03,1,4'd13,2'b11,0,0,64'd13);
    apply_and_check(8'h05,8'h03,0,4'd14,2'b11,0,0,64'd14);
    apply_and_check(8'hAB,8'hFF,0,4'd12,2'b11,0,0,64'd15);
    apply_and_check(8'hAB,8'hFF,0,4'd13,2'b11,0,0,64'd16);
    apply_and_check(8'h03,8'h02,1,4'd0, 2'b11,0,0,64'd17);

    apply_and_check(8'h03,8'h02,1,4'd0,2'b11,0,0,64'd18);
    OPA=8'h03; OPB=8'h03; mode=1; cmd=4'd9; input_valid=2'b11; CE=1;
    @(posedge clk);
    input_valid=2'b00; reference_model;
    @(posedge clk); @(posedge clk); check_outputs(64'd18);
    input_valid=2'b11; exp_err=0;

    apply_and_check(8'h0F,8'hF0,1,4'd0, 2'b11,0,0,64'd19);
    apply_and_check(8'h0F,8'hF0,0,4'd4, 2'b11,0,0,64'd19);
    apply_and_check(8'hAA,8'h55,0,4'd2, 2'b11,0,0,64'd20);
    apply_and_check(8'hAA,8'h55,1,4'd1, 2'b11,0,0,64'd20);
    apply_and_check(8'h03,8'h02,1,4'd0, 2'b11,0,0,64'd21);
    apply_and_check(8'h03,8'h02,0,4'd0, 2'b11,0,0,64'd21);
    apply_and_check(8'h03,8'h02,1,4'd0, 2'b11,0,0,64'd21);

    apply_and_check(8'h05,8'h03,1,4'd0,2'b11,0,0,64'd22);
    apply_and_check(8'h00,8'h00,1,4'd0,2'b11,0,0,64'd23);
    apply_and_check(8'hFF,8'h01,1,4'd0,2'b11,0,0,64'd24);
    apply_and_check(8'hFF,8'hFF,1,4'd0,2'b11,0,0,64'd25);
    apply_and_check(8'h0A,8'h05,1,4'd2,2'b11,0,0,64'd26);
    apply_and_check(8'h0A,8'h05,1,4'd2,2'b11,1,0,64'd27);
    apply_and_check(8'h01,8'h01,1,4'd0,2'b11,0,0,64'd28);
    apply_and_check(8'h02,8'h02,1,4'd0,2'b11,0,0,64'd28);
    apply_and_check(8'h03,8'h03,1,4'd0,2'b11,0,0,64'd28);

    apply_and_check(8'h0A,8'h03,1,4'd1,2'b11,0,0,64'd29);
    apply_and_check(8'h07,8'h07,1,4'd1,2'b11,0,0,64'd30);
    apply_and_check(8'h03,8'h0A,1,4'd1,2'b11,0,0,64'd31);
    apply_and_check(8'h08,8'h03,1,4'd3,2'b11,0,0,64'd32);
    apply_and_check(8'h08,8'h03,1,4'd3,2'b11,1,0,64'd33);
    apply_and_check(8'h00,8'h01,1,4'd1,2'b11,0,0,64'd34);
    apply_and_check(8'hFF,8'h00,1,4'd1,2'b11,0,0,64'd35);

    apply_and_check(8'h05,8'h03,1,4'd11,2'b11,0,0,64'd36);
    apply_and_check(8'hFB,8'hFD,1,4'd11,2'b11,0,0,64'd37);
    apply_and_check(8'h7F,8'h01,1,4'd11,2'b11,0,0,64'd38);
    apply_and_check(8'h80,8'hFF,1,4'd11,2'b11,0,0,64'd39);
    apply_and_check(8'h7F,8'h7F,1,4'd11,2'b11,0,0,64'd40);
    apply_and_check(8'h80,8'h80,1,4'd11,2'b11,0,0,64'd41);
    apply_and_check(8'h05,8'hFD,1,4'd11,2'b11,0,0,64'd42);
    apply_and_check(8'h00,8'h00,1,4'd11,2'b11,0,0,64'd43);
    apply_and_check(8'hFC,8'h00,1,4'd11,2'b11,0,0,64'd44);
    apply_and_check(8'h10,8'h20,1,4'd11,2'b11,0,0,64'd45);
    apply_and_check(8'h30,8'h10,1,4'd11,2'b11,0,0,64'd45);

    apply_and_check(8'h0A,8'h03,1,4'd12,2'b11,0,0,64'd46);
    apply_and_check(8'hFB,8'h03,1,4'd12,2'b11,0,0,64'd47);
    apply_and_check(8'h7F,8'hFF,1,4'd12,2'b11,0,0,64'd48);
    apply_and_check(8'h80,8'h01,1,4'd12,2'b11,0,0,64'd49);
    apply_and_check(8'h7F,8'h80,1,4'd12,2'b11,0,0,64'd50);
    apply_and_check(8'h80,8'h7F,1,4'd12,2'b11,0,0,64'd51);
    apply_and_check(8'h07,8'h07,1,4'd12,2'b11,0,0,64'd52);
    apply_and_check(8'h10,8'h05,1,4'd12,2'b11,0,0,64'd53);
    apply_and_check(8'h20,8'h08,1,4'd12,2'b11,0,0,64'd53);

    apply_and_check(8'h05,8'h00,1,4'd4,2'b01,0,0,64'd54);
    apply_and_check(8'hFF,8'h00,1,4'd4,2'b01,0,0,64'd55);
    apply_and_check(8'h05,8'h00,1,4'd5,2'b01,0,0,64'd56);
    apply_and_check(8'h00,8'h00,1,4'd5,2'b01,0,0,64'd57);
    apply_and_check(8'h00,8'h07,1,4'd6,2'b10,0,0,64'd58);
    apply_and_check(8'h00,8'h07,1,4'd7,2'b10,0,0,64'd59);
    apply_and_check(8'h00,8'hFF,1,4'd6,2'b10,0,0,64'd60);
    apply_and_check(8'h00,8'h00,1,4'd7,2'b10,0,0,64'd61);

    apply_and_check(8'h0A,8'h05,1,4'd8,2'b11,0,0,64'd62);
    apply_and_check(8'h05,8'h0A,1,4'd8,2'b11,0,0,64'd62);
    apply_and_check(8'h07,8'h07,1,4'd8,2'b11,0,0,64'd62);

    apply_and_check(8'h05,8'h03,1,4'd11,2'b11,0,0,64'd62);
    apply_and_check(8'h03,8'h05,1,4'd11,2'b11,0,0,64'd63);
    apply_and_check(8'h05,8'h05,1,4'd11,2'b11,0,0,64'd64);
    apply_and_check(8'hFE,8'hFB,1,4'd11,2'b11,0,0,64'd65);
    apply_and_check(8'hF8,8'hFF,1,4'd11,2'b11,0,0,64'd66);
    apply_and_check(8'hFE,8'hFE,1,4'd11,2'b11,0,0,64'd67);
    apply_and_check(8'h05,8'hFB,1,4'd11,2'b11,0,0,64'd68);
    apply_and_check(8'hFB,8'h05,1,4'd11,2'b11,0,0,64'd69);
    apply_and_check(8'h00,8'h00,1,4'd11,2'b11,0,0,64'd70);
    apply_and_check(8'h00,8'h05,1,4'd11,2'b11,0,0,64'd71);
    apply_and_check(8'h00,8'hFB,1,4'd11,2'b11,0,0,64'd72);
    apply_and_check(8'h7F,8'h40,1,4'd11,2'b11,0,0,64'd73);
    apply_and_check(8'h80,8'hFF,1,4'd11,2'b11,0,0,64'd74);
    apply_and_check(8'h7F,8'h80,1,4'd11,2'b11,0,0,64'd75);
    apply_and_check(8'h80,8'h7F,1,4'd11,2'b11,0,0,64'd76);
    apply_and_check(8'hFF,8'h00,1,4'd11,2'b11,0,0,64'd77);
    apply_and_check(8'h00,8'hFF,1,4'd11,2'b11,0,0,64'd78);
    apply_and_check(8'h7F,8'h80,1,4'd11,2'b11,0,0,64'd79);
    apply_and_check(8'h80,8'h7F,1,4'd11,2'b11,0,0,64'd80);
    apply_and_check(8'h06,8'h02,1,4'd11,2'b11,0,0,64'd81);
    apply_and_check(8'h01,8'h09,1,4'd11,2'b11,0,0,64'd81);
    apply_and_check(8'h05,8'h03,1,4'd11,2'b11,0,0,64'd82);
    apply_and_check(8'h02,8'h01,1,4'd0, 2'b11,0,0,64'd82);

    apply_and_check(8'h03,8'h02,1,4'd9, 2'b11,0,1,64'd83);
    apply_and_check(8'h00,8'h00,1,4'd9, 2'b11,0,1,64'd84);
    apply_and_check(8'h01,8'h05,1,4'd10,2'b11,0,1,64'd85);
    apply_and_check(8'hFF,8'hFF,1,4'd9, 2'b11,0,1,64'd86);
    apply_and_check(8'h04,8'h03,1,4'd10,2'b11,0,1,64'd87);
    apply_and_check(8'h05,8'h04,1,4'd9, 2'b11,0,1,64'd88);
    apply_and_check(8'h02,8'h02,1,4'd9, 2'b11,0,1,64'd89);
    apply_and_check(8'h03,8'h03,1,4'd9, 2'b11,0,1,64'd89);

    OPA=8'h04; OPB=8'h04; mode=1; cmd=4'd9; input_valid=2'b11; CE=1;
    @(posedge clk);
    input_valid=2'b00; reference_model;
    @(posedge clk); @(posedge clk); check_outputs(64'd90);
    input_valid=2'b11; exp_err=0;

    apply_and_check(8'h06,8'h05,1,4'd9, 2'b11,0,1,64'd91);
    apply_and_check(8'h03,8'h02,1,4'd9, 2'b11,0,1,64'd92);
    apply_and_check(8'h02,8'h03,1,4'd9, 2'b11,0,1,64'd93);
    apply_and_check(8'h01,8'h01,1,4'd9, 2'b11,0,1,64'd93);
    apply_and_check(8'hFF,8'hFF,1,4'd9, 2'b11,0,1,64'd94);
    apply_and_check(8'h00,8'h00,1,4'd9, 2'b11,0,1,64'd95);

    apply_and_check(8'h00,8'h00,0,4'd0,2'b11,0,0,64'd96);
    apply_and_check(8'hFF,8'hFF,0,4'd0,2'b11,0,0,64'd97);
    apply_and_check(8'h00,8'hFF,0,4'd0,2'b11,0,0,64'd98);
    apply_and_check(8'hAA,8'h55,0,4'd0,2'b11,0,0,64'd99);
    apply_and_check(8'hA5,8'hA5,0,4'd0,2'b11,0,0,64'd100);

    apply_and_check(8'h00,8'h00,0,4'd2,2'b11,0,0,64'd101);
    apply_and_check(8'hFF,8'hFF,0,4'd2,2'b11,0,0,64'd102);
    apply_and_check(8'h00,8'hFF,0,4'd2,2'b11,0,0,64'd103);
    apply_and_check(8'hAA,8'h55,0,4'd2,2'b11,0,0,64'd104);
    apply_and_check(8'hA5,8'hA5,0,4'd2,2'b11,0,0,64'd105);

    apply_and_check(8'h00,8'h00,0,4'd4,2'b11,0,0,64'd106);
    apply_and_check(8'hFF,8'hFF,0,4'd4,2'b11,0,0,64'd107);
    apply_and_check(8'hAA,8'h55,0,4'd4,2'b11,0,0,64'd108);
    apply_and_check(8'hA5,8'hA5,0,4'd4,2'b11,0,0,64'd109);

    apply_and_check(8'h00,8'h00,0,4'd1,2'b11,0,0,64'd110);
    apply_and_check(8'hFF,8'hFF,0,4'd1,2'b11,0,0,64'd111);
    apply_and_check(8'hAA,8'h55,0,4'd1,2'b11,0,0,64'd112);

    apply_and_check(8'h00,8'h00,0,4'd3,2'b11,0,0,64'd113);
    apply_and_check(8'hFF,8'hFF,0,4'd3,2'b11,0,0,64'd114);
    apply_and_check(8'hAA,8'h55,0,4'd3,2'b11,0,0,64'd115);

    apply_and_check(8'h00,8'h00,0,4'd5,2'b11,0,0,64'd116);
    apply_and_check(8'hFF,8'hFF,0,4'd5,2'b11,0,0,64'd117);
    apply_and_check(8'hAA,8'h55,0,4'd5,2'b11,0,0,64'd118);
    apply_and_check(8'hA5,8'hA5,0,4'd5,2'b11,0,0,64'd119);

    apply_and_check(8'h00,8'h00,0,4'd6,2'b01,0,0,64'd120);
    apply_and_check(8'hFF,8'h00,0,4'd6,2'b01,0,0,64'd121);
    apply_and_check(8'hAA,8'h00,0,4'd6,2'b01,0,0,64'd122);
    apply_and_check(8'h00,8'h00,0,4'd7,2'b10,0,0,64'd123);
    apply_and_check(8'h00,8'hFF,0,4'd7,2'b10,0,0,64'd124);
    apply_and_check(8'h00,8'hAA,0,4'd7,2'b10,0,0,64'd125);

    apply_and_check(8'h00,8'h00,0,4'd9,2'b01,0,0,64'd126);
    apply_and_check(8'hFF,8'h00,0,4'd9,2'b01,0,0,64'd127);
    apply_and_check(8'h01,8'h00,0,4'd9,2'b01,0,0,64'd128);
    apply_and_check(8'h80,8'h00,0,4'd9,2'b01,0,0,64'd129);
    apply_and_check(8'hAB,8'h00,0,4'd9,2'b01,0,0,64'd130);

    apply_and_check(8'h00,8'h00,0,4'd8,2'b01,0,0,64'd131);
    apply_and_check(8'hFF,8'h00,0,4'd8,2'b01,0,0,64'd132);
    apply_and_check(8'h02,8'h00,0,4'd8,2'b01,0,0,64'd133);
    apply_and_check(8'h01,8'h00,0,4'd8,2'b01,0,0,64'd134);
    apply_and_check(8'hAB,8'h00,0,4'd8,2'b01,0,0,64'd135);

    apply_and_check(8'h00,8'h01,0,4'd11,2'b10,0,0,64'd136);
    apply_and_check(8'h00,8'hFF,0,4'd11,2'b10,0,0,64'd137);
    apply_and_check(8'h00,8'h80,0,4'd11,2'b10,0,0,64'd138);
    apply_and_check(8'h00,8'h02,0,4'd10,2'b10,0,0,64'd139);
    apply_and_check(8'h00,8'hFF,0,4'd10,2'b10,0,0,64'd140);
    apply_and_check(8'h00,8'h01,0,4'd10,2'b10,0,0,64'd141);

    apply_and_check(8'hA5,8'h00,0,4'd12,2'b11,0,0,64'd142);
    apply_and_check(8'hA5,8'h01,0,4'd12,2'b11,0,0,64'd143);
    apply_and_check(8'hA5,8'h07,0,4'd12,2'b11,0,0,64'd144);
    apply_and_check(8'h80,8'h01,0,4'd12,2'b11,0,0,64'd145);
    apply_and_check(8'h3C,8'h02,0,4'd12,2'b11,0,0,64'd146);

    apply_and_check(8'hA5,8'h00,0,4'd13,2'b11,0,0,64'd147);
    apply_and_check(8'hA5,8'h01,0,4'd13,2'b11,0,0,64'd148);
    apply_and_check(8'hA5,8'h07,0,4'd13,2'b11,0,0,64'd149);
    apply_and_check(8'h01,8'h01,0,4'd13,2'b11,0,0,64'd150);
    apply_and_check(8'h3C,8'h02,0,4'd13,2'b11,0,0,64'd151);

    apply_and_check(8'hFF,8'h01,1,4'd0, 2'b11,0,0,64'd152);
    apply_and_check(8'h01,8'h01,1,4'd1, 2'b11,0,0,64'd152);
    apply_and_check(8'h7F,8'h01,1,4'd11,2'b11,0,0,64'd153);
    apply_and_check(8'h01,8'h01,1,4'd0, 2'b11,0,0,64'd153);

    OPA=8'hFF; OPB=8'h01; mode=1; cmd=4'd0; input_valid=2'b11; CE=1;
    reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd154);
    input_valid=2'b00; reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd154);
    input_valid=2'b11; exp_err=0;

    apply_and_check(8'h00,8'h01,1,4'd0,2'b11,0,0,64'd155);
    apply_and_check(8'h01,8'h02,1,4'd0,2'b11,0,0,64'd155);
    apply_and_check(8'h02,8'h03,1,4'd0,2'b11,0,0,64'd155);
    apply_and_check(8'h03,8'h04,1,4'd0,2'b11,0,0,64'd155);

    apply_and_check(8'h05,8'h03,1,4'd0, 2'b11,0,0,64'd156);
    apply_and_check(8'h04,8'h02,1,4'd9, 2'b11,0,1,64'd156);
    apply_and_check(8'h09,8'h03,1,4'd1, 2'b11,0,0,64'd156);

    apply_and_check(8'h02,8'h02,1,4'd9,2'b11,0,1,64'd157);
    apply_and_check(8'h03,8'h03,1,4'd9,2'b11,0,1,64'd157);
    apply_and_check(8'h04,8'h04,1,4'd9,2'b11,0,1,64'd157);

    OPA=8'h05; OPB=8'h03; mode=1; cmd=4'd0; input_valid=2'b11; CE=1;
    reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd158);
    input_valid=2'b00; reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd158);
    input_valid=2'b11; exp_err=0;

    apply_and_check(8'h0A,8'h05,1,4'd0,2'b11,0,0,64'd159);
    apply_and_check(8'h08,8'h03,1,4'd1,2'b11,0,0,64'd159);

    apply_and_check(8'hAB,8'h00,0,4'd8, 2'b10,0,0,64'd160);
    apply_and_check(8'h00,8'hAB,0,4'd9, 2'b10,0,0,64'd160);
    apply_and_check(8'hAB,8'h00,0,4'd10,2'b01,0,0,64'd160);
    apply_and_check(8'h00,8'hAB,0,4'd11,2'b01,0,0,64'd160);
    apply_and_check(8'hAB,8'h00,0,4'd6, 2'b10,0,0,64'd161);
    apply_and_check(8'h00,8'hAB,0,4'd7, 2'b01,0,0,64'd161);
    apply_and_check(8'h03,8'h02,1,4'd9, 2'b01,0,0,64'd162);
    apply_and_check(8'h03,8'h02,1,4'd10,2'b10,0,0,64'd162);
    apply_and_check(8'h05,8'h03,1,4'd0, 2'b11,1,0,64'd163);
    apply_and_check(8'h05,8'h03,1,4'd1, 2'b11,1,0,64'd163);

    apply_and_check(8'h05,8'h03,1,4'd0,2'b11,0,0,64'd164);
    OPA=8'h03; OPB=8'h04; mode=1; cmd=4'd9; input_valid=2'b11; CE=1;
    @(posedge clk); @(posedge clk); CE=0;
    reference_model; @(posedge clk); @(posedge clk); check_outputs(64'd164);
    CE=1;

    apply_and_check(8'h7F,8'h7F,1,4'd9, 2'b11,0,1,64'd165);
    apply_and_check(8'h80,8'hC7,1,4'd10,2'b11,0,1,64'd165);
    apply_and_check(8'hFF,8'h80,1,4'd9, 2'b11,0,1,64'd165);
    apply_and_check(8'hC8,8'h64,1,4'd10,2'b11,0,1,64'd165);
    apply_and_check(8'hFE,8'hFE,1,4'd9, 2'b11,0,1,64'd165);

    apply_and_check(8'hB7,8'h03,0,4'd12,2'b11,0,0,64'd166);
    apply_and_check(8'hB7,8'h04,0,4'd12,2'b11,0,0,64'd166);
    apply_and_check(8'hB7,8'h05,0,4'd12,2'b11,0,0,64'd166);
    apply_and_check(8'hB7,8'h06,0,4'd12,2'b11,0,0,64'd166);
    apply_and_check(8'h01,8'h07,0,4'd12,2'b11,0,0,64'd166);
    apply_and_check(8'hB7,8'h03,0,4'd13,2'b11,0,0,64'd166);
    apply_and_check(8'hB7,8'h04,0,4'd13,2'b11,0,0,64'd166);
    apply_and_check(8'hB7,8'h05,0,4'd13,2'b11,0,0,64'd166);
    apply_and_check(8'hB7,8'h06,0,4'd13,2'b11,0,0,64'd166);
    apply_and_check(8'h80,8'h07,0,4'd13,2'b11,0,0,64'd166);

    apply_and_check(8'hA5,8'h08,0,4'd12,2'b11,0,0,64'd167);
    apply_and_check(8'hA5,8'h10,0,4'd12,2'b11,0,0,64'd167);
    apply_and_check(8'hA5,8'h08,0,4'd13,2'b11,0,0,64'd167);
    apply_and_check(8'hA5,8'h10,0,4'd13,2'b11,0,0,64'd167);
    apply_and_check(8'h00,8'h00,1,4'd3,2'b11,1,0,64'd168);
    apply_and_check(8'h01,8'h01,1,4'd3,2'b11,1,0,64'd168);
    apply_and_check(8'hFF,8'hFE,1,4'd3,2'b11,1,0,64'd168);
    apply_and_check(8'h80,8'h7F,1,4'd3,2'b11,1,0,64'd168);

    apply_and_check(8'h7F,8'h00,1,4'd2,2'b11,1,0,64'd169);
    apply_and_check(8'hFE,8'h00,1,4'd2,2'b11,1,0,64'd169);
    apply_and_check(8'hFE,8'h01,1,4'd2,2'b11,1,0,64'd169);
    apply_and_check(8'hFF,8'hFF,1,4'd2,2'b11,1,0,64'd169);

    apply_and_check(8'h01,8'h00,1,4'd12,2'b11,0,0,64'd170);
    apply_and_check(8'hFE,8'hFF,1,4'd12,2'b11,0,0,64'd170);
    apply_and_check(8'h40,8'h40,1,4'd12,2'b11,0,0,64'd170);

    apply_and_check(8'hFF,8'hFF,0,4'd6,2'b01,0,0,64'd171);
    apply_and_check(8'h00,8'hFF,0,4'd7,2'b10,0,0,64'd171);
    apply_and_check(8'hFF,8'h00,0,4'd6,2'b01,0,0,64'd171);

    apply_and_check(8'hAA,8'h55,0,4'd15,2'b11,0,0,64'd172);

    apply_and_check(8'hAA,8'h55,1,4'd15,2'b11,0,0,64'd173);

    apply_and_check(8'h55,8'h00,1,4'd4,2'b01,0,0,64'd174);
    apply_and_check(8'hAA,8'h00,1,4'd5,2'b01,0,0,64'd174);
    apply_and_check(8'h00,8'h55,1,4'd6,2'b10,0,0,64'd174);
    apply_and_check(8'h00,8'hAA,1,4'd7,2'b10,0,0,64'd174);

    apply_and_check(8'h55,8'h00,0,4'd9,2'b01,0,0,64'd175);
    apply_and_check(8'hAA,8'h00,0,4'd9,2'b01,0,0,64'd175);
    apply_and_check(8'h55,8'h00,0,4'd8,2'b01,0,0,64'd175);
    apply_and_check(8'hAA,8'h00,0,4'd8,2'b01,0,0,64'd175);
    apply_and_check(8'h00,8'h55,0,4'd11,2'b10,0,0,64'd175);
    apply_and_check(8'h00,8'hAA,0,4'd10,2'b10,0,0,64'd175);

    apply_and_check(8'h00,8'hFF,1,4'd8,2'b11,0,0,64'd176);
    apply_and_check(8'hFF,8'h00,1,4'd8,2'b11,0,0,64'd176);
    apply_and_check(8'h80,8'h7F,1,4'd8,2'b11,0,0,64'd176);
    apply_and_check(8'h7F,8'h80,1,4'd8,2'b11,0,0,64'd176);
    apply_and_check(8'hFF,8'hFF,1,4'd8,2'b11,0,0,64'd176);

    apply_and_check(8'hFF,8'h01,1,4'd11,2'b11,0,0,64'd177);
    apply_and_check(8'h80,8'h7F,1,4'd11,2'b11,0,0,64'd177);
    apply_and_check(8'h7F,8'h80,1,4'd11,2'b11,0,0,64'd177);

    apply_and_check(8'h00,8'h01,1,4'd12,2'b11,0,0,64'd178);
    apply_and_check(8'h01,8'hFF,1,4'd12,2'b11,0,0,64'd178);
    apply_and_check(8'hFE,8'h01,1,4'd12,2'b11,0,0,64'd178);

    apply_and_check(8'hAA,8'h55,1,4'd0, 2'b01,0,0,64'd179);
    apply_and_check(8'hAA,8'h55,1,4'd0, 2'b10,0,0,64'd180);
    apply_and_check(8'hAA,8'h55,1,4'd1, 2'b01,0,0,64'd181);
    apply_and_check(8'hAA,8'h55,1,4'd1, 2'b10,0,0,64'd182);
    apply_and_check(8'hAA,8'h55,1,4'd2, 2'b01,0,0,64'd183);
    apply_and_check(8'hAA,8'h55,1,4'd2, 2'b10,0,0,64'd184);
    apply_and_check(8'hAA,8'h55,1,4'd3, 2'b01,0,0,64'd185);
    apply_and_check(8'hAA,8'h55,1,4'd3, 2'b10,0,0,64'd186);
    apply_and_check(8'h00,8'h55,1,4'd4, 2'b10,0,0,64'd187);
    apply_and_check(8'h00,8'h55,1,4'd5, 2'b10,0,0,64'd188);
    apply_and_check(8'hAA,8'h00,1,4'd6, 2'b01,0,0,64'd189);
    apply_and_check(8'hAA,8'h00,1,4'd7, 2'b01,0,0,64'd190);
    apply_and_check(8'hAA,8'h55,1,4'd8, 2'b01,0,0,64'd191);
    apply_and_check(8'hAA,8'h55,1,4'd8, 2'b10,0,0,64'd192);
    apply_and_check(8'hAA,8'h55,1,4'd9, 2'b01,0,0,64'd193);
    apply_and_check(8'hAA,8'h55,1,4'd9, 2'b10,0,0,64'd194);
    apply_and_check(8'hAA,8'h55,1,4'd10,2'b01,0,0,64'd195);
    apply_and_check(8'hAA,8'h55,1,4'd10,2'b10,0,0,64'd196);
    apply_and_check(8'hAA,8'h55,1,4'd11,2'b01,0,0,64'd197);
    apply_and_check(8'hAA,8'h55,1,4'd11,2'b10,0,0,64'd198);
    apply_and_check(8'hAA,8'h55,1,4'd12,2'b01,0,0,64'd199);
    apply_and_check(8'hAA,8'h55,1,4'd12,2'b10,0,0,64'd200);
    apply_and_check(8'hAA,8'h55,0,4'd0, 2'b01,0,0,64'd201);
    apply_and_check(8'hAA,8'h55,0,4'd0, 2'b10,0,0,64'd202);
    apply_and_check(8'hAA,8'h55,0,4'd1, 2'b01,0,0,64'd203);
    apply_and_check(8'hAA,8'h55,0,4'd1, 2'b10,0,0,64'd204);
    apply_and_check(8'hAA,8'h55,0,4'd2, 2'b01,0,0,64'd205);
    apply_and_check(8'hAA,8'h55,0,4'd2, 2'b10,0,0,64'd206);
    apply_and_check(8'hAA,8'h55,0,4'd3, 2'b01,0,0,64'd207);
    apply_and_check(8'hAA,8'h55,0,4'd3, 2'b10,0,0,64'd208);
    apply_and_check(8'hAA,8'h55,0,4'd4, 2'b01,0,0,64'd209);
    apply_and_check(8'hAA,8'h55,0,4'd4, 2'b10,0,0,64'd210);
    apply_and_check(8'hAA,8'h55,0,4'd5, 2'b01,0,0,64'd211);
    apply_and_check(8'hAA,8'h55,0,4'd5, 2'b10,0,0,64'd212);
    apply_and_check(8'h00,8'h55,0,4'd6, 2'b10,0,0,64'd213);
    apply_and_check(8'hAA,8'h00,0,4'd7, 2'b01,0,0,64'd214);
    apply_and_check(8'h00,8'h55,0,4'd8, 2'b10,0,0,64'd215);
    apply_and_check(8'hAA,8'h00,0,4'd9, 2'b10,0,0,64'd216);
    apply_and_check(8'hAA,8'h00,0,4'd10,2'b01,0,0,64'd217);
    apply_and_check(8'hAA,8'h00,0,4'd11,2'b01,0,0,64'd218);
    apply_and_check(8'hAA,8'h55,0,4'd12,2'b01,0,0,64'd219);
    apply_and_check(8'hAA,8'h55,0,4'd12,2'b10,0,0,64'd220);
    apply_and_check(8'hAA,8'h55,0,4'd13,2'b01,0,0,64'd221);
    apply_and_check(8'hAA,8'h55,0,4'd13,2'b10,0,0,64'd222);
    apply_and_check(8'h03,8'h0A,1,4'd1, 2'b11,0,0,64'd223);
    apply_and_check(8'h7F,8'h01,1,4'd11,2'b11,0,0,64'd224);
    apply_and_check(8'h80,8'h01,1,4'd12,2'b11,0,0,64'd225);
    apply_and_check(8'h05,8'h03,1,4'd11,2'b11,0,0,64'd226);
    apply_and_check(8'h03,8'h05,1,4'd11,2'b11,0,0,64'd227);
    apply_and_check(8'h04,8'h04,1,4'd11,2'b11,0,0,64'd228);
    apply_and_check(8'h05,8'h03,1,4'd12,2'b11,0,0,64'd229);
    apply_and_check(8'h03,8'h05,1,4'd12,2'b11,0,0,64'd230);
    apply_and_check(8'h04,8'h04,1,4'd12,2'b11,0,0,64'd231);
    apply_and_check(8'h0A,8'h05,1,4'd8, 2'b11,0,0,64'd232);
    apply_and_check(8'h05,8'h0A,1,4'd8, 2'b11,0,0,64'd233);
    apply_and_check(8'h07,8'h07,1,4'd8, 2'b11,0,0,64'd234);
    apply_and_check(8'hFF,8'h01,1,4'd0, 2'b11,0,0,64'd235);
    apply_and_check(8'h80,8'hFF,1,4'd11,2'b11,0,0,64'd236);
    
    @(posedge clk); 
    $display("=====================================");
    $display("RESULTS: PASS=%0d  FAIL=%0d",pass_cnt,fail_cnt);
    $display("=====================================");
    $finish;
end

endmodule
