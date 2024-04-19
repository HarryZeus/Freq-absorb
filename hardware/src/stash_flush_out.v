`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/14 20:10:18
// Design Name: 
// Module Name: stash_flush_out
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


module stash_flush_out #(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
   	parameter C_S_AXIS_TUSER_WIDTH = 128,
    parameter KEY_WIDTH  		   = 32 ,
    parameter TCAM_MATCH_ADDR      = 5
)(

input           axis_aclk,
input           axis_resetn,
input           i_tcam_match,
input           i_tcam_match_end,

input  [255:0]  s_axis_tdata , // op0
input  [31:0]   s_axis_tkeep ,
input  [127:0]  s_axis_tuser ,
input           s_axis_tvalid,
output          s_axis_tready,
input           s_axis_tlast ,

output reg [255:0]  o_op1_stash_tdata ,
output reg [31:0]   o_op1_stash_tkeep ,
output reg [127:0]  o_op1_stash_tuser ,
output reg          o_op1_stash_tvalid,
input           	o_op1_stash_tready,
output reg        	o_op1_stash_tlast ,

output reg [255:0]  o_op0_serve_tdata ,
output reg [31:0]   o_op0_serve_tkeep ,
output reg [127:0]  o_op0_serve_tuser ,
output reg          o_op0_serve_tvalid,
input           	o_op0_serve_tready,
output reg         	o_op0_serve_tlast 

);

localparam  WAIT_FIRST_PKT  = 3'b000,
            WAIT_SECOND_PKT = 3'b001,
            BUFFER_CTL      = 3'b010,
            BUFFER_DATA     = 3'b011;

wire        pkt_fifo_nearly_full;
wire        pkt_fifo_empty;

assign s_axis_tready = (!pkt_fifo_nearly_full);
 
// reg  [3:0] vlan_id;
// wire [11:0] w_vlan_id;
// assign  w_vlan_id = tdata_fifo[116+:12];
 
wire [C_S_AXIS_DATA_WIDTH-1:0]		 tdata_fifo;
wire [C_S_AXIS_TUSER_WIDTH-1:0]		 tuser_fifo;
wire [C_S_AXIS_DATA_WIDTH/8-1:0]	 tkeep_fifo;
wire								 tlast_fifo;

reg [C_S_AXIS_DATA_WIDTH-1:0]		 r_tdata_fifo;
reg [C_S_AXIS_TUSER_WIDTH-1:0]		 r_tuser_fifo;
reg [C_S_AXIS_DATA_WIDTH/8-1:0]	 	 r_tkeep_fifo;
reg								 	 r_tlast_fifo;
 
reg                                  pkt_fifo_wr_en,pkt_fifo_rd_en  ;
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
	if (!axis_resetn) begin
		r_tdata_fifo  <= 0;
		r_tuser_fifo  <= 0;
		r_tkeep_fifo  <= 0;
		r_tlast_fifo  <= 0;
	end else begin
		r_tdata_fifo  <= tdata_fifo;
		r_tuser_fifo  <= tuser_fifo;
		r_tkeep_fifo  <= tkeep_fifo;
		r_tlast_fifo  <= tlast_fifo;
	end
end


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
    end
    else begin
        case(fil_in_state)
            WAIT_FIRST_PKT: begin
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

reg [2:0]                          fil_out_state;

localparam  FIL_OUT_IDLE           = 3'b000,//起始状态机跳转
   			FIL_OUT_SWITCH         = 3'b001,//一包数据后状态机跳转
            FLUSH_OP1_TDATA        = 3'b010,
            FLUSH_OP0_DATA         = 3'b011;

always @(posedge axis_aclk) begin
        if(!axis_resetn) begin
            pkt_fifo_rd_en <= 1'b0;
   		    fil_out_state <= FIL_OUT_IDLE;
   		    o_op1_stash_tdata      <= 0; 
            o_op1_stash_tkeep      <= 0;
            o_op1_stash_tuser      <= 0;
            o_op1_stash_tvalid     <= 0;
            o_op1_stash_tlast      <= 0;

            o_op0_serve_tdata     <= 0; 
            o_op0_serve_tkeep     <= 0;
            o_op0_serve_tuser     <= 0;
            o_op0_serve_tvalid    <= 0;
            o_op0_serve_tlast     <= 0;      
        end
        else begin
            case(fil_out_state)
   			    FIL_OUT_IDLE:begin//fifo不是一开始就有数据，要等待3包数据之后才有数据

                    o_op1_stash_tdata      <= 0; 
                    o_op1_stash_tkeep      <= 0;
                    o_op1_stash_tuser      <= 0;
                    o_op1_stash_tvalid     <= 0;
                    o_op1_stash_tlast      <= 0;
        
                    o_op0_serve_tdata      <= 0; 
                    o_op0_serve_tkeep      <= 0;
                    o_op0_serve_tuser      <= 0;
                    o_op0_serve_tvalid     <= 0;
                    o_op0_serve_tlast      <= 0;
                   
   			    	if(i_tcam_match_end) begin //读出需要提前一拍取
                        if(i_tcam_match)
                            fil_out_state      <= FLUSH_OP1_TDATA;
                        else
                            fil_out_state      <= FLUSH_OP0_DATA;
   			    		    pkt_fifo_rd_en     <= 1'd1;
   			    	end
   			    	else begin
   			    		pkt_fifo_rd_en     <= 1'd0;
   			    		fil_out_state      <= FIL_OUT_IDLE;
   			    	end
   			    end
   			    FIL_OUT_SWITCH:begin
   				if(!pkt_fifo_empty) begin //连续读第二包数据，因为空状态置高比tdata输出要慢一拍
   					pkt_fifo_rd_en <= 1'b1;
   					if(i_tcam_match) begin
   						fil_out_state       <= FLUSH_OP1_TDATA;
   						o_op1_stash_tdata  <= tdata_fifo;
   						o_op1_stash_tkeep  <= tkeep_fifo;
   						o_op1_stash_tuser  <= tuser_fifo;
   						o_op1_stash_tvalid <= 1'b1;
   						o_op1_stash_tlast  <= tlast_fifo;
   					end
   					else begin
   						fil_out_state <= FLUSH_OP0_DATA;
   						o_op0_serve_tdata  <= tdata_fifo;
   						o_op0_serve_tkeep  <= tkeep_fifo;
   						o_op0_serve_tuser  <= tuser_fifo;
   						o_op0_serve_tvalid <= 1'b1;
   						o_op0_serve_tlast  <= tlast_fifo;
   					end
   				end
   				else begin //回到初始状态
   					pkt_fifo_rd_en <= 1'b0;
   					fil_out_state <= FIL_OUT_IDLE; //fifo空了一定可以回到初始状态去取数据，因为要至少有三拍，空的状态置高
   					o_op1_stash_tdata   <= 0;//最后一拍读取的数据无效
   					o_op1_stash_tkeep   <= 0;
   					o_op1_stash_tuser   <= 0;
   					o_op1_stash_tvalid  <= 0;
   					o_op1_stash_tlast   <= 0;
   					o_op0_serve_tdata   <= 0 ;
   					o_op0_serve_tkeep   <= 0 ;
   					o_op0_serve_tuser   <= 0 ;
   					o_op0_serve_tvalid  <= 0 ;
   					o_op0_serve_tlast   <= 0 ;
   				end
   			end
   			FLUSH_OP1_TDATA:begin
   				if(o_op1_stash_tready)begin //下一个模块准备好了
   					if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
   						fil_out_state <= FIL_OUT_SWITCH;
   						pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
                        o_op1_stash_tdata  <= tdata_fifo;
                        o_op1_stash_tkeep  <= tkeep_fifo;
                        o_op1_stash_tuser  <= tuser_fifo;
                        o_op1_stash_tvalid  <=1'b1;
                        o_op1_stash_tlast  <= tlast_fifo;
   					end
   					else begin
   						fil_out_state <= FLUSH_OP1_TDATA;
   						if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
   							pkt_fifo_rd_en <= 1'b1;
                            o_op1_stash_tdata <= tdata_fifo;
                            o_op1_stash_tkeep <= tkeep_fifo;
                            o_op1_stash_tuser <= tuser_fifo;
                            o_op1_stash_tvalid <=1'b0;
                            o_op1_stash_tlast <= 1'b0;
   						end
   						else begin //fifo没有空，继续读
   							if(pkt_fifo_rd_en)begin
   								o_op1_stash_tdata  <= tdata_fifo;
   								o_op1_stash_tkeep  <= tkeep_fifo;
   								o_op1_stash_tuser  <= tuser_fifo;
   								o_op1_stash_tvalid <= 1'b1;
   								o_op1_stash_tlast  <= tlast_fifo;
   							end
   							else begin
   								o_op1_stash_tdata  <= 0;
   								o_op1_stash_tkeep  <= 0;
   								o_op1_stash_tuser  <= 0;
   								o_op1_stash_tvalid <= 0;
   								o_op1_stash_tlast  <= 0;
   							end
   							pkt_fifo_rd_en <= 1'b1;
   						end
   					end
   				end
   				else begin
   					pkt_fifo_rd_en <= 1'b0;
   					o_op1_stash_tdata  <= 0;
   					o_op1_stash_tkeep  <= 0;
   					o_op1_stash_tuser  <= 0;
   					o_op1_stash_tvalid <= 0;
   					o_op1_stash_tlast  <= 0;
   					fil_out_state <= FLUSH_OP1_TDATA;
   				end
   			end
   			FLUSH_OP0_DATA:begin
   				if(o_op0_serve_tready)begin
   					if(!r_tlast_fifo & tlast_fifo) begin
                        o_op0_serve_tdata  <= tdata_fifo;
                        o_op0_serve_tkeep  <= tkeep_fifo;
                        o_op0_serve_tuser  <= tuser_fifo;
                        o_op0_serve_tvalid <= 1'b1;
                        o_op0_serve_tlast  <= tlast_fifo;
   						fil_out_state      <= FIL_OUT_SWITCH;
   						pkt_fifo_rd_en     <= 1'b1;
   					end
   					else begin
   						fil_out_state <= FLUSH_OP0_DATA;
   						if(pkt_fifo_empty)begin
   							pkt_fifo_rd_en     <= 1'b1;
   							o_op0_serve_tdata  <= 0;
   						    o_op0_serve_tkeep  <= 0;
   						    o_op0_serve_tuser  <= 0;
   						    o_op0_serve_tvalid <= 0;
   						    o_op0_serve_tlast  <= 0;
   						end
   						else begin
   							if(pkt_fifo_rd_en)begin
   								o_op0_serve_tdata  <= tdata_fifo;
   								o_op0_serve_tkeep  <= tkeep_fifo;
   								o_op0_serve_tuser  <= tuser_fifo;
   								o_op0_serve_tvalid <= 1'b1;
   								o_op0_serve_tlast  <= tlast_fifo;
   							end
   							else begin
   								o_op0_serve_tdata  <= 0;
   						    	o_op0_serve_tkeep  <= 0;
   						    	o_op0_serve_tuser  <= 0;
   						    	o_op0_serve_tvalid <= 0;
   						    	o_op0_serve_tlast  <= 0;
   							end
   							pkt_fifo_rd_en <= 1'b1;
   						end
   					end
   				end
   				else begin
   					pkt_fifo_rd_en <= 1'b0;
   					o_op0_serve_tdata   <= 0 ;
   					o_op0_serve_tkeep   <= 0 ;
   					o_op0_serve_tuser   <= 0 ;
   					o_op0_serve_tvalid  <= 0 ;
   					o_op0_serve_tlast   <= 0 ;
   				end
   			end
   		endcase
   	 end
end


endmodule
