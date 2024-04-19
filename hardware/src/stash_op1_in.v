`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 11:21:41
// Design Name: 
// Module Name: cache_op1_in
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
`define INET            8'h0008

module stash_op1_in#(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
    parameter C_S_AXIS_TUSER_WIDTH = 128
)(
    input          axis_aclk    ,  
    input          axis_resetn  ,

    input [C_S_AXIS_DATA_WIDTH-1:0]         i_stash_s_axis_op1_tdata    ,
    input [((C_S_AXIS_DATA_WIDTH/8))-1:0]   i_stash_s_axis_op1_tkeep    ,
    input [C_S_AXIS_TUSER_WIDTH-1:0]        i_stash_s_axis_op1_tuser    ,
    input                                   i_stash_s_axis_op1_tvalid   ,
    output                                  o_stash_s_axis_op1_tready   ,
    input                                   i_stash_s_axis_op1_tlast    ,
 
    output                                  o_pkt_fifo_empty_1    ,
    input                                   i_pkt_fifo_rd_en_1    ,
 
    output [C_S_AXIS_DATA_WIDTH-1:0]        o_tdata_fifo_1        ,
    output [C_S_AXIS_TUSER_WIDTH-1:0]       o_tuser_fifo_1        ,
    output [((C_S_AXIS_DATA_WIDTH/8))-1:0]  o_tkeep_fifo_1        ,
    output                                  o_tlast_fifo_1        ,
    output                                  o_tvalid_fifo_1       
                   
);


reg                                  pkt_fifo_wr_en_1 ;
reg                                  pkt_fifo_rd_en_1 ;
reg [C_S_AXIS_DATA_WIDTH-1:0]        r_s_axis_tdata_1 ;
reg [((C_S_AXIS_DATA_WIDTH/8))-1:0]  r_s_axis_tkeep_1 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]       r_s_axis_tuser_1 ;
reg                                  r_s_axis_tvalid_1;
reg                                  r_s_axis_tlast_1 ;

reg [C_S_AXIS_DATA_WIDTH-1:0]        r1_s_axis_tdata_1 ;
reg [((C_S_AXIS_DATA_WIDTH/8))-1:0]  r1_s_axis_tkeep_1 ;
reg [C_S_AXIS_TUSER_WIDTH-1:0]       r1_s_axis_tuser_1 ;
reg                                  r1_s_axis_tvalid_1;
reg                                  r1_s_axis_tlast_1 ;
reg [31:0]                           src_ip_1          ;
reg                                  rd_fifo_flag_1    ;
wire                                 pkt_fifo_nearly_full_1;
// wire                                 pkt_fifo_empty_1      ;

reg [2:0]                            fil_in_state_1    ;
localparam  WAIT_FIRST_PKT           =          3'b000,
            WAIT_SECOND_PKT          =          3'b001,
            BUFFER_CTL               =          3'b010,
            BUFFER_DATA              =          3'b011;

assign o_cache_s_axis_op1_tready = !pkt_fifo_nearly_full_1;

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
    	r_s_axis_tdata_1  <= 0;
    	r_s_axis_tkeep_1  <= 0;
    	r_s_axis_tuser_1  <= 0;
    	r_s_axis_tvalid_1 <= 0;
    	r_s_axis_tlast_1  <= 0;
    end
    else if(i_stash_s_axis_op1_tvalid) begin
        r_s_axis_tdata_1  <= i_stash_s_axis_op1_tdata ;
        r_s_axis_tkeep_1  <= i_stash_s_axis_op1_tkeep ;
        r_s_axis_tuser_1  <= i_stash_s_axis_op1_tuser ;
        r_s_axis_tvalid_1 <= i_stash_s_axis_op1_tvalid;
        r_s_axis_tlast_1  <= i_stash_s_axis_op1_tlast ; 
    end
    else begin
    	r_s_axis_tdata_1  <= 0;
        r_s_axis_tkeep_1  <= 0;
        r_s_axis_tuser_1  <= 0;
        r_s_axis_tvalid_1 <= 0;
        r_s_axis_tlast_1  <= 0; 
    end
