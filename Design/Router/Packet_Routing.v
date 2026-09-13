module Packet_Routing #(
    parameter DATA_WIDTH = 24
) (
    input clk, rst_n,
    input [DATA_WIDTH - 1: 0] packet_in,
    input packet_valid,
    input port0_ready, port1_ready, port2_ready, port3_ready,
    output reg [DATA_WIDTH - 1: 0] port0_data, port1_data, port2_data, port3_data,
    output reg port0_valid, port1_valid, port2_valid, port3_valid
);

    localparam Dest0 = 2'b00,
               Dest1 = 2'b01,
               Dest2 = 2'b10,
               Dest3 = 2'b11;

    reg [DATA_WIDTH-1:0] packet_reg;
    reg [1:0] destination_reg;
    reg packet_active;

    always @(posedge clk) begin

        if (!rst_n) begin

            packet_reg      <= {DATA_WIDTH{1'b0}};
            destination_reg <= 2'b00;
            packet_active   <= 1'b0;

        end
        else begin

            if (!packet_active && packet_valid) begin

                packet_reg      <= packet_in;
                destination_reg <= packet_in[23:22];
                packet_active   <= 1'b1;

            end

            else if (packet_active) begin

                case (destination_reg)

                    Dest0: begin
                        if (port0_ready)
                            packet_active <= 1'b0;
                    end

                    Dest1: begin
                        if (port1_ready)
                            packet_active <= 1'b0;
                    end

                    Dest2: begin
                        if (port2_ready)
                            packet_active <= 1'b0;
                    end

                    Dest3: begin
                        if (port3_ready)
                            packet_active <= 1'b0;
                    end

                    default: begin
                        packet_active <= 1'b0;
                    end

                endcase

            end

        end

    end


    always @(*) begin

        port0_valid = 1'b0;
        port1_valid = 1'b0;
        port2_valid = 1'b0;
        port3_valid = 1'b0;
        port0_data = {DATA_WIDTH{1'b0}};
        port1_data = {DATA_WIDTH{1'b0}};
        port2_data = {DATA_WIDTH{1'b0}};
        port3_data = {DATA_WIDTH{1'b0}};

        if (packet_active) begin

             case (destination_reg)

                Dest0: begin
                    port0_valid = 1'b1;
                    port0_data  = packet_reg;
                end

                Dest1: begin
                    port1_valid = 1'b1;
                    port1_data  = packet_reg;
                end

                Dest2: begin
                    port2_valid = 1'b1;
                    port2_data  = packet_reg;
                end

                Dest3: begin
                    port3_valid = 1'b1;
                    port3_data  = packet_reg;
                end

                default: begin
                    port0_valid = 1'b0;
                    port1_valid = 1'b0;
                    port2_valid = 1'b0;
                    port3_valid = 1'b0;

                    port0_data = {DATA_WIDTH{1'b0}};
                    port1_data = {DATA_WIDTH{1'b0}};
                    port2_data = {DATA_WIDTH{1'b0}};
                    port3_data = {DATA_WIDTH{1'b0}};
                end

            endcase

        end

    end
    

endmodule