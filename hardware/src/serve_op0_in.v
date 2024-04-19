`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 11:52:45
// Design Name: 
// Module Name: serve_op0_in
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


module server_op0_in#(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
    parameter C_S_AXIS_TUSER_WIDTH = 128
)(
    input          axis_aclk    ,  
    input          axis_resetn  ,

    input [C_S_AXIS_DATA_WIDTH-1:0]         i_op0_server_tdata    ,
    input [((C_S_AXIS_DATA_WIDTH/8))-1:0]   i_op0_server_tkeep    ,
    input [C_S_AXIS_TUSER_WIDTH-1:0]        i_op0_server_tuser    ,
    input                                   i_op0_server_tvalid   ,
    output                                  o_op0_server_tready   ,
    input                                   i_op0_server_tlast    ,

    output                                  o_pkt_fifo_empty_2    ,
    input                                   i_pkt_fifo_rd_en_2    ,
 
    output [C_S_AXIS_DATA_WIDTH-1:0]        o_tdata_fifo_2        ,
    output [C_S_AXIS_TUSER_WIDTH-1:0]       o_tuser_fifo_2        ,
    output [((C_S_AXIS_DATA_WIDTH/8))-1:0]  o_tkeep_fifo_2        ,
    output                                  o_tlast_fifo_2        ,
    output                                  o_tvalid_fifo_2        
);

//////////////////////////////////////////input 2////////////////////////////////////
wire                                  pkt_fifo_nearly_full_2;
// wire                               pkt_fifo_empty_2;
assign o_op0_server_tready = !pkt_fifo_nearly_full_2;
 
 
wire [C_S_AXIS_DATA_WIDTH-1:0]		    tdata_fifo_2;
wire [C_S_AXIS_TUSER_WIDTH-1:0]		    tuser_fifo_2;
wire [C_S_AXIS_DATA_WIDTH/8-1:0]	    tkeep_fifo_2;
wire								    tlast_fifo_2;
 
reg                                  pkt_fifo_wr_en_2;
reg                                  pkt_fifo_rd_en_2;
reg [C_S_AXIS_DATA_WIDTH-1:0]        r_s_axis_tdata_2;
reg [((C_S_AXIS_DATA_WIDTH/8))-1:0]  r_s_axis_tkeep_2;
reg [C_S_AXIS_TUSER_WIDTH-1:0]       r_s_axis_tuser_2;
reg                                  r_s_axis_tvalid_2;
reg                                  r_s_axis_tlast_2;
reg                                  rd_fifo_flag_2; 

reg [2:0]                            fil_in_state_2;
localparam  WAIT_FIRST_PKT           =          3'b000,
            WAIT_SECOND_PKT          =          3'b001,
            BUFFER_CTL               =          3'b010,
            BUFFER_DATA              =          3'b011;

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
    	r_s_axis_tdata_2  <= 0;
    	r_s_axis_tkeep_2  <= 0;
    	r_s_axis_tuser_2  <= 0;
    	r_s_axis_tvalid_2 <= 0;
    	r_s_axis_tlast_2  <= 0;
    end
    else if(i_op0_server_tvalid)begin
        r_s_axis_tdata_2  <= i_op0_server_tdata ;
        r_s_axis_tkeep_2  <= i_op0_server_tkeep ;
        r_s_axis_tuser_2  <= i_op0_server_tuser ;
        r_s_axis_tvalid_2 <= i_op0_server_tvalid;
        r_s_axis_tlast_2  <= i_op0_server_tlast ;  
    end
    else begin
    	r_s_axis_tdata_2  <= 0;
        r_s_axis_tkeep_2  <= 0;
        r_s_axis_tuser_2  <= 0;
        r_s_axis_tvalid_2 <= 0;
        r_s_axis_tlast_2  <= 0; 
    end
end  
    
fallthrough_small_fifo #(
    .WIDTH(C_S_AXIS_DATA_WIDTH + C_S_AXIS_TUSER_WIDTH + C_S_AXIS_DATA_WIDTH/8 + 1),
    .MAX_DEPTH_BITS(10)
)
input_fifo_ins2
(
	.din							    ({r_s_axis_tdata_2, r_s_axis_tuser_2, r_s_axis_tkeep_2, r_s_axis_tlast_2}),
	.wr_en								(pkt_fifo_wr_en_2),
	.rd_en								(i_pkt_fifo_rd_en_2),
	.dout								({tdata_fifo_2, tuser_fifo_2, tkeep_fifo_2, tlast_fifo_2}),
	.full								(),
	.prog_full							(),
	.nearly_full						(pkt_fifo_nearly_full_2),
	.empty								(o_pkt_fifo_empty_2),
	.reset								(~axis_resetn),
	.clk							    (axis_aclk)
);

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
	    pkt_fifo_wr_en_2 <= 1'b0;
	    rd_fifo_flag_2 <= 1'b0;
	    fil_in_state_2 <= WAIT_FIRST_PKT;
    end
    else begin
        case(fil_in_state_2)
            WAIT_FIRST_PKT: begin
                rd_fifo_flag_2 <= 1'b0;
                if(i_op0_server_tvalid) begin
                    if(i_op0_server_tdata[191:184]==`IPPROT_UDP) begin
                        pkt_fifo_wr_en_2 <= 1'b1;
					    fil_in_state_2   <= WAIT_SECOND_PKT;
                    end
                    else begin
                        pkt_fifo_wr_en_2 <= 1'b0;
                        fil_in_state_2   <= WAIT_FIRST_PKT;
                    end
                end
                else begin
                    pkt_fifo_wr_en_2 <= 1'b0;
				    fil_in_state_2   <= WAIT_FIRST_PKT;
                end
            end
            WAIT_SECOND_PKT:begin
                if(i_op0_server_tvalid) begin
				    rd_fifo_flag_2     <= 1'b1;
				    pkt_fifo_wr_en_2 <= 1'b1;
				    if (i_op0_server_tdata[47:32]==`DST_PORT) begin
				    	fil_in_state_2 <= BUFFER_DATA;
				    end
				    else begin
				    	fil_in_state_2 <= WAIT_FIRST_PKT;
				    end
			    end
			    else begin
			    	pkt_fifo_wr_en_2 <= 1'b0;
			    	fil_in_state_2 <= WAIT_SECOND_PKT;
			    end
            end
		    BUFFER_DATA:begin 
		    	rd_fifo_flag_2 <= 1'b1;
		    	if(i_op0_server_tvalid && i_op0_server_tlast) begin
		    		pkt_fifo_wr_en_2 <= 1'b1;
		    		fil_in_state_2 <= WAIT_FIRST_PKT;
		    	end
		    	else if(i_op0_server_tvalid) begin
		    		pkt_fifo_wr_en_2 <= 1'b1;
		    		fil_in_state_2 <= BUFFER_DATA;
		    	end
		    	else begin
		    		pkt_fifo_wr_en_2 <= 1'b0;
		    		fil_in_state_2 <= BUFFER_DATA;
		    	end
		    end
        endcase
    end 
end

endmodule
