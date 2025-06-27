#!/opt/gowin-eda-ide/bin/gw_sh
# build_gowin.tcl - Gowin FPGA build and programming script

proc show_help {} {
    puts "\nUsage: ./build_gowin.tcl \[OPTIONS\]"
    puts "Options:"
    puts "  -h      Show this help message"
    puts "  -s      Run synthesis only (generate bitstream)"
    puts "  -p      Program FPGA only (requires existing bitstream)"
    puts "  -f      Program to flash memory (use with -p)"
    puts ""
    puts "If no options are provided, runs full flow (synthesis + programming to RAM)"
    puts ""
    puts "Examples:"
    puts "  ./build_gowin.tcl -s    # Synthesize project"
    puts "  ./build_gowin.tcl -p    # Program FPGA (RAM)"
    puts "  ./build_gowin.tcl -p -f # Program FPGA (Flash)"
    puts "  ./build_gowin.tcl       # Full synthesis + programming to RAM (default)"
    exit 0
}

# Argument parsing
set do_synth 0
set do_prog 0
set do_flash 0
set force_mode 0

foreach arg $argv {
    switch -- $arg {
        "-h" {show_help}
        "-s" {set do_synth 1; set force_mode 1}
        "-p" {set do_prog 1; set force_mode 1}
        "-f" {set do_flash 1}
        default {
            puts "ERROR: Unknown option '$arg'"
            show_help
            exit 1
        }
    }
}

# Validate argument combinations
if {$do_flash && !$do_prog} {
    puts "ERROR: -f can only be used with -p"
    show_help
    exit 1
}

# 1. Find project file
set project_files [glob -nocomplain *.gprj]
if {[llength $project_files] == 0} {
    puts "ERROR: No project file (.gprj) found in current directory"
    exit 1
}
set project_name [file rootname [lindex $project_files 0]]

# 2. Set bitstream path
set bitstream_path "impl/pnr/$project_name.fs"

# Operation modes
if {$do_synth} {
    # Synthesis-only mode
    puts "\n=== Starting project synthesis ==="
    open_project $project_name.gprj
    run all
    puts "Synthesis completed. Bitstream: $bitstream_path"
} elseif {$do_prog} {
    # Programming-only mode
    if {![file exists $bitstream_path]} {
        puts "ERROR: Bitstream file not found: $bitstream_path"
        puts "Please run synthesis first (use -s option)"
        exit 1
    }

    puts "\n=== Starting FPGA programming ==="
    set flash_cmd "openFPGALoader"
    if {$do_flash} {
        append flash_cmd " -f"
        puts "Mode: Programming to FLASH memory"
    } else {
        puts "Mode: Programming to RAM (volatile)"
    }

    puts "Using bitstream: $bitstream_path"
    catch {eval exec $flash_cmd $bitstream_path} result
    puts $result
} else {
    # Default mode (synthesis + programming)
    puts "\n=== Full flow: synthesis + programming ==="
    open_project $project_name.gprj
    run all

    if {![file exists $bitstream_path]} {
        puts "ERROR: Failed to generate bitstream file"
        exit 1
    }

    puts "Programming FPGA (RAM)..."
    catch {eval exec openFPGALoader $bitstream_path} result
    puts $result
}

exit 0
