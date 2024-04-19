`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/02 09:42:56
// Design Name: 
// Module Name: stash
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


module stash #(

)(
    input          axis_aclk         ,
    input          axis_resetn       ,

    input  [255:0] i_op0_stash_tdata ,  //cache没有命中，数据进入stash查询
    input  [31:0 ] i_op0_stash_tkeep ,
    input  [127:0] i_op0_stash_tuser ,
    input          i_op0_stash_tvalid,
    output         o_op0_stash_tready,
    input          i_op0_stash_tlast ,

    input  [255:0] i_op2_stash_tdata , //写stash
    input  [31:0 ] i_op2_stash_tkeep ,
    input  [127:0] i_op2_stash_tuser ,
    input          i_op2_stash_tvalid,
    output         o_op2_stash_tready,
    input          i_op2_stash_tlast ,

    output [255:0] o_op1_stash_tdata ,  //stash命中返回报文，进入到输出交换模块 READ_REPLY
    output [31:0 ] o_op1_stash_tkeep ,
    output [127:0] o_op1_stash_tuser ,
    output         o_op1_stash_tvalid,
    input          i_op1_stash_tready,
    output          o_op1_stash_tlast ,

    output [255:0] o_op0_server_tdata ,  //stash没有命中(或者stash满，再看)，转发到交换端口给服务
    output [31:0 ] o_op0_server_tkeep ,
    output [127:0] o_op0_server_tuser ,
    output         o_op0_server_tvalid,
    input          i_op0_server_tready,
    output         o_op0_server_tlast ,

    output [255:0] o_op5_stash_tdata , //stash syn
    output [31:0 ] o_op5_stash_tkeep ,
    output [127:0] o_op5_stash_tuser ,
    output         o_op5_stash_tvalid,
    input          i_op5_stash_tready,
    output         o_op5_stash_tlast
    
);
wire o_op0_stash_key_tready;
wire o_op0_flush_tready    ;
assign o_op0_stash_tready = o_op0_stash_key_tready &  o_op0_flush_tready;
wire [31:0]        op0_key_bit      ;
wire               op0_key_bit_valid;
wire               op0_key_bit_mask ;

wire [31:0]        op2_key_bit      ;
wire               op2_key_bit_valid;
wire               op2_key_bit_mask ;


//写op0和op2分别实现写tcam
stash_wr_tcam #(
    
)stash_wr_tcam(
    .axis_aclk                (axis_aclk                ),
    .axis_resetn              (axis_resetn              ),

    .s_op2_axis_tdata         (i_op2_stash_tdata        ),
    .s_op2_axis_tkeep         (i_op2_stash_tkeep        ),
    .s_op2_axis_tuser         (i_op2_stash_tuser        ),
    .s_op2_axis_tvalid        (i_op2_stash_tvalid       ),
    .s_op2_axis_tready        (o_op2_stash_tready       ),
    .s_op2_axis_tlast         (i_op2_stash_tlast        ),

    //op0先查询TCAM,判断是否写入TCAM对应的地址       
    .i_op0_key           (op0_key_bit              ), //op0读回复
    .i_op0_key_valid     (op0_key_bit_valid        ),
    .o_op0_match         (op0_tcam_match           ), //op0的key匹配上了，原数据转发
    .o_op0_match_end     (op0_tcam_match_end       ),

    .i_op2_key           (op2_key_bit              ), //op2写stash的key进tcam，先查找tcam，看是否存在tcam
    .i_op2_key_valid     (op2_key_bit_valid        ),

    //sync
    .o_op5_stash_tdata        (o_op5_stash_tdata        ),       
    .o_op5_stash_tkeep        (o_op5_stash_tkeep        ),
    .o_op5_stash_tuser        (o_op5_stash_tuser        ),
    .o_op5_stash_tvalid       (o_op5_stash_tvalid       ),
    .i_op5_stash_tready       (i_op5_stash_tready       ),
    .o_op5_stash_tlast        (o_op5_stash_tlast        )
);
extract_key #(

)stash_key_op0(
    .axis_aclk                (axis_aclk          ),
    .axis_resetn              (axis_resetn        ),

    .s_axis_tdata             (i_op0_stash_tdata  ),
    .s_axis_tkeep             (i_op0_stash_tkeep  ),
    .s_axis_tuser             (i_op0_stash_tuser  ),
    .s_axis_tvalid            (i_op0_stash_tvalid ),
    .s_axis_tready            (o_op0_stash_key_tready ),
    .s_axis_tlast             (i_op0_stash_tlast  ),

    .o_key_bit                (op0_key_bit        ),
    .o_key_bit_valid          (op0_key_bit_valid  ),
    .o_key_bit_mask           (op0_key_bit_mask   )     
);

extract_key #(

)stash_key_op2(
    .axis_aclk                (axis_aclk          ),
    .axis_resetn              (axis_resetn        ),

    .s_axis_tdata             (i_op2_stash_tdata  ),
    .s_axis_tkeep             (i_op2_stash_tkeep  ),
    .s_axis_tuser             (i_op2_stash_tuser  ),
    .s_axis_tvalid            (i_op2_stash_tvalid ),
    .s_axis_tready            (o_op2_stash_tready ),
    .s_axis_tlast             (i_op2_stash_tlast  ),

    .o_key_bit                (op2_key_bit        ),
    .o_key_bit_valid          (op2_key_bit_valid  ),
    .o_key_bit_mask           (op2_key_bit_mask   )     
);

//     //数据在op0下回复不同转发
stash_flush_out #(

)flush_out
(
    .axis_aclk                  (axis_aclk         ),
    .axis_resetn                (axis_resetn       ),

    .i_tcam_match               (op0_tcam_match     ),
    .i_tcam_match_end           (op0_tcam_match_end ),

    .s_axis_tdata               (i_op0_stash_tdata  ),
    .s_axis_tkeep               (i_op0_stash_tkeep  ),
    .s_axis_tuser               (i_op0_stash_tuser  ),
    .s_axis_tvalid              (i_op0_stash_tvalid ),
    .s_axis_tready              (o_op0_flush_tready ),
    .s_axis_tlast               (i_op0_stash_tlast  ),

    .o_op1_stash_tdata          (o_op1_stash_tdata   ),
    .o_op1_stash_tkeep          (o_op1_stash_tkeep   ),
    .o_op1_stash_tuser          (o_op1_stash_tuser   ),
    .o_op1_stash_tvalid         (o_op1_stash_tvalid  ),
    .o_op1_stash_tready         (o_op1_stash_tready  ),
    .o_op1_stash_tlast          (o_op1_stash_tlast   ),

    .o_op0_serve_tdata          (o_op0_server_tdata   ),
    .o_op0_serve_tkeep          (o_op0_server_tkeep   ),
    .o_op0_serve_tuser          (o_op0_server_tuser   ),
    .o_op0_serve_tvalid         (o_op0_server_tvalid  ),
    .o_op0_serve_tready         (o_op0_server_tready  ),
    .o_op0_serve_tlast          (o_op0_server_tlast   )
);

    
endmodule
