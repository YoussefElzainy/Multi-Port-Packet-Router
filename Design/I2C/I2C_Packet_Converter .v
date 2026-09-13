module I2C_PacketConverter #(
    parameter DATA_WIDTH = 24
) (
    input clk, rst_n,

    // Router - PackConverter Interface
    input router_ready, port_valid,
    input [DATA_WIDTH - 1 : 0] router_dout,
    output reg wr_en, port_ready,
    output [DATA_WIDTH - 1 : 0] router_din,
    
    // PackConverter - I2C Master Interface
    input ack_err, busy,
    input [7:0] data_read,
    output reg en, rw, 
    output reg [7:0] data_write,
    output [6:0] slave_addr
);

    // FSM States
    localparam IDLE           = 3'b000,
               WRITE_BYTE     = 3'b001,
               WAIT_WRITE_ACK = 3'b010,
               WRITE_DONE     = 3'b011,
               READ_BYTE      = 3'b100,
               WAIT_READ_ACK  = 3'b101,
               READ_DONE      = 3'b110;

    reg [2:0] cs, ns;

    
    reg [DATA_WIDTH - 1 : 0] packet_reg;
    reg [1:0] byte_cnt;
    reg busy_d1;
    wire busy_falling_edge;
    reg [6:0] slave_addr_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy_d1 <= 1'b0;
        end else begin
            busy_d1 <= busy;
        end
    end

    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        slave_addr_reg <= 7'b0;
    end else if (cs == IDLE && port_valid && router_ready) begin
        slave_addr_reg <= router_dout[20:14]; // Shift or mask properly according to packet spec
    end
end

    
    assign busy_falling_edge = (busy_d1 == 1'b1) && (busy == 1'b0);
    assign slave_addr = (cs == IDLE) ? router_dout[20:14] : slave_addr_reg;
    assign router_din = (cs == READ_DONE) ? packet_reg : {DATA_WIDTH{1'b0}};

    // Current State Register Logic
    always @(posedge clk) begin
        if (!rst_n) begin
            cs <= IDLE;
        end else begin
            cs <= ns;
        end
    end

    
    always @(posedge clk) begin
        if (!rst_n) begin
            packet_reg <= {DATA_WIDTH{1'b0}};
            byte_cnt   <= 2'b00;
        end else begin
            case (cs)
                IDLE: begin
                    byte_cnt <= 2'b00;
                    if (port_valid && router_ready) begin
                        if (!router_dout[21]) begin
                            packet_reg <= router_dout; // Store packet for Write operation
                        end else begin
                            packet_reg <= {DATA_WIDTH{1'b0}}; // Clear buffer for incoming Read bytes
                        end
                    end
                end

                WAIT_WRITE_ACK: begin
                    if (busy_falling_edge && !ack_err) begin
                        if (byte_cnt < 2'd2) begin
                            byte_cnt <= byte_cnt + 1'b1;
                        end
                    end
                end

                WAIT_READ_ACK: begin
                    if (busy_falling_edge && !ack_err) begin
                        case (byte_cnt)
                            2'b00: packet_reg [23 : 16] <= data_read;
                            2'b01: packet_reg [15 : 8] <= data_read;
                            2'b10: packet_reg [7 : 0] <= data_read;
                        endcase

                        if (byte_cnt < 2'd2) begin
                            byte_cnt <= byte_cnt + 1'b1;
                        end
                    end
                end
            endcase
        end
    end

    // Next State Combinational Logic
    always @(*) begin
        case (cs)
            IDLE: begin
                if (port_valid && router_ready && !router_dout[21]) begin
                    ns = WRITE_BYTE;
                end else if (port_valid && router_ready && router_dout[21]) begin
                    ns = READ_BYTE;
                end else begin
                    ns = IDLE;
                end
            end 

            WRITE_BYTE: begin
                if (busy) begin
                    ns = WAIT_WRITE_ACK;
                end else begin
                    ns = WRITE_BYTE;
                end
            end

            WAIT_WRITE_ACK: begin
                if (ack_err) begin
                    ns = IDLE;
                end else if (busy_falling_edge) begin
                    if (byte_cnt < 2'd2) begin
                        ns = WRITE_BYTE;       
                    end else begin
                        ns = WRITE_DONE;
                    end
                end else begin
                    ns = WAIT_WRITE_ACK;
                end
            end

            WRITE_DONE: begin
                ns = IDLE;
            end

            READ_BYTE: begin
                if (busy) begin
                    ns = WAIT_READ_ACK;
                end else begin
                    ns = READ_BYTE;
                end
            end

            WAIT_READ_ACK: begin
                if (ack_err) begin
                    ns = IDLE;
                end else if (busy_falling_edge) begin
                    if (byte_cnt < 2'd2) begin
                        ns = READ_BYTE;
                    end else begin
                        ns = READ_DONE;
                    end
                end else begin
                    ns = WAIT_READ_ACK;
                end
            end

            READ_DONE: begin
                ns = IDLE;
            end

            default: ns = IDLE;
        endcase
    end

    // Combinational Output Logic
    always @(*) begin
    
        en = 1'b0;
        rw = 1'b0;
        wr_en = 1'b0;
        port_ready = 1'b0;
        data_write = 8'h00;

        case (cs)
            IDLE: begin
                port_ready = router_ready;
            end

            WRITE_BYTE: begin
                en = 1'b1;
                rw = 1'b0; // Write operation
                case (byte_cnt)
                    2'b00: data_write = packet_reg[23:16];
                    2'b01: data_write = packet_reg[15:8];
                    2'b10: data_write = packet_reg[7:0];
                    default: data_write = 8'h00;
                endcase
            end

            WAIT_WRITE_ACK: begin
                rw = 1'b0;
                case (byte_cnt)
                    2'b00: data_write = packet_reg[23:16];
                    2'b01: data_write = packet_reg[15:8];
                    2'b10: data_write = packet_reg[7:0];
                    default: data_write = 8'h00;
                endcase
            end

            WRITE_DONE: begin
                port_ready = 1'b1;
            end

            READ_BYTE, WAIT_READ_ACK: begin
                en = (cs == READ_BYTE);
                rw = 1'b1; // Read operation
            end

            READ_DONE: begin
                wr_en = 1'b1; 
                port_ready = 1'b1;
            end

        endcase
    end

endmodule