# Fault Detection and Alarm Controller
## RTL-to-GDSII Implementation Using SKY130A, OpenLane and OpenROAD


## Project Overview

The **Fault Detection and Alarm Controller** is a sequential digital design implemented using Verilog HDL. It detects rising-edge fault events, counts the detected faults, and activates an alarm when the fault count reaches a predefined threshold.

The project covers the digital design flow from RTL development and functional verification to synthesis, physical implementation, timing analysis, physical verification, and final GDSII generation.

### Tools and Technologies

- Verilog HDL
- Icarus Verilog
- GTKWave
- Yosys
- OpenLane
- OpenROAD
- SKY130A PDK
- SKY130 HD standard-cell library
- Magic
- Static Timing Analysis (STA)
- Gate-Level Simulation (GLS)

## Project Objectives

1. Design a sequential digital circuit using Verilog.
2. Detect fault events and count them.
3. Generate an alarm when the fault count reaches the threshold.
4. Verify the RTL using a testbench and simulation waveforms.
5. Perform logic synthesis and technology mapping.
6. Complete physical implementation using OpenLane/OpenROAD.
7. Perform post-route timing analysis.
8. Verify the design using DRC, LVS, and other signoff checks.
9. Generate the final GDSII layout.
10. Document additional GLS and BabySoC simulation exercises separately.

---

# 1. Verilog RTL Design

RTL (Register Transfer Level) describes the sequential and combinational behavior of a digital circuit.

The design consists of four main Verilog modules.

| File | Description |
|---|---|
| `top_module.v` | Top-level module connecting the design blocks |
| `fault_detector.v` | Detects rising edges on the fault input |
| `fault_counter.v` | Counts detected fault events |
| `alarm_controller.v` | Activates the alarm when the threshold is reached |

### Block Diagram

```text
             +----------------------+
             |      Fault Input     |
             |       fault_in       |
             +----------+-----------+
                        |
                        v
             +----------------------+
             |    Fault Detector    |
             | Rising-edge detection|
             +----------+-----------+
                        |
                   fault_pulse
                        |
                        v
             +----------------------+
             |    Fault Counter     |
             |      4-bit count     |
             +----------+-----------+
                        |
                   fault_count
                        |
                        v
             +----------------------+
             |   Alarm Controller   |
             |   Threshold = 3      |
             +----------+-----------+
                        |
                        v
             +----------------------+
             |     Alarm Output     |
             |        alarm         |
             +----------------------+

          clk and rst connect to all modules.
```

### Inputs and Outputs

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | Clock signal |
| `rst` | Input | Active-high asynchronous reset |
| `fault_in` | Input | Digital fault input |
| `fault_count[3:0]` | Output | Four-bit fault counter |
| `alarm` | Output | Alarm status |

### Working Principle

1. The clock drives the sequential logic.
2. Reset clears the detector state, counter, and alarm.
3. The fault detector identifies a low-to-high transition on `fault_in`.
4. A one-cycle `fault_pulse` is generated.
5. The counter increments when it receives the pulse.
6. The alarm controller checks whether `fault_count` is at least 3.
7. The alarm output is registered and becomes high when the threshold condition is sampled.

### Inspect RTL Files

```bash
cd ~/OpenLane/designs/fault_alarm

cat src/top_module.v
cat src/fault_detector.v
cat src/fault_counter.v
cat src/alarm_controller.v
```

---

# 2. Functional Verification and Simulation

Functional verification checks whether the RTL behaves according to the design requirements before synthesis and physical implementation.

The testbench generates clock and reset signals, applies fault inputs, and observes the counter and alarm outputs.

### Simulation Flow

```text
Verilog RTL + Testbench
          |
          v
    Icarus Verilog
          |
          v
   Simulation Executable
          |
          v
      VVP Simulator
        /       \
       v         v
  Text Output   VCD Waveform
                    |
                    v
                 GTKWave
```

### Testbench Location

```text
~/VLSI/fault_alarm_project/sim/tb_top_module.v
```
<img width="1178" height="606" alt="image" src="https://github.com/user-attachments/assets/df4164b0-f77d-4813-b1e2-fae868c5363e" />

