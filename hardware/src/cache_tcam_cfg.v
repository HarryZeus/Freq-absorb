`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/10 09:30:03
// Design Name: 
// Module Name: data_path_tcam_cfg
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
//该模块提取配置到tcam模块里的数据

module cache_tcam_cfg#(
    parameter C_AXIS_DATA_WIDTH  = 256 ,
    parameter C_AXIS_TUSER_WIDTH = 128 ,
    parameter KEY_WIDTH  		 = 32 ,
    parameter TCAM_MATCH_ADDR    = 5
)(
    input                 axis_clk,
    input                 aresetn ,

    input [C_AXIS_DATA_WIDTH-1:0  ]            ctrl_s_axis_tdata      ,
    input [C_AXIS_TUSER_WIDTH-1:0 ]            ctrl_s_axis_tuser      ,
    input [C_AXIS_DATA_WIDTH/8-1:0]            ctrl_s_axis_tkeep      ,
    input                                      ctrl_s_axis_tvalid     ,
    input                                      ctrl_s_axis_tlast      ,

    input [KEY_WIDTH-1:0]              		   i_key_bit               ,             
    input                                      i_key_bit_valid         ,   
	input         	                		   i_key_bit_mask          ,  
  
    output wire                                o_key_tcam_busy         ,        
    output wire                                o_key_tcam_match        ,
	output reg								   o_key_tcam_end		   ,
    output wire [TCAM_MATCH_ADDR-1:0]          o_key_tcam_match_addr   

    );


//===================== OP=0 ====================================
reg [KEY_WIDTH-1:0] r_path_bit;
reg         		r_path_bit_vld;
reg [1:0]   		cmp_state;
always @(posedge axis_clk) begin
    if(!aresetn) begin
        r_path_bit		<= 32'd0    ;
        r_path_bit_vld  <= 1'd0      ;
		cmp_state       <= 2'd0      ;
    end  
    else begin
		case(cmp_state)
			0: begin
				o_key_tcam_end  <= 1'b0;
				if(i_key_bit_valid)begin  
					r_path_bit		<= i_key_bit  ; //key
        			r_path_bit_vld  <= 1'd1      ;
					cmp_state <= 2'd1;
    			end
    			else begin
        			r_path_bit		<= 32'hffffffff;//如果非进行tcam查找的数据，让数据输出错误
        			r_path_bit_vld  <= 1'd0      ;
					cmp_state <= 2'd0;
    			end
			end
			1:begin //空拍，等
				cmp_state 		<= 2'd2;
				r_path_bit_vld  <= 1'd0      ;
				r_path_bit		<= 32'hffffffff;
				o_key_tcam_end  <= 1'b1;
			end
			2:begin
				cmp_state 		<= 2'd3;
				r_path_bit_vld  <= 1'd0      ;
				r_path_bit		<= 32'hffffffff;
				o_key_tcam_end  <= 1'b0;
			end
			3:begin
				if(o_key_tcam_match) begin
					r_path_bit		<= 32'hffffffff;//如果非进行tcam查找的数据，让数据输出错误
        			r_path_bit_vld  <= 1'd1      ;
					cmp_state       <= 2'd0      ;
				end
				else begin
					cmp_state       <= 2'd0      ;//如果一次匹配之后没有匹配上
				end
			end
		endcase
	end
end


wire [C_AXIS_DATA_WIDTH-1:0]	ctrl_s_axis_tdata_swapped;
assign ctrl_s_axis_tdata_swapped = ctrl_s_axis_tdata;
// assign ctrl_s_axis_tdata_swapped = {	ctrl_s_axis_tdata[0 +:8],      	//[255:248]
// 										ctrl_s_axis_tdata[8 +:8],		//[247:240]
// 										ctrl_s_axis_tdata[16+:8],		//[239:232]
// 										ctrl_s_axis_tdata[24+:8],		//[231:224]
// 										ctrl_s_axis_tdata[32+:8],		//[223:216]
// 										ctrl_s_axis_tdata[40+:8],		//[215:208]
// 										ctrl_s_axis_tdata[48+:8],		//[207:200]
// 										ctrl_s_axis_tdata[56+:8],		//[199:192]
// 										ctrl_s_axis_tdata[64+:8],		//[191:184]
// 										ctrl_s_axis_tdata[72+:8],		//[183:176]
// 										ctrl_s_axis_tdata[80+:8],		//[175:168]
// 										ctrl_s_axis_tdata[88+:8],		//[167:160]
// 										ctrl_s_axis_tdata[96+:8],		//[159:152]
// 										ctrl_s_axis_tdata[104+:8],		//[151:144]
// 										ctrl_s_axis_tdata[112+:8],		//[143:136]
// 										ctrl_s_axis_tdata[120+:8],		//[135:128]
// 										ctrl_s_axis_tdata[128+:8],		//[127:120]
// 										ctrl_s_axis_tdata[136+:8],		//[119:112]
// 										ctrl_s_axis_tdata[144+:8],		//[111:104]
// 										ctrl_s_axis_tdata[152+:8],		//[103:96 ]
// 										ctrl_s_axis_tdata[160+:8],		//[95 :88 ]
// 										ctrl_s_axis_tdata[168+:8],		//[87 :80 ]
// 										ctrl_s_axis_tdata[176+:8],		//[79 :72 ]
// 										ctrl_s_axis_tdata[184+:8],		//[71 :64 ]
// 										ctrl_s_axis_tdata[192+:8],		//[63 :56 ]
// 										ctrl_s_axis_tdata[200+:8],		//[55 :48 ]
// 										ctrl_s_axis_tdata[208+:8],		//[47 :40 ]
// 										ctrl_s_axis_tdata[216+:8],		//[39 :32 ]
// 										ctrl_s_axis_tdata[224+:8],		//[31 :24 ]
// 										ctrl_s_axis_tdata[232+:8],		//[23 :16 ]
// 										ctrl_s_axis_tdata[240+:8],		//[15 :08 ]
// 										ctrl_s_axis_tdata[248+:8]};		//[07 :00 ]

reg [KEY_WIDTH-1:0] r_cam_mask ;

reg [4:0]  ctrl_fifo_state;
localparam TCAM_FIFO_IDLE	= 0;
localparam BUFFER_TCAM 	 	= 1;
localparam FLUSH_REST_C  	= 2;

reg [255:0] 				r_fifo_tdata     ;
reg         				r_fifo_tvalid    ;
reg         				r_fifo_tlast     ;
reg [TCAM_MATCH_ADDR-1:0]   r_fifo_tcam_addr ;
reg 						r_dp_tcam_busy   ;
//因为不明确TCAM的busy信号是什么时候拉高，
//所以这里对ctrl信号做一个fifo缓存，当busy有效时候，从fifo读取控制报文
//判别有效数据进入FIFO
always @(posedge axis_clk) begin
    if (!aresetn) begin
        r_fifo_tcam_addr <= 5'd0;
    end else begin
		if(r_fifo_tcam_addr == 5'd31 &&(r_dp_tcam_busy == 1'b1)) begin //最后一个数据写到tcam了，且计数满了
	    	r_fifo_tcam_addr <= 5'd0;
	    end
	    else if(r_fifo_tvalid) begin
	    	r_fifo_tcam_addr <= r_fifo_tcam_addr +1'b1;
	    end
	    else begin
	    	r_fifo_tcam_addr <= r_fifo_tcam_addr;
	    end
    end
end

always @(posedge axis_clk) begin
	if(!aresetn) begin
		r_fifo_tdata    <= 256'd0;
		r_fifo_tvalid   <= 1'b0  ;
		r_fifo_tlast    <= 1'b0  ;
		ctrl_fifo_state <= TCAM_FIFO_IDLE;
		r_cam_mask      <= 32'd0	;
	end
	else begin
		case(ctrl_fifo_state)
			TCAM_FIFO_IDLE:begin
				r_fifo_tdata  		<= 256'd0;
				r_fifo_tvalid 		<= 1'b0;
				r_fifo_tlast  		<= 1'b0;
				if(ctrl_s_axis_tvalid) begin
					ctrl_fifo_state <= BUFFER_TCAM;
				end
				else begin //报文没进来过，2.报文返回了一次但是没配置下一次
					ctrl_fifo_state <= TCAM_FIFO_IDLE;
					r_cam_mask <= 32'd0;
				end
			end
			BUFFER_TCAM:begin //由上位机下发只有该固定格式的配置报文
				if(ctrl_s_axis_tvalid) begin
					r_fifo_tdata  <= ctrl_s_axis_tdata_swapped[255:0];
					r_fifo_tvalid <= 1'b1;
					if(ctrl_s_axis_tlast) begin
						ctrl_fifo_state <= TCAM_FIFO_IDLE;
						r_fifo_tlast  <= 1'b1;
					end
					else begin
						ctrl_fifo_state <= FLUSH_REST_C;
						r_fifo_tlast  <= 1'b0;
					end
				end
				else begin
					r_fifo_tdata  <= 256'd0;
					r_fifo_tvalid <= 1'b0;
					r_fifo_tlast  <= 1'b0;
					ctrl_fifo_state <= TCAM_FIFO_IDLE;
				end
			end
			FLUSH_REST_C:begin
				r_fifo_tdata  <= 256'd0;
				r_fifo_tvalid <= 1'b0;
				r_fifo_tlast  <= 1'b0;//配置报文数据格式不对，寄存器处理清零
				if(ctrl_s_axis_tlast)
					ctrl_fifo_state <= TCAM_FIFO_IDLE;
				else
					ctrl_fifo_state <= FLUSH_REST_C;
			end
		endcase
	end
end

wire [C_AXIS_DATA_WIDTH-1:0]     c_data_tcam                ;
wire 					         c_axis_tvalid              ;
wire 					         c_axis_tlast               ;
wire [TCAM_MATCH_ADDR-1:0]       c_axis_tcam_addr           ;

wire                             c_data_fifo_nearly_full    ;
wire                             c_data_fifo_empty          ;

wire 						     w_dp_tcam_busy1			;
wire 						     w_dp_tcam_match1			;
wire [TCAM_MATCH_ADDR-1:0] 	     w_dp_tcam_match_addr1		;
wire 						     w_dp_tcam_busy2			;
wire 						     w_dp_tcam_match2			;
wire [TCAM_MATCH_ADDR-1:0] 	     w_dp_tcam_match_addr2		;


always @(posedge axis_clk) begin
	if(!aresetn) 
		r_dp_tcam_busy <= 1'b0;
	else
		r_dp_tcam_busy <= w_dp_tcam_busy2;
end
fallthrough_small_fifo #(
	.WIDTH(263),
	.MAX_DEPTH_BITS(10)
)
cache_cfg_fifo
(
	.din									({r_fifo_tdata,r_fifo_tvalid,r_fifo_tlast,r_fifo_tcam_addr}),
	.wr_en									(r_fifo_tvalid ),
	.rd_en									(r_dp_tcam_busy),//在tcam忙的时候切换下一个信号
	.dout									({c_data_tcam,c_axis_tvalid,c_axis_tlast,c_axis_tcam_addr}),
	.full									(),
	.prog_full								(),
	.nearly_full							(),
	.empty									(c_data_fifo_empty),
	.reset									(~aresetn),
	.clk									(axis_clk)
);

wire   c_wr_en_cam;
assign c_wr_en_cam = c_axis_tvalid && !c_data_fifo_empty;//数据从fifo有效输出并且fifo有数据时候写入
//we use mode Block RAM-Based which need one cycle delay xapp1151 write operation
//tcam会延迟几拍出
// tcam1 for lookup
// cam_top # ( 
//     .C_DEPTH			(16	),
//     .C_WIDTH			(128),
//     .C_MEM_INIT			(0	)
//  //   .C_MEM_INIT_FILE	("./cam_init_file.mif")
// )		   
// //TODO remember to change it back.
// cam_datapath_lookup1
// (
//     .CLK					(axis_clk				 ),
//     .CMP_DIN				(r_path_bit				 ),//来自数据提取的128b有效字段
//     .CMP_DATA_MASK		(            			 ),//来自数据提取的128b实际有效位
//     .BUSY				(w_dp_tcam_busy1		 ),
//     .MATCH				(w_dp_tcam_match1		 ),
//     .MATCH_ADDR			(w_dp_tcam_match_addr1	 ),

//     .WE                  (c_wr_en_cam             ),//控制报文算好的128b数据
//     .WR_ADDR             (c_axis_tcam_addr[3:0]   ),//由控制报文下发的5b的查找地址
//     .DATA_MASK           (r_cam_mask			     ),//TODO do we need ternary matching?
//     .DIN                 (c_data_tcam[255:128]    ),//由控制报文下发的128b数据匹配路径
//     .EN					(1'b1					 )
// );	 

//tcam会延迟几拍出
// tcam1 for lookup
cam_top # ( 
    .C_DEPTH			(32),
    .C_WIDTH			(32),
    .C_MEM_INIT			(0	)
 //   .C_MEM_INIT_FILE	("./cam_init_file.mif")
)		   
cam_datapath_lookup2
(
    .CLK				(axis_clk				 ),
    .CMP_DIN			(r_path_bit				 ),//来自数据提取的128b有效字段
    .CMP_DATA_MASK		(           			 ),//来自数据提取的128b实际有效位
    .BUSY				(w_dp_tcam_busy2		 ),
    .MATCH				(w_dp_tcam_match2		 ),
    .MATCH_ADDR			(w_dp_tcam_match_addr2	 ),

    .WE                 (c_wr_en_cam             ),//控制报文算好的128b数据
    .WR_ADDR            (c_axis_tcam_addr        ),//由控制报文下发的5b的查找地址
    .DATA_MASK          (r_cam_mask			 	 ),//TODO do we need ternary matching?
    .DIN                (c_data_tcam[119:88]     ),//4 bytes Key in
    .EN					(1'b1					 )
);	 



assign o_key_tcam_busy       = w_dp_tcam_busy2;
assign o_key_tcam_match      = w_dp_tcam_match2;
// assign o_key_tcam_end        = (w_dp_tcam_match2) ? 1'b1 : 1'b0;
assign o_key_tcam_match_addr = w_dp_tcam_match_addr2;


// reg [3:0] r_dp_tcam_match_addr;
// reg       r_dp_tcam_match     ;


// always @(posedge axis_clk) begin
// 	if(!aresetn) begin
// 		r_dp_tcam_match_addr <= 5'd0;
// 		r_dp_tcam_match <= 1'b0;
// 	end
// 	else begin
// 		if(w_dp_tcam_match2)begin
// 			r_dp_tcam_match_addr <= w_dp_tcam_match_addr2;
// 			r_dp_tcam_match <= 1'b1;
// 		end
// 		else begin
// 			r_dp_tcam_match_addr <= r_dp_tcam_match_addr;
// 			r_dp_tcam_match <= 1'b0;
// 		end
// 	end
// end

// // assign w_dp_tcam_match_addr = (w_dp_tcam_match2)?{1'b1,w_dp_tcam_match_addr2}:{1'b0,w_dp_tcam_match_addr1};


// always @(posedge axis_clk) begin
// 	if(!aresetn) begin
// 		o_key_tcam_busy       <= 1'b0;
// 		o_key_tcam_match      <= 1'b0;
// 		o_key_tcam_match_addr <= 5'd0;
// 	end
// 	else begin
// 		o_key_tcam_busy       <= r_dp_tcam_busy      ;
// 		o_key_tcam_match      <= r_dp_tcam_match     ;//匹配状态只持续一个周期
// 		o_key_tcam_match_addr <= r_dp_tcam_match_addr;
// 	end
// end

endmodule