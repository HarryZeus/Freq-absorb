`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/29 17:25:35
// Design Name: 
// Module Name: switch_port
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
//eth0/client->nf3->input_ip(nf3)->freq_s->switch_port(m)->output_ip nf3->eth0
//nf0->enp5s0
//enp5s0 -> nf0 -> nf3 -> eth0

`define DST_PORT        16'hb822
`define IPPROT_UDP      8'h11
`define INET            8'h0008

module switch_port#(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
   	parameter C_S_AXIS_TUSER_WIDTH = 128
)(
    input          axis_aclk    ,  
    input          axis_resetn  ,

    input [255:0]  i_def_m_axis_tdata ,
    input [31:0]   i_def_m_axis_tkeep ,
    input [127:0]  i_def_m_axis_tuser ,
    input          i_def_m_axis_tvalid,
    output         o_def_m_axis_tready,
    input          i_def_m_axis_tlast ,
    
    input  [255:0] i_cache_s_axis_op1_tdata ,//输入0  switch-to-client
    input  [31:0]  i_cache_s_axis_op1_tkeep ,
    input  [127:0] i_cache_s_axis_op1_tuser ,
    input          i_cache_s_axis_op1_tvalid,
    output         o_cache_s_axis_op1_tready,
    input          i_cache_s_axis_op1_tlast ,

    input  [255:0] i_stash_s_axis_op1_tdata ,//输入1  switch-to-client
    input  [31:0]  i_stash_s_axis_op1_tkeep ,
    input  [127:0] i_stash_s_axis_op1_tuser ,
    input          i_stash_s_axis_op1_tvalid,
    output         o_stash_s_axis_op1_tready,
    input          i_stash_s_axis_op1_tlast ,

    input  [255:0] i_op0_server_tdata ,//输入2
    input  [31:0]  i_op0_server_tkeep ,
    input  [127:0] i_op0_server_tuser ,
    input          i_op0_server_tvalid,
    output         o_op0_server_tready,
    input          i_op0_server_tlast ,

    input  [255:0] i_op1_server_tdata ,//输入3
    input  [31:0]  i_op1_server_tkeep ,
    input  [127:0] i_op1_server_tuser ,
    input          i_op1_server_tvalid,
    output         o_op1_server_tready,
    input          i_op1_server_tlast ,

    input  [255:0] i_op5_server_tdata ,//输入4
    input  [31:0]  i_op5_server_tkeep ,
    input  [127:0] i_op5_server_tuser ,
    input          i_op5_server_tvalid,
    output         o_op5_server_tready,
    input          i_op5_server_tlast ,

    input  [255:0] i_op6_stash_tdata , //输入5，WRITE_REPLY
    input  [31:0]  i_op6_stash_tkeep ,
    input  [127:0] i_op6_stash_tuser ,
    input          i_op6_stash_tvalid,
    output         i_op6_stash_tready,
    input          i_op6_stash_tlast ,
                  
    output [255:0] o_axis_opl_tdata ,
    output [31:0]  o_axis_opl_tkeep ,
    output [127:0] o_axis_opl_tuser ,
    output         o_axis_opl_tvalid,
    input          i_axis_opl_tready,//1
    output         o_axis_opl_tlast 
   
);

ila_1_switch_port ila_switch_port (
	.clk(axis_aclk), // input wire clk


	.probe0(i_cache_s_axis_op1_tdata ), // input wire [255:0]  probe0  
	.probe1(i_cache_s_axis_op1_tkeep ), // input wire [31:0]  probe1 
	.probe2(i_cache_s_axis_op1_tuser ), // input wire [127:0]  probe2 
	.probe3(i_cache_s_axis_op1_tvalid), // input wire [0:0]  probe3 
	.probe4(i_cache_s_axis_op1_tready), // input wire [0:0]  probe4 
	.probe5(i_cache_s_axis_op1_tlast ), // input wire [0:0]  probe5 
	.probe6 (o_axis_opl_tdata ), // input wire [255:0]  probe6 
	.probe7 (o_axis_opl_tkeep ), // input wire [31:0]  probe7 
	.probe8 (o_axis_opl_tuser ), // input wire [127:0]  probe8 
	.probe9 (o_axis_opl_tvalid), // input wire [0:0]  probe9 
	.probe10(o_axis_opl_tready), // input wire [0:0]  probe10 
	.probe11(o_axis_opl_tlast ) // input wire [0:0]  probe11
);