### Compile and Run Simulation

```bash
cd ~/VLSI/fault_alarm_project/sim

iverilog -g2012 -o fault_sim \
  tb_top_module.v \
  ~/OpenLane/designs/fault_alarm/src/top_module.v \
  ~/OpenLane/designs/fault_alarm/src/fault_detector.v \
  ~/OpenLane/designs/fault_alarm/src/fault_counter.v \
  ~/OpenLane/designs/fault_alarm/src/alarm_controller.v

vvp fault_sim
```

### Open the Waveform

```bash
gtkwave fault_waveform.vcd
```
<img width="1600" height="802" alt="image" src="https://github.com/user-attachments/assets/62987364-59ff-4251-8876-3d847385c1f1" />


### Functional Scenarios

- Reset operation.
- Detection of rising-edge fault events.
- Fault counter increment.
- Prevention of repeated counting while the input stays high.
- Alarm activation at the configured threshold.
- Counter and alarm reset behavior.

<img width="677" height="591" alt="image" src="https://github.com/user-attachments/assets/56505f03-b9cb-47d1-ba1a-30ec75b37faa" />

<img width="1600" height="789" alt="image" src="https://github.com/user-attachments/assets/714d24ed-ccaa-45a5-8be9-05a7ba504795" />

---

# 3. Logic Synthesis

Logic synthesis converts RTL code into a gate-level representation using registers, logic gates, and cells from a target standard-cell library.

Yosys is used for synthesis and technology mapping.

### Synthesis Flow

```text
Verilog RTL
     |
     v
RTL Elaboration
     |
     v
Process Conversion
     |
     v
Logic Optimization
     |
     v
Technology Mapping
     |
     v
Mapped Gate-Level Netlist
     |
     v
Synthesis Reports
```

### Existing Synthesis Artifacts

The project workspace contains files such as:

- `fault_alarm_sky130.v`
- `results/fault_alarm_synth.v`
- `results/synthesis.log`
- `results/sky130_synthesis.log`
- `synthesis_report.txt`
- `final_synthesis_summary.txt`

### Inspect Synthesis Results

```bash
cd ~/VLSI/fault_alarm_project

ls -lh
ls -lh results/

cat final_synthesis_summary.txt
cat synthesis_report.txt
```

Search for errors and warnings:

```bash
grep -inE 'error|warning' results/synthesis.log
grep -inE 'error|warning' results/sky130_synthesis.log
```

**Evidence to include:** Mapped netlist, synthesis reports, and synthesis logs.

---

# 4. Logic Optimization and Technology Mapping

Logic optimization improves the circuit representation by simplifying Boolean logic, removing unused logic, and optimizing the implementation.

Technology mapping translates the optimized logic into cells available in the SKY130 HD standard-cell library.

### Main Activities

- Boolean logic optimization.
- Constant propagation.
- Removal of unused logic.
- Register and combinational logic mapping.
- Standard-cell selection.
- Mapped netlist inspection.
- Synthesis statistics analysis.

### Inspect the Mapped Netlist

```bash
cd ~/VLSI/fault_alarm_project

less results/fault_alarm_synth.v
```

Inspect optimization messages:

```bash
grep -inE 'opt|techmap|mapping|number of cells' \
  results/synthesis.log | head -100
```

**Evidence to include:** Technology-mapped netlist and synthesis statistics.

---

# 5. Design Constraints

Design constraints describe the timing requirements and operating assumptions used by synthesis and physical-design tools.

The main clock settings recorded for this project are:

- Clock port: `clk`
- Clock period: 10 ns
- PDK: SKY130A
- Standard-cell library: SKY130 HD

### Inspect OpenLane Configuration

```bash
cd ~/OpenLane/designs/fault_alarm

cat config.json
```

Locate the SDC files generated or used by the flow:

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

