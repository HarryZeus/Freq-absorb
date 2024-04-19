`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/05 15:15:05
// Design Name: 
// Module Name: extract_key_op0
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
`define DST_PORT        16'hb822
`define IPPROT_UDP      8'h11
`define READ            8'h00
`define READ_REPLY      8'h01
`define WRITE           8'h02
`define DELETE          8'h03
`define HOT_INSERT      8'h04
`define STASH_SYN       8'h05
`define WRITE_REPLY     8'h06

module extract_key#(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
   	parameter C_S_AXIS_TUSER_WIDTH = 128,
    parameter KEY_WIDTH  		   = 32 
)(
input                                 axis_aclk    , 
input                                 axis_resetn  ,

input [C_S_AXIS_DATA_WIDTH-1:0]       s_axis_tdata ,
input [((C_S_AXIS_DATA_WIDTH/8))-1:0] s_axis_tkeep ,
input [C_S_AXIS_TUSER_WIDTH-1:0]      s_axis_tuser ,
input                                 s_axis_tvalid,
output                                s_axis_tready,
input                                 s_axis_tlast ,

output reg [KEY_WIDTH-1:0]            o_key_bit      ,
output reg                            o_key_bit_valid,
output                                o_key_bit_mask
);

localparam  WAIT_FIRST_PKT  = 3'b000,
            WAIT_SECOND_PKT = 3'b001,
            BUFFER_CTL      = 3'b010,
            BUFFER_DATA     = 3'b011;

wire                                  pkt_fifo_nearly_full;
wire                                  pkt_fifo_empty;

assign s_axis_tready = (!pkt_fifo_nearly_full);
 
// reg  [3:0] vlan_id;
// wire [11:0] w_vlan_id;
// assign  w_vlan_id = tdata_fifo[116+:12];
 
wire [C_S_AXIS_DATA_WIDTH-1:0]		tdata_fifo;
wire [C_S_AXIS_TUSER_WIDTH-1:0]		tuser_fifo;
wire [C_S_AXIS_DATA_WIDTH/8-1:0]	    tkeep_fifo;
wire								    tlast_fifo;
 
reg                                  pkt_fifo_wr_en, pkt_fifo_rd_en;
reg [C_S_AXIS_DATA_WIDTH-1:0]        r_s_axis_tdata_0;
reg [((C_S_AXIS_DATA_WIDTH/8))-1:0]  r_s_axis_tkeep_0;
reg [C_S_AXIS_TUSER_WIDTH-1:0]       r_s_axis_tuser_0;
reg                                  r_s_axis_tvalid_0;
reg                                  r_s_axis_tlast_0;
reg                                  rd_fifo_flag; 
 
 
fallthrough_small_fifo #(
	.WIDTH(C_S_AXIS_DATA_WIDTH + C_S_AXIS_TUSER_WIDTH + C_S_AXIS_DATA_WIDTH/8 + 1),
	.MAX_DEPTH_BITS(10)
)
extracter_fifo
(
	.din									({r_s_axis_tdata_0, r_s_axis_tuser_0, r_s_axis_tkeep_0, r_s_axis_tlast_0}),
	.wr_en									(pkt_fifo_wr_en),
	.rd_en									(pkt_fifo_rd_en),
	.dout									({tdata_fifo, tuser_fifo, tkeep_fifo, tlast_fifo}),
	.full									(),
	.prog_full								(),
	.nearly_full							(pkt_fifo_nearly_full),
	.empty									(pkt_fifo_empty),
	.reset									(~axis_resetn),
	.clk									(axis_aclk)
);

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
    	r_s_axis_tdata_0  <= 0;
    	r_s_axis_tkeep_0  <= 0;
    	r_s_axis_tuser_0  <= 0;
    	r_s_axis_tvalid_0 <= 0;
    	r_s_axis_tlast_0  <= 0;
    end
    else if(s_axis_tvalid)begin
        r_s_axis_tdata_0  <= s_axis_tdata ;
        r_s_axis_tkeep_0  <= s_axis_tkeep ;
        r_s_axis_tuser_0  <= s_axis_tuser ;
        r_s_axis_tvalid_0 <= s_axis_tvalid;
        r_s_axis_tlast_0  <= s_axis_tlast ;  
    end
    else begin
    	r_s_axis_tdata_0  <= 0;
        r_s_axis_tkeep_0  <= 0;
        r_s_axis_tuser_0  <= 0;
        r_s_axis_tvalid_0 <= 0;
        r_s_axis_tlast_0  <= 0; 
    end