//def data in
wire w_pkt_fifo_empty_d;
wire w_pkt_fifo_rd_en_d;

wire [255:0] w_tdata_fifo_d     ;
wire [127:0] w_tuser_fifo_d     ;
wire [31:0 ] w_tkeep_fifo_d     ;
wire         w_tlast_fifo_d     ;
wire         w_tvalid_fifo_d    ;

def_in  #(
    .C_S_AXIS_DATA_WIDTH  (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH)
) def_in(
    .axis_aclk            (axis_aclk  ),  
    .axis_resetn          (axis_resetn),

    .i_def_s_axis_tdata   (i_def_m_axis_tdata ),
    .i_def_s_axis_tkeep   (i_def_m_axis_tkeep ),
    .i_def_s_axis_tuser   (i_def_m_axis_tuser ),
    .i_def_s_axis_tvalid  (i_def_m_axis_tvalid),
    .o_def_s_axis_tready  (o_def_m_axis_tready),
    .i_def_s_axis_tlast   (i_def_m_axis_tlast ),
    
    .o_pkt_fifo_empty_d   (w_pkt_fifo_empty_d ),
    .i_pkt_fifo_rd_en_d   (w_pkt_fifo_rd_en_d ),

    .o_tdata_fifo_d       (w_tdata_fifo_d     ),   
    .o_tuser_fifo_d       (w_tuser_fifo_d     ),
    .o_tkeep_fifo_d       (w_tkeep_fifo_d     ),
    .o_tlast_fifo_d       (w_tlast_fifo_d     ),
    .o_tvalid_fifo_d      (w_tvalid_fifo_d    )
);

 
// cache_op1_in
wire w_pkt_fifo_empty_0;
wire w_pkt_fifo_rd_en_0;

wire [C_S_AXIS_DATA_WIDTH-1:0]	 w_tdata_fifo_0     ;
wire [C_S_AXIS_TUSER_WIDTH-1:0]  w_tuser_fifo_0     ;
wire [C_S_AXIS_DATA_WIDTH/8-1:0] w_tkeep_fifo_0     ;
wire                             w_tlast_fifo_0     ;
wire                             w_tvalid_fifo_0    ;

cache_op1_in  #(
    .C_S_AXIS_DATA_WIDTH  (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH)
) cache_op1_in(
    .axis_aclk                  (axis_aclk                ),  
    .axis_resetn                (axis_resetn              ),

    .i_cache_s_axis_op1_tdata   (i_cache_s_axis_op1_tdata ),
    .i_cache_s_axis_op1_tkeep   (i_cache_s_axis_op1_tkeep ),
    .i_cache_s_axis_op1_tuser   (i_cache_s_axis_op1_tuser ),
    .i_cache_s_axis_op1_tvalid  (i_cache_s_axis_op1_tvalid),
    .o_cache_s_axis_op1_tready  (o_cache_s_axis_op1_tready),
    .i_cache_s_axis_op1_tlast   (i_cache_s_axis_op1_tlast ),

    .o_pkt_fifo_empty_0         (w_pkt_fifo_empty_0       ),
    .i_pkt_fifo_rd_en_0         (w_pkt_fifo_rd_en_0       ),

    .o_tdata_fifo_0             (w_tdata_fifo_0           ),   
    .o_tuser_fifo_0             (w_tuser_fifo_0           ),
    .o_tkeep_fifo_0             (w_tkeep_fifo_0           ),
    .o_tlast_fifo_0             (w_tlast_fifo_0           ),
    .o_tvalid_fifo_0            (w_tvalid_fifo_0          )
);