find "$RUN" -type f -name '*.sdc' -print
```

### Important Constraint Concepts

- Clock definition.
- Clock period.
- Input and output delays.
- Clock uncertainty.
- Input transition.
- Output load.
- Setup and hold requirements.

**Evidence to include:** OpenLane configuration and the actual SDC file used by the run.

---

# 6. Physical Design Using OpenLane/OpenROAD

Physical design transforms the synthesized netlist into a physical layout containing standard cells, power structures, clock networks, and routed interconnects.

### Physical Design Flow

```text
       Synthesized Netlist
                |
                v
          Floorplanning
                |
                v
          Pin Placement
                |
                v
         Power Planning
              (PDN)
                |
                v
      Standard-Cell Placement
                |
                v
       Clock-Tree Synthesis
              (CTS)
                |
                v
          Global Routing
                |
                v
         Detailed Routing
                |
                v
      Parasitic Extraction
                |
                v
        Post-Route STA
                |
                v
          Signoff Checks
                |
                v
           Final GDSII
```

The completed run is recorded under:

```text
~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31
```

## 6.1 Floorplanning

Floorplanning defines the core and die regions in which the design will be implemented. It establishes the physical area available for cells and routing.

## 6.2 Pin Placement

Pin placement assigns physical locations to the input and output ports. The pin names and configuration must match the RTL interface.

## 6.3 Power Planning (PDN Generation)

Power planning creates the power distribution network for the design. The PDN distributes power and ground to the standard cells.

## 6.4 Standard-Cell Placement

Placement assigns locations to standard cells inside the core. Placement optimization can improve timing and routability.

## 6.5 Clock-Tree Synthesis (CTS)

CTS builds a clock distribution network for sequential elements. It inserts clock buffers and attempts to control clock skew and transition.

The inspected CTS summary reported:

- Worst setup slack: approximately +6.82 ns.
- Worst hold slack: approximately +0.21 ns.

These are CTS-stage values, not the final post-route values.
<img width="1465" height="343" alt="image" src="https://github.com/user-attachments/assets/2958d42a-941f-4877-808d-30e008ff0f0b" />

## 6.6 Global and Detailed Routing

Global routing plans interconnect paths and estimates routing resources. Detailed routing creates the physical metal connections.

### Inspect Physical-Design Results

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

find "$RUN/results" -maxdepth 4 -type f | sort
find "$RUN/reports" -maxdepth 4 -type f | sort
```

<img width="1600" height="803" alt="image" src="https://github.com/user-attachments/assets/457771ea-30f8-4ac8-9fae-31fe2833f604" />


---

# 7. Static Timing Analysis (STA)

Static Timing Analysis evaluates timing paths without applying input test vectors. It uses timing constraints, standard-cell timing models, and interconnect information.
<img width="926" height="932" alt="image" src="https://github.com/user-attachments/assets/86eaa482-8329-401f-9a42-242e3c5cf907" />

### Important STA Terms

- **Setup time:** Minimum time data must be stable before the capture clock edge.
- <img width="957" height="947" alt="image" src="https://github.com/user-attachments/assets/483f43b2-2d24-468b-bf7c-bf59091a8897" />

- **Hold time:** Minimum time data must remain stable after the capture clock edge.
- **Slack:** Difference between required and actual timing.
- **Critical path:** Path with the most restrictive timing margin.
- **WNS:** Worst negative slack.
- **TNS:** Total negative slack across violating paths.
<img width="1142" height="977" alt="image" src="https://github.com/user-attachments/assets/85b8c866-071c-41a6-b99c-d55cb3ad2f0a" />
<img width="1160" height="988" alt="image" src="https://github.com/user-attachments/assets/0d4fd737-d79a-473d-88e2-42092b9c39d9" />

### Inspect Post-Route STA

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

cat "$RUN/reports/signoff/31-rcx_sta.summary.rpt"

less "$RUN/reports/signoff/31-rcx_sta.max.rpt"

