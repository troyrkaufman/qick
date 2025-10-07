// axi_slv_sg_v6.sv
// 

module axi_slv_sg_v6 #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 6)(
    input logic aclk,
    input logic aresetn,

    // Write Address Channel
    input logic [ADDR_WIDTH-1:0] awaddr,
    input logic [2:0] awprot,
    input logic awvalid,
    output logic awready,

    // Write Data Channel
    input logic [DATA_WIDTH-1:0] wdata,
    input logic [(DATA_WIDTH/8)-1:0] wstrb,
    input logic wvalid,
    output logic wready,

    // Write Response Channel
    output logic [1:0] bresp,
    output logic bvalid,
    input logic bready,

    // Read Address Channel
    output logic [DATA_WIDTH-1:0] rdata,
    output logic [1:0] rresp,
    output logic rvalid,
    input logic rready,

    // Registers
    output logic [31:0] START_ADDR_REG,
    output logic WE_REG
);

    logic [ADDR_WIDTH-1:0] axi_awaddr;
    logic axi_awready;
    logic axi_wready;
    logic [1:0] axi_bresp;
    logic axi_bvalid;
    logic [ADDR_WIDTH-1:0] axi_araddr;
    logic axi_arready;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0] axi_rresp;
    logic axi_rvalid;

    localparam int ADDR_LSB = (DATA_WIDTH/32)+1;
    localparam int OPT_MEM_ADDR_BITS = 3;

    // Number of Slave Registers 16
    logic [DATA_WIDTH-1:0] slv_reg0;
    logic [DATA_WIDTH-1:0] slv_reg1;
    logic [DATA_WIDTH-1:0] slv_reg2;
    logic [DATA_WIDTH-1:0] slv_reg3;
    logic [DATA_WIDTH-1:0] slv_reg4;
    logic [DATA_WIDTH-1:0] slv_reg5;
    logic [DATA_WIDTH-1:0] slv_reg6;
    logic [DATA_WIDTH-1:0] slv_reg7;
    logic [DATA_WIDTH-1:0] slv_reg8;
    logic [DATA_WIDTH-1:0] slv_reg9;
    logic [DATA_WIDTH-1:0] slv_reg10;
    logic [DATA_WIDTH-1:0] slv_reg11;
    logic [DATA_WIDTH-1:0] slv_reg12;
    logic [DATA_WIDTH-1:0] slv_reg13;
    logic [DATA_WIDTH-1:0] slv_reg14;
    logic [DATA_WIDTH-1:0] slv_reg15;
    logic slv_reg_rden;
    logic slv_reg_wren;
    logic [DATA_WIDTH-1:0] reg_data_out;
    int bte_index;
    logic aw_en;

    //I/O Connections assignments
    assign awready = axi_awready;
    assign wready = axi_wready;
    assign bresp = axi_bresp;
    assign bvalid = axi_bvalid;
    assign arready = axi_arready;
    assign rdata = axi_rdata;
    assign rresp = axi_rresp;
    assign rvalid = axi_rvalid;

    always_ff@(posedge aclk) begin 
        if (~aresetn) begin 
            axi_awready <= 0;
            aw_en <= 0;
        end else begin 
            if (axi_awready == 0 && awvalid == 1 && wvalid == 1 && aw_en == 1) begin 
                axi_awready <= 1;
                aw_en <= 0;
            end else if (bready == 1 && axi_bvalid == 1) begin 
                axi_awready <= 0;
                aw_en <= 1;
            end else 
                axi_awready <= 0;
        end 
    end

    // Implement axi_awaddr latching
    always_ff@(posedge aclk) begin 
        if (~aresetn) begin 
            axi_awddr <= 0;
        end else begin 
            if (axi_awready == 0 && awvalid == 1 && wvalid == 1 && aw_en == 1) begin
                axi_awaddr <= awaddr;
            end
        end
    end

    // Implement axi_wready generation
    always_ff@(posedge aclk) begin 
        if (~nrst) begin 
            axi_wready <= 0;
        end else begin 
            if (axi_wready == 0 && wvalid == 1 && awvalid == 1 && aw_en) begin 
                axi_wready <= 1;
            end else begin 
                axi_wready <= 0;
            end
        end
        end

    // Implement memory mapped register select and write logic generation
    assign slv_reg_wren = axi_wready && wvalid && axi_awready && awvalid;

    logic [OPT_MEM_ADDR_BITS:0] loc_addr;

    always_ff@(posedge aclk) begin 
        if (~aresetn) begin 
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
            slv_reg4 <= 0;
            slv_reg5 <= 0;
            slv_reg6 <= 0;
            slv_reg7 <= 0;
            slv_reg8 <= 0;
            slv_reg9 <= 0;
            slv_reg10 <= 0;
            slv_reg11 <= 0;
            slv_reg12 <= 0;
            slv_reg13 <= 0;
            slv_reg14 <= 0;
            slv_reg15 <= 0;
        end else begin 
            loc_Addr <= axi_awaddr((ADDR_LSB + OPT_MEM_ADDR_BITS):ADDR_LSB);

            if (slv_reg_wren) begin 
                case (loc_addr)
                    'b0000: 
                        genvar byte_index;
                        generate 
                            for (byte_index = 0; i < (DATA_WIDTH/8)-1; i++) begin 
                                if (wsterb(byte_index) == 1) begin 
                                    slv_reg0[(byte_index*8+7):(byte_index*8)] <= wdata[(byte_index*8+7):(byte_index*8)];
                                end
                            end
                        endgenerate
                    'b0001:
                    
                endcase
        end
    end




endmodule