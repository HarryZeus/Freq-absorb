`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 11:57:22
// Design Name: 
// Module Name: server_op1_in
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module server_op1_in#(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
    parameter C_S_AXIS_TUSER_WIDTH = 128
)(
    input          axis_aclk    ,  
    input          axis_resetn  ,

    input [C_S_AXIS_DATA_WIDTH-1:0]         i_op1_server_tdata    ,
    input [((C_S_AXIS_DATA_WIDTH/8))-1:0]   i_op1_server_tkeep    ,
    input [C_S_AXIS_TUSER_WIDTH-1:0]        i_op1_server_tuser    ,
    input                                   i_op1_server_tvalid   ,
    output                                  o_op1_server_tready   ,
    input                                   i_op1_server_tlast    ,
 
    output                                  o_pkt_fifo_empty_3    ,
    input                                   i_pkt_fifo_rd_en_3    ,
 
    output  [C_S_AXIS_DATA_WIDTH-1:0]       o_tdata_fifo_3        ,
    output  [C_S_AXIS_TUSER_WIDTH-1:0]      o_tuser_fifo_3        ,
    output  [((C_S_AXIS_DATA_WIDTH/8))-1:0] o_tkeep_fifo_3        ,
    output                                  o_tlast_fifo_3        ,
    output                                  o_tvalid_fifo_3       
);

//////////////////////////////////////////input 3////////////////////////////////////
wire                                   pkt_fifo_nearly_full_3;
// wire                                   pkt_fifo_empty_3;
 
wire [C_S_AXIS_DATA_WIDTH-1:0]		    tdata_fifo_3     ;
wire [C_S_AXIS_TUSER_WIDTH-1:0]		    tuser_fifo_3     ;
wire [C_S_AXIS_DATA_WIDTH/8-1:0]	    tkeep_fifo_3     ;
wire								    tlast_fifo_3     ;
 
reg                                     pkt_fifo_wr_en_3 ;
reg                                     pkt_fifo_rd_en_3 ;
reg [C_S_AXIS_DATA_WIDTH-1:0]           r_s_axis_tdata_3 ;
reg [((C_S_AXIS_DATA_WIDTH/8))-1:0]     r_s_axis_tkeep_3 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]          r_s_axis_tuser_3 ;
reg                                     r_s_axis_tvalid_3;
reg                                     r_s_axis_tlast_3 ;
reg                                     rd_fifo_flag_3   ; 

reg [2:0]                               fil_in_state_3   ;
localparam  WAIT_FIRST_PKT              =          3'b000,
            WAIT_SECOND_PKT             =          3'b001,
            BUFFER_CTL                  =          3'b010,
            BUFFER_DATA                 =          3'b011;

assign o_op1_server_tready = !pkt_fifo_nearly_full_3;

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
    	r_s_axis_tdata_3  <= 0;
    	r_s_axis_tkeep_3  <= 0;
    	r_s_axis_tuser_3  <= 0;
    	r_s_axis_tvalid_3 <= 0;
    	r_s_axis_tlast_3  <= 0;
    end
    else if(i_op1_server_tvalid)begin
        r_s_axis_tdata_3  <= i_op1_server_tdata ;
        r_s_axis_tkeep_3  <= i_op1_server_tkeep ;
        r_s_axis_tuser_3  <= i_op1_server_tuser ;
        r_s_axis_tvalid_3 <= i_op1_server_tvalid;
        r_s_axis_tlast_3  <= i_op1_server_tlast ;  
    end
    else begin
    	r_s_axis_tdata_3  <= 0;
        r_s_axis_tkeep_3  <= 0;
        r_s_axis_tuser_3  <= 0;
        r_s_axis_tvalid_3 <= 0;
        r_s_axis_tlast_3  <= 0; 
    end
end

fallthrough_small_fifo #(
 .WIDTH(C_S_AXIS_DATA_WIDTH + C_S_AXIS_TUSER_WIDTH + C_S_AXIS_DATA_WIDTH/8 + 1),
 .MAX_DEPTH_BITS(10)
)
input_fifo_ins3
(
	.din								({r_s_axis_tdata_3, r_s_axis_tuser_3, r_s_axis_tkeep_3, r_s_axis_tlast_3}),
	.wr_en								(pkt_fifo_wr_en_3),
	.rd_en								(pkt_fifo_rd_en_3),
	.dout								({tdata_fifo_3, tuser_fifo_3, tkeep_fifo_3, tlast_fifo_3}),
	.full								(),
	.prog_full							(),
	.nearly_full						(pkt_fifo_nearly_full_3),
	.empty								(o_pkt_fifo_empty_3),
	.reset								(~axis_resetn),
	.clk								(axis_aclk)
);
    
always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
	    pkt_fifo_wr_en_3 <= 1'b0;
	    rd_fifo_flag_3 <= 1'b0;
	    fil_in_state_3 <= WAIT_FIRST_PKT;
    end
    else begin
        case(fil_in_state_3)
            WAIT_FIRST_PKT: begin
                rd_fifo_flag_3 <= 1'b0;
                if(i_op1_server_tvalid) begin
                    if(i_op1_server_tdata[191:184]==`IPPROT_UDP) begin
                        pkt_fifo_wr_en_3 <= 1'b1;
					    fil_in_state_3   <= WAIT_SECOND_PKT;
                    end
                    else begin
                        pkt_fifo_wr_en_3 <= 1'b0;
                        fil_in_state_3   <= WAIT_FIRST_PKT;
                    end
                end
                else begin
                    pkt_fifo_wr_en_3 <= 1'b0;
				    fil_in_state_3   <= WAIT_FIRST_PKT;
                end
            end
            WAIT_SECOND_PKT:begin
                if(i_op1_server_tvalid) begin
				    rd_fifo_flag_3     <= 1'b1;
				    pkt_fifo_wr_en_3 <= 1'b1;
				    if (i_op1_server_tdata[47:32]==`DST_PORT) begin
				    	fil_in_state_3 <= BUFFER_DATA;
				    end
				    else begin
				    	fil_in_state_3 <= WAIT_FIRST_PKT;
				    end
			        end
			        else begin
			        	pkt_fifo_wr_en_3 <= 1'b0;
			        	fil_in_state_3 <= WAIT_SECOND_PKT;
			        end
            end
		    BUFFER_DATA:begin 
		    	rd_fifo_flag_3 <= 1'b1;
		    	if(i_op1_server_tvalid && i_op1_server_tlast) begin
		    		pkt_fifo_wr_en_3 <= 1'b1;
		    		fil_in_state_3 <= WAIT_FIRST_PKT;
		    	end
		    	else if(i_op1_server_tvalid) begin
		    		pkt_fifo_wr_en_3 <= 1'b1;
		    		fil_in_state_3 <= BUFFER_DATA;
		    	end
		    	else begin
		    		pkt_fifo_wr_en_3 <= 1'b0;
		    		fil_in_state_3 <= BUFFER_DATA;
		    	end
		    end
        endcase
    end 
end

endmodule