less "$RUN/reports/signoff/31-rcx_sta.min.rpt"
```

### Recorded Post-Route Results

| Metric | Reported Value |
|---|---:|
| Worst setup slack | +6.81 ns |
| Worst hold slack | +0.32 ns |
| WNS | 0.00 |
| TNS | 0.00 |

Positive setup and hold slack indicate timing margin for the checks represented in the report. Always identify the timing stage and corner when reporting values.
<img width="1536" height="377" alt="image" src="https://github.com/user-attachments/assets/12a9d0a0-69a6-45a6-b34c-26ea094f5690" />

<img width="1600" height="984" alt="image" src="https://github.com/user-attachments/assets/a38bc357-c8d5-4c98-b9ae-781f152f4a48" />


---

# 8. Parasitic Extraction

Parasitic extraction estimates the resistance and capacitance of routed interconnects. These parasitics affect signal delay and transition time.

Post-route STA uses extracted interconnect information to evaluate timing more accurately than an ideal-wire analysis.

### Extraction Flow

```text
Detailed Routing
       |
       v
Routed Interconnect
       |
       v
Parasitic Extraction
       |
       v
Extracted RC Information
       |
       v
Post-Route Timing Analysis
```

### Locate Extraction Files

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

find "$RUN" -type f \( -iname '*.spef' -o -iname '*rcx*' \) -print
```

The exact output format depends on the flow configuration. Inspect the extraction logs and STA reports rather than relying only on a particular file extension.

**Evidence to include:** Extraction logs or outputs and post-route timing reports.

---

# 9. Physical Layout Design, Magic, GDSII, and DEF

The physical layout represents the design using standard-cell instances and metal geometries.

- **GDSII:** Layout database containing physical geometry.
- **DEF:** Design implementation information, including placement and routing.
- **Magic:** Layout viewing and physical verification tool.
- **DRC:** Checks layout against manufacturing geometry rules.
- **LVS:** Compares extracted layout connectivity with the reference netlist.
<img width="1600" height="812" alt="image" src="https://github.com/user-attachments/assets/de7d6ebe-d6e7-41ca-b4a1-601e7beef68c" />

### Inspect Final Layout Files

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

ls -lh "$RUN/results/final/gds/top_module.gds"
ls -lh "$RUN/results/final/def/top_module.def"
```

The inspected final files were approximately:

- GDSII: 246 KB.
- DEF: 54 KB.

GDSII and DEF are layout artifacts. DRC and LVS reports are separate verification outputs.

**Evidence to include:** Final GDSII, final DEF, and a layout screenshot.

---

# 10. Design Rule Checking (DRC)

Design Rule Checking verifies whether the layout satisfies manufacturing geometry rules, including minimum width, spacing, and enclosure.

### Inspect DRC Results

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

cat "$RUN/reports/signoff/drc.rpt"
```

The inspected report showed a violation count of **0**.

Preserve the report and its associated checker log as evidence.

---
<img width="1162" height="247" alt="image" src="https://github.com/user-attachments/assets/2417f616-c144-4f46-9b26-7e000d4b7dd4" />

# 11. Layout Versus Schematic (LVS)

LVS compares the circuit extracted from the physical layout against the reference netlist. It checks connectivity and device consistency.

### Inspect LVS Results

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

cat "$RUN/reports/signoff/39-top_module.lvs.rpt"
```

The inspected report was described as showing:

- No net mismatches.
- No device mismatches.
- No pin mismatches.
- No property mismatches.
- Zero total errors.

LVS and DRC are different checks; both are required to assess physical correctness.

<img width="1600" height="773" alt="image" src="https://github.com/user-attachments/assets/f209194a-e64d-44f5-9f08-c798850153d0" />


---

# 12. SoC and ASIC Design Flow

This project demonstrates an **ASIC RTL-to-GDSII flow** for a digital fault detection and alarm controller.

A complete SoC usually integrates a processor, memory, interconnect, and peripherals. The Fault Detection and Alarm Controller is an individual digital design block, not a complete SoC.

### ASIC RTL-to-GDSII Flow

```text
RTL Design
    |
    v
Functional Verification
    |
    v
Synthesis and Technology Mapping
    |
    v
Constraints and Floorplanning
    |
    v
PDN and Placement
    |
    v
Clock-Tree Synthesis
    |
    v
Global and Detailed Routing
    |
    v
Parasitic Extraction
    |
    v
Post-Route STA
    |
    v
