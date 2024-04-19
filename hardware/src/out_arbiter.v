`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 11:50:09
// Design Name: 
// Module Name: out_arbiter
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


module out_arbiter#(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
   	parameter C_S_AXIS_TUSER_WIDTH = 128
)(
    input                                        axis_aclk            ,  
    input                                        axis_resetn          ,
   
    input  [C_S_AXIS_DATA_WIDTH-1:0]             i_tdata_fifo_d       ,  
    input  [C_S_AXIS_TUSER_WIDTH-1:0]            i_tuser_fifo_d       ,  
    input  [((C_S_AXIS_DATA_WIDTH/8))-1:0]       i_tkeep_fifo_d       ,  
    input                                        i_tlast_fifo_d       ,  
    input                                        i_tvalid_fifo_d      , 
    input                                        i_pkt_fifo_empty_d   , 
    output reg                                   o_pkt_fifo_rd_en_d   ,

    input  [C_S_AXIS_DATA_WIDTH-1:0]             i_tdata_fifo_0       ,   
    input  [C_S_AXIS_TUSER_WIDTH-1:0]            i_tuser_fifo_0       ,
    input  [((C_S_AXIS_DATA_WIDTH/8))-1:0]       i_tkeep_fifo_0       ,
    input                                        i_tlast_fifo_0       ,
    input                                        i_tvalid_fifo_0      ,
    input                                        i_pkt_fifo_empty_0   , 
    output reg                                   o_pkt_fifo_rd_en_0   ,
   
    input  [C_S_AXIS_DATA_WIDTH-1:0]             i_tdata_fifo_1       ,  
    input  [C_S_AXIS_TUSER_WIDTH-1:0]            i_tuser_fifo_1       ,
    input  [((C_S_AXIS_DATA_WIDTH/8))-1:0]       i_tkeep_fifo_1       ,
    input                                        i_tlast_fifo_1       ,
    input                                        i_tvalid_fifo_1      ,
    input                                        i_pkt_fifo_empty_1   , 
    output reg                                   o_pkt_fifo_rd_en_1   ,

    input  [C_S_AXIS_DATA_WIDTH-1:0]             i_tdata_fifo_2       ,   
    input  [C_S_AXIS_TUSER_WIDTH-1:0]            i_tuser_fifo_2       ,
    input  [((C_S_AXIS_DATA_WIDTH/8))-1:0]       i_tkeep_fifo_2       ,
    input                                        i_tlast_fifo_2       ,
    input                                        i_tvalid_fifo_2      ,
    input                                        i_pkt_fifo_empty_2   , 
    output reg                                   o_pkt_fifo_rd_en_2   ,
   
    input  [C_S_AXIS_DATA_WIDTH-1:0]             i_tdata_fifo_3       ,
    input  [C_S_AXIS_TUSER_WIDTH-1:0]            i_tuser_fifo_3       ,
    input  [((C_S_AXIS_DATA_WIDTH/8))-1:0]       i_tkeep_fifo_3       ,
    input                                        i_tlast_fifo_3       ,
    input                                        i_tvalid_fifo_3      ,
    input                                        i_pkt_fifo_empty_3   , 
    output reg                                   o_pkt_fifo_rd_en_3   ,

    input  [C_S_AXIS_DATA_WIDTH-1:0]             i_tdata_fifo_4       ,   
    input  [C_S_AXIS_TUSER_WIDTH-1:0]            i_tuser_fifo_4       ,
    input  [((C_S_AXIS_DATA_WIDTH/8))-1:0]       i_tkeep_fifo_4       ,
    input                                        i_tlast_fifo_4       ,
    input                                        i_tvalid_fifo_4      ,
    input                                        i_pkt_fifo_empty_4   , 
    output reg                                   o_pkt_fifo_rd_en_4   ,
   
    output reg [C_S_AXIS_DATA_WIDTH-1:0]         o_axis_opl_tdata     ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0]   o_axis_opl_tkeep     ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]        o_axis_opl_tuser     ,
    output reg                                   o_axis_opl_tvalid    ,
    input                                        i_axis_opl_tready    ,
    output reg                                   o_axis_opl_tlast    
);
    ////////////////////////////////////////// 5 -> 1 ////////////////////////////////////
wire                                    pkt_fifo_empty_d;
wire                                    pkt_fifo_empty_0;
wire                                    pkt_fifo_empty_1;
wire                                    pkt_fifo_empty_2;
wire                                    pkt_fifo_empty_3;
wire                                    pkt_fifo_empty_4;

assign  pkt_fifo_empty_0 = i_pkt_fifo_empty_0; 
assign  pkt_fifo_empty_1 = i_pkt_fifo_empty_1;
assign  pkt_fifo_empty_2 = i_pkt_fifo_empty_2;
assign  pkt_fifo_empty_3 = i_pkt_fifo_empty_3;
assign  pkt_fifo_empty_4 = i_pkt_fifo_empty_4;
assign  pkt_fifo_empty_d = i_pkt_fifo_empty_d;

always @(posedge axis_aclk) begin
    if (!axis_resetn ) begin
        // cur_fifo <= 0;
        o_pkt_fifo_rd_en_d <= 0;
        o_pkt_fifo_rd_en_0 <= 0;
        o_pkt_fifo_rd_en_1 <= 0;
        o_pkt_fifo_rd_en_2 <= 0;
        o_pkt_fifo_rd_en_3 <= 0;
        o_pkt_fifo_rd_en_4 <= 0;
    end
    else if(!pkt_fifo_empty_d) begin
        if(i_tlast_fifo_d)
            o_pkt_fifo_rd_en_d <= 1'b0                 ;
        else
            o_pkt_fifo_rd_en_d <= 1'b1                 ;
    end 
    else if(!pkt_fifo_empty_0) begin
        if(i_tlast_fifo_0)
            o_pkt_fifo_rd_en_0 <= 1'b0                 ;
        else
            o_pkt_fifo_rd_en_0 <= 1'b1                 ;
    end
    else if(!pkt_fifo_empty_1) begin
        if(i_tlast_fifo_1)
            o_pkt_fifo_rd_en_1 <= 1'b0                 ;
        else
            o_pkt_fifo_rd_en_1 <= 1'b1                 ;
    end
    else if(!pkt_fifo_empty_2) begin
        if(i_tlast_fifo_2)
            o_pkt_fifo_rd_en_2 <= 1'b0                 ;
        else
            o_pkt_fifo_rd_en_2 <= 1'b1                 ;
    end
    else if(!pkt_fifo_empty_3) begin
        if(i_tlast_fifo_3)
            o_pkt_fifo_rd_en_3 <= 1'b0                 ;
        else
            o_pkt_fifo_rd_en_3 <= 1'b1                 ;          
    end
    else if(!pkt_fifo_empty_4) begin
        if(i_tlast_fifo_4)
            o_pkt_fifo_rd_en_4 <= 1'b0                 ;
        else
            o_pkt_fifo_rd_en_4 <= 1'b1                 ;
    end
    else begin
        o_pkt_fifo_rd_en_d <= 0;
        o_pkt_fifo_rd_en_0 <= 0;
        o_pkt_fifo_rd_en_1 <= 0;
        o_pkt_fifo_rd_en_2 <= 0;
        o_pkt_fifo_rd_en_3 <= 0;
        o_pkt_fifo_rd_en_4 <= 0;
    end
end

wire [7:0] src_mac;
wire [7:0] dst_mac;
assign src_mac = i_tuser_fifo_d[23:16];
assign dst_mac = (src_mac== 8'h40)?8'h01:(src_mac== 8'h01)?8'h40:8'h00;
always @(posedge axis_aclk) begin
    if(!axis_resetn) begin
        o_axis_opl_tdata   <= 0;
        o_axis_opl_tkeep   <= 0;
        o_axis_opl_tuser   <= 0;
        o_axis_opl_tvalid  <= 0;
        o_axis_opl_tlast   <= 0;
    end
    else if(o_pkt_fifo_rd_en_d) begin
        o_axis_opl_tdata   <= i_tdata_fifo_d       ;
        o_axis_opl_tuser   <= {i_tuser_fifo_d[127:32],dst_mac,i_tuser_fifo_d[23:0]};
        o_axis_opl_tkeep   <= i_tkeep_fifo_d       ;
        o_axis_opl_tvalid  <= 1'b1                 ;
        o_axis_opl_tlast   <= i_tlast_fifo_d       ;
    end
    else if(o_pkt_fifo_rd_en_0)begin
        o_axis_opl_tdata  <= i_tdata_fifo_0;
		o_axis_opl_tkeep  <= i_tkeep_fifo_0;
		o_axis_opl_tuser  <= {i_tuser_fifo_0[127:32],i_tuser_fifo_0[23:16],i_tuser_fifo_0[23:0]};
		o_axis_opl_tvalid <= 1'b1;
		o_axis_opl_tlast  <= i_tlast_fifo_0;
    end
    else if(o_pkt_fifo_rd_en_1)begin
        o_axis_opl_tdata  <= i_tdata_fifo_1;
		o_axis_opl_tkeep  <= i_tkeep_fifo_1;
		o_axis_opl_tuser  <= i_tuser_fifo_1;
		o_axis_opl_tvalid <= 1'b1;
		o_axis_opl_tlast  <= i_tlast_fifo_1;
    end
    else if(o_pkt_fifo_rd_en_2)begin
        o_axis_opl_tdata <= i_tdata_fifo_2;
        o_axis_opl_tkeep <= i_tkeep_fifo_2;
        o_axis_opl_tuser <= i_tuser_fifo_2;
        o_axis_opl_tvalid<= 1'b1;
        o_axis_opl_tlast <= i_tlast_fifo_2;
    end
    else if(o_pkt_fifo_rd_en_3)begin
        o_axis_opl_tdata <= i_tdata_fifo_3;
        o_axis_opl_tkeep <= i_tkeep_fifo_3;
        o_axis_opl_tuser <= i_tuser_fifo_3;
        o_axis_opl_tvalid<= 1'b1;
        o_axis_opl_tlast <= i_tlast_fifo_3;
    end
    else if(o_pkt_fifo_rd_en_4)begin
        o_axis_opl_tdata <= i_tdata_fifo_4;
        o_axis_opl_tkeep <= i_tkeep_fifo_4;
        o_axis_opl_tuser <= i_tuser_fifo_4;
        o_axis_opl_tvalid<= 1'b1;
        o_axis_opl_tlast <= i_tlast_fifo_4;
    end
    else begin
        o_axis_opl_tdata   <= 0;
        o_axis_opl_tkeep   <= 0;
        o_axis_opl_tuser   <= 0;
        o_axis_opl_tvalid  <= 0;
        o_axis_opl_tlast   <= 0;
    end
end

endmodule
