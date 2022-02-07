onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gc_cntrl_tb/clk
add wave -noupdate /gc_cntrl_tb/res_n
add wave -noupdate /gc_cntrl_tb/data
add wave -noupdate -divider gc_cntrl
add wave -noupdate /gc_cntrl_tb/uut/cntrl_state
add wave -noupdate /gc_cntrl_tb/uut/do_send
add wave -noupdate /gc_cntrl_tb/uut/received_valid
add wave -noupdate /gc_cntrl_tb/uut/received_data
add wave -noupdate /gc_cntrl_tb/uut/refresh_counter
add wave -noupdate /gc_cntrl_tb/uut/pwe_inst/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