DRC / LVS / Signoff
    |
    v
Final GDSII
```

---

# 13. Gate-Level Simulation (GLS)

## 13.1 Introduction

Gate-Level Simulation verifies a synthesized or implemented gate-level netlist using a digital simulator and compatible standard-cell simulation models.

### Types of GLS

- **Post-synthesis GLS:** Uses the synthesized gate-level netlist.
- **Post-route GLS:** Uses the routed or implemented gate-level netlist.
- **Timing-annotated GLS:** Uses a compatible SDF file to annotate cell and/or interconnect delays.

A generated netlist alone does not mean GLS has been performed. Mark a stage complete only after the simulation has actually run and its result has been checked.

## 13.2 Locate Netlists and Simulation Models

```bash
find ~/VLSI/fault_alarm_project ~/OpenLane/designs/fault_alarm \
  -type f \( -iname '*synth*.v' -o -iname '*sky130*.v' -o -iname '*.sdf' \) \
  -print
```

## 13.3 Post-Synthesis GLS Command Template

Replace the placeholder paths with the actual synthesis netlist and compatible SKY130 simulation model files.

```bash
iverilog -g2012 -o post_synth_gls \
  sim/tb_top_module.v \
  /path/to/synthesis_netlist.v \
  /path/to/sky130_cell_models.v

vvp post_synth_gls
```

Do not compile both the original RTL definition of `top_module` and another netlist that defines the same module. Use the cell models instantiated by the mapped netlist.

## 13.4 Post-Route GLS

Locate the relevant netlist and SDF files:

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

find "$RUN" -type f \( -iname '*.v' -o -iname '*.sdf' \) -print
```

For timing-annotated simulation, confirm that the netlist and SDF match the same implementation and that delay annotation succeeded.

**Evidence to include if performed:** Netlist, simulation models, SDF if used, simulation log, and waveform.

---

# 14. BabySoC Pre-Synthesis and Post-Synthesis Simulation

> **Separate learning exercise:** BabySoC simulation is documented independently from the Fault Detection and Alarm Controller. It is not part of the controller's main physical-design signoff.

The recorded BabySoC workspace is:

```text
~/VLSI/baby_soc/BabySoc_Simulation
```

The previous simulation work generated:

- `pre_synth_sim.vcd`
- `post_synth_sim.vcd`

## 14.1 BabySoC Pre-Synthesis Simulation

Pre-synthesis simulation runs the RTL or behavioral design before synthesis. It checks the expected behavior using the project testbench and required simulation models.

### Locate the Files

```bash
cd ~/VLSI/baby_soc/BabySoc_Simulation

find . -maxdepth 4 -type f | sort | head -200

find . -type f -name 'pre_synth_sim.vcd' -print
```

Inspect the Makefile before running targets:

```bash
sed -n '1,220p' Makefile
```

Open the waveform using the actual path returned by `find`:

```bash
gtkwave /actual/path/to/pre_synth_sim.vcd
```
<img width="1600" height="804" alt="image" src="https://github.com/user-attachments/assets/36c47bf6-507e-4a37-adce-58c813ed356c" />

## 14.2 BabySoC Post-Synthesis Simulation

Post-synthesis simulation runs the synthesized gate-level netlist with the appropriate standard-cell simulation models. It checks whether the mapped implementation behaves as expected.

### Locate the Files

```bash
cd ~/VLSI/baby_soc/BabySoc_Simulation

find . -type f \( \
  -name 'post_synth_sim.vcd' -o \
  -iname '*synth*.v' -o \
  -iname '*sky130*.v' -o \
  -iname '*tb*.v' \
\) -print
```

Open the waveform using its actual location:

```bash
gtkwave /actual/path/to/post_synth_sim.vcd
```

Check the clock, reset, inputs, and outputs against the intended behavior. Preserve the simulation log and waveform.
<img width="1600" height="797" alt="image" src="https://github.com/user-attachments/assets/6c6eb170-0f30-4579-9fea-10640687ae79" />

## 14.3 Suggested Folder Structure

