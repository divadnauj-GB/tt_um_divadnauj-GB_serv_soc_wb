/*
	Copyright 2020 Efabless Corp.

	Author: Mohamed Shalan (mshalan@efabless.com)
  adjusted for KianV-RISCV rv32ima tapeout by Hirosh Dabui <hirosh@dabui.de>
	
	Licensed under the Apache License, Version 2.0 (the "License"); 
	you may not use this file except in compliance with the License. 
	You may obtain a copy of the License at:
	http://www.apache.org/licenses/LICENSE-2.0
	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.
*/

// A behavioral model for a quad I/O SPI PSRAM 

module psram #(
    parameter FILENAME = "firmware/firmware.hex"
) (
    input sck,
    inout [3:0] dio,
    input ce_n
);

  localparam  ST_IDLE = 3'h0,
                ST_CMD  = 3'h1,
                ST_ADDR = 3'h2,
                ST_DUMMY= 3'h3,
                ST_DR   = 3'h4,
                ST_DW   = 3'h5;

  reg [2:0] state = ST_IDLE;
  reg [7:0] cmd;
  reg [23:0] addr;
  reg [7:0] data;
  reg [7:0] cycle_count;

  reg [7:0] RAM[0:8*1024*1024-1];  // 8kbytes

  initial begin
    $display("Memory 5 bytes = 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x", RAM[0],
             RAM[1], RAM[2],  // 0x100000
             RAM[3], RAM[4]);
    $display("Reading %s", FILENAME);
    $readmemh(FILENAME, RAM);
    $display("%s loaded into memory", FILENAME);
    $display("Memory 5 bytes = 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x", RAM[0],
             RAM[1], RAM[2], RAM[3], RAM[4]);
  end


  always @(negedge ce_n or posedge ce_n)
    if (!ce_n) begin
      if (state == ST_IDLE) begin
        state <= ST_CMD;
        cycle_count <= 0;
        addr = 24'hFFFFFF;
        data = 0;
      end
    end else if (ce_n) state <= ST_IDLE;

  always @(posedge sck)
    case (state)
      ST_CMD: if (cycle_count == 7) state <= ST_ADDR;
      ST_ADDR:
      if ((cmd&8'hF0) != 8'h00) begin
        if (cycle_count == 13)
          if (cmd == 8'hEB) state <= ST_DUMMY;
          else if (cmd == 8'h38) state <= ST_DW;
      end else begin
        if (cycle_count == 31)
          if (cmd == 8'h03) state <= ST_DR;
          else if (cmd == 8'h02) state <= ST_DW;
      end
      ST_DUMMY: if (cycle_count == 19) state <= ST_DR;
    endcase

  always @(posedge sck)
    case (state)
      ST_CMD:  cmd <= {cmd[6:0], dio[0]};
      ST_ADDR: 
        if ((cmd&8'hF0)!=8'h00) 
          addr <= {addr[20:0], dio};
        else
          addr <= {addr[22:0], dio[0]};
      ST_DW:  
        if ((cmd&8'hF0)!=8'h00) 
          data <= {data[3:0], dio};
        else
          data <= {data[6:0], dio[0]};
  
    endcase

  always @(posedge sck) cycle_count <= cycle_count + 1;

  always @(negedge sck or ce_n)
    if (state == ST_DW) 
      if (cmd == 8'h38) begin
        if (cycle_count >= 16)
          if ((cycle_count - 16) % 2 == 0 || ce_n) begin
            RAM[addr] = data;
            //   $display("PSRAM: Write to %x, value: %x", addr, RAM[addr]);
            addr = addr + 1;
          end
      end else begin
        if (cycle_count >= 40)
          if ((cycle_count - 40) % 8 == 0 || ce_n) begin
            RAM[addr] = data;
            //   $display("PSRAM: Write to %x, value: %x", addr, RAM[addr]);
            addr = addr + 1;
          end
      end


  always @(posedge sck)
    if (cmd == 8'hEB) begin
      if (state == ST_DUMMY || state == ST_DR)
        if (cycle_count >= 19)
          if ((cycle_count - 19) % 2 == 0) begin
            data = RAM[addr];
            addr = addr + 1;
            //      $display("PSRAM: Read from %x, value: %x", addr-1, data);
          end
    end 
  reg sck_dly;
  always @(posedge sck_dly)
  if (cmd == 8'h03) begin
    if (state == ST_DR )
      if (cycle_count >= 32)
        if ((cycle_count - 32) % 8 == 0) begin
          data = RAM[addr];
          addr = addr + 1;
          //      $display("PSRAM: Read from %x, value: %x", addr-1, data);
        end
    end

  always 
  
	begin
		#0.5 sck_dly = sck;
	end

  reg [3:0] do_;
  always @(negedge sck)
    if (state == ST_DR) begin
      if (cmd == 8'hEB) begin
        do_  = data[7:4];
        data = data << 4;
      end else begin
        do_  = {2'b0, data[7],  1'b0};
        data = data << 1;
      end

    end

  assign dio = (state == ST_DR) ? do_ : 4'bz;

endmodule