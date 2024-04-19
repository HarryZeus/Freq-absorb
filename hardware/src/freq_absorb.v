`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/03 15:52:44
// Design Name: 
// Module Name: freq_absorb
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


module freq_absorb #(
    parameter C_S_AXIS_DATA_WIDTH  = 256,
   	parameter C_S_AXIS_TUSER_WIDTH = 128,
    parameter KEY_WIDTH  		   = 32 ,
    parameter TCAM_MATCH_ADDR      = 5
)(
    input               axis_aclk    ,
    input               axis_resetn  ,

    input [255:0]       s_axis_tdata ,
    input [31:0 ]       s_axis_tkeep ,
    input [127:0]       s_axis_tuser ,
    input               s_axis_tvalid,
    output              s_axis_tready,
    input               s_axis_tlast ,

    output [255:0]      m_axis_tdata ,
    output [31:0 ]      m_axis_tkeep ,
    output [127:0]      m_axis_tuser ,
    output              m_axis_tvalid ,
    input               m_axis_tready ,
    output              m_axis_tlast
);

assign s_axis_tready = 1'b1;
    // 报文解析
wire [255:0] m_axis_op0_tdata ; // READ_REQUEST
wire [31:0 ] m_axis_op0_tkeep ;
wire [127:0] m_axis_op0_tuser ;
wire         m_axis_op0_tvalid;
wire         m_axis_op0_tready;
wire         m_axis_op0_tlast ;

wire [255:0] m_axis_op1_tdata ; //READ_REPLY
wire [31:0 ] m_axis_op1_tkeep ;
wire [127:0] m_axis_op1_tuser ;
wire         m_axis_op1_tvalid;
wire         m_axis_op1_tready;
wire         m_axis_op1_tlast ;

wire [255:0] m_axis_op2_tdata ; //WRITE
wire [31:0 ] m_axis_op2_tkeep ;
wire [127:0] m_axis_op2_tuser ;
wire         m_axis_op2_tvalid;
wire         m_axis_op2_tready;
wire         m_axis_op2_tlast ;

wire [255:0] m_axis_op3_tdata ; //DELETE
wire [31:0 ] m_axis_op3_tkeep ;
wire [127:0] m_axis_op3_tuser ;
wire         m_axis_op3_tvalid;
wire         m_axis_op3_tready;
wire         m_axis_op3_tlast ;

wire [255:0] m_axis_op4_tdata ;//HOT_INSERY
wire [31:0 ] m_axis_op4_tkeep ;
wire [127:0] m_axis_op4_tuser ;
wire         m_axis_op4_tvalid;
wire         m_axis_op4_tready;
wire         m_axis_op4_tlast ;

wire [255:0] m_axis_op5_tdata ;//STASH_SYN
wire [31:0 ] m_axis_op5_tkeep ;
wire [127:0] m_axis_op5_tuser ;
wire         m_axis_op5_tvalid;
wire         m_axis_op5_tready;
wire         m_axis_op5_tlast ;

wire [255:0] m_axis_op6_tdata ;//WRITE_REPLY
wire [31:0 ] m_axis_op6_tkeep ;
wire [127:0] m_axis_op6_tuser ;
wire         m_axis_op6_tvalid;
wire         m_axis_op6_tready;
wire         m_axis_op6_tlast ;


wire [255:0] w_op1_server_tdata ;
wire [31:0 ] w_op1_server_tkeep ;
wire [127:0] w_op1_server_tuser ;
wire         w_op1_server_tvalid;
wire         w_op1_server_tready;
wire         w_op1_server_tlast ;

wire [255:0] stash_s_op0_tdata ;
wire [31:0 ] stash_s_op0_tkeep ;
wire [127:0] stash_s_op0_tuser ;
wire         stash_s_op0_tvalid;
wire         stash_s_op0_tready;
wire         stash_s_op0_tlast ;
    

wire [255:0] w_cache_m_axis_op1_tdata ;
wire [31:0 ] w_cache_m_axis_op1_tkeep ;
wire [127:0] w_cache_m_axis_op1_tuser ;
wire         w_cache_m_axis_op1_tvalid;
wire         w_cache_m_axis_op1_tready;
wire         w_cache_m_axis_op1_tlast ;

wire [255:0] w_stash_m_axis_op1_tdata ;
wire [31:0 ] w_stash_m_axis_op1_tkeep ;
wire [127:0] w_stash_m_axis_op1_tuser ;
wire         w_stash_m_axis_op1_tvalid;
wire          w_stash_m_axis_op1_tready;
wire         w_stash_m_axis_op1_tlast ;

wire [255:0] w_op0_server_tdata ;
wire [31 :0] w_op0_server_tkeep ;
wire [127:0] w_op0_server_tuser ;
wire         w_op0_server_tvalid;
wire         w_op0_server_tready;
wire         w_op0_server_tlast ;

wire [255:0] w_op5_server_tdata ;
wire [31 :0] w_op5_server_tkeep ;
wire [127:0] w_op5_server_tuser ;
wire         w_op5_server_tvalid;
wire         w_op5_server_tready;
wire         w_op5_server_tlast ;

wire [255:0] def_m_axis_tdata ;  
wire [31:0 ] def_m_axis_tkeep ;
wire [127:0] def_m_axis_tuser ;
wire         def_m_axis_tvalid;
wire         def_m_axis_tready;
wire         def_m_axis_tlast ;



op_parser#(
    .C_S_AXIS_DATA_WIDTH (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH(C_S_AXIS_TUSER_WIDTH)
) op_parser(
.axis_aclk         (axis_aclk       ),
.axis_resetn       (axis_resetn     ),

.s_axis_tdata      (s_axis_tdata    ), 
.s_axis_tkeep      (s_axis_tkeep    ), 
.s_axis_tuser      (s_axis_tuser    ), 
.s_axis_tvalid     (s_axis_tvalid   ),
.s_axis_tready     (                ),//out
.s_axis_tlast      (s_axis_tlast    ), 

.m_axis_tdata      (def_m_axis_tdata ),
.m_axis_tkeep      (def_m_axis_tkeep ),
.m_axis_tuser      (def_m_axis_tuser ),
.m_axis_tvalid     (def_m_axis_tvalid),
.m_axis_tready     (1'b1),
.m_axis_tlast      (def_m_axis_tlast ),

.m_axis_op0_tdata  (m_axis_op0_tdata ), // READ_REQUEST
.m_axis_op0_tkeep  (m_axis_op0_tkeep ),
.m_axis_op0_tuser  (m_axis_op0_tuser ),
.m_axis_op0_tvalid (m_axis_op0_tvalid),
.m_axis_op0_tready (m_axis_op0_tready),
.m_axis_op0_tlast  (m_axis_op0_tlast ),

.m_op1_server_tdata  (w_op1_server_tdata ),//from server ,READ_REPLAY
.m_op1_server_tkeep  (w_op1_server_tkeep ),                                  
.m_op1_server_tuser  (w_op1_server_tuser ),                                  
.m_op1_server_tvalid (w_op1_server_tvalid),                                  
.m_op1_server_tready (w_op1_server_tready),                                  
.m_op1_server_tlast  (w_op1_server_tlast ),                                  

.m_axis_op2_tdata  (m_axis_op2_tdata ), //WRITE
.m_axis_op2_tkeep  (m_axis_op2_tkeep ), 
.m_axis_op2_tuser  (m_axis_op2_tuser ), 
.m_axis_op2_tvalid (m_axis_op2_tvalid), 
.m_axis_op2_tready (m_axis_op2_tready), 
.m_axis_op2_tlast  (m_axis_op2_tlast ), 

.m_axis_op3_tdata  (m_axis_op3_tdata ), //DELETE
.m_axis_op3_tkeep  (m_axis_op3_tkeep ), 
.m_axis_op3_tuser  (m_axis_op3_tuser ), 
.m_axis_op3_tvalid (m_axis_op3_tvalid), 
.m_axis_op3_tready (m_axis_op3_tready), 
.m_axis_op3_tlast  (m_axis_op3_tlast ), 

.m_axis_op4_tdata  (m_axis_op4_tdata ), //HOT_INSERY
.m_axis_op4_tkeep  (m_axis_op4_tkeep ), 
.m_axis_op4_tuser  (m_axis_op4_tuser ), 
.m_axis_op4_tvalid (m_axis_op4_tvalid), 
.m_axis_op4_tready (m_axis_op4_tready), 
.m_axis_op4_tlast  (m_axis_op4_tlast ), 

.m_axis_op5_tdata  (m_axis_op5_tdata ), //STASH_SYN
.m_axis_op5_tkeep  (m_axis_op5_tkeep ), 
.m_axis_op5_tuser  (m_axis_op5_tuser ), 
.m_axis_op5_tvalid (m_axis_op5_tvalid), 
.m_axis_op5_tready (m_axis_op5_tready), 
.m_axis_op5_tlast  (m_axis_op5_tlast ), 

.m_axis_op6_tdata  (m_axis_op6_tdata ), //WRITE_REPLY
.m_axis_op6_tkeep  (m_axis_op6_tkeep ), 
.m_axis_op6_tuser  (m_axis_op6_tuser ), 
.m_axis_op6_tvalid (m_axis_op6_tvalid), 
.m_axis_op6_tready (m_axis_op6_tready), 
.m_axis_op6_tlast  (m_axis_op6_tlast )

);
 
cache #(
    .C_S_AXIS_DATA_WIDTH (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH(C_S_AXIS_TUSER_WIDTH)
)cache(
    .axis_aclk                (axis_aclk              ),
    .axis_resetn              (axis_resetn            ),
    
    .s_axis_tdata             (m_axis_op0_tdata       ), // READ_REQUEST
    .s_axis_tkeep             (m_axis_op0_tkeep       ),
    .s_axis_tuser             (m_axis_op0_tuser       ),
    .s_axis_tvalid            (m_axis_op0_tvalid      ),
    .s_axis_tready            (m_axis_op0_tready      ),
    .s_axis_tlast             (m_axis_op0_tlast       ),
    
    .o_op0_stash_tdata        (stash_s_op0_tdata      ), //cache没有命中，数据进入stash查询
    .o_op0_stash_tkeep        (stash_s_op0_tkeep      ),
    .o_op0_stash_tuser        (stash_s_op0_tuser      ),
    .o_op0_stash_tvalid       (stash_s_op0_tvalid     ),
    .o_op0_stash_tready       (stash_s_op0_tready     ),
    .o_op0_stash_tlast        (stash_s_op0_tlast      ),
    
    .o_m_axis_op1_tdata      (w_cache_m_axis_op1_tdata ), //cache命中返回报文，进入到输出交换模块 READ_REPLY
    .o_m_axis_op1_tkeep      (w_cache_m_axis_op1_tkeep ),
    .o_m_axis_op1_tuser      (w_cache_m_axis_op1_tuser ),
    .o_m_axis_op1_tvalid     (w_cache_m_axis_op1_tvalid),
    .o_m_axis_op1_tready     (w_cache_m_axis_op1_tready),
    .o_m_axis_op1_tlast      (w_cache_m_axis_op1_tlast ),
    
    .s_axis_op4_tdata        (m_axis_op4_tdata         ),
    .s_axis_op4_tkeep        (m_axis_op4_tkeep         ),
    .s_axis_op4_tuser        (m_axis_op4_tuser         ),
    .s_axis_op4_tvalid       (m_axis_op4_tvalid        ),
    .s_axis_op4_tready       (m_axis_op4_tready        ),
    .s_axis_op4_tlast        (m_axis_op4_tlast         )
    
);

stash#(

)stash(
    .axis_aclk         (axis_aclk              ),
    .axis_resetn       (axis_resetn            ),
    
    .i_op0_stash_tdata (stash_s_op0_tdata      ),//cache没有命中，数据进入stash查询
    .i_op0_stash_tkeep (stash_s_op0_tkeep      ),
    .i_op0_stash_tuser (stash_s_op0_tuser      ),
    .i_op0_stash_tvalid(stash_s_op0_tvalid     ),
    .o_op0_stash_tready(stash_s_op0_tready     ),
    .i_op0_stash_tlast (stash_s_op0_tlast      ),

    .i_op2_stash_tdata (m_axis_op2_tdata         ),//写stash
    .i_op2_stash_tkeep (m_axis_op2_tkeep         ),
    .i_op2_stash_tuser (m_axis_op2_tuser         ),
    .i_op2_stash_tvalid(m_axis_op2_tvalid        ),
    .o_op2_stash_tready(m_axis_op2_tready        ),
    .i_op2_stash_tlast (m_axis_op2_tlast         ),
    
    .o_op1_stash_tdata (w_stash_m_axis_op1_tdata ),//stash命中返回报文，进入到输出交换模块 READ_REPLY
    .o_op1_stash_tkeep (w_stash_m_axis_op1_tkeep ),
    .o_op1_stash_tuser (w_stash_m_axis_op1_tuser ),
    .o_op1_stash_tvalid(w_stash_m_axis_op1_tvalid),
    .i_op1_stash_tready(w_stash_m_axis_op1_tready),
    .o_op1_stash_tlast (w_stash_m_axis_op1_tlast ),
    
    .o_op0_server_tdata (w_op0_server_tdata        ),//stash没有命中，转发到交换端口给服务 
    .o_op0_server_tkeep (w_op0_server_tkeep        ),
    .o_op0_server_tuser (w_op0_server_tuser        ),
    .o_op0_server_tvalid(w_op0_server_tvalid       ),
    .i_op0_server_tready(w_op0_server_tready       ),
    .o_op0_server_tlast (w_op0_server_tlast        ),
   
    .o_op5_stash_tdata (w_op5_server_tdata        ),
    .o_op5_stash_tkeep (w_op5_server_tkeep        ),
    .o_op5_stash_tuser (w_op5_server_tuser        ),
    .o_op5_stash_tvalid(w_op5_server_tvalid       ),
    .i_op5_stash_tready(w_op5_server_tready       ),
    .o_op5_stash_tlast (w_op5_server_tlast        )  
);

switch_port #(
    .C_S_AXIS_DATA_WIDTH (C_S_AXIS_DATA_WIDTH ),
    .C_S_AXIS_TUSER_WIDTH(C_S_AXIS_TUSER_WIDTH)
) switch_port(
        .axis_aclk    (axis_aclk), 
        .axis_resetn  (axis_resetn), 

        .i_def_m_axis_tdata          (def_m_axis_tdata         ),
        .i_def_m_axis_tkeep          (def_m_axis_tkeep         ),
        .i_def_m_axis_tuser          (def_m_axis_tuser         ),
        .i_def_m_axis_tvalid         (def_m_axis_tvalid        ),
        .o_def_m_axis_tready         (def_m_axis_tready        ),
        .i_def_m_axis_tlast          (def_m_axis_tlast         ),
        
        .i_cache_s_axis_op1_tdata    (w_cache_m_axis_op1_tdata ),//cache 命中的报文，发给客户端输出
        .i_cache_s_axis_op1_tkeep    (w_cache_m_axis_op1_tkeep ),
        .i_cache_s_axis_op1_tuser    (w_cache_m_axis_op1_tuser ),
        .i_cache_s_axis_op1_tvalid   (w_cache_m_axis_op1_tvalid),
        .o_cache_s_axis_op1_tready   (w_cache_m_axis_op1_tready),
        .i_cache_s_axis_op1_tlast    (w_cache_m_axis_op1_tlast ),
          
        .i_stash_s_axis_op1_tdata    (w_stash_m_axis_op1_tdata ),//stash 命中的报文，发给客户端输出
        .i_stash_s_axis_op1_tkeep    (w_stash_m_axis_op1_tkeep ),
        .i_stash_s_axis_op1_tuser    (w_stash_m_axis_op1_tuser ),
        .i_stash_s_axis_op1_tvalid   (w_stash_m_axis_op1_tvalid),
        .o_stash_s_axis_op1_tready   (w_stash_m_axis_op1_tready),
        .i_stash_s_axis_op1_tlast    (w_stash_m_axis_op1_tlast ),
        
        .i_op0_server_tdata          (w_op0_server_tdata       ),//stash he cache dou meiyou mingzhong,fa gei fuwuqi
        .i_op0_server_tkeep          (w_op0_server_tkeep       ),
        .i_op0_server_tuser          (w_op0_server_tuser       ),
        .i_op0_server_tvalid         (w_op0_server_tvalid      ),
        .o_op0_server_tready         (w_op0_server_tready      ),
        .i_op0_server_tlast          (w_op0_server_tlast       ),
        
        .i_op1_server_tdata          (w_op1_server_tdata       ),//fuwuqi mingzhong op0 fanhuigei kehuduan
        .i_op1_server_tkeep          (w_op1_server_tkeep       ),
        .i_op1_server_tuser          (w_op1_server_tuser       ),
        .i_op1_server_tvalid         (w_op1_server_tvalid      ),
        .o_op1_server_tready         (w_op1_server_tready      ),
        .i_op1_server_tlast          (w_op1_server_tlast       ), 
        
        .i_op5_server_tdata          (w_op5_server_tdata       ),
        .i_op5_server_tkeep          (w_op5_server_tkeep       ),
        .i_op5_server_tuser          (w_op5_server_tuser       ),
        .i_op5_server_tvalid         (w_op5_server_tvalid      ),
        .o_op5_server_tready         (w_op5_server_tready      ),
        .i_op5_server_tlast          (w_op5_server_tlast       ),

        .i_op6_stash_tdata           (m_axis_op6_tdata         ), // OP6, WRITE_REPLY
        .i_op6_stash_tkeep           (m_axis_op6_tkeep         ),
        .i_op6_stash_tuser           (m_axis_op6_tuser         ),
        .i_op6_stash_tvalid          (m_axis_op6_tvalid        ),
        .i_op6_stash_tready          (m_axis_op6_tready        ),
        .i_op6_stash_tlast           (m_axis_op6_tlast         ), 
        
        .o_axis_opl_tdata            (m_axis_tdata             ), 
        .o_axis_opl_tkeep            (m_axis_tkeep             ), 
        .o_axis_opl_tuser            (m_axis_tuser             ), 
        .o_axis_opl_tvalid           (m_axis_tvalid            ),
        .i_axis_opl_tready           (1'b1                     ),
        .o_axis_opl_tlast            (m_axis_tlast             )  
);

ila_1_freq_absorb ila_freq_absorb(
    .clk(axis_aclk), // input wire clk

    .probe0(s_axis_tdata ), // input wire [255:0]  probe0  
    .probe1(s_axis_tkeep ), // input wire [31:0]  probe1 
    .probe2(s_axis_tuser ), // input wire [127:0]  probe2 
    .probe3(s_axis_tvalid), // input wire [0:0]  probe3 
    .probe4(s_axis_tready), // input wire [0:0]  probe4 
    .probe5(s_axis_tlast ), // input wire [0:0]  probe5 
    .probe6 (m_axis_tdata  ), // input wire [255:0]  probe6 
    .probe7 (m_axis_tkeep  ), // input wire [31:0]  probe7 
    .probe8 (m_axis_tuser  ), // input wire [127:0]  probe8 
    .probe9 (m_axis_tvalid ), // input wire [0:0]  probe9 
    .probe10(m_axis_tready), // input wire [0:0]  probe10 
    .probe11(m_axis_tlast) // input wire [0:0]  probe11
);
endmodule