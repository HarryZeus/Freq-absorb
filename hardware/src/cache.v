`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/02 09:20:36
// Design Name: 
// Module Name: cache
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

module cache #(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
   	parameter C_S_AXIS_TUSER_WIDTH = 128,
    parameter KEY_WIDTH  		   = 32 ,
    parameter TCAM_MATCH_ADDR      = 10
)(
    input  axis_aclk  , 
    input  axis_resetn, 
    
    input  [C_S_AXIS_DATA_WIDTH-1:0]           s_axis_tdata ,
    input  [((C_S_AXIS_DATA_WIDTH/8))-1:0]     s_axis_tkeep ,
    input  [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_tuser ,
    input                                      s_axis_tvalid,
    output                                     s_axis_tready,
    input                                      s_axis_tlast ,
        
    input  [C_S_AXIS_DATA_WIDTH-1:0]           s_axis_op4_tdata ,
    input  [((C_S_AXIS_DATA_WIDTH/8))-1:0]     s_axis_op4_tkeep ,
    input  [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_op4_tuser ,
    input                                      s_axis_op4_tvalid,
    output                                     s_axis_op4_tready,
    input                                      s_axis_op4_tlast ,
    
    output reg [C_S_AXIS_DATA_WIDTH-1:0]       o_op0_stash_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] o_op0_stash_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      o_op0_stash_tuser ,
    output reg                                 o_op0_stash_tvalid,
    input                                      o_op0_stash_tready,
    output reg                                 o_op0_stash_tlast ,
    
    output reg [C_S_AXIS_DATA_WIDTH-1:0]       o_m_axis_op1_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] o_m_axis_op1_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      o_m_axis_op1_tuser ,
    output reg                                 o_m_axis_op1_tvalid,
    input                                      o_m_axis_op1_tready,
    output reg                                 o_m_axis_op1_tlast 
);

ila_1_cache ila_cache (
	.clk(axis_aclk), // input wire clk

	.probe0(s_axis_tdata ), // input wire [255:0]  probe0  
	.probe1(s_axis_tkeep ), // input wire [31:0]  probe1 
	.probe2(s_axis_tuser ), // input wire [127:0]  probe2 
	.probe3(s_axis_tvalid), // input wire [0:0]  probe3 
	.probe4(s_axis_tready), // input wire [0:0]  probe4 
	.probe5(s_axis_tlast ), // input wire [0:0]  probe5 
	.probe6 (o_m_axis_op1_tdata ), // input wire [255:0]  probe6 
	.probe7 (o_m_axis_op1_tkeep ), // input wire [31:0]  probe7 
	.probe8 (o_m_axis_op1_tuser ), // input wire [127:0]  probe8 
	.probe9 (o_m_axis_op1_tvalid), // input wire [0:0]  probe9 
	.probe10(o_m_axis_op1_tready), // input wire [0:0]  probe10 
	.probe11(o_m_axis_op1_tlast ) // input wire [0:0]  probe11
);

wire [KEY_WIDTH-1:0]                        key_bit      ;
wire                                        key_bit_valid;
wire                                        key_bit_mask ;

wire                                       key_tcam_busy      ;
wire                                       key_tcam_match     ;
wire [TCAM_MATCH_ADDR-1:0]                 key_tcam_match_addr;
wire                                       key_tcam_end       ;


cache_tcam_cfg cache_tcam_cfg (
    .axis_clk               (axis_aclk             ),
    .aresetn                (axis_resetn           ),

    .ctrl_s_axis_tdata      (s_axis_op4_tdata      ),
    .ctrl_s_axis_tuser      (s_axis_op4_tuser      ),
    .ctrl_s_axis_tkeep      (s_axis_op4_tkeep      ),
    .ctrl_s_axis_tvalid     (s_axis_op4_tvalid     ),
    .ctrl_s_axis_tlast      (s_axis_op4_tlast      ),

    .i_key_bit              (key_bit               ),     
    .i_key_bit_valid        (key_bit_valid         ),
    .i_key_bit_mask         (key_bit_mask          ),

    .o_key_tcam_busy        (key_tcam_busy         ),
    .o_key_tcam_match       (key_tcam_match        ),
    .o_key_tcam_match_addr  (key_tcam_match_addr   ),
    .o_key_tcam_end         (key_tcam_end          )
);

extract_key cache_extracter(
    .axis_aclk          (axis_aclk    ),
    .axis_resetn        (axis_resetn  ),
    
    .s_axis_tdata       (s_axis_tdata ),
    .s_axis_tkeep       (s_axis_tkeep ),
    .s_axis_tuser       (s_axis_tuser ),
    .s_axis_tvalid      (s_axis_tvalid),
    .s_axis_tready      (s_axis_tready),
    .s_axis_tlast       (s_axis_tlast ),  
      
    .o_key_bit          (key_bit      ),
    .o_key_bit_valid    (key_bit_valid),
    .o_key_bit_mask     (key_bit_mask )
);


reg                                        pkt_fifo_rd_en;
reg                                        pkt_fifo_wr_en;
wire [C_S_AXIS_DATA_WIDTH-1:0]		       tdata_fifo;
wire [C_S_AXIS_TUSER_WIDTH-1:0]		       tuser_fifo;
wire [C_S_AXIS_DATA_WIDTH/8-1:0]	       tkeep_fifo;
wire								       tlast_fifo;
wire                                       tvalid_fifo;
wire                                       tready_fifo; 

wire                                       pkt_fifo_nearly_full;
wire                                       pkt_fifo_empty;
reg                                        r_tlast_fifo;
reg                                        rd_fifo_flag; 

reg [C_S_AXIS_DATA_WIDTH-1:0]	           r_s_axis_tdata ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]	           r_s_axis_tuser ;
reg [C_S_AXIS_DATA_WIDTH/8-1:0]            r_s_axis_tkeep ;
reg                                        r_s_axis_tvalid;
reg                                        r_s_axis_tlast ;      

always @(posedge axis_aclk) begin
    if(!axis_resetn) begin
        r_s_axis_tdata  <= 256'b0;  
        r_s_axis_tuser  <= 128'b0; 
        r_s_axis_tkeep  <= 64'b0 ; 
        r_s_axis_tvalid <= 1'b0  ;
        r_s_axis_tlast  <= 1'b0  ; 
    end
    else begin
        r_s_axis_tdata  <= s_axis_tdata ;
        r_s_axis_tuser  <= s_axis_tuser ;
        r_s_axis_tkeep  <= s_axis_tkeep ;
        r_s_axis_tvalid <= s_axis_tvalid;
        r_s_axis_tlast  <= s_axis_tlast ;
    end
end


fallthrough_small_fifo #(
	.WIDTH(256+32+128+3),
	.MAX_DEPTH_BITS(10)
)
cache_fifo
(
	.din					({r_s_axis_tdata,r_s_axis_tkeep,r_s_axis_tuser,r_s_axis_tvalid,r_s_axis_tready,r_s_axis_tlast}),
	.wr_en					(pkt_fifo_wr_en ),
	.rd_en					(pkt_fifo_rd_en),//在tcam忙的时候切换下一个信号
	.dout					({tdata_fifo,tkeep_fifo,tuser_fifo,tvalid_fifo,tready_fifo,tlast_fifo}),
	.full					(),
	.prog_full				(),
	.nearly_full			(pkt_fifo_nearly_full),
	.empty					(pkt_fifo_empty),
	.reset					(~axis_resetn),
	.clk					(axis_aclk)
);

// assign s_axis_tready = ((o_m_axis_op1_tready || o_op0_stash_tready) && !pkt_fifo_nearly_full);

always @(posedge axis_aclk) begin
    if (!axis_resetn) begin
        r_tlast_fifo <= 0;    
    end 
    else begin
        r_tlast_fifo <= tlast_fifo; 
    end
end

reg [2:0] fil_in_state;

localparam  WAIT_FIRST_PKT  = 3'b000,
            WAIT_SECOND_PKT = 3'b001,
            BUFFER_CTL      = 3'b010,
            BUFFER_DATA     = 3'b011;

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
	    pkt_fifo_wr_en <= 1'b0;
	    rd_fifo_flag <= 1'b0;
	    fil_in_state <= WAIT_FIRST_PKT;
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
				    	fil_in_state <= BUFFER_DATA;
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
            FLUSH_CACHE_OP1_TDATA  = 3'b010,
            FLUSH_STASH_DATA       = 3'b011;

always @(posedge axis_aclk) begin
        if(!axis_resetn) begin
            pkt_fifo_rd_en <= 1'b0;
   		    fil_out_state <= FIL_OUT_IDLE;
   		    o_op0_stash_tdata      <= 0; 
            o_op0_stash_tkeep      <= 0;
            o_op0_stash_tuser      <= 0;
            o_op0_stash_tvalid     <= 0;
            o_op0_stash_tlast      <= 0;

            o_m_axis_op1_tdata     <= 0; 
            o_m_axis_op1_tkeep     <= 0;
            o_m_axis_op1_tuser     <= 0;
            o_m_axis_op1_tvalid    <= 0;
            o_m_axis_op1_tlast     <= 0;      
        end
        else begin
            case(fil_out_state)
   			    FIL_OUT_IDLE:begin//fifo不是一开始就有数据，要等待3包数据之后才有数据

                    o_op0_stash_tdata      <= 0; 
                    o_op0_stash_tkeep      <= 0;
                    o_op0_stash_tuser      <= 0;
                    o_op0_stash_tvalid     <= 0;
                    o_op0_stash_tlast      <= 0;

                    o_m_axis_op1_tdata     <= 0; 
                    o_m_axis_op1_tkeep     <= 0;
                    o_m_axis_op1_tuser     <= 0;
                    o_m_axis_op1_tvalid    <= 0;
                    o_m_axis_op1_tlast     <= 0;
                   
   			    	if(key_tcam_end) begin //读出需要提前一拍取
                        if(key_tcam_match)
                            fil_out_state      <= FLUSH_CACHE_OP1_TDATA;
                        else
                            fil_out_state      <= FLUSH_STASH_DATA;
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
   					if(key_tcam_match) begin
   						fil_out_state       <= FLUSH_CACHE_OP1_TDATA;
   						o_m_axis_op1_tdata  <= tdata_fifo;
   						o_m_axis_op1_tkeep  <= tkeep_fifo;
   						o_m_axis_op1_tuser  <= tuser_fifo;
   						o_m_axis_op1_tvalid <= 1'b1;
   						o_m_axis_op1_tlast  <= tlast_fifo;
   					end
   					else begin
   						fil_out_state <= FLUSH_STASH_DATA;
   						o_op0_stash_tdata  <= tdata_fifo;
   						o_op0_stash_tkeep  <= tkeep_fifo;
   						o_op0_stash_tuser  <= tuser_fifo;
   						o_op0_stash_tvalid <= 1'b1;
   						o_op0_stash_tlast  <= tlast_fifo;
   					end
   				end
   				else begin //回到初始状态
   					pkt_fifo_rd_en <= 1'b0;
   					fil_out_state <= FIL_OUT_IDLE; //fifo空了一定可以回到初始状态去取数据，因为要至少有三拍，空的状态置高
   					o_m_axis_op1_tdata  <= 0;//最后一拍读取的数据无效
   					o_m_axis_op1_tkeep  <= 0;
   					o_m_axis_op1_tuser  <= 0;
   					o_m_axis_op1_tvalid <= 0;
   					o_m_axis_op1_tlast  <= 0;
   					o_op0_stash_tdata   <= 0 ;
   					o_op0_stash_tkeep   <= 0 ;
   					o_op0_stash_tuser   <= 0 ;
   					o_op0_stash_tvalid  <= 0 ;
   					o_op0_stash_tlast   <= 0 ;
   				end
   			end
   			FLUSH_CACHE_OP1_TDATA:begin
   				if(o_m_axis_op1_tready)begin //下一个模块准备好了
   					if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
   						fil_out_state <= FIL_OUT_SWITCH;
   						pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
                        o_m_axis_op1_tdata <= tdata_fifo;
                        o_m_axis_op1_tkeep <= tkeep_fifo;
                        o_m_axis_op1_tuser <= tuser_fifo;
                        o_m_axis_op1_tvalid <=1'b1;
                        o_m_axis_op1_tlast <= tlast_fifo;
   					end
   					else begin
   						fil_out_state <= FLUSH_CACHE_OP1_TDATA;
   						if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
   							pkt_fifo_rd_en <= 1'b1;
                            o_m_axis_op1_tdata <= tdata_fifo;
                            o_m_axis_op1_tkeep <= tkeep_fifo;
                            o_m_axis_op1_tuser <= tuser_fifo;
                            o_m_axis_op1_tvalid <=1'b0;
                            o_m_axis_op1_tlast <= 1'b0;
   						end
   						else begin //fifo没有空，继续读
   							if(pkt_fifo_rd_en)begin
   								o_m_axis_op1_tdata  <= tdata_fifo;
   								o_m_axis_op1_tkeep  <= tkeep_fifo;
   								o_m_axis_op1_tuser  <= tuser_fifo;
   								o_m_axis_op1_tvalid <= 1'b1;
   								o_m_axis_op1_tlast  <= tlast_fifo;
   							end
   							else begin
   								o_m_axis_op1_tdata  <= 0;
   								o_m_axis_op1_tkeep  <= 0;
   								o_m_axis_op1_tuser  <= 0;
   								o_m_axis_op1_tvalid <= 0;
   								o_m_axis_op1_tlast  <= 0;
   							end
   							pkt_fifo_rd_en <= 1'b1;
   						end
   					end
   				end
   				else begin
   					pkt_fifo_rd_en <= 1'b0;
   					o_m_axis_op1_tdata  <= 0;
   					o_m_axis_op1_tkeep  <= 0;
   					o_m_axis_op1_tuser  <= 0;
   					o_m_axis_op1_tvalid <= 0;
   					o_m_axis_op1_tlast  <= 0;
   					fil_out_state <= FLUSH_CACHE_OP1_TDATA;
   				end
   			end
   			FLUSH_STASH_DATA:begin
   				if(o_op0_stash_tready)begin
   					if(!r_tlast_fifo & tlast_fifo) begin
                        o_op0_stash_tdata  <= tdata_fifo;
                        o_op0_stash_tkeep  <= tkeep_fifo;
                        o_op0_stash_tuser  <= tuser_fifo;
                        o_op0_stash_tvalid <= 1'b1;
                        o_op0_stash_tlast  <= tlast_fifo;
   						fil_out_state      <= FIL_OUT_SWITCH;
   						pkt_fifo_rd_en     <= 1'b1;
   					end
   					else begin
   						fil_out_state <= FLUSH_STASH_DATA;
   						if(pkt_fifo_empty)begin
   							pkt_fifo_rd_en     <= 1'b1;
   							o_op0_stash_tdata  <= 0;
   						    o_op0_stash_tkeep  <= 0;
   						    o_op0_stash_tuser  <= 0;
   						    o_op0_stash_tvalid <= 0;
   						    o_op0_stash_tlast  <= 0;
   						end
   						else begin
   							if(pkt_fifo_rd_en)begin
   								o_op0_stash_tdata  <= tdata_fifo;
   								o_op0_stash_tkeep  <= tkeep_fifo;
   								o_op0_stash_tuser  <= tuser_fifo;
   								o_op0_stash_tvalid <= 1'b1;
   								o_op0_stash_tlast  <= tlast_fifo;
   							end
   							else begin
   								o_op0_stash_tdata  <= 0;
   						    	o_op0_stash_tkeep  <= 0;
   						    	o_op0_stash_tuser  <= 0;
   						    	o_op0_stash_tvalid <= 0;
   						    	o_op0_stash_tlast  <= 0;
   							end
   							pkt_fifo_rd_en <= 1'b1;
   						end
   					end
   				end
   				else begin
   					pkt_fifo_rd_en <= 1'b0;
   					o_op0_stash_tdata   <= 0 ;
   					o_op0_stash_tkeep   <= 0 ;
   					o_op0_stash_tuser   <= 0 ;
   					o_op0_stash_tvalid  <= 0 ;
   					o_op0_stash_tlast   <= 0 ;
   				end
   			end
   		endcase
   	 end
end

endmodule