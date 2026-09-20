`default_nettype none

module spi_peripheral (

    input wire clk,
    input wire rst_n,
    input wire COPI,
    input wire nCS,
    input wire SCLK,

    output wire [7:0] en_reg_out_7_0,
    output wire [7:0] en_reg_out_15_8,
    output wire [7:0] en_reg_pwm_7_0,
    output wire [7:0] en_reg_pwm_15_8,
    output wire [7:0] pwm_duty_cycle

);

    localparam integer MAX_ADDRESS = 4;
    reg [7:0] memory_map [0:MAX_ADDRESS];

    reg sync1_SCLK, sync2_SCLK, detect_edge_SCLK;
    reg sync1_COPI, sync2_COPI;
    reg sync1_nCS, sync2_nCS, detect_edge_nCS;

    wire is_posedge_SCLK = (sync2_SCLK == 1 && detect_edge_SCLK == 0);
    wire is_posedge_nCS = (sync2_nCS == 1 && detect_edge_nCS == 0);
    reg [4:0] bit_counter;
    reg [15:0] copi_input_storage;

    integer i;

    assign en_reg_out_7_0 = memory_map[0];
    assign en_reg_out_15_8 = memory_map[1];
    assign en_reg_pwm_7_0 = memory_map[2];
    assign en_reg_pwm_15_8 = memory_map[3];
    assign pwm_duty_cycle = memory_map[4];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync1_SCLK <= 0;
            sync2_SCLK <= 0;
            detect_edge_SCLK <= 0;
            sync1_COPI <= 0;
            sync2_COPI <= 0;
            sync1_nCS <= 1;
            sync2_nCS <= 1;
            detect_edge_nCS <= 1;
            bit_counter <= 5'd0;
            copi_input_storage <= 16'd0;

            for (i = 0; i <= MAX_ADDRESS; i = i+1) begin 
                memory_map[i] <= 8'd0;
            end

        end else begin
            sync1_SCLK <= SCLK;
            sync2_SCLK <= sync1_SCLK;
            detect_edge_SCLK <= sync2_SCLK;
        
            sync1_COPI <= COPI;
            sync2_COPI <= sync1_COPI;

            sync1_nCS <= nCS;
            sync2_nCS <= sync1_nCS;
            detect_edge_nCS <= sync2_nCS;

            if (is_posedge_SCLK && !sync2_nCS) begin 
                copi_input_storage <= {copi_input_storage[14:0], sync2_COPI};

                bit_counter <= bit_counter + 1;
            end else if (is_posedge_nCS) begin 
 
                if (bit_counter == 16 && copi_input_storage[15] && copi_input_storage[14:11] == 4'h0 && copi_input_storage[10:8] <= 3'b100) begin 
                    memory_map[copi_input_storage[10:8]] <= copi_input_storage[7:0];
                end

                bit_counter <= 0;
            end

        
        end
        
    end



endmodule
