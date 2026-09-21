# RTL Packet Router

A Verilog RTL implementation of a packet-based router that receives read/write transactions and routes them to the appropriate memory based on the packet address.

## Project Overview

The design demonstrates a simple RTL packet-routing architecture. A testbench generates read and write packets, the router decodes the packet information, selects the target memory according to the address, and handles the corresponding transaction.

The project focuses on the core packet-routing functionality rather than protocol-specific interfaces.

## Architecture

The current implementation includes:

- Packet input from the testbench
- Packet decoding and routing logic
- Address-based memory selection
- Read and write transaction handling
- Three memory blocks connected to the router
- Simulation-based verification

### High-Level Flow

```
        Testbench
            |
            v
      +-------------+
      | Packet      |
      | Router      |
      +-------------+
        |    |    |
        v    v    v
      +----+ +----+ +----+
      |Mem0| |Mem1| |Mem2|
      +----+ +----+ +----+
```

## Packet Routing

Each transaction contains the information required by the router to determine:

- Whether the operation is a read or write
- The target address
- The data associated with the transaction

The router uses the address to select the appropriate memory block.

## Supported Operations

- Write data to a selected memory
- Read data from a selected memory
- Route transactions according to their address
- Verify memory transactions through simulation

## Verification

The design is verified using a Verilog testbench that generates read and write transactions and checks communication with the memory blocks.

The project was simulated during RTL development to verify the routing and memory-access behavior.

## Tools

- Verilog HDL
- QuestaSim
- Xilinx Vivado

## Project Status

**Completed core implementation**

The current version focuses on the packet router and its connection to three memory blocks.

Protocol adapters such as SPI, I2C, and UART are **not part of the current implementation**. They may be considered as future extensions, but the present project is intentionally documented around the functionality that was actually implemented.

## Future Extensions

Possible future improvements include:

- Adding protocol adapters
- Supporting additional endpoints
- Adding more advanced arbitration
- Improving packet formats and routing flexibility
- Extending the verification environment

## Author

**Youssef Elzainy**

Electrical Communication & Electronics Systems Engineering
