read_sdc $::env(DESIGN_DIR)/base.sdc
# ── Clock ─────────────────────────────────────────────────────────
set_clock_uncertainty 2.5 -rise_from clk -fall_to clk
set_clock_uncertainty 2 -fall_from clk -rise_to clk

# Fix reset delay
set_input_delay 1.5 -clock [get_clocks $::env(CLOCK_PORT)] {rst_n}

# ── Input / Output Delays ─────────────────────────────────────────
set bidi_delay_value [expr $::env(CLOCK_PERIOD) * 0.6]
set_input_delay $bidi_delay_value -clock [get_clocks $::env(CLOCK_PORT)] {uio_in ui_in}

# Longer output delay on bidi IOs to improve coherence
set_output_delay $bidi_delay_value -clock [get_clocks $::env(CLOCK_PORT)] {uio_out uio_oe}

# ── Reset and enable are async → false paths ──────────────────────
set_false_path -from [get_ports rst_n]
set_false_path -from [get_ports ena]

set_propagated_clock [all_clocks]