```text
additional_work/
└── babysoc_simulation/
    ├── README.md
    ├── pre_synth/
    │   ├── pre_synth_sim.vcd
    │   └── simulation.log
    └── post_synth/
        ├── post_synth_sim.vcd
        ├── simulation.log
        └── notes.md
```

### Pre-Synthesis vs Post-Synthesis

| Item | Pre-Synthesis | Post-Synthesis |
|---|---|---|
| Representation | RTL | Gate-level netlist |
| Purpose | Verify RTL behavior | Verify synthesized behavior |
| Cell simulation models | Usually unnecessary for pure RTL | Required when mapped library cells are instantiated |
| Output | Log and waveform | Log and waveform |
| Timing annotation | Usually absent | Not automatic |
| Does not prove | Physical layout correctness | DRC/LVS cleanliness or post-route timing closure |

Do not claim BabySoC post-route STA or GLS unless those specific analyses were performed and their results are available.

---

# 15. Debugging and Report Analysis

Debugging involves investigating errors and warnings across RTL, simulation, synthesis, physical implementation, and timing analysis.

### Common Debugging Areas

- RTL compilation errors.
- Testbench timing and expected-output checks.
- Missing standard-cell simulation models.
- Port and pin-order mismatches.
- Incorrect clock constraints.
- Floorplanning and PDN failures.
- Placement and routing errors.
- Setup and hold violations.
- DRC and LVS mismatches.
- Missing or inconsistent signoff artifacts.

### Locate Logs and Reports

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

find "$RUN/logs" -type f | sort
find "$RUN/reports" -type f | sort
```

Search for diagnostic messages:

```bash
grep -RinE 'error|warning|failed|violation' \
  "$RUN/logs" 2>/dev/null | head -100
```

Review the context of each message before classifying it as a failure. Keep a short record of the issue, the fix, and the verification result.

---

# 16. Final Design Signoff

Final signoff reviews the timing, physical verification, antenna checks, and final layout artifacts before declaring the implementation ready for the next stage.

### Previously Inspected Results

| Check | Recorded result |
|---|---|
| Final GDSII | Generated, approximately 246 KB |
| Final DEF | Generated, approximately 54 KB |
| Post-route setup slack | +6.81 ns |
| Post-route hold slack | +0.32 ns |
| WNS / TNS | Both reported as 0.00 |
| DRC | Inspected report showed 0 violations |
| LVS | Report described zero mismatches/errors |
| Antenna reports | Inspected violator files contained zero listed lines |
| XOR comparison | Reported XOR differences: 0 |
| CTS | CTS results and summary reports present |

These values refer to the previously inspected run. Confirm the source report and run directory before publishing results. Empty antenna files should be accompanied by the relevant checker log/status.

### Inspect Signoff Reports

```bash
RUN=~/OpenLane/designs/fault_alarm/runs/RUN_2026.10.21_09.49.31

ls -lh "$RUN/results/final/gds/top_module.gds"
ls -lh "$RUN/results/final/def/top_module.def"

cat "$RUN/reports/signoff/31-rcx_sta.summary.rpt"
cat "$RUN/reports/signoff/drc.rpt"
cat "$RUN/reports/signoff/39-top_module.lvs.rpt"

find "$RUN/reports/signoff" -maxdepth 2 -type f | sort
```

---

<img width="1191" height="627" alt="image" src="https://github.com/user-attachments/assets/a2f4e5fc-8144-499e-8d45-47327b0ea61e" />

## Conclusion

The Fault Detection and Alarm Controller demonstrates sequential RTL design, functional simulation, synthesis, technology mapping, physical implementation, post-route timing analysis, physical verification, and final GDSII generation using the SKY130A PDK and OpenLane/OpenROAD.

The repository documents the complete RTL-to-GDSII workflow, including floorplanning, pin placement, power planning, placement, CTS, routing, parasitic extraction, STA, DRC, LVS, and final signoff.

GLS is documented as a verification method and should be marked complete only after the appropriate gate-level simulation has been executed and verified. BabySoC pre-synthesis and post-synthesis simulations are included as separate additional work, not as part of the controller's main RTL-to-GDSII implementation.