////////////////////////////////////////////////////////////////////////////////////
//stash_op1_in
wire w_pkt_fifo_empty_1;
wire w_pkt_fifo_rd_en_1;

wire [C_S_AXIS_DATA_WIDTH-1:0]	 w_tdata_fifo_1     ;
wire [C_S_AXIS_TUSER_WIDTH-1:0]  w_tuser_fifo_1     ;
wire [C_S_AXIS_DATA_WIDTH/8-1:0] w_tkeep_fifo_1     ;
wire                             w_tlast_fifo_1     ;
wire                             w_tvalid_fifo_1    ;

stash_op1_in  #(
    .C_S_AXIS_DATA_WIDTH  (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH)
) stash_op1_in(
    .axis_aclk                  (axis_aclk                ),  
    .axis_resetn                (axis_resetn              ),

    .i_stash_s_axis_op1_tdata   (i_stash_s_axis_op1_tdata ),
    .i_stash_s_axis_op1_tkeep   (i_stash_s_axis_op1_tkeep ),
    .i_stash_s_axis_op1_tuser   (i_stash_s_axis_op1_tuser ),
    .i_stash_s_axis_op1_tvalid  (i_stash_s_axis_op1_tvalid),
    .o_stash_s_axis_op1_tready  (o_stash_s_axis_op1_tready),
    .i_stash_s_axis_op1_tlast   (i_stash_s_axis_op1_tlast ),

    .o_pkt_fifo_empty_1         (w_pkt_fifo_empty_1       ),
    .i_pkt_fifo_rd_en_1         (w_pkt_fifo_rd_en_1       ),

    .o_tdata_fifo_1             (w_tdata_fifo_1           ),   
    .o_tuser_fifo_1             (w_tuser_fifo_1           ),
    .o_tkeep_fifo_1             (w_tkeep_fifo_1           ),
    .o_tlast_fifo_1             (w_tlast_fifo_1           ),
    .o_tvalid_fifo_1            (w_tvalid_fifo_1          )
);


////////////////////////////////////////////////////////////////////////////////////
//server_op0_in
wire w_pkt_fifo_empty_2;
wire w_pkt_fifo_rd_en_2;

wire [C_S_AXIS_DATA_WIDTH-1:0]	 w_tdata_fifo_2     ;
wire [C_S_AXIS_TUSER_WIDTH-1:0]  w_tuser_fifo_2     ;
wire [C_S_AXIS_DATA_WIDTH/8-1:0] w_tkeep_fifo_2     ;
wire                             w_tlast_fifo_2     ;
wire                             w_tvalid_fifo_2    ;

server_op0_in #(
    .C_S_AXIS_DATA_WIDTH  (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH)
) server_op0_in(
    .axis_aclk                  (axis_aclk                ),  
    .axis_resetn                (axis_resetn              ),

    .i_op0_server_tdata         (i_op0_server_tdata       ),
    .i_op0_server_tkeep         (i_op0_server_tkeep       ),
    .i_op0_server_tuser         (i_op0_server_tuser       ),
    .i_op0_server_tvalid        (i_op0_server_tvalid      ),
    .o_op0_server_tready        (o_op0_server_tready      ),
    .i_op0_server_tlast         (i_op0_server_tlast       ),

    .o_pkt_fifo_empty_2         (w_pkt_fifo_empty_2       ),
    .i_pkt_fifo_rd_en_2         (w_pkt_fifo_rd_en_2       ),

    .o_tdata_fifo_2             (w_tdata_fifo_2           ),   
    .o_tuser_fifo_2             (w_tuser_fifo_2           ),
    .o_tkeep_fifo_2             (w_tkeep_fifo_2           ),
    .o_tlast_fifo_2             (w_tlast_fifo_2           ),
    .o_tvalid_fifo_2            (w_tvalid_fifo_2          )
);



