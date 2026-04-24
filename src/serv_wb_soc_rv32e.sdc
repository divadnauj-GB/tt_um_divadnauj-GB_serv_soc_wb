# ── Clock ─────────────────────────────────────────────────────────
create_clock -name clock -period 20.000 [get_ports clk]

set_clock_uncertainty -setup 0.5 [get_clocks clock]
set_clock_uncertainty -hold  0.2 [get_clocks clock]


# ── Reset and enable are async → false paths ──────────────────────
set_false_path -from [get_ports rst_n]