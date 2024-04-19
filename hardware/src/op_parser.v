`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/01 17:18:58
// Design Name: 
// Module Name: op_parser
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

module op_parser #(
    parameter C_S_AXIS_DATA_WIDTH = 256,
   	parameter C_S_AXIS_TUSER_WIDTH = 128
)(
    input                                       axis_aclk    ,
    input                                       axis_resetn  ,

    input  wire [C_S_AXIS_DATA_WIDTH-1:0]       s_axis_tdata ,
    input  wire [((C_S_AXIS_DATA_WIDTH/8))-1:0] s_axis_tkeep ,
    input  wire [C_S_AXIS_TUSER_WIDTH-1:0]      s_axis_tuser ,
    input  wire                                 s_axis_tvalid,
    output wire                                 s_axis_tready,
    input  wire                                 s_axis_tlast ,

    output reg [C_S_AXIS_DATA_WIDTH-1:0]       m_axis_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] m_axis_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      m_axis_tuser ,
    output reg                                 m_axis_tvalid,
    input  wire                                m_axis_tready,
    output reg                                 m_axis_tlast ,

    output reg [C_S_AXIS_DATA_WIDTH-1:0]       m_axis_op0_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] m_axis_op0_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      m_axis_op0_tuser ,
    output reg                                 m_axis_op0_tvalid,
    input  wire                                m_axis_op0_tready,
    output reg                                 m_axis_op0_tlast ,

    output reg [C_S_AXIS_DATA_WIDTH-1:0]       m_op1_server_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] m_op1_server_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      m_op1_server_tuser ,
    output reg                                 m_op1_server_tvalid,
    input  wire                                m_op1_server_tready,
    output reg                                 m_op1_server_tlast ,

    output reg [C_S_AXIS_DATA_WIDTH-1:0]       m_axis_op2_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] m_axis_op2_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      m_axis_op2_tuser ,
    output reg                                 m_axis_op2_tvalid,
    input  wire                                m_axis_op2_tready,
    output reg                                 m_axis_op2_tlast ,

    output reg [C_S_AXIS_DATA_WIDTH-1:0]       m_axis_op3_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] m_axis_op3_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      m_axis_op3_tuser ,
    output reg                                 m_axis_op3_tvalid,
    input  wire                                m_axis_op3_tready,
    output reg                                 m_axis_op3_tlast ,

    output reg [C_S_AXIS_DATA_WIDTH-1:0]       m_axis_op4_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] m_axis_op4_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      m_axis_op4_tuser ,
    output reg                                 m_axis_op4_tvalid,
    input  wire                                m_axis_op4_tready,
    output reg                                 m_axis_op4_tlast ,

    output reg [C_S_AXIS_DATA_WIDTH-1:0]       m_axis_op5_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] m_axis_op5_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      m_axis_op5_tuser ,
    output reg                                 m_axis_op5_tvalid,
    input  wire                                m_axis_op5_tready,
    output reg                                 m_axis_op5_tlast ,

    output reg [C_S_AXIS_DATA_WIDTH-1:0]       m_axis_op6_tdata ,
    output reg [((C_S_AXIS_DATA_WIDTH/8))-1:0] m_axis_op6_tkeep ,
    output reg [C_S_AXIS_TUSER_WIDTH-1:0]      m_axis_op6_tuser ,
    output reg                                 m_axis_op6_tvalid,
    input  wire                                m_axis_op6_tready,
    output reg                                 m_axis_op6_tlast 

);   

ila_1_op_parser ila_op_parser (
	.clk(axis_aclk), // input wire clk

	.probe0(s_axis_tdata ), // input wire [255:0]  probe0  
	.probe1(s_axis_tkeep ), // input wire [31:0]  probe1 
	.probe2(s_axis_tuser ), // input wire [127:0]  probe2 
	.probe3(s_axis_tvalid), // input wire [0:0]  probe3 
	.probe4(s_axis_tready), // input wire [0:0]  probe4 
	.probe5(s_axis_tlast ), // input wire [0:0]  probe5 
	.probe6 (m_op1_server_tdata ), // input wire [255:0]  probe6 
	.probe7 (m_op1_server_tkeep ), // input wire [31:0]  probe7 
	.probe8 (m_op1_server_tuser ), // input wire [127:0]  probe8 
	.probe9 (m_op1_server_tvalid), // input wire [0:0]  probe9 
	.probe10(m_op1_server_tready), // input wire [0:0]  probe10 
	.probe11(m_op1_server_tlast ) // input wire [0:0]  probe11
);

localparam  WAIT_FIRST_PKT  = 3'b000,
            WAIT_SECOND_PKT = 3'b001,
            BUFFER_CTL      = 3'b010,
            BUFFER_DATA     = 3'b011,
            FLUSH_IDLE_PKT  = 3'b100;

localparam  FIL_OUT_IDLE   = 4'b0000,//起始状态机跳转
   			FIL_OUT_SWITCH = 4'b0001,//一包数据后状态机跳转
            FLUSH_OP0      = 4'b0010,
            FLUSH_OP1      = 4'b0011,
            FLUSH_OP2      = 4'b0100,
            FLUSH_OP3      = 4'b0101,
            FLUSH_OP4      = 4'b0110,
            FLUSH_OP5      = 4'b0111,
            FLUSH_OP6      = 4'b1000,
            FLUSH_OP7      = 4'b1001;
            // FLUSH_CTL      = 3'b010,
            // FLUSH_DATA     = 3'b011;

   wire                                  pkt_fifo_nearly_full;
   wire                                  pkt_fifo_empty;

   assign s_axis_tready = (m_axis_tready && !pkt_fifo_nearly_full);

    
   wire [C_S_AXIS_DATA_WIDTH-1:0]		tdata_fifo;
   wire [C_S_AXIS_TUSER_WIDTH-1:0]		tuser_fifo;
   wire [C_S_AXIS_DATA_WIDTH/8-1:0]	    tkeep_fifo;
   wire								    tlast_fifo;
    
   reg                                  pkt_fifo_wr_en,pkt_fifo_rd_en  ;
   reg [C_S_AXIS_DATA_WIDTH-1:0]        r_s_axis_tdata_0;
   reg [((C_S_AXIS_DATA_WIDTH/8))-1:0]  r_s_axis_tkeep_0;
   reg [C_S_AXIS_TUSER_WIDTH-1:0]       r_s_axis_tuser_0;
   reg                                  r_s_axis_tvalid_0;
   reg                                  r_s_axis_tlast_0;
   reg                                  rd_fifo_flag; 

   reg [7:0]                            op_type;
   
    
   fallthrough_small_fifo #(
   	.WIDTH(C_S_AXIS_DATA_WIDTH + C_S_AXIS_TUSER_WIDTH + C_S_AXIS_DATA_WIDTH/8 + 1),
   	.MAX_DEPTH_BITS(10)
   )
   op_parser_fifo
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
   		    rd_fifo_flag <= 1'b0;
   		    fil_in_state <= WAIT_FIRST_PKT;
            op_type      <= 8'hff;
   	    end
        else begin
            case(fil_in_state)
                WAIT_FIRST_PKT: begin
                    op_type      <= 8'hff;
                    rd_fifo_flag <= 1'b0;
                    if(s_axis_tvalid) begin
                        if(s_axis_tdata[191:184]==`IPPROT_UDP) begin
                            pkt_fifo_wr_en <= 1'b1;
   						    fil_in_state   <= WAIT_SECOND_PKT;
                        end
                        else begin
                            op_type <= 8'h07;
                            fil_in_state <= FLUSH_IDLE_PKT;//ICMP
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
                            op_type      <= s_axis_tdata[87:80];
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
                FLUSH_IDLE_PKT:begin
                    op_type <= 8'h07;
                    if(s_axis_tlast)
                        fil_in_state <= WAIT_FIRST_PKT;
                    else
                        fil_in_state <= FLUSH_IDLE_PKT;
                end
            endcase
        end 
    end

    always @(posedge axis_aclk)begin //op_type==7 out
        if(!axis_resetn)begin
            m_axis_tdata   <= 0;
            m_axis_tkeep   <= 0;
            m_axis_tuser   <= 0;
            m_axis_tvalid  <= 0;
            m_axis_tlast   <= 0;
        end
        else if(op_type == 8'h7)begin
            m_axis_tdata   <= r_s_axis_tdata_0 ;
            m_axis_tkeep   <= r_s_axis_tkeep_0 ;
            m_axis_tuser   <= r_s_axis_tuser_0 ;
            m_axis_tvalid  <= r_s_axis_tvalid_0;
            m_axis_tlast   <= r_s_axis_tlast_0 ;
        end
        else begin
            m_axis_tdata   <= r_s_axis_tdata_0 ;
            m_axis_tkeep   <= r_s_axis_tkeep_0 ;
            m_axis_tuser   <= r_s_axis_tuser_0 ;
            m_axis_tvalid  <= r_s_axis_tvalid_0;
            m_axis_tlast   <= r_s_axis_tlast_0 ;
        end
    end

    wire [7:0] w_op_type;
    assign w_op_type = (rd_fifo_flag)?op_type:w_op_type;


    reg [3:0] fil_out_state;
    reg       r_tlast_fifo;

    always @(posedge axis_aclk) begin
   	    if(!axis_resetn)
   	    	r_tlast_fifo <= 1'b0;
   	    else
   	    	r_tlast_fifo <= tlast_fifo;
    end

    always @(posedge axis_aclk) begin
        if(!axis_resetn) begin
            pkt_fifo_rd_en <= 1'b0;
   		    fil_out_state <= FIL_OUT_IDLE;

            m_axis_op0_tdata  <= 0;
            m_axis_op0_tkeep  <= 0;
            m_axis_op0_tuser  <= 0;
            m_axis_op0_tvalid <= 0;
            m_axis_op0_tlast  <= 0;  
            
            m_op1_server_tdata  <= 0;
            m_op1_server_tkeep  <= 0;
            m_op1_server_tuser  <= 0;
            m_op1_server_tvalid <= 0;
            m_op1_server_tlast  <= 0;
            
            m_axis_op2_tdata  <= 0;
            m_axis_op2_tkeep  <= 0;
            m_axis_op2_tuser  <= 0;
            m_axis_op2_tvalid <= 0;
            m_axis_op2_tlast  <= 0;
            
            m_axis_op3_tdata  <= 0;
            m_axis_op3_tkeep  <= 0;
            m_axis_op3_tuser  <= 0;
            m_axis_op3_tvalid <= 0;
            m_axis_op3_tlast  <= 0;
            
            m_axis_op4_tdata  <= 0;
            m_axis_op4_tkeep  <= 0;
            m_axis_op4_tuser  <= 0;
            m_axis_op4_tvalid <= 0;
            m_axis_op4_tlast  <= 0; 
            
            m_axis_op5_tdata  <= 0;
            m_axis_op5_tkeep  <= 0;
            m_axis_op5_tuser  <= 0;
            m_axis_op5_tvalid <= 0;
            m_axis_op5_tlast  <= 0; 
            
            m_axis_op6_tdata  <= 0;
            m_axis_op6_tkeep  <= 0;
            m_axis_op6_tuser  <= 0;
            m_axis_op6_tvalid <= 0;
            m_axis_op6_tlast  <= 0;
        end
        else begin
            case(fil_out_state)
   			    FIL_OUT_IDLE:begin//fifo不是一开始就有数据，要等待3包数据之后才有数据

                    m_axis_op0_tdata  <= 0;
                    m_axis_op0_tkeep  <= 0;
                    m_axis_op0_tuser  <= 0;
                    m_axis_op0_tvalid <= 0;
                    m_axis_op0_tlast  <= 0;

                    m_op1_server_tdata  <= 0;
                    m_op1_server_tkeep  <= 0;
                    m_op1_server_tuser  <= 0;
                    m_op1_server_tvalid <= 0;
                    m_op1_server_tlast  <= 0;

                    m_axis_op2_tdata  <= 0;
                    m_axis_op2_tkeep  <= 0;
                    m_axis_op2_tuser  <= 0;
                    m_axis_op2_tvalid <= 0;
                    m_axis_op2_tlast  <= 0; 

                    m_axis_op3_tdata  <= 0;
                    m_axis_op3_tkeep  <= 0;
                    m_axis_op3_tuser  <= 0;
                    m_axis_op3_tvalid <= 0;
                    m_axis_op3_tlast  <= 0;

                    m_axis_op4_tdata  <= 0;
                    m_axis_op4_tkeep  <= 0;
                    m_axis_op4_tuser  <= 0;
                    m_axis_op4_tvalid <= 0;
                    m_axis_op4_tlast  <= 0;

                    m_axis_op5_tdata  <= 0;
                    m_axis_op5_tkeep  <= 0;
                    m_axis_op5_tuser  <= 0;
                    m_axis_op5_tvalid <= 0;
                    m_axis_op5_tlast  <= 0;

                    m_axis_op6_tdata  <= 0;
                    m_axis_op6_tkeep  <= 0;
                    m_axis_op6_tuser  <= 0;
                    m_axis_op6_tvalid <= 0;
                    m_axis_op6_tlast  <= 0;
   			    	if(!pkt_fifo_empty) begin //读出需要提前一拍取
   			    		pkt_fifo_rd_en     <= 1'd1;
                        case(w_op_type)
                            8'h00:
                                fil_out_state      <= FLUSH_OP0;
                            8'h01:
                                fil_out_state      <= FLUSH_OP1;
                            8'h02:
                                fil_out_state      <= FLUSH_OP2;
                            8'h03:
                                fil_out_state      <= FLUSH_OP3;
                            8'h04:
                                fil_out_state      <= FLUSH_OP4;
                            8'h05:
                                fil_out_state      <= FLUSH_OP5;
                            8'h06:
                                fil_out_state      <= FLUSH_OP6;
                            default:
                                fil_out_state      <= FIL_OUT_IDLE;
                        endcase
                    end
   			    	else begin
   			    		pkt_fifo_rd_en     <= 1'd0;
   			    		fil_out_state      <= FIL_OUT_IDLE;
   			    	end
   			    end
                FIL_OUT_SWITCH:begin
                    if (!pkt_fifo_empty) begin
                        pkt_fifo_rd_en <= 1'b1;
                        case (w_op_type)
                            8'h00: begin
                                fil_out_state     <= FLUSH_OP0;
                                m_axis_op0_tdata  <= tdata_fifo;
                                m_axis_op0_tkeep  <= tkeep_fifo;
                                m_axis_op0_tuser  <= tuser_fifo;
                                m_axis_op0_tvalid <= 1'b1;
                                m_axis_op0_tlast  <= tlast_fifo;

                                m_op1_server_tdata  <= 0;
                                m_op1_server_tkeep  <= 0;
                                m_op1_server_tuser  <= 0;
                                m_op1_server_tvalid <= 0;
                                m_op1_server_tlast  <= 0;

                                m_axis_op2_tdata  <= 0;
                                m_axis_op2_tkeep  <= 0;
                                m_axis_op2_tuser  <= 0;
                                m_axis_op2_tvalid <= 0;
                                m_axis_op2_tlast  <= 0; 

                                m_axis_op3_tdata  <= 0;
                                m_axis_op3_tkeep  <= 0;
                                m_axis_op3_tuser  <= 0;
                                m_axis_op3_tvalid <= 0;
                                m_axis_op3_tlast  <= 0;

                                m_axis_op4_tdata  <= 0;
                                m_axis_op4_tkeep  <= 0;
                                m_axis_op4_tuser  <= 0;
                                m_axis_op4_tvalid <= 0;
                                m_axis_op4_tlast  <= 0;

                                m_axis_op5_tdata  <= 0;
                                m_axis_op5_tkeep  <= 0;
                                m_axis_op5_tuser  <= 0;
                                m_axis_op5_tvalid <= 0;
                                m_axis_op5_tlast  <= 0;

                                m_axis_op6_tdata  <= 0;
                                m_axis_op6_tkeep  <= 0;
                                m_axis_op6_tuser  <= 0;
                                m_axis_op6_tvalid <= 0;
                                m_axis_op6_tlast  <= 0;
                            end
                            8'h01: begin
                                fil_out_state       <= FLUSH_OP1;
                                m_op1_server_tdata  <= tdata_fifo;
                                m_op1_server_tkeep  <= tkeep_fifo;
                                m_op1_server_tuser  <= tuser_fifo;
                                m_op1_server_tvalid <= 1'b1;
                                m_op1_server_tlast  <= tlast_fifo;

                                m_axis_op0_tdata  <= 0;
                                m_axis_op0_tkeep  <= 0;
                                m_axis_op0_tuser  <= 0;
                                m_axis_op0_tvalid <= 0;
                                m_axis_op0_tlast  <= 0;

                                m_axis_op2_tdata  <= 0;
                                m_axis_op2_tkeep  <= 0;
                                m_axis_op2_tuser  <= 0;
                                m_axis_op2_tvalid <= 0;
                                m_axis_op2_tlast  <= 0; 

                                m_axis_op3_tdata  <= 0;
                                m_axis_op3_tkeep  <= 0;
                                m_axis_op3_tuser  <= 0;
                                m_axis_op3_tvalid <= 0;
                                m_axis_op3_tlast  <= 0;

                                m_axis_op4_tdata  <= 0;
                                m_axis_op4_tkeep  <= 0;
                                m_axis_op4_tuser  <= 0;
                                m_axis_op4_tvalid <= 0;
                                m_axis_op4_tlast  <= 0;

                                m_axis_op5_tdata  <= 0;
                                m_axis_op5_tkeep  <= 0;
                                m_axis_op5_tuser  <= 0;
                                m_axis_op5_tvalid <= 0;
                                m_axis_op5_tlast  <= 0;

                                m_axis_op6_tdata  <= 0;
                                m_axis_op6_tkeep  <= 0;
                                m_axis_op6_tuser  <= 0;
                                m_axis_op6_tvalid <= 0;
                                m_axis_op6_tlast  <= 0;
                            end
                            8'h02: begin
                                fil_out_state <= FLUSH_OP2;
                                m_axis_op2_tdata  <= tdata_fifo;
                                m_axis_op2_tkeep  <= tkeep_fifo;
                                m_axis_op2_tuser  <= tuser_fifo;
                                m_axis_op2_tvalid <= 1'b1;
                                m_axis_op2_tlast  <= tlast_fifo;

                                m_axis_op0_tdata  <= 0;
                                m_axis_op0_tkeep  <= 0;
                                m_axis_op0_tuser  <= 0;
                                m_axis_op0_tvalid <= 0;
                                m_axis_op0_tlast  <= 0;

                                m_op1_server_tdata  <= 0;
                                m_op1_server_tkeep  <= 0;
                                m_op1_server_tuser  <= 0;
                                m_op1_server_tvalid <= 0;
                                m_op1_server_tlast  <= 0; 

                                m_axis_op3_tdata  <= 0;
                                m_axis_op3_tkeep  <= 0;
                                m_axis_op3_tuser  <= 0;
                                m_axis_op3_tvalid <= 0;
                                m_axis_op3_tlast  <= 0;

                                m_axis_op4_tdata  <= 0;
                                m_axis_op4_tkeep  <= 0;
                                m_axis_op4_tuser  <= 0;
                                m_axis_op4_tvalid <= 0;
                                m_axis_op4_tlast  <= 0;

                                m_axis_op5_tdata  <= 0;
                                m_axis_op5_tkeep  <= 0;
                                m_axis_op5_tuser  <= 0;
                                m_axis_op5_tvalid <= 0;
                                m_axis_op5_tlast  <= 0;

                                m_axis_op6_tdata  <= 0;
                                m_axis_op6_tkeep  <= 0;
                                m_axis_op6_tuser  <= 0;
                                m_axis_op6_tvalid <= 0;
                                m_axis_op6_tlast  <= 0;
                            end
                            8'h03: begin
                                fil_out_state <= FLUSH_OP3;
                                m_axis_op3_tdata  <= tdata_fifo;
                                m_axis_op3_tkeep  <= tkeep_fifo;
                                m_axis_op3_tuser  <= tuser_fifo;
                                m_axis_op3_tvalid <= 1'b1;
                                m_axis_op3_tlast  <= tlast_fifo;
                                m_axis_op2_tvalid <= 1'b0;

                                m_axis_op0_tdata  <= 0;
                                m_axis_op0_tkeep  <= 0;
                                m_axis_op0_tuser  <= 0;
                                m_axis_op0_tvalid <= 0;
                                m_axis_op0_tlast  <= 0;

                                m_op1_server_tdata  <= 0;
                                m_op1_server_tkeep  <= 0;
                                m_op1_server_tuser  <= 0;
                                m_op1_server_tvalid <= 0;
                                m_op1_server_tlast  <= 0;

                                m_axis_op2_tdata  <= 0;
                                m_axis_op2_tkeep  <= 0;
                                m_axis_op2_tuser  <= 0;
                                m_axis_op2_tvalid <= 0;
                                m_axis_op2_tlast  <= 0; 

                                m_axis_op4_tdata  <= 0;
                                m_axis_op4_tkeep  <= 0;
                                m_axis_op4_tuser  <= 0;
                                m_axis_op4_tvalid <= 0;
                                m_axis_op4_tlast  <= 0;

                                m_axis_op5_tdata  <= 0;
                                m_axis_op5_tkeep  <= 0;
                                m_axis_op5_tuser  <= 0;
                                m_axis_op5_tvalid <= 0;
                                m_axis_op5_tlast  <= 0;

                                m_axis_op6_tdata  <= 0;
                                m_axis_op6_tkeep  <= 0;
                                m_axis_op6_tuser  <= 0;
                                m_axis_op6_tvalid <= 0;
                                m_axis_op6_tlast  <= 0;
                            end
                            8'h04: begin
                                fil_out_state     <= FLUSH_OP4;
                                m_axis_op4_tdata  <= tdata_fifo;
                                m_axis_op4_tkeep  <= tkeep_fifo;
                                m_axis_op4_tuser  <= tuser_fifo;
                                m_axis_op4_tvalid <= 1'b1;
                                m_axis_op4_tlast  <= tlast_fifo;

                                m_axis_op0_tdata  <= 0;
                                m_axis_op0_tkeep  <= 0;
                                m_axis_op0_tuser  <= 0;
                                m_axis_op0_tvalid <= 0;
                                m_axis_op0_tlast  <= 0;

                                m_op1_server_tdata  <= 0;
                                m_op1_server_tkeep  <= 0;
                                m_op1_server_tuser  <= 0;
                                m_op1_server_tvalid <= 0;
                                m_op1_server_tlast  <= 0;

                                m_axis_op2_tdata  <= 0;
                                m_axis_op2_tkeep  <= 0;
                                m_axis_op2_tuser  <= 0;
                                m_axis_op2_tvalid <= 0;
                                m_axis_op2_tlast  <= 0; 

                                m_axis_op3_tdata  <= 0;
                                m_axis_op3_tkeep  <= 0;
                                m_axis_op3_tuser  <= 0;
                                m_axis_op3_tvalid <= 0;
                                m_axis_op3_tlast  <= 0;

                                m_axis_op5_tdata  <= 0;
                                m_axis_op5_tkeep  <= 0;
                                m_axis_op5_tuser  <= 0;
                                m_axis_op5_tvalid <= 0;
                                m_axis_op5_tlast  <= 0;

                                m_axis_op6_tdata  <= 0;
                                m_axis_op6_tkeep  <= 0;
                                m_axis_op6_tuser  <= 0;
                                m_axis_op6_tvalid <= 0;
                                m_axis_op6_tlast  <= 0;
                            end
                            8'h05: begin
                                fil_out_state <= FLUSH_OP5;
                                m_axis_op5_tdata  <= tdata_fifo;
                                m_axis_op5_tkeep  <= tkeep_fifo;
                                m_axis_op5_tuser  <= tuser_fifo;
                                m_axis_op5_tvalid <= 1'b1;
                                m_axis_op5_tlast  <= tlast_fifo;
            
                                m_axis_op0_tdata  <= 0;
                                m_axis_op0_tkeep  <= 0;
                                m_axis_op0_tuser  <= 0;
                                m_axis_op0_tvalid <= 0;
                                m_axis_op0_tlast  <= 0;
            
                                m_op1_server_tdata  <= 0;
                                m_op1_server_tkeep  <= 0;
                                m_op1_server_tuser  <= 0;
                                m_op1_server_tvalid <= 0;
                                m_op1_server_tlast  <= 0;
            
                                m_axis_op2_tdata  <= 0;
                                m_axis_op2_tkeep  <= 0;
                                m_axis_op2_tuser  <= 0;
                                m_axis_op2_tvalid <= 0;
                                m_axis_op2_tlast  <= 0; 
            
                                m_axis_op3_tdata  <= 0;
                                m_axis_op3_tkeep  <= 0;
                                m_axis_op3_tuser  <= 0;
                                m_axis_op3_tvalid <= 0;
                                m_axis_op3_tlast  <= 0;
            
                                m_axis_op4_tdata  <= 0;
                                m_axis_op4_tkeep  <= 0;
                                m_axis_op4_tuser  <= 0;
                                m_axis_op4_tvalid <= 0;
                                m_axis_op4_tlast  <= 0;
            
                                m_axis_op6_tdata  <= 0;
                                m_axis_op6_tkeep  <= 0;
                                m_axis_op6_tuser  <= 0;
                                m_axis_op6_tvalid <= 0;
                                m_axis_op6_tlast  <= 0;
                            end
                            8'h06: begin
                                fil_out_state <= FLUSH_OP6;
                                m_axis_op6_tdata  <= tdata_fifo;
                                m_axis_op6_tkeep  <= tkeep_fifo;
                                m_axis_op6_tuser  <= tuser_fifo;
                                m_axis_op6_tvalid <= 1'b1;
                                m_axis_op6_tlast  <= tlast_fifo;

                                m_axis_op0_tdata  <= 0;
                                m_axis_op0_tkeep  <= 0;
                                m_axis_op0_tuser  <= 0;
                                m_axis_op0_tvalid <= 0;
                                m_axis_op0_tlast  <= 0;

                                m_op1_server_tdata  <= 0;
                                m_op1_server_tkeep  <= 0;
                                m_op1_server_tuser  <= 0;
                                m_op1_server_tvalid <= 0;
                                m_op1_server_tlast  <= 0;

                                m_axis_op2_tdata  <= 0;
                                m_axis_op2_tkeep  <= 0;
                                m_axis_op2_tuser  <= 0;
                                m_axis_op2_tvalid <= 0;
                                m_axis_op2_tlast  <= 0; 

                                m_axis_op3_tdata  <= 0;
                                m_axis_op3_tkeep  <= 0;
                                m_axis_op3_tuser  <= 0;
                                m_axis_op3_tvalid <= 0;
                                m_axis_op3_tlast  <= 0;

                                m_axis_op4_tdata  <= 0;
                                m_axis_op4_tkeep  <= 0;
                                m_axis_op4_tuser  <= 0;
                                m_axis_op4_tvalid <= 0;
                                m_axis_op4_tlast  <= 0;

                                m_axis_op5_tdata  <= 0;
                                m_axis_op5_tkeep  <= 0;
                                m_axis_op5_tuser  <= 0;
                                m_axis_op5_tvalid <= 0;
                                m_axis_op5_tlast  <= 0;
                            end
                            default: begin
                                fil_out_state  <= FIL_OUT_IDLE;

                                m_axis_op0_tdata  <= 0;
                                m_axis_op0_tkeep  <= 0;
                                m_axis_op0_tuser  <= 0;
                                m_axis_op0_tvalid <= 0;
                                m_axis_op0_tlast  <= 0;

                                m_op1_server_tdata  <= 0;
                                m_op1_server_tkeep  <= 0;
                                m_op1_server_tuser  <= 0;
                                m_op1_server_tvalid <= 0;
                                m_op1_server_tlast  <= 0;

                                m_axis_op2_tdata  <= 0;
                                m_axis_op2_tkeep  <= 0;
                                m_axis_op2_tuser  <= 0;
                                m_axis_op2_tvalid <= 0;
                                m_axis_op2_tlast  <= 0; 

                                m_axis_op3_tdata  <= 0;
                                m_axis_op3_tkeep  <= 0;
                                m_axis_op3_tuser  <= 0;
                                m_axis_op3_tvalid <= 0;
                                m_axis_op3_tlast  <= 0;

                                m_axis_op4_tdata  <= 0;
                                m_axis_op4_tkeep  <= 0;
                                m_axis_op4_tuser  <= 0;
                                m_axis_op4_tvalid <= 0;
                                m_axis_op4_tlast  <= 0;

                                m_axis_op5_tdata  <= 0;
                                m_axis_op5_tkeep  <= 0;
                                m_axis_op5_tuser  <= 0;
                                m_axis_op5_tvalid <= 0;
                                m_axis_op5_tlast  <= 0;

                                m_axis_op6_tdata  <= 0;
                                m_axis_op6_tkeep  <= 0;
                                m_axis_op6_tuser  <= 0;
                                m_axis_op6_tvalid <= 0;
                                m_axis_op6_tlast  <= 0;
                            end
                        endcase
                    end 
                    else begin
                        pkt_fifo_rd_en <= 1'b0;

                        m_axis_op0_tdata  <= 0;
                        m_axis_op0_tkeep  <= 0;
                        m_axis_op0_tuser  <= 0;
                        m_axis_op0_tvalid <= 0;
                        m_axis_op0_tlast  <= 0;

                        m_op1_server_tdata  <= 0;
                        m_op1_server_tkeep  <= 0;
                        m_op1_server_tuser  <= 0;
                        m_op1_server_tvalid <= 0;
                        m_op1_server_tlast  <= 0;

                        m_axis_op2_tdata  <= 0;
                        m_axis_op2_tkeep  <= 0;
                        m_axis_op2_tuser  <= 0;
                        m_axis_op2_tvalid <= 0;
                        m_axis_op2_tlast  <= 0; 

                        m_axis_op3_tdata  <= 0;
                        m_axis_op3_tkeep  <= 0;
                        m_axis_op3_tuser  <= 0;
                        m_axis_op3_tvalid <= 0;
                        m_axis_op3_tlast  <= 0;

                        m_axis_op4_tdata  <= 0;
                        m_axis_op4_tkeep  <= 0;
                        m_axis_op4_tuser  <= 0;
                        m_axis_op4_tvalid <= 0;
                        m_axis_op4_tlast  <= 0;

                        m_axis_op5_tdata  <= 0;
                        m_axis_op5_tkeep  <= 0;
                        m_axis_op5_tuser  <= 0;
                        m_axis_op5_tvalid <= 0;
                        m_axis_op5_tlast  <= 0;

                        m_axis_op6_tdata  <= 0;
                        m_axis_op6_tkeep  <= 0;
                        m_axis_op6_tuser  <= 0;
                        m_axis_op6_tvalid <= 0;
                        m_axis_op6_tlast  <= 0;
                        fil_out_state <= FIL_OUT_IDLE;
                    end
                end
                FLUSH_OP0:begin
                    if(m_axis_tready)begin //下一个模块准备好了
					    if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
                            m_axis_op0_tdata <= tdata_fifo;
                            m_axis_op0_tkeep <= tkeep_fifo;
                            m_axis_op0_tuser <= tuser_fifo;
                            m_axis_op0_tvalid<= 1'b1;
                            m_axis_op0_tlast <= tlast_fifo;
					    	fil_out_state <= FIL_OUT_SWITCH;
					    	pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
					    end
					    else begin
					    	fil_out_state <= FLUSH_OP0;
					    	if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
					    		pkt_fifo_rd_en <= 1'b1;
					    		m_axis_op0_tdata  <= 0;
					    	    m_axis_op0_tkeep  <= 0;
					    	    m_axis_op0_tuser  <= 0;
					    	    m_axis_op0_tvalid <= 0;
					    	    m_axis_op0_tlast  <= 0;
					    	end
					    	else begin //fifo没有空，继续读
					    		if(pkt_fifo_rd_en)begin
					    			m_axis_op0_tdata  <= tdata_fifo;
					    			m_axis_op0_tkeep  <= tkeep_fifo;
					    			m_axis_op0_tuser  <= tuser_fifo;
					    			m_axis_op0_tvalid <= 1'b1;
					    			m_axis_op0_tlast  <= tlast_fifo;
					    		end
					    		else begin
					    			m_axis_op0_tdata  <= 0;
					    			m_axis_op0_tkeep  <= 0;
					    			m_axis_op0_tuser  <= 0;
					    			m_axis_op0_tvalid <= 0;
					    			m_axis_op0_tlast  <= 0;
					    		end
					    		pkt_fifo_rd_en <= 1'b1;
					    	end
					    end
				    end
				    else begin
				    	pkt_fifo_rd_en <= 1'b0;
				    	m_axis_op0_tdata  <= 0;
				    	m_axis_op0_tkeep  <= 0;
				    	m_axis_op0_tuser  <= 0;
				    	m_axis_op0_tvalid <= 0;
				    	m_axis_op0_tlast  <= 0;
				    	fil_out_state <= FLUSH_OP0;
				    end
                end
                FLUSH_OP1:begin
                    if(m_axis_tready)begin //下一个模块准备好了
					    if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
                            m_op1_server_tdata <= tdata_fifo;
                            m_op1_server_tkeep <= tkeep_fifo;
                            m_op1_server_tuser <= tuser_fifo;
                            m_op1_server_tvalid<= 1'b1;
                            m_op1_server_tlast <= tlast_fifo;
					    	fil_out_state <= FIL_OUT_SWITCH;
					    	pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
					    end
					    else begin
					    	fil_out_state <= FLUSH_OP1;
					    	if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
					    		pkt_fifo_rd_en <= 1'b1;
					    		m_op1_server_tdata  <= 0;
					    	    m_op1_server_tkeep  <= 0;
					    	    m_op1_server_tuser  <= 0;
					    	    m_op1_server_tvalid <= 0;
					    	    m_op1_server_tlast  <= 0;
					    	end
					    	else begin //fifo没有空，继续读
					    		if(pkt_fifo_rd_en)begin
					    			m_op1_server_tdata  <= tdata_fifo;
					    			m_op1_server_tkeep  <= tkeep_fifo;
					    			m_op1_server_tuser  <= tuser_fifo;
					    			m_op1_server_tvalid <= 1'b1;
					    			m_op1_server_tlast  <= tlast_fifo;
					    		end
					    		else begin
					    			m_op1_server_tdata  <= 0;
					    			m_op1_server_tkeep  <= 0;
					    			m_op1_server_tuser  <= 0;
					    			m_op1_server_tvalid <= 0;
					    			m_op1_server_tlast  <= 0;
					    		end
					    		pkt_fifo_rd_en <= 1'b1;
					    	end
					    end
				    end
				    else begin
				    	pkt_fifo_rd_en <= 1'b0;
				    	m_op1_server_tdata  <= 0;
				    	m_op1_server_tkeep  <= 0;
				    	m_op1_server_tuser  <= 0;
				    	m_op1_server_tvalid <= 0;
				    	m_op1_server_tlast  <= 0;
				    	fil_out_state <= FLUSH_OP1;
				    end
                end
                FLUSH_OP2:begin
                    if(m_axis_tready)begin //下一个模块准备好了
					    if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
                            m_axis_op2_tdata <= tdata_fifo;
                            m_axis_op2_tkeep <= tkeep_fifo;
                            m_axis_op2_tuser <= tuser_fifo;
                            m_axis_op2_tvalid<= 1'b1;
                            m_axis_op2_tlast <= tlast_fifo;
					    	fil_out_state <= FIL_OUT_SWITCH;
					    	pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
					    end
					    else begin
					    	fil_out_state <= FLUSH_OP2;
					    	if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
					    		pkt_fifo_rd_en <= 1'b1;
					    		m_axis_op2_tdata  <= 0;
					    	    m_axis_op2_tkeep  <= 0;
					    	    m_axis_op2_tuser  <= 0;
					    	    m_axis_op2_tvalid <= 0;
					    	    m_axis_op2_tlast  <= 0;
					    	end
					    	else begin //fifo没有空，继续读
					    		if(pkt_fifo_rd_en)begin
					    			m_axis_op2_tdata  <= tdata_fifo;
					    			m_axis_op2_tkeep  <= tkeep_fifo;
					    			m_axis_op2_tuser  <= tuser_fifo;
					    			m_axis_op2_tvalid <= 1'b1;
					    			m_axis_op2_tlast  <= tlast_fifo;
					    		end
					    		else begin
					    			m_axis_op2_tdata   <= 0;
					    			m_axis_op2_tkeep   <= 0;
					    			m_axis_op2_tuser   <= 0;
					    			m_axis_op2_tvalid <= 0;
					    			m_axis_op2_tlast   <= 0;
					    		end
					    		pkt_fifo_rd_en <= 1'b1;
					    	end
					    end
				    end
				    else begin
				    	pkt_fifo_rd_en <= 1'b0;
				    	m_axis_op2_tdata  <= 0;
				    	m_axis_op2_tkeep  <= 0;
				    	m_axis_op2_tuser  <= 0;
				    	m_axis_op2_tvalid <= 0;
				    	m_axis_op2_tlast  <= 0;
				    	fil_out_state <= FLUSH_OP2;
				    end
                end
                FLUSH_OP3:begin
                    if(m_axis_tready)begin //下一个模块准备好了
					    if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
                            m_axis_op3_tdata <= tdata_fifo;
                            m_axis_op3_tkeep <= tkeep_fifo;
                            m_axis_op3_tuser <= tuser_fifo;
                            m_axis_op3_tvalid<= 1'b1;
                            m_axis_op3_tlast <= tlast_fifo;
					    	fil_out_state <= FIL_OUT_SWITCH;
					    	pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
					    end
					    else begin
					    	fil_out_state <= FLUSH_OP3;
					    	if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
					    		pkt_fifo_rd_en <= 1'b1;
					    		m_axis_op3_tdata  <= 0;
					    	    m_axis_op3_tkeep  <= 0;
					    	    m_axis_op3_tuser  <= 0;
					    	    m_axis_op3_tvalid <= 0;
					    	    m_axis_op3_tlast  <= 0;
					    	end
					    	else begin //fifo没有空，继续读
					    		if(pkt_fifo_rd_en)begin
					    			m_axis_op3_tdata  <= tdata_fifo;
					    			m_axis_op3_tkeep  <= tkeep_fifo;
					    			m_axis_op3_tuser  <= tuser_fifo;
					    			m_axis_op3_tvalid <= 1'b1;
					    			m_axis_op3_tlast  <= tlast_fifo;
					    		end
					    		else begin
					    			m_axis_op3_tdata   <= 0;
					    			m_axis_op3_tkeep   <= 0;
					    			m_axis_op3_tuser   <= 0;
					    			m_axis_op3_tvalid <= 0;
					    			m_axis_op3_tlast   <= 0;
					    		end
					    		pkt_fifo_rd_en <= 1'b1;
					    	end
					    end
				    end
				    else begin
				    	pkt_fifo_rd_en <= 1'b0;
				    	m_axis_op3_tdata  <= 0;
				    	m_axis_op3_tkeep  <= 0;
				    	m_axis_op3_tuser  <= 0;
				    	m_axis_op3_tvalid <= 0;
				    	m_axis_op3_tlast  <= 0;
				    	fil_out_state <= FLUSH_OP3;
				    end
                end
                FLUSH_OP4:begin
                    if(m_axis_tready)begin //下一个模块准备好了
					    if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
                            m_axis_op4_tdata <= tdata_fifo;
                            m_axis_op4_tkeep <= tkeep_fifo;
                            m_axis_op4_tuser <= tuser_fifo;
                            m_axis_op4_tvalid<= 1'b1;
                            m_axis_op4_tlast <= tlast_fifo;
					    	fil_out_state <= FIL_OUT_SWITCH;
					    	pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
					    end
					    else begin
					    	fil_out_state <= FLUSH_OP4;
					    	if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
					    		pkt_fifo_rd_en <= 1'b1;
					    		m_axis_op4_tdata  <= 0;
					    	    m_axis_op4_tkeep  <= 0;
					    	    m_axis_op4_tuser  <= 0;
					    	    m_axis_op4_tvalid <= 0;
					    	    m_axis_op4_tlast  <= 0;
					    	end
					    	else begin //fifo没有空，继续读
					    		if(pkt_fifo_rd_en)begin
					    			m_axis_op4_tdata  <= tdata_fifo;
					    			m_axis_op4_tkeep  <= tkeep_fifo;
					    			m_axis_op4_tuser  <= tuser_fifo;
					    			m_axis_op4_tvalid <= 1'b1;
					    			m_axis_op4_tlast  <= tlast_fifo;
					    		end
					    		else begin
					    			m_axis_op4_tdata   <= 0;
					    			m_axis_op4_tkeep   <= 0;
					    			m_axis_op4_tuser   <= 0;
					    			m_axis_op4_tvalid <= 0;
					    			m_axis_op4_tlast   <= 0;
					    		end
					    		pkt_fifo_rd_en <= 1'b1;
					    	end
					    end
				    end
				    else begin
				    	pkt_fifo_rd_en <= 1'b0;
				    	m_axis_op4_tdata  <= 0;
				    	m_axis_op4_tkeep  <= 0;
				    	m_axis_op4_tuser  <= 0;
				    	m_axis_op4_tvalid <= 0;
				    	m_axis_op4_tlast  <= 0;
				    	fil_out_state <= FLUSH_OP4;
				    end
                end
                FLUSH_OP5:begin
                    if(m_axis_tready)begin //下一个模块准备好了
					    if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
                            m_axis_op5_tdata <= tdata_fifo;
                            m_axis_op5_tkeep <= tkeep_fifo;
                            m_axis_op5_tuser <= tuser_fifo;
                            m_axis_op5_tvalid<= 1'b1;
                            m_axis_op5_tlast <= tlast_fifo;
					    	fil_out_state <= FIL_OUT_SWITCH;
					    	pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
					    end
					    else begin
					    	fil_out_state <= FLUSH_OP5;
					    	if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
					    		pkt_fifo_rd_en <= 1'b1;
					    		m_axis_op5_tdata  <= 0;
					    	    m_axis_op5_tkeep  <= 0;
					    	    m_axis_op5_tuser  <= 0;
					    	    m_axis_op5_tvalid <= 0;
					    	    m_axis_op5_tlast  <= 0;
					    	end
					    	else begin //fifo没有空，继续读
					    		if(pkt_fifo_rd_en)begin
					    			m_axis_op5_tdata  <= tdata_fifo;
					    			m_axis_op5_tkeep  <= tkeep_fifo;
					    			m_axis_op5_tuser  <= tuser_fifo;
					    			m_axis_op5_tvalid <= 1'b1;
					    			m_axis_op5_tlast  <= tlast_fifo;
					    		end
					    		else begin
					    			m_axis_op5_tdata   <= 0;
					    			m_axis_op5_tkeep   <= 0;
					    			m_axis_op5_tuser   <= 0;
					    			m_axis_op5_tvalid <= 0;
					    			m_axis_op5_tlast   <= 0;
					    		end
					    		pkt_fifo_rd_en <= 1'b1;
					    	end
					    end
				    end
				    else begin
				    	pkt_fifo_rd_en <= 1'b0;
				    	m_axis_op5_tdata  <= 0;
				    	m_axis_op5_tkeep  <= 0;
				    	m_axis_op5_tuser  <= 0;
				    	m_axis_op5_tvalid <= 0;
				    	m_axis_op5_tlast  <= 0;
				    	fil_out_state <= FLUSH_OP5;
				    end
                end
                FLUSH_OP6:begin
                    if(m_axis_tready)begin //下一个模块准备好了
					    if(tlast_fifo & !r_tlast_fifo) begin //读报文结束
                            m_axis_op6_tdata <= tdata_fifo;
                            m_axis_op6_tkeep <= tkeep_fifo;
                            m_axis_op6_tuser <= tuser_fifo;
                            m_axis_op6_tvalid<= 1'b1;
                            m_axis_op6_tlast <= tlast_fifo;
					    	fil_out_state <= FIL_OUT_SWITCH;
					    	pkt_fifo_rd_en <= 1'b1;//最后一拍仍可以读取，但是可以由下一状态的空满判定报文是否有效
					    end
					    else begin
					    	fil_out_state <= FLUSH_OP6;
					    	if(pkt_fifo_empty)begin //读报文没有结束但是fifo空了
					    		pkt_fifo_rd_en <= 1'b1;
					    		m_axis_op6_tdata  <= 0;
					    	    m_axis_op6_tkeep  <= 0;
					    	    m_axis_op6_tuser  <= 0;
					    	    m_axis_op6_tvalid <= 0;
					    	    m_axis_op6_tlast  <= 0;
					    	end
					    	else begin //fifo没有空，继续读
					    		if(pkt_fifo_rd_en)begin
					    			m_axis_op6_tdata  <= tdata_fifo;
					    			m_axis_op6_tkeep  <= tkeep_fifo;
					    			m_axis_op6_tuser  <= tuser_fifo;
					    			m_axis_op6_tvalid <= 1'b1;
					    			m_axis_op6_tlast  <= tlast_fifo;
					    		end
					    		else begin
					    			m_axis_op6_tdata   <= 0;
					    			m_axis_op6_tkeep   <= 0;
					    			m_axis_op6_tuser   <= 0;
					    			m_axis_op6_tvalid <= 0;
					    			m_axis_op6_tlast   <= 0;
					    		end
					    		pkt_fifo_rd_en <= 1'b1;
					    	end
					    end
				    end
				    else begin
				    	pkt_fifo_rd_en <= 1'b0;
				    	m_axis_op6_tdata  <= 0;
				    	m_axis_op6_tkeep  <= 0;
				    	m_axis_op6_tuser  <= 0;
				    	m_axis_op6_tvalid <= 0;
				    	m_axis_op6_tlast  <= 0;
				    	fil_out_state <= FLUSH_OP6;
				    end
                end
            endcase
        end
    end

endmodule
    