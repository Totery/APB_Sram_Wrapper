onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Pink -itemcolor Pink /tb/clk
add wave -noupdate -color Pink -itemcolor Pink /tb/rstn
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /tb/psel
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /tb/penable
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /tb/pwrite
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /tb/pstrb_s
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /tb/paddr
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /tb/pwdata
add wave -noupdate -color Red -itemcolor Red /tb/pready
add wave -noupdate -color Red -itemcolor Red /tb/prdata
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {13020 ps}
