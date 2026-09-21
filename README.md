# Packet Routing System

## Project Documentation

**Names:**
- Youssef Hossam EldeenMohamed Elzainy
- Fares Nagah Ibrahim
- Yehia Omar

**Course:** Digital IC Design Using FPGA

## 1. Introduction

In most digital systems, more than one part of the chip needs to send data to shared resources at the same time. A single bus cannot serve four sources at once without collisions, so some form of arbitration and routing is needed between the sources and the destinations. This project implements a small router that solves exactly that problem for a system with four input ports and four output ports.

The design accepts data from four independent write ports, each backed by its own synchronous FIFO buffer. A round-robin arbiter monitors the four FIFOs and grants access to the shared output path in a fair, rotating order, so no single port can starve the others. Once a packet is granted access, it passes through a packet routing block that reads the destination bits embedded in the packet and forwards it to the correct one of four output ports. Three of the output ports are connected to simple RAM-based memory nodes that model slave devices on the network, while the fourth port is exposed directly to the testbench so that responses coming back from the memory nodes can be observed and checked.

### 1.1 Objective

The objective of this project is to design and verify a 4-port packet router at the RTL level using Verilog, covering the full data path from FIFO buffering and arbitration through to packet routing and delivery, and to confirm correct operation through simulation and synthesis.

### 1.2 Project Overview

The system is built up from a small set of reusable blocks. A generic synchronous FIFO (FIFO_Memory.v) is instantiated four times (Four_FIFO_Buffers.v) to buffer incoming data on each port. A round-robin arbiter (RR_Arbiter.v) decides, cycle by cycle, which non-empty FIFO is allowed to send its data out, and this is combined with the FIFO buffers in FIFO_Arbiter_System.v. The arbitrated data stream is then handed to the Packet_Routing.v module, which decodes the destination field of each packet and steers it to the correct output port. These pieces come together in Router_TopModule.v, which is the top-level router.

Around the router, network.v adds three memory nodes (ram.v) that receive packets, service them, and send response packets back into the network, forming a small closed network rather than just a router in isolation. Port 3 is left open and connects straight to the testbench (n_tb.v), which drives input packets and checks that the corresponding responses come back correctly.

## 2. System Architecture

The system consists of four input ports, four synchronous FIFO buffers, a round-robin arbiter, a packet routing block, four output ports, three RAM-based memory nodes, and a testbench-connected port. The router first buffers incoming packets, arbitrates between non-empty FIFOs, and then routes the selected packet according to its destination field.

## 3. Design Files

### 3.1 FIFO_Memory.v — Synchronous FIFO

A parameterized synchronous FIFO is used as the basic buffering element. It contains write and read pointers, a counter for the number of stored entries, and empty/full status signals. The FIFO has a configurable data width and depth.

### 3.2 Four_FIFO_Buffers.v — Four FIFO Buffers

This module instantiates four synchronous FIFOs, one for each router input port. Each FIFO has a depth of 16 and shares the configured data width.

### 3.3 RR_Arbiter.v — Round Robin Arbiter

The round-robin arbiter monitors the four FIFO empty signals and generates one-hot grant signals. Its state rotates through FIFO0, FIFO1, FIFO2, and FIFO3, providing fair access to the shared router path and avoiding starvation.

### 3.4 FIFO_Arbiter_System.v — FIFO + Arbiter Integration

This module integrates the four FIFO buffers with the round-robin arbiter. The selected FIFO is read when Router_Ready is asserted, and the corresponding data is presented as the arbitrated packet stream.

### 3.5 Packet_Routing.v — Packet Routing Module

The packet routing module receives the arbitrated packet and extracts the destination field from the two most significant bits. Destinations are encoded as:

- Dest0 = 2'b00
- Dest1 = 2'b01
- Dest2 = 2'b10
- Dest3 = 2'b11

The module holds the packet until the selected output port is ready, then asserts the corresponding valid signal and forwards the packet to that port.

### 3.6 ram.v — Memory Node

The memory node models a RAM-based slave device. It accepts read/write packets, decodes the read/write bit, address, and data fields, performs writes directly to memory, and generates a response packet for read operations. Read responses are routed to Port 3, which is connected to the testbench.

The packet fields used by the memory node are:

- Bit 21: read/write control
- Bits 20:16: 5-bit memory address
- Bits 15:0: 16-bit data

### 3.7 network.v — Network System Top

Network_System_Top is the structural wrapper around the router and the three memory nodes. Ports 0, 1, and 2 are connected to RAM-based memory nodes, while Port 3 is exposed to the testbench for injecting transactions and receiving read responses.

### 3.8 Router_TopModule.v — Router Top Module

Router_Top integrates FIFO_Arbiter_System and Packet_Routing into the complete four-port router. It provides the top-level interface for the four input ports and four output ports.

## 4. Testbench

### 4.1 n_tb.v — Network Testbench

The testbench operates with a 100 MHz clock generated using a 10 ns period. It drives transactions into Port 3 and checks the responses returned from the memory nodes.

The testbench contains tasks for:

- Sending write packets to a selected destination and address.
- Sending read request packets.
- Waiting for and verifying read responses.

The test sequence writes the following values:

- Node 0, Address 4: 16'hA1B2
- Node 1, Address 10: 16'hC3D4
- Node 2, Address 31: 16'hE5F6

It then reads the same addresses and verifies that the expected data is returned.

## 5. Simulation Results

### 5.1 Waveforms

The simulation verifies the packet routing, memory write operations, memory read operations, and return of read responses through Port 3.

## 6. Synthesis

### 6.1 RTL Schematic

The RTL schematic represents the synthesized hierarchy of the four-port packet router, including the FIFO buffers, round-robin arbiter, packet routing logic, and associated memory-node connections.

### 6.2 Resource Utilization

The synthesis results and resource utilization are included in the project documentation.

