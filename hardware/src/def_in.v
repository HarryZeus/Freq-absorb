`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 10:52:03
// Design Name: 
// Module Name: def_in
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


module def_in
#(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
    parameter C_S_AXIS_TUSER_WIDTH = 128
)(
    input          axis_aclk    ,  
    input          axis_resetn  ,

    input [C_S_AXIS_DATA_WIDTH-1:0]         i_def_s_axis_tdata    ,
    input [((C_S_AXIS_DATA_WIDTH/8))-1:0]   i_def_s_axis_tkeep    ,
    input [C_S_AXIS_TUSER_WIDTH-1:0]        i_def_s_axis_tuser    ,
    input                                   i_def_s_axis_tvalid   ,
    output                                  o_def_s_axis_tready   ,
    input                                   i_def_s_axis_tlast    ,
 
    output                                  o_pkt_fifo_empty_d    ,
    input                                   i_pkt_fifo_rd_en_d    ,
 
    output [C_S_AXIS_DATA_WIDTH-1:0]        o_tdata_fifo_d        ,
    output [C_S_AXIS_TUSER_WIDTH-1:0]       o_tuser_fifo_d        ,
    output [((C_S_AXIS_DATA_WIDTH/8))-1:0]  o_tkeep_fifo_d        ,
    output                                  o_tlast_fifo_d        ,
    output                                  o_tvalid_fifo_d        
                   
    );

    reg [C_S_AXIS_DATA_WIDTH-1:0]           r_s_axis_tdata_d      ;
    reg [((C_S_AXIS_DATA_WIDTH/8))-1:0]     r_s_axis_tkeep_d      ;
    reg [C_S_AXIS_TUSER_WIDTH-1:0]          r_s_axis_tuser_d      ;
    reg                                     r_s_axis_tvalid_d     ;
    reg                                     r_s_axis_tlast_d      ;
    reg                                     rd_fifo_flag_d        ; 
    reg                                     pkt_fifo_wr_en_d      ;
    reg                                     pkt_fifo_rd_en_d      ;

    wire                                    pkt_fifo_nearly_full_d;
    

    reg  [2:0]                              fil_in_state_d        ;
    localparam  WAIT_FIRST_PKT  = 3'b000,
                WAIT_SECOND_PKT = 3'b001,
                BUFFER_CTL      = 3'b010,
                BUFFER_DATA     = 3'b011;

    always @(posedge axis_aclk) begin
        if(!axis_resetn)begin
        	r_s_axis_tdata_d  <= 0;
        	r_s_axis_tkeep_d  <= 0;
        	r_s_axis_tuser_d  <= 0;
        	r_s_axis_tvalid_d <= 0;
        	r_s_axis_tlast_d  <= 0;
        end
        else if(i_def_s_axis_tvalid)begin
            r_s_axis_tdata_d  <= i_def_s_axis_tdata ;
            r_s_axis_tkeep_d  <= i_def_s_axis_tkeep ;
            r_s_axis_tuser_d  <= i_def_s_axis_tuser ;
            r_s_axis_tvalid_d <= i_def_s_axis_tvalid;
            r_s_axis_tlast_d  <= i_def_s_axis_tlast ;  
        end
        else begin
        	r_s_axis_tdata_d  <= 0;
            r_s_axis_tkeep_d  <= 0;
            r_s_axis_tuser_d  <= 0;
            r_s_axis_tvalid_d <= 0;
            r_s_axis_tlast_d  <= 0; 
        end
    end

fallthrough_small_fifo #(
    .WIDTH(C_S_AXIS_DATA_WIDTH + C_S_AXIS_TUSER_WIDTH + C_S_AXIS_DATA_WIDTH/8 + 1),
    .MAX_DEPTH_BITS(10)
   )
   input_fifo_insd
   (
   	.din							    ({r_s_axis_tdata_d, r_s_axis_tuser_d, r_s_axis_tkeep_d, r_s_axis_tlast_d}),
   	.wr_en								(pkt_fifo_wr_en_d),
   	.rd_en								(i_pkt_fifo_rd_en_d),
   	.dout								({o_tdata_fifo_d, o_tuser_fifo_d, o_tkeep_fifo_d, o_tlast_fifo_d}),
   	.full								(),
   	.prog_full							(),
   	.nearly_full						(pkt_fifo_nearly_full_d),
   	.empty								(o_pkt_fifo_empty_d),
   	.reset								(~axis_resetn),
   	.clk							    (axis_aclk)
   );

   assign o_def_s_axis_tready =  !pkt_fifo_nearly_full_d ;


    always @(posedge axis_aclk) begin
        if(!axis_resetn)begin
   		    pkt_fifo_wr_en_d <= 1'b0;
   		    rd_fifo_flag_d <= 1'b0;
   		    fil_in_state_d <= WAIT_FIRST_PKT;
   	    end
        else begin
            case(fil_in_state_d)
                WAIT_FIRST_PKT: begin
                    rd_fifo_flag_d <= 1'b0;
                    if(i_def_s_axis_tvalid) begin
                        pkt_fifo_wr_en_d <= 1'b1;
   						fil_in_state_d   <= WAIT_SECOND_PKT;
                        
                    end
                    else begin
                        pkt_fifo_wr_en_d <= 1'b0;
   					    fil_in_state_d   <= WAIT_FIRST_PKT;
                    end
                end
                WAIT_SECOND_PKT:begin
                    if(i_def_s_axis_tvalid) begin
   					    rd_fifo_flag_d     <= 1'b1;
   					    pkt_fifo_wr_en_d <= 1'b1;
   					    fil_in_state_d <= BUFFER_DATA;	
   				    end
   				    else begin
   				    	pkt_fifo_wr_en_d <= 1'b0;
   				    	fil_in_state_d <= WAIT_SECOND_PKT;
   				    end
                end
   			    BUFFER_DATA:begin 
   			    	rd_fifo_flag_d <= 1'b1;
   			    	if(i_def_s_axis_tvalid && i_def_s_axis_tlast) begin
   			    		pkt_fifo_wr_en_d <= 1'b1;
   			    		fil_in_state_d <= WAIT_FIRST_PKT;
   			    	end
   			    	else if(i_def_s_axis_tvalid) begin
   			    		pkt_fifo_wr_en_d <= 1'b1;
   			    		fil_in_state_d <= BUFFER_DATA;
   			    	end
   			    	else begin
   			    		pkt_fifo_wr_en_d <= 1'b0;
   			    		fil_in_state_d <= BUFFER_DATA;
   			    	end
   			    end

            endcase
        end 
    end
endmodule