end

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
    	r1_s_axis_tdata_1  <= 0;
    	r1_s_axis_tkeep_1  <= 0;
    	r1_s_axis_tuser_1  <= 0;
    	r1_s_axis_tvalid_1 <= 0;
    	r1_s_axis_tlast_1  <= 0;
        src_ip_1 <= 0;
    end
    else if(r_s_axis_tvalid_1) begin
        if (r_s_axis_tdata_1[111:96]==`INET && r_s_axis_tdata_1[191:184]==`IPPROT_UDP) begin //first 256
            r1_s_axis_tdata_1 <= {r_s_axis_tdata_1[223:208],r_s_axis_tdata_1[239:96],r_s_axis_tdata_1[47:0],r_s_axis_tdata_1[95:48]};
            // rr_s_axis_tdata_1  <= {r_s_axis_tdata_1[95:48],r_s_axis_tdata_1[47:0],r_s_axis_tdata_1[239:96],r_s_axis_tdata_1[223:208]};
            r1_s_axis_tkeep_1  <= r_s_axis_tkeep_1 ;
            r1_s_axis_tuser_1  <= r_s_axis_tuser_1 ;
            r1_s_axis_tvalid_1 <= r_s_axis_tvalid_1;
            r1_s_axis_tlast_1  <= r_s_axis_tlast_1 ; 
            src_ip_1 <= r_s_axis_tdata_1[239:208];
        end 
        else if(r_s_axis_tdata_1[47:32]==`DST_PORT) begin //second 256
            r1_s_axis_tdata_1  <= {r_s_axis_tdata_1[255:16],src_ip_1[31:16]} ;
            r1_s_axis_tkeep_1  <= r_s_axis_tkeep_1 ;
            r1_s_axis_tuser_1  <= r_s_axis_tuser_1 ;
            r1_s_axis_tvalid_1 <= r_s_axis_tvalid_1;
            r1_s_axis_tlast_1  <= r_s_axis_tlast_1 ;
        end
        else begin
            r1_s_axis_tdata_1  <= r_s_axis_tdata_1 ;
            r1_s_axis_tkeep_1  <= r_s_axis_tkeep_1 ;
            r1_s_axis_tuser_1  <= r_s_axis_tuser_1 ;
            r1_s_axis_tvalid_1 <= r_s_axis_tvalid_1;
            r1_s_axis_tlast_1  <= r_s_axis_tlast_1 ; 
        end 
    end
    else begin
    	r1_s_axis_tdata_1  <= 0;
        r1_s_axis_tkeep_1  <= 0;
        r1_s_axis_tuser_1  <= 0;
        r1_s_axis_tvalid_1 <= 0;
        r1_s_axis_tlast_1  <= 0; 
        src_ip_1 <= 0;
    end
end

always @(posedge axis_aclk) begin
    if(!axis_resetn)begin
   	    pkt_fifo_wr_en_1 <= 1'b0;
   	    rd_fifo_flag_1 <= 1'b0;
   	    fil_in_state_1 <= WAIT_FIRST_PKT;
   	end
    else begin
        case(fil_in_state_1)
            WAIT_FIRST_PKT: begin
                rd_fifo_flag_1 <= 1'b0;
                if(r_s_axis_tvalid_1) begin
                    if(r_s_axis_tdata_1[191:184]==`IPPROT_UDP) begin
                        pkt_fifo_wr_en_1 <= 1'b1;
   					    fil_in_state_1   <= WAIT_SECOND_PKT;
                    end
                    else begin
                        pkt_fifo_wr_en_1 <= 1'b0;
                        fil_in_state_1   <= WAIT_FIRST_PKT;
                    end
                end
                else begin
                    pkt_fifo_wr_en_1 <= 1'b0;
   				    fil_in_state_1   <= WAIT_FIRST_PKT;
                end
            end
            WAIT_SECOND_PKT:begin
                if(r_s_axis_tvalid_1) begin
   				     rd_fifo_flag_1     <= 1'b1;
   				     pkt_fifo_wr_en_1 <= 1'b1;
   				     if (r_s_axis_tdata_1[47:32]==`DST_PORT) begin
   				     	fil_in_state_1 <= BUFFER_DATA;
   				     end
   				     else begin
   				     	fil_in_state_1 <= WAIT_FIRST_PKT;
   				     end
   			     end
   			     else begin
   			     	pkt_fifo_wr_en_1 <= 1'b0;
   			     	fil_in_state_1 <= WAIT_SECOND_PKT;
   			     end
            end
   		    BUFFER_DATA:begin 
   		    	rd_fifo_flag_1 <= 1'b1;
   		    	if(r_s_axis_tvalid_1 && r_s_axis_tlast_1) begin
   		    		pkt_fifo_wr_en_1 <= 1'b1;
   		    		fil_in_state_1 <= WAIT_FIRST_PKT;
   		    	end
   		    	else if(r_s_axis_tvalid_1) begin
   		    		pkt_fifo_wr_en_1 <= 1'b1;
   		    		fil_in_state_1 <= BUFFER_DATA;
   		    	end
   		    	else begin
   		    		pkt_fifo_wr_en_1 <= 1'b0;
   		    		fil_in_state_1 <= BUFFER_DATA;
   		    	end
   		    end
        endcase
    end 
end


fallthrough_small_fifo #(
    .WIDTH(C_S_AXIS_DATA_WIDTH + C_S_AXIS_TUSER_WIDTH + C_S_AXIS_DATA_WIDTH/8 + 1),
    .MAX_DEPTH_BITS(10)
)
input_fifo_ins1
(
	.din									({rr_s_axis_tdata_1, rr_s_axis_tuser_1, rr_s_axis_tkeep_1, rr_s_axis_tlast_1}),
	.wr_en									(pkt_fifo_wr_en_1  ),
	.rd_en									(i_pkt_fifo_rd_en_1),
	.dout									({tdata_fifo_1, tuser_fifo_1, tkeep_fifo_1, tlast_fifo_1}),
	.full									(),
	.prog_full							    (),
	.nearly_full						    (pkt_fifo_nearly_full_1),
	.empty									(o_pkt_fifo_empty_1),
	.reset									(~axis_resetn),
	.clk									(axis_aclk)
);

 
endmodule
