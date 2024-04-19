`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/14 20:12:16
// Design Name: 
// Module Name: stash_wr_tcam
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


module stash_wr_tcam #(
    parameter C_AXIS_DATA_WIDTH  = 256 ,
    parameter C_AXIS_TUSER_WIDTH = 128 ,
    parameter KEY_WIDTH  		 = 32  ,
    parameter TCAM_MATCH_ADDR    = 5
)(

input               axis_aclk,
input               axis_resetn,

input [255:0]       s_op2_axis_tdata ,
input [32:0]        s_op2_axis_tkeep ,
input [127:0]       s_op2_axis_tuser ,
input               s_op2_axis_tvalid,
output              s_op2_axis_tready,
input               s_op2_axis_tlast ,

input [31:0]        i_op0_key        , //read
input               i_op0_key_valid  ,
output              o_op0_match      ,
output              o_op0_match_end  ,             

input [31:0]        i_op2_key        , //write
input               i_op2_key_valid  ,

output reg [255:0]  o_op5_stash_tdata ,
output reg [32:0]   o_op5_stash_tkeep ,
output reg [127:0]  o_op5_stash_tuser ,
output reg          o_op5_stash_tvalid,
input               i_op5_stash_tready,
output reg          o_op5_stash_tlast 

);

reg [1:0] 				r_key_flag;

assign o_op0_match     = (r_key_flag == 2'd1) ? o_key_tcam_match : 1'b0;
assign o_op0_match_end = (r_key_flag == 2'd1) ? o_key_tcam_end : 1'b0  ;

//////////////////////////////////////////////////////////////////////////////////

reg [KEY_WIDTH-1:0]     i_key_bit        ;
reg                     i_key_bit_valid  ;


wire [KEY_WIDTH-1:0]    w_i_op0_key      ;
wire                    w_i_op0_key_valid;
reg                     op0_fifo_wr_en   ;
reg                     op0_fifo_rd_en   ;
wire                    op0_fifo_empty   ;

wire [KEY_WIDTH-1:0]    w_i_op2_key      ;  //新改
wire                    w_i_op2_key_valid;
reg                     op2_fifo_wr_en   ;
reg                     op2_fifo_rd_en   ;
wire                    op2_fifo_empty   ;

reg [1:0]               key_flag         ; //初始为0，1表示当前key是op0_key, 2表示op2_key


// always @(posedge axis_aclk) begin
//     if(!axis_resetn) begin
//         r_i_op0_key       <= 0;
//         r_i_op0_key_valid <= 0;
//     end
//     else begin
//         r_i_op0_key       <= i_op0_key      ; 
//         r_i_op0_key_valid <= i_op0_key_valid;
//     end
// end
// always @(posedge axis_aclk) begin
//     if(!axis_resetn) begin
//         r_i_op2_key       <= 0;
//         r_i_op2_key_valid <= 0;
//     end
//     else begin
//         r_i_op2_key       <= i_op2_key      ; 
//         r_i_op2_key_valid <= i_op2_key_valid;
//     end
// end

// op0_key in fifo
always @(posedge axis_aclk) begin
    if (!axis_resetn) begin
        op0_fifo_wr_en <= 1'b0;
    end 
    else begin
        if (i_op0_key_valid) begin
            op0_fifo_wr_en <= 1'b1;
        end 
        else begin
            op0_fifo_wr_en <= 1'b0;
        end     
    end
end
// op2_key in fifo
always @(posedge axis_aclk) begin
    if (!axis_resetn) begin
        op2_fifo_wr_en <= 1'b0;
    end 
    else begin
        if (i_op2_key_valid) begin
            op2_fifo_wr_en <= 1'b1;
        end 
        else begin
            op2_fifo_wr_en <= 1'b0;
        end     
    end
end

fallthrough_small_fifo #(
	.WIDTH(33),
	.MAX_DEPTH_BITS(10)
)
key_op0_fifo
(
	.din									({i_op0_key, i_op0_key_valid}),
	.wr_en									(op0_fifo_wr_en),
	.rd_en									(op0_fifo_rd_en),
	.dout									({w_i_op0_key, w_i_op0_key_valid}),
	.full									(),
	.prog_full								(),
	.nearly_full							(),
	.empty									(op0_fifo_empty),
	.reset									(~axis_resetn),
	.clk									(axis_clk)
);

fallthrough_small_fifo #(
	.WIDTH(33),
	.MAX_DEPTH_BITS(10)
)
key_op2_fifo
(
	.din									({i_op2_key, i_op2_key_valid}),
	.wr_en									(op2_fifo_wr_en),
	.rd_en									(op2_fifo_rd_en),
	.dout									({w_i_op2_key, w_i_op2_key_valid}),
	.full									(),
	.prog_full								(),
	.nearly_full							(),
	.empty									(op2_fifo_empty),
	.reset									(~axis_resetn),
	.clk									(axis_clk)
);

always @(posedge axis_aclk) begin
    if (!axis_resetn) begin
        op0_fifo_rd_en <= 1'b0;
        op2_fifo_rd_en <= 1'b0;
    end
    else if (!op2_fifo_empty) begin
        op2_fifo_rd_en <= 1'b1;
    end
    else if (!op0_fifo_empty) begin
        op0_fifo_rd_en <= 1'b1;
    end  
    else begin
        op0_fifo_rd_en <= 1'b0;
        op2_fifo_rd_en <= 1'b0;
    end
end

always @(posedge axis_aclk) begin
    if(!axis_resetn) begin
        i_key_bit_valid <= 1'b0;
        i_key_bit       <= 32'hffffffff;
        key_flag        <= 2'b0;
    end
    else if(op2_fifo_rd_en)begin
        i_key_bit_valid <= 1'b1;
        i_key_bit       <= w_i_op2_key;
        key_flag        <= 2'd2;
    end
    else if(op0_fifo_rd_en)begin
        i_key_bit_valid <= 1'b1;
        i_key_bit       <= w_i_op0_key;
        key_flag        <= 2'd1;
    end
    else begin
        i_key_bit_valid <= 1'b0;
        i_key_bit       <= 32'hffffffff;
        key_flag        <= 2'b0;
    end
end

always @(posedge axis_aclk) begin
    if (!axis_resetn) begin
        r_key_flag  <= 2'b0;    
    end 
    else begin
        if (i_key_bit_valid) begin
            r_key_flag <= key_flag;
        end
        else begin
            r_key_flag <= 2'b0;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////

reg [KEY_WIDTH-1:0] r_path_bit;
reg         		r_path_bit_vld;
reg [1:0]   		cmp_state;

wire                o_key_tcam_match;
reg                 o_key_tcam_end;

always @(posedge axis_clk) begin
    if(!axis_resetn) begin
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

reg [KEY_WIDTH-1:0] r_cam_mask ;

reg [4:0]  ctrl_fifo_state;
localparam TCAM_FIFO_IDLE	= 0;
localparam BUFFER_TCAM 	 	= 1;

reg [255:0] 				r_fifo_tdata     ;
reg [31:0]                  r_fifo_tkeep     ;
reg [127:0]                 r_fifo_tuser     ;
reg         				r_fifo_tvalid    ;
reg         				r_fifo_tlast     ;

reg [TCAM_MATCH_ADDR-1:0]   r_fifo_tcam_addr ;
reg 						r_dp_tcam_busy   ;
//因为不明确TCAM的busy信号是什么时候拉高，
//所以这里对ctrl信号做一个fifo缓存，当busy有效时候，从fifo读取控制报文
//判别有效数据进入FIFO
always @(posedge axis_clk) begin
    if (!axis_resetn) begin
        r_fifo_tcam_addr <= 5'd0;
    end else begin
        if(r_fifo_tvalid) begin
	    	r_fifo_tcam_addr <= r_fifo_tcam_addr +1'b1;
	    end
	    else if(r_fifo_tcam_addr == 5'd31 &&(r_dp_tcam_busy == 1'b1)) begin //最后一个数据写到tcam了，且计数满了
	    	r_fifo_tcam_addr <= 5'd0;
	    end
	    else begin
	    	r_fifo_tcam_addr <= r_fifo_tcam_addr;
	    end
    end
end

always @(posedge axis_clk) begin
	if(!axis_resetn) begin
		r_fifo_tdata    <= 256'd0;
        r_fifo_tkeep    <= 32'b0 ;
        r_fifo_tuser    <= 128'b0;
		r_fifo_tvalid   <= 1'b0  ;
		r_fifo_tlast    <= 1'b0  ;
        
		ctrl_fifo_state <= TCAM_FIFO_IDLE;
		r_cam_mask      <= 32'd0	;
	end
	else begin
		case(ctrl_fifo_state)
			TCAM_FIFO_IDLE:begin
				r_fifo_tdata  		<= 256'd0;
                r_fifo_tkeep        <= 32'b0 ;
                r_fifo_tuser        <= 128'b0;
                r_fifo_tvalid 		<= 1'b0;
				r_fifo_tlast  		<= 1'b0;
				if(s_op2_axis_tvalid) begin
					ctrl_fifo_state <= BUFFER_TCAM;
                    r_fifo_tdata  	<= s_op2_axis_tdata;
                    r_fifo_tkeep    <= s_op2_axis_tkeep;
                    r_fifo_tuser    <= s_op2_axis_tuser;
                    r_fifo_tvalid 	<= 1'b1;
                    r_fifo_tlast  	<= s_op2_axis_tlast;
				end
				else begin 
					ctrl_fifo_state <= TCAM_FIFO_IDLE;
					r_cam_mask <= 32'd0;
				end
			end
			BUFFER_TCAM:begin 
				if(s_op2_axis_tvalid) begin
					r_fifo_tdata  	<= s_op2_axis_tdata;
                    r_fifo_tkeep    <= s_op2_axis_tkeep;
                    r_fifo_tuser    <= s_op2_axis_tuser;
                    r_fifo_tvalid 	<= 1'b1;
                    r_fifo_tlast    <= 1'b0;
					if(s_op2_axis_tlast) begin
						ctrl_fifo_state <= TCAM_FIFO_IDLE;
						r_fifo_tlast  <= 1'b1;
					end
					else begin
						ctrl_fifo_state <= BUFFER_TCAM;
						r_fifo_tlast  <= 1'b0;
					end
				end
				else begin
					r_fifo_tdata  <= 256'd0;
                    r_fifo_tkeep        <= 32'b0 ;
                    r_fifo_tuser        <= 128'b0;
					r_fifo_tvalid <= 1'b0;
					r_fifo_tlast  <= 1'b0;
					ctrl_fifo_state <= TCAM_FIFO_IDLE;
				end
			end
		endcase
	end
end

// 转出sync pkt, TODO：将op改为5
reg [2:0]                          fil_out_state;

localparam  FIL_OUT_IDLE           = 3'b000,//起始状态机跳转
   			FIL_OUT_SWITCH         = 3'b001,//一包数据后状态机跳转
            FLUSH_SYN_DATA         = 3'b010,
            FLUSH_DATA             = 3'b011;

always @(posedge axis_aclk) begin
    if(!axis_resetn) begin
        pkt_fifo_rd_en <= 1'b0;
	    fil_out_state <= FIL_OUT_IDLE;

        o_op5_stash_tdata     <= 0; 
        o_op5_stash_tkeep     <= 0;
        o_op5_stash_tuser     <= 0;
        o_op5_stash_tvalid    <= 0;
        o_op5_stash_tlast     <= 0;      
    end
    else begin
        case(fil_out_state)
		    FIL_OUT_IDLE:begin//fifo不是一开始就有数据，要等待3包数据之后才有数据
                o_op5_stash_tdata     <= 0; 
                o_op5_stash_tkeep     <= 0;
                o_op5_stash_tuser     <= 0;
                o_op5_stash_tvalid    <= 0;
                o_op5_stash_tlast     <= 0;

		    	if(o_op0_match_end) begin //读出需要提前一拍取
                    if(o_op0_match) begin
						fil_out_state      <= FLUSH_DATA;
                        pkt_fifo_rd_en     <= 1'd1;
					end 
                    else begin
						fil_out_state      <= FLUSH_SYN_DATA;
		    		    pkt_fifo_rd_en     <= 1'd1;
					end      
		    	end
		    	else begin
		    		pkt_fifo_rd_en     <= 1'd0;
		    		fil_out_state      <= FIL_OUT_IDLE;
		    	end
		    end
		    FIL_OUT_SWITCH:begin
			    if(!c_data_fifo_empty) begin //连续读第二包数据，因为空状态置高比tdata输出要慢一拍
			    	pkt_fifo_rd_en <= 1'b1;
			    	if(o_op0_match) begin
			    		fil_out_state       <= FLUSH_DATA;
			    		o_op5_stash_tdata   <= c_data_tcam;
			    		o_op5_stash_tkeep   <= c_axis_tkeep;
			    		o_op5_stash_tuser   <= c_axis_tuser;
			    		o_op5_stash_tvalid  <= 1'b1;
			    		o_op5_stash_tlast   <= c_axis_tlast;
			    	end
			    	else begin
			    		fil_out_state <= FLUSH_SYN_DATA;
			    	end
			    end
			    else begin //回到初始状态
			    	pkt_fifo_rd_en <= 1'b0;
			    	fil_out_state <= FIL_OUT_IDLE; //fifo空了一定可以回到初始状态去取数据，因为要至少有三拍，空的状态置高
			    	o_op5_stash_tdata  <= 0;//最后一拍读取的数据无效
			    	o_op5_stash_tkeep  <= 0;
			    	o_op5_stash_tuser  <= 0;
			    	o_op5_stash_tvalid <= 0;
			    	o_op5_stash_tlast  <= 0;
			    end
		    end
		    FLUSH_SYN_DATA:begin
		    	if(i_op5_stash_tready)begin //下一个模块准备好了
		    		if(c_axis_tlast & !r_c_axis_tlast) begin //读报文结束
		    			fil_out_state <= FIL_OUT_SWITCH;
		    			pkt_fifo_rd_en     <= 1'b1;        //最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
                        o_op5_stash_tdata  <= c_data_tcam ;
                        o_op5_stash_tkeep  <= c_axis_tkeep;
                        o_op5_stash_tuser  <= c_axis_tuser;
                        o_op5_stash_tvalid <= 1'b1;
                        o_op5_stash_tlast  <= c_axis_tlast;
		    		end
		    		else begin
		    			fil_out_state <= FLUSH_SYN_DATA;
		    			if(c_data_fifo_empty)begin //读报文没有结束但是fifo空了
		    				pkt_fifo_rd_en     <= 1'b1;
                            o_op5_stash_tdata  <= c_data_tcam ;
                            o_op5_stash_tkeep  <= c_axis_tkeep;
                            o_op5_stash_tuser  <= c_axis_tuser;
                            o_op5_stash_tvalid <= 1'b0;
                            o_op5_stash_tlast  <= 1'b0;
		    			end
		    			else begin //fifo没有空，继续读
		    				if(pkt_fifo_rd_en)begin
		    					o_op5_stash_tdata  <= c_data_tcam ;
		    					o_op5_stash_tkeep  <= c_axis_tkeep;
		    					o_op5_stash_tuser  <= c_axis_tuser;
		    					o_op5_stash_tvalid <= 1'b1;
		    					o_op5_stash_tlast  <= c_axis_tlast;
		    				end
		    				else begin
		    					o_op5_stash_tdata  <= 0;
		    					o_op5_stash_tkeep  <= 0;
		    					o_op5_stash_tuser  <= 0;
		    					o_op5_stash_tvalid <= 0;
		    					o_op5_stash_tlast  <= 0;
		    				end
		    				pkt_fifo_rd_en <= 1'b1;
		    			end
		    		end
		    	end
		    	else begin
		    		pkt_fifo_rd_en <= 1'b0;
		    		o_op5_stash_tdata  <= 0;
		    		o_op5_stash_tkeep  <= 0;
		    		o_op5_stash_tuser  <= 0;
		    		o_op5_stash_tvalid <= 0;
		    		o_op5_stash_tlast  <= 0;
		    		fil_out_state <= FLUSH_SYN_DATA;
		    	end
		    end
            FLUSH_DATA: begin
                if(c_axis_tlast & !r_c_axis_tlast) begin
                    pkt_fifo_rd_en <= 1'b1;
                    fil_out_state <= FIL_OUT_IDLE;
                end
                else if (c_axis_tvalid) begin
                    pkt_fifo_rd_en <= 1'b1;
                    fil_out_state <= FLUSH_DATA;
                end
                else begin
                    pkt_fifo_rd_en <= 1'b0;
                    fil_out_state <= FIL_OUT_IDLE;
                end
            end
	    endcase
    end
end

//////////////////////////////////////////////////////////////////////////////////

wire [C_AXIS_DATA_WIDTH-1:0]     c_data_tcam                ;
wire [31:0]                      c_axis_tkeep               ;
wire [127:0]                     c_axis_tuser               ;
wire 					         c_axis_tvalid              ;
wire 					         c_axis_tlast               ;
wire [TCAM_MATCH_ADDR-1:0]       c_axis_tcam_addr           ;

reg  [C_AXIS_DATA_WIDTH-1:0]     r_c_data_tcam              ;
reg  [31:0]                      r_c_axis_tkeep             ;
reg  [127:0]                     r_c_axis_tuser             ;
reg  					         r_c_axis_tvalid            ;
reg  					         r_c_axis_tlast             ;
reg  [TCAM_MATCH_ADDR-1:0]       r_c_axis_tcam_addr         ;

wire                             c_data_fifo_nearly_full    ;
wire                             c_data_fifo_empty          ;

wire 						     w_dp_tcam_busy2            ;
wire 						     w_dp_tcam_match2           ;
wire [TCAM_MATCH_ADDR-1:0] 	     w_dp_tcam_match_addr2      ;

reg                              pkt_fifo_rd_en;

always @(posedge axis_clk) begin
	if (!axis_resetn) begin
		r_c_data_tcam      <= 0;
		r_c_axis_tkeep     <= 0;
		r_c_axis_tuser     <= 0;
		r_c_axis_tvalid    <= 0;
		r_c_axis_tlast     <= 0;
		r_c_axis_tcam_addr <= 0;
	end else begin
		r_c_data_tcam      <= c_data_tcam     ;
		r_c_axis_tkeep     <= c_axis_tkeep    ;
		r_c_axis_tuser     <= c_axis_tuser    ;
		r_c_axis_tvalid    <= c_axis_tvalid   ;
		r_c_axis_tlast     <= c_axis_tlast    ;
		r_c_axis_tcam_addr <= c_axis_tcam_addr;
	end
end


always @(posedge axis_clk) begin
	if(!axis_resetn) 
		r_dp_tcam_busy <= 1'b0;
	else
		r_dp_tcam_busy <= w_dp_tcam_busy2;
end
fallthrough_small_fifo #(
	.WIDTH(423),
	.MAX_DEPTH_BITS(10)
)
stash_cam_fifo
(
	.din									({r_fifo_tdata, r_fifo_tkeep, r_fifo_tuser, r_fifo_tvalid, r_fifo_tlast, r_fifo_tcam_addr}),
	.wr_en									(r_fifo_tvalid ),
	.rd_en									(pkt_fifo_rd_en),
	.dout									({c_data_tcam, c_axis_tkeep, c_axis_tuser, c_axis_tvalid, c_axis_tlast, c_axis_tcam_addr}),
	.full									(),
	.prog_full								(),
	.nearly_full							(),
	.empty									(c_data_fifo_empty),
	.reset									(~axis_resetn),
	.clk									(axis_clk)
);

wire   c_wr_en_cam;
assign c_wr_en_cam = (r_key_flag == 2'd2 && o_key_tcam_match && o_key_tcam_end) ? 1'b1 : 1'b0; // for op2, if not exist, then write


//tcam会延迟几拍出
// tcam1 for lookup
cam_top # ( 
    .C_DEPTH			(32	),
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
    .DIN                (c_data_tcam[151:120]     ),//4 bytes Key in
    .EN					(1'b1					 )
);	 

assign o_key_tcam_match = w_dp_tcam_match2;


endmodule
