import matplotlib.pyplot as plt
from PySpice.Spice.Netlist import Circuit
from PySpice.Unit import *

circuit = Circuit('NMOS Inverter')
circuit.V('dd', 'Vdd', circuit.gnd, 5@u_V)
circuit.V('in', 'Vin', circuit.gnd, 0@u_V)
circuit.R('1', 'Vdd', 'Vout', 10@u_kΩ)
circuit.MOSFET('1', 'Vout', 'Vin', circuit.gnd, circuit.gnd, model='NMOS')

# NMOSモデル定義（簡易モデル）
circuit.model('NMOS', 'NMOS (VTO=1 KP=2e-3)')

# シミュレーション
simulator = circuit.simulator(temperature=25, nominal_temperature=25)
analysis = simulator.dc(Vin=slice(0, 5, 0.01))

plt.plot(analysis.Vin, analysis.Vout)
plt.xlabel('Input Voltage (V)')
plt.ylabel('Output Voltage (V)')
plt.title('NMOS Inverter DC Sweep')
plt.grid()
plt.show()
