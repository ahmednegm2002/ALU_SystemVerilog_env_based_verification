# ====================================================
# QuestaSim DO file - Compile Only
# ====================================================

# Clean old libraries
vdel -all
vlib work
vmap work work

# ====================================================
# Compile RTL
# ====================================================
vlog alu.v +cover -covercells

# ====================================================
# Compile Testbench Files
# ====================================================
vlog -sv alu_if.sv
vlog -sv env_pkg.sv
vlog -sv testenv.sv
vlog -sv top.sv
#======================================================
# simulate 
#======================================================
vsim -voptargs=+acc work.top -cover
add wave *
coverage save top.ucdb -onexit -du work.alu
run -all
return
quit -sim

vcover report top.ucdb -details -annotate -all -output coverage_rpt.txt