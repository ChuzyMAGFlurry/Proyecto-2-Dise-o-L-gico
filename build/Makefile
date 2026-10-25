
# ==========================================
# CONFIGURACION GENERAL
# ==========================================

PROYECT := resta
BOARD   := tangnano9k
DEVICE  := GW1NR-LV9QN88PC6/I5
FAMILY  := GW1N-9C

TOP_DESIGN := top

DESIGN_DIR := ../design
CONSTR_DIR := ../constr

CONSTRAINTS := $(CONSTR_DIR)/Tang_nano_9k.cst

# ==========================================
# ARCHIVOS DEL PROYECTO
# ==========================================

SOURCES := \
	$(DESIGN_DIR)/Debounce.sv \
	$(DESIGN_DIR)/EscanearTeclado.sv \
	$(DESIGN_DIR)/DecodificadorDisplay.sv \
	$(DESIGN_DIR)/resta_aritmetica.sv \
	$(DESIGN_DIR)/Top.sv

# ==========================================
# HERRAMIENTAS
# ==========================================

YOSYS       := yosys
NEXTPNR     := nextpnr-gowin
GOWIN_PACK  := gowin_pack
FPGA_LOADER := openFPGALoader

# ==========================================
# ARCHIVOS GENERADOS
# ==========================================

SYNTH_JSON := $(PROYECT).json
PNR_JSON   := $(PROYECT)_pnr.json
BITSTREAM  := $(PROYECT)_$(BOARD).fs

# ==========================================
# OBJETIVOS
# ==========================================

.PHONY: all check synth pnr bitstream load clean

all: bitstream

# ==========================================
# VERIFICAR ARCHIVOS
# Compatible con GNU Make en Windows
# ==========================================

check:

	$(YOSYS) -p "read_verilog -sv $(SOURCES); hierarchy -check -top $(TOP_DESIGN)"
	@echo "Verificacion completada."

# ==========================================
# SINTESIS
# ==========================================

synth: check
	$(YOSYS) -p "read_verilog -sv $(SOURCES); hierarchy -check -top $(TOP_DESIGN); synth_gowin -top $(TOP_DESIGN) -json $(SYNTH_JSON)"

# ==========================================
# PLACE AND ROUTE
# ==========================================

pnr: synth
	$(NEXTPNR) --device $(DEVICE) --family $(FAMILY) --cst $(CONSTRAINTS) --json $(SYNTH_JSON) --write $(PNR_JSON) --freq 10

# ==========================================
# GENERAR BITSTREAM
# ==========================================

bitstream: pnr
	$(GOWIN_PACK) -d $(FAMILY) -o $(BITSTREAM) $(PNR_JSON)
	@echo "Bitstream generado: $(BITSTREAM)"

# ==========================================
# PROGRAMAR FPGA
# ==========================================

load: bitstream
	$(FPGA_LOADER) -b $(BOARD) $(BITSTREAM)

# ==========================================
# LIMPIAR ARCHIVOS GENERADOS
# ==========================================

clean:
	$(RM) $(SYNTH_JSON) $(PNR_JSON) $(BITSTREAM)
	@echo "Limpieza terminada."