////////////////////////////////////////////////////////////////////////////////////
//op1_serve_in
wire w_pkt_fifo_empty_3;
wire w_pkt_fifo_rd_en_3;

wire [C_S_AXIS_DATA_WIDTH-1:0]	 w_tdata_fifo_3     ;
wire [C_S_AXIS_TUSER_WIDTH-1:0]  w_tuser_fifo_3     ;
wire [C_S_AXIS_DATA_WIDTH/8-1:0] w_tkeep_fifo_3     ;
wire                             w_tlast_fifo_3     ;
wire                             w_tvalid_fifo_3    ;

server_op1_in #(
    .C_S_AXIS_DATA_WIDTH  (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH)
) server_op1_in(
    .axis_aclk                  (axis_aclk                ),  
    .axis_resetn                (axis_resetn              ),

    .i_op1_server_tdata         (i_op1_server_tdata       ),
    .i_op1_server_tkeep         (i_op1_server_tkeep       ),
    .i_op1_server_tuser         (i_op1_server_tuser       ),
    .i_op1_server_tvalid        (i_op1_server_tvalid      ),
    .o_op1_server_tready        (o_op1_server_tready      ),
    .i_op1_server_tlast         (i_op1_server_tlast       ),

    .o_pkt_fifo_empty_3         (w_pkt_fifo_empty_3       ),
    .i_pkt_fifo_rd_en_3         (w_pkt_fifo_rd_en_3       ),

    .o_tdata_fifo_3             (w_tdata_fifo_3           ),   
    .o_tuser_fifo_3             (w_tuser_fifo_3           ),
    .o_tkeep_fifo_3             (w_tkeep_fifo_3           ),
    .o_tlast_fifo_3             (w_tlast_fifo_3           ),
    .o_tvalid_fifo_3            (w_tvalid_fifo_3          )

);


////////////////////////////////////////////////////////////////////////////////////
//op5_serve_in
wire w_pkt_fifo_empty_4;
wire w_pkt_fifo_rd_en_4;

wire [C_S_AXIS_DATA_WIDTH-1:0]	 w_tdata_fifo_4     ;
wire [C_S_AXIS_TUSER_WIDTH-1:0]  w_tuser_fifo_4     ;
wire [C_S_AXIS_DATA_WIDTH/8-1:0] w_tkeep_fifo_4     ;
wire                             w_tlast_fifo_4     ;
wire                             w_tvalid_fifo_4    ;

server_op5_in #(
    .C_S_AXIS_DATA_WIDTH  (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH)
)server_op5_in(
    .axis_aclk                  (axis_aclk                ),  
    .axis_resetn                (axis_resetn              ),

    .i_op5_server_tdata         (i_op5_server_tdata       ),
    .i_op5_server_tkeep         (i_op5_server_tkeep       ),
    .i_op5_server_tuser         (i_op5_server_tuser       ),
    .i_op5_server_tvalid        (i_op5_server_tvalid      ),
    .o_op5_server_tready        (o_op5_server_tready      ),
    .i_op5_server_tlast         (i_op5_server_tlast       ),

    .o_pkt_fifo_empty_4         (w_pkt_fifo_empty_4       ),
    .i_pkt_fifo_rd_en_4         (w_pkt_fifo_rd_en_4       ),

    .o_tdata_fifo_4             (w_tdata_fifo_4           ),   
    .o_tuser_fifo_4             (w_tuser_fifo_4           ),
    .o_tkeep_fifo_4             (w_tkeep_fifo_4           ),
    .o_tlast_fifo_4             (w_tlast_fifo_4           ),
    .o_tvalid_fifo_4            (w_tvalid_fifo_4          )
);



