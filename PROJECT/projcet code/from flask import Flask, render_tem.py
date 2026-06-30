from flask import Flask, render_template
from flask_socketio import SocketIO
import serial, serial.tools.list_ports, threading, time

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")
ser = None

def find_port():
    ports = list(serial.tools.list_ports.comports())
    for p in ports:
        desc = p.description.lower()
        if any(x in desc for x in ["usb", "uart", "serial", "cp210", "ch340", "ftdi"]):
            print("Found port:", p.device, "-", p.description)
            return p.device
    if ports:
        print("Using first port:", ports[0].device)
        return ports[0].device
    print("No port found!")
    return None

def connect_serial():
    global ser
    while True:
        try:
            if ser is None or not ser.is_open:
                port = find_port()
                if port:
                    ser = serial.Serial(port, 9600, timeout=1)
                    print("Connected to", port)
                    socketio.emit("port_status", {"connected": True, "port": port})
                else:
                    socketio.emit("port_status", {"connected": False, "port": ""})
                    time.sleep(3)
        except Exception as e:
            print("Serial error:", e)
            ser = None
            socketio.emit("port_status", {"connected": False, "port": ""})
            time.sleep(3)
        time.sleep(1)

def read_serial():
    global ser
    while True:
        try:
            if ser and ser.is_open and ser.in_waiting:
                data = ser.read(1)
                val = int.from_bytes(data, "big")
                # bit0 = Slot1, bit1 = Slot2 ... bit7 = Slot8
                slots = [(val >> i) & 1 for i in range(8)]
                print("Received:", hex(val), "-> slots:", slots)
                socketio.emit("slot_update", {"slots": slots})
        except Exception as e:
            print("Read error:", e)
            ser = None
        time.sleep(0.01)

@app.route("/")
def index():
    return render_template("index.html")

@socketio.on("toggle_slot")
def toggle_slot(data):
    global ser
    try:
        if ser and ser.is_open:
            slot = data["slot"]
            cmd = str(slot).encode()  # ASCII '1'-'8' matches Verilog 0x31-0x38
            ser.write(cmd)
            print(f"Sent slot {slot} as ASCII {hex(ord(str(slot)))}")
        else:
            print("Serial not connected")
    except Exception as e:
        print("Write error:", e)

if __name__ == "__main__":
    threading.Thread(target=connect_serial, daemon=True).start()
    threading.Thread(target=read_serial, daemon=True).start()
    socketio.run(app, port=5000, debug=False)