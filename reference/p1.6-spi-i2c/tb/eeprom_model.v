`timescale 1ns/1ps
// Behavioral I2C EEPROM (24xx-like, 256 bytes). Answers only its own address;
// any other address gets no ACK (the line stays high = NACK).
module eeprom_model #(parameter [6:0] ADDR = 7'h50) (inout wire scl, inout wire sda);
  reg [7:0] mem [0:255];
  reg [7:0] ptr, sh; integer bitn; reg drive_low = 0;
  reg [2:0] st;                                    // 0 idle, 1 addr, 2 ptr, 3 data-in, 4 data-out
  reg ack_phase = 0, reading = 0, out_bit;
  assign sda = drive_low ? 1'b0 : 1'bz;
  integer i; initial begin for (i = 0; i < 256; i = i + 1) mem[i] = 8'hFF; st = 0; end

  always @(negedge sda) if (scl === 1'b1) begin st <= 1; bitn <= 0; ack_phase <= 0; reading <= 0; end  // START / Sr
  always @(posedge sda) if (scl === 1'b1) begin st <= 0; drive_low <= 0; end                        // STOP

  always @(posedge scl) if (st != 0) begin
    if (ack_phase) begin
      if (reading && sda !== 1'b0) st <= 0;        // master NACK ends the read
    end else if (!reading) begin
      sh = {sh[6:0], sda === 1'b1}; bitn = bitn + 1;
    end else bitn = bitn + 1;
  end

  always @(negedge scl) if (st != 0) begin
    if (ack_phase) begin                           // end of the ack clock
      ack_phase <= 0; drive_low <= 0; bitn = 0;
      if (reading) begin drive_low <= ~mem[ptr][7]; sh = mem[ptr]; end
    end else if (!reading && bitn == 8) begin      // byte received: decide on ACK
      case (st)
        1: if (sh[7:1] == ADDR) begin
             drive_low <= 1; ack_phase <= 1;
             if (sh[0]) begin reading <= 1; st <= 4; end else st <= 2;
           end else st <= 0;                       // not us: stay off the bus
        2: begin ptr <= sh; drive_low <= 1; ack_phase <= 1; st <= 3; end
        3: begin mem[ptr] <= sh; ptr <= ptr + 1; drive_low <= 1; ack_phase <= 1; end
      endcase
    end else if (reading) begin
      if (bitn == 8) begin drive_low <= 0; ack_phase <= 1; ptr <= ptr + 1; end  // release for master's ack
      else begin sh = {sh[6:0], 1'b0}; drive_low <= ~sh[7]; end
    end
  end
endmodule