////////////////////////////////////////////////////////////////////////////////////
// out_arbiter
out_arbiter  #(
    .C_S_AXIS_DATA_WIDTH  (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH)
) out_arbiter(
    .axis_aclk            (axis_aclk           ),  
    .axis_resetn          (axis_resetn         ),

    .i_tdata_fifo_d       (w_tdata_fifo_d      ),   
    .i_tuser_fifo_d       (w_tuser_fifo_d      ),
    .i_tkeep_fifo_d       (w_tkeep_fifo_d      ),
    .i_tlast_fifo_d       (w_tlast_fifo_d      ),
    .i_tvalid_fifo_d      (w_tvalid_fifo_d     ),
    .i_pkt_fifo_empty_d   (w_pkt_fifo_empty_d  ),
    .o_pkt_fifo_rd_en_d   (w_pkt_fifo_rd_en_d  ),

    .i_tdata_fifo_0       (w_tdata_fifo_0      ),   
    .i_tuser_fifo_0       (w_tuser_fifo_0      ),
    .i_tkeep_fifo_0       (w_tkeep_fifo_0      ),
    .i_tlast_fifo_0       (w_tlast_fifo_0      ),
    .i_tvalid_fifo_0      (w_tvalid_fifo_0     ),
    .i_pkt_fifo_empty_0   (w_pkt_fifo_empty_0  ),
    .o_pkt_fifo_rd_en_0   (w_pkt_fifo_rd_en_0  ),

    .i_tdata_fifo_1       (w_tdata_fifo_1      ),   
    .i_tuser_fifo_1       (w_tuser_fifo_1      ),
    .i_tkeep_fifo_1       (w_tkeep_fifo_1      ),
    .i_tlast_fifo_1       (w_tlast_fifo_1      ),
    .i_tvalid_fifo_1      (w_tvalid_fifo_1     ),
    .i_pkt_fifo_empty_1   (w_pkt_fifo_empty_1  ),
    .o_pkt_fifo_rd_en_1   (w_pkt_fifo_rd_en_1  ),

    .i_tdata_fifo_2       (w_tdata_fifo_2      ),   
    .i_tuser_fifo_2       (w_tuser_fifo_2      ),
    .i_tkeep_fifo_2       (w_tkeep_fifo_2      ),
    .i_tlast_fifo_2       (w_tlast_fifo_2      ),
    .i_tvalid_fifo_2      (w_tvalid_fifo_2     ),
    .i_pkt_fifo_empty_2   (w_pkt_fifo_empty_2  ),
    .o_pkt_fifo_rd_en_2   (w_pkt_fifo_rd_en_2  ),

    .i_tdata_fifo_3       (w_tdata_fifo_3      ),   
    .i_tuser_fifo_3       (w_tuser_fifo_3      ),
    .i_tkeep_fifo_3       (w_tkeep_fifo_3      ),
    .i_tlast_fifo_3       (w_tlast_fifo_3      ),
    .i_tvalid_fifo_3      (w_tvalid_fifo_3     ),
    .i_pkt_fifo_empty_3   (w_pkt_fifo_empty_3  ),
    .o_pkt_fifo_rd_en_3   (w_pkt_fifo_rd_en_3  ),

    .i_tdata_fifo_4       (w_tdata_fifo_4      ),   
    .i_tuser_fifo_4       (w_tuser_fifo_4      ),
    .i_tkeep_fifo_4       (w_tkeep_fifo_4      ),
    .i_tlast_fifo_4       (w_tlast_fifo_4      ),
    .i_tvalid_fifo_4      (w_tvalid_fifo_4     ),
    .i_pkt_fifo_empty_4   (w_pkt_fifo_empty_4  ),
    .o_pkt_fifo_rd_en_4   (w_pkt_fifo_rd_en_4  ),

    .o_axis_opl_tdata     (o_axis_opl_tdata    ),
    .o_axis_opl_tkeep     (o_axis_opl_tkeep    ),
    .o_axis_opl_tuser     (o_axis_opl_tuser    ),
    .o_axis_opl_tvalid    (o_axis_opl_tvalid   ),
    .i_axis_opl_tready    (i_axis_opl_tready   ),//1
    .o_axis_opl_tlast     (o_axis_opl_tlast    )

);


endmodule