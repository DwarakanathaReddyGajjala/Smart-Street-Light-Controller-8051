# Smart-Street-Light-Controller-8051

## Overview  
This project implements an **automatic street light control system** using an **8051 microcontroller** and **infrared (IR) sensors**.  
The system conserves energy by turning street lights **ON only when vehicles are detected** and switching them **OFF when no vehicle is present**.  

- Two **IR sensors** are placed along the road.  
- When a vehicle crosses **Sensor 1**, the microcontroller turns **ON** the corresponding street light.  
- When the vehicle reaches **Sensor 2**, the **previous light turns OFF** and the **next one turns ON**.  
- If an EXIT is detected without a prior entry, the LCD displays **INVALID OPERATION**.  
- This ensures illumination only where required, reducing energy wastage.  

---

### Circuit Diagram in Proteus  
In **Proteus**, the following components are connected to implement the system:  
- **8051 Microcontroller (AT89C51)** → runs the Assembly code  
- **IR Sensors** → detect vehicle entry and exit  
- **Street Light LEDs** → represent street lights  
- **16x2 LCD** → display messages (entry/exit, person count, invalid operations)  

These components are interconnected as shown in the circuit diagram (`circuit.png`).  

---

## Files  
- [`street_light_controller.asm`](street_light_controller.asm) → 8051 Assembly code  
- [`circuit.png`](circuit.png) → Circuit diagram (Proteus)  

---

## How to Run  

### Option 1: Keil µVision + Proteus Simulation  
1. Open [`street_light_controller.asm`](street_light_controller.asm) in **Keil µVision**.  
2. Compile → generate `.hex` file.  
3. In **Proteus**, **connect the components as shown in the circuit diagram** (`circuit.png`):  
   - 8051 Microcontroller (AT89C51)  
   - IR Sensors (vehicle detection)  
   - LCD (16x2 display)  
   - LEDs (street lights)  
4. Load the generated `.hex` file into the 8051 microcontroller.  
5. Run the simulation → observe street light switching and LCD messages.  

### Option 2: Hardware Implementation  
1. Burn the compiled `.hex` file into an **AT89C51** using a programmer.  
2. Assemble the circuit on breadboard/PCB exactly as shown in the diagram.  
3. Power the circuit with a regulated **+5V supply**.  
4. Pass an object in front of the IR sensors → observe street light LEDs and LCD messages.  

---

## Advantages  
- Saves energy by lighting only when required  
- Reduces light pollution  
- Increases street light lifespan  
- Enhances road safety  

---