end

reg [2:0] fil_in_state;

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
	    pkt_fifo_wr_en <= 1'b0;
	    rd_fifo_flag   <= 1'b0;
	    fil_in_state   <= WAIT_FIRST_PKT;
        o_key_bit        <= 32'b0;
        o_key_bit_valid  <= 1'b0;
    end
    else begin
        case(fil_in_state)
            WAIT_FIRST_PKT: begin
                o_key_bit        <= 32'b0;
                o_key_bit_valid  <= 1'b0;
                rd_fifo_flag <= 1'b0;
                if(s_axis_tvalid) begin
                    if(s_axis_tdata[191:184]==`IPPROT_UDP) begin
                        pkt_fifo_wr_en <= 1'b1;
					    fil_in_state   <= WAIT_SECOND_PKT;
                    end
                    else begin
                        pkt_fifo_wr_en <= 1'b0;
                        fil_in_state <= WAIT_FIRST_PKT;
                    end
                end
                else begin
                    pkt_fifo_wr_en <= 1'b0;
				    fil_in_state <= WAIT_FIRST_PKT;
                end
            end
            WAIT_SECOND_PKT:begin
                if(s_axis_tvalid) begin
				    rd_fifo_flag <= 1'b1;
				    pkt_fifo_wr_en <= 1'b1;
				    if (s_axis_tdata[47:32]==`DST_PORT) begin
				    	fil_in_state    <= BUFFER_DATA;
                        o_key_bit       <= s_axis_tdata[119:88];
                        o_key_bit_valid <= 1'b1;
				    end
				    else begin
				    	fil_in_state <= WAIT_FIRST_PKT;
				    end
			    end
			    else begin
			    	pkt_fifo_wr_en <= 1'b0;
			    	fil_in_state <= WAIT_SECOND_PKT;
			    end
            end
		    BUFFER_DATA:begin 
		    	rd_fifo_flag <= 1'b1;
		    	if(s_axis_tvalid && s_axis_tlast) begin
		    		pkt_fifo_wr_en <= 1'b1;
		    		fil_in_state <= WAIT_FIRST_PKT;
		    	end
		    	else if(s_axis_tvalid) begin
		    		pkt_fifo_wr_en <= 1'b1;
		    		fil_in_state <= BUFFER_DATA;
		    	end
		    	else begin
		    		pkt_fifo_wr_en <= 1'b0;
		    		fil_in_state <= BUFFER_DATA;
		    	end
		    end

        endcase
    end 
end

//提取key后，清空fifo
localparam  FIFO_OUT_IDLE   = 3'b000,//起始状态机跳转
   			FLUSH_FIFO      = 3'b001;//一包数据后状态机跳转

reg [2:0] fifo_out_state;

always @(posedge axis_aclk) begin
    if (!axis_resetn) begin
        pkt_fifo_rd_en <= 1'b0;
        fifo_out_state <= FIFO_OUT_IDLE;
    end 
    else begin
        case (fifo_out_state)
            FIFO_OUT_IDLE: begin
                if (!pkt_fifo_empty) begin
                    fifo_out_state <= FLUSH_FIFO;
                end
                else begin
                    fifo_out_state <= FIFO_OUT_IDLE;
                end
            end
            FLUSH_FIFO: begin
                if (!pkt_fifo_empty) begin
                    pkt_fifo_rd_en <= 1'b1;
                    fifo_out_state <= FLUSH_FIFO;
                end
                else begin
                    pkt_fifo_rd_en <= 1'b0;
                    fifo_out_state <= FIFO_OUT_IDLE;
                end
            end
        endcase
    end
end


endmodule