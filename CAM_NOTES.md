# CAM notes 

Reference card for common CPM/CAM operations and notes

# Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is a github organization. 

CPM contains a number of repo's used by Condor. 
Condor-Performance-Modeling/how-to contains documentation, patches and 
support scripts. The steps that follow document building the Condor 
perf modeling environment and provide instructions on how to use it.

# Condor Architecture Model

CAM is the Condor Architecture Model. Presently this supports a 
single microarchitecture, Cuzco.

CAM used Olympia as the starting point. Over time CAM will
diverge from Olympia. Not all CAM changes will be made
available up stream.

# FAQ ToC

1. [How to dump the full parameter set](#how-to-dump-the-full-parameter-set)

1. [How to allow CAM to run outside the build directory](#how-to-allow-CAM-to-run-outside-the-build-directory)

1. [Command line help](#command-line-help)

---------------------------------------------------------------------
## How to dump the full parameter configuration of the model

Output is configuration.yaml

```
cd $CAM/release; \
./cam \
--arch-search-dir $BENCHMARKS/arches --arch cuzco_arch \
$TRACELIB/coremark_1.linux.stf \
--write-final-config configuration.yaml
```

## How to allow CAM to run outside the build directory

By default CAM expects the architecture configuration and mavis files 
to be in a relative path.

```
FIXME
```

## Command line help

This is a reference snapshot taken 2023.11.13 of the CAM command line help.

```
# Name:     Olympia RISC-V Perf Model 
# Cmdline:  ./cam --help
# Exe:      ./cam
# SimulatorVersion: v0.1.0
# Repro:    
# Start:    Monday Mon Nov 13 11:52:04 2023
# Elapsed:  0.000254s
# Sparta Version: map_v2.0.11

Usage:
    [-i insts] [-r RUNTIME] [--show-tree] [--show-dag]
    [-p PATTERN VAL] [-c FILENAME]
    [-l PATTERN CATEGORY DEST]
    [-h,--help] <workload [stf trace or JSON]>


General Options:
  -h [ --help ]                                   Show complete help message on stdout then exit
  --help-brief                                    Show brief help on stdout then exit
  --verbose-help                                  Deprecated. Use --help
  --help-topic TOPIC                              Show help information on a particular topic then exit. Use "topics" as TOPIC to show all 
                                                  topic options
  --no-run                                        Quit with exit code 0 prior to finalizing the simulation. When running without this (or 
                                                  without other option having the same effect such as --show-parameters), the simulator 
                                                  will still attempt to run and may exit with an error if the default configuration does 
                                                  not run successfully as-is
  --show-tree                                     Show the device tree during all stages of construction excluding hidden nodes. This also 
                                                  enables printing of the tree when an exception is printed
  --show-parameters                               Show all device tree Parameters after configuration excluding hidden nodes. Shown in a 
                                                  separate tree printout from all other --show-* parameters.
                                                  See related: --write-final-config
  --show-ports                                    Show all device tree Ports after finalization. Shown in a separate tree printout from all
                                                  other --show-* parameters
  --show-counters                                 Show the device tree Counters, Statistics, and other instrumentation after finalization. 
                                                  Shown in a separate tree printout from all other --show-* parameters
  --show-stats                                    Same as --show-counters
  --show-notifications                            Show the device tree notifications after finalization excluding hidden nodes and Logger 
                                                  MessageSource nodes. Shown in a separate tree printout from all other --show-* parameters
  --show-loggers                                  Show the device tree logger MessageSource nodes after finalization.  Shown in a separate 
                                                  tree printout from all other --show-* parameters
  --show-dag                                      Show the dag tree just prior to running simulation
  --show-clocks                                   Show the clock tree after finalization. Shown in a seperate tree printoutfrom all other 
                                                  --show-* parameters
  --help-tree                                     Sets --no-run and shows the device tree during all stages of construction excluding 
                                                  hidden nodes. This also enables printing of the tree when an exception is printed
  --help-parameters                               Sets --no-run and shows all device tree Parameters after configuration excluding hidden 
                                                  nodes. Shown in a separate tree printout from all other --show-* parameters.
                                                  See related: --write-final-config
  --help-ports                                    Sets --no-run and shows all device tree Ports after finalization. Shown in a separate 
                                                  tree printout from all other --show-* parameters
  --help-counters                                 Sets --no-run and shows the device tree Counters, Statistics, and other instrumentation 
                                                  after finalization. Shown in a separate tree printout from all other --show-* parameters
  --help-stats                                    Same as --help-counters
  --help-notifications                            Sets --no-run and shows the device tree notifications after finalization excluding hidden
                                                  nodes and Logger MessageSource nodes. Shown in a separate tree printout from all other 
                                                  --show-* parameters
  --help-loggers                                  Sets --no-run and shows the device tree logger MessageSource nodes after finalization. 
                                                  Shown in a separate tree printout from all other --show-* parameters
  --help-clocks                                   Sets --no-run and shows the device tree clock nodes after finalization. Shown in a 
                                                  separate tree printout from all other --show-* parameters
  --help-pevents                                  Sets --no-run and shows the pevents types in the model after finalization. 
  --validate-post-run                             Enable post-run validation. After run completes without throwing an exception, the entire
                                                  tree is walked and posteach resource is allowed to perform post-run-validation if it 
                                                  chooses. Any resource with invalid state have the opportunity to throw an exception which
                                                  will cause the simulator to exit with an error. Note that this validation may not aways 
                                                  be appropriate because the simulation can be be ended abruptly with an instruction-count 
                                                  or cycle-count limit
  --disable-infinite-loop-protection              Disable detection of infinite loops during simulation.
  --debug-dump POLICY                             Control debug dumping to a file of the simulator's choosing. Valid values include 
                                                  'error': (default) dump when exiting with an exception. 'never': never dump, 'always': 
                                                  Always dump on success, failure, or error.
                                                  Note that this dump will not be triggered on command-line errors such as invalid options 
                                                  or unparseable command-lines. Bad simulation-tree parameters (-p) will trigger this error
                                                  dump.
  --debug-dump-options OPTIONS                    When debug dumping is enabled, use this option to narrow down what specifically should be
                                                  captured in the error log. Valid values include 'all', 'asserts_only', and 
                                                  'backtrace_only'
  --debug-dump-filename FILENAME                  Sets the filename used when creating a debug dump after running or durring an run/setup 
                                                  error. Defaults to "" which causes the simulator to create a name in the form 
                                                  "error-TIMESTAMP.dbg"
  --pevents FILENAME CATEGORY                     Log pevents in category CATEGORY that are passed to the PEventLogger during simulation to
                                                  FILENAME.
                                                  when CATEGORY == ALL, all pevent types will be logged to FILENAME
                                                  Examples: 
                                                  --pevents output.pevents ALL
                                                  --pevents log.log complete,retire,decode
  --verbose-pevents FILENAME CATEGORY             Log more verbose pevents in category CATEGORY that are passed to the PEventLogger during 
                                                  simulation to FILENAME.
                                                  when CATEGORY == ALL, all pevent types will be logged to FILENAME
                                                  Examples: 
                                                  --pevents output.pevents ALL
                                                  --pevents log.log RETIRE,decode
  --pevents-at FILENAME TREENODE CATEGORY         Log pevents of type CATEGORY at and below TREENODE.
                                                  When CATEGORY == ALL then all pevent types will be logged below and at TREENODE.Example: 
                                                  "--pevents-at lsu_events.log top.core0.lsu ALL" This option can be specified none or many
                                                  times.
  --verbose-pevents-at FILENAME TREENODE CATEGORY Log verbose pevents of type CATEGORY at and below TREENODE.
                                                  When CATEGORY == ALL then all pevent types will be logged below and at TREENODE.Example: 
                                                  "--verbose-pevents-at lsu_events.log top.core0.lsu ALL" This option can be specified none
                                                  or many times.

Parameter Options:
  -p [ --parameter ] PATTERN VAL             Specify an individual parameter value. Multiple parameters can be identified using '*' and '?'
                                             glob-like wildcards. 
                                             Example: --parameter top.core0.params.foo value
  --optional-parameter PATTERN VAL           Specify an optional individual parameter value. Unlike --parameter/-p, this will not fail if 
                                             no parameter(s) matching PATTERN can be found. However, if matching nodes are found, the value
                                             given must be compatible with those parameter nodes. Otherwise, behavior is idenitical to 
                                             --parameter/-p
  -c [ --config-file ] FILENAME              Specify a YAML config file to load at the global namespace of the simulator device tree. 
                                             Example: "--config-file config.yaml" This is effectively the same as --node-config-file top 
                                             params.yaml
  --read-final-config FILENAME               Read a previously generated final configuration file. When this is used parameters in the 
                                             model are set purely off the values specified in FILENAME. The simulator can not override the 
                                             values nor can -p or other configuration files be specified. In other words, simulation is 
                                             guaranteed to run with the same values as the parameters specified in this file
  -n [ --node-config-file ] PATTERN FILENAME Specify a YAML config file to load at a specific node (or nodes using '*' and '?' glob-like 
                                             wildcards) in the device tree.
                                             Example: "--node-config-file top.core0 core0_params.yaml"
  -e [ --extension-file ] FILENAME           Specify a YAML extension file to load at the global namespace of the simulator device tree. 
                                             Example: "--extension-file extensions.yaml"
  --control FILENAME                         Specify a YAML control file that contains trigger expressions for simulation pause, resume, 
                                             terminate, and custom named events. Example: "--control ctrl_expressions.yaml"
  --arch ARCH_NAME                           Applies a configuration at the global namespace of the simulator device tree in a similar way 
                                             as --config-file/-c. This configuration is effectively a set of new defaults for any included 
                                             parameters. Example: 
                                             "--arch project_x"
                                             Valid arguments can be found in the --arch-search-dir directory which defaults to "[arches]"
  --arch-search-dir DIR                      Base directory in which to search for the architecture configuration baseline chosen by --arch
                                             (default: "[arches]")
                                             Example: "--arch-search-dir /archive/20130201/architecures/"
                                             
  --config-search-dir DIR                    Additional search directories in which to search for includes found in configuration files 
                                             given by --config-file/-c <file.yaml> (default is : "./")
                                             Example: "--config-search-dir /archive/20130201/configurations/"
                                             
  --report-search-dir DIR                    Additional search directories in which to search for report definition files referenced inside
                                             a multi-report YAML file (SPARTA v1.6+) given by --report <file.yaml> (default is: "./")
                                             Example: "--report-search-dir /full/path/to/definition/files/"
                                             
  --write-final-config FILENAME              Write the final configuration of the device tree to the specified file before running the 
                                             simulation
  --write-final-config-verbose FILENAME      Write the final configuration of the device tree to the specified file before running the 
                                             simulation. The output will include parameter descriptions and extra whitespace for 
                                             readability
  --enable-state-tracking FILENAME           Specify a Text file to save State Residency Tracking Histograms. Example: 
                                             "--enable-state-tracking data/histograms.txt"

Run-time Options:
  -r [ --run-length ] [CLOCK] CYCLE Run the simulator for the given cycles based on the optional clock
                                    Examples:
                                    '-r core_clk 500'
                                    '-r 500,'
                                    If no clock is specified, this value is interpreted in a a simulator-specific way.Run a length of 
                                    simulation in cycles on a particular clock. With no clock specified, this is interpted in a 
                                    simulator-specific way
  --wall-timeout HOURS EXIT_TYPE    Run the simulator until HOURS wall clock time has passed.
                                    Examples:
                                    '--wall-timeout 5 clean'
                                    '--wall-timeout 5 error'
                                    The only exit types are "clean" and "error". error throws an exception, clean will stop simulation 
                                    nicely.
  --cpu-timeout HOURS EXIT_TYPE     Run the simulator until HOURS cpu user clock time has passed.
                                    Examples:
                                    '--cpu-timeout 5 clean'
                                    '--cpu-timeout 5 error'
                                    The only exit types are "clean" and "error". error throws an exception, clean will stop simulation 
                                    nicely.

Logging Options:
  -l [ --log ] PATTERN CATEGORY DEST Specify a node in the simulator device tree at the node described by PATTERN (or nodes using '*' and 
                                     '?' glob wildcards) on which to place place a log-message tap (observer) that watches for messages 
                                     having the category CATEGORY. Matching messages from those node's subtree are written to the filename 
                                     in DEST. DEST may also be '1' to refer to stdout and '2' to refer to cerr. Any number of taps can be 
                                     added anywhere in the device tree. An error is generated if PATTERN does not refer to a 1 or more 
                                     nodes. Use --help for more details
                                     Example: "--log top.core0 warning core0_warnings.log"
  --warn-file FILENAME               Filename to which warnings from the simulator will be logged. This file will be overwritten. This has 
                                     no relationship with --no-warn-stderr
  --no-warn-stderr                   Do not write warnings from the simulator to stderr. Unset by default. This is has no relationship with
                                     --warn-file

Pipeline-Collection Options:
  -z [ --pipeline-collection ] OUTPUTPATH   Run pipeline collection on this simulation, and dump the output files to OUTPUTPATH. OUTPUTPATH
                                            can be a prefix such as myfiles_ for the pipeline files and may be a directory
                                            Example: "--pipeline-collection data/test1_"
                                            Note: Any directories in this path must already exist.
                                            
  -k [ --collection-at ] TREENODE           Specify a treenode to recursively turn on at and below for pipeline collection.Example: 
                                            "--collection-at top.core0.rename" This option can be specified none or many times.
  -K [ --pipeViewer-collection-at ] ALFFILE Specify an pipeViewer ALFFILE file to restrict pipeline collection to only those nodes found in
                                            the ALF.Example: "--pipeViewer-collection-at layouts/exe40.alf" This option can be specified 
                                            none or many times.
  --heartbeat HEARTBEAT                     The interval in ticks at which index pointers will be written to file during pipeline 
                                            collection. The heartbeat also represents the longest life duration of lingering transactions. 
                                            Transactions with a life span longer than the heartbeat will be finalized and then restarted 
                                            with a new start time. Must be a multiple of 100 for efficient reading by pipeViewer. Large 
                                            values will reduce responsiveness of pipeViewer when jumping to different areas of the file and
                                            loading.
                                            Default = 0 ticks.
                                            

Debug Options:
  --debug-on [CLOCK] CYCLE       
                                 Delay the recording of useful information starting until a specified simulator cycle at the given clock. 
                                 If no clock provided, a default is chosen, typically the fastest. This includes any user-configured 
                                 pipeline collection or logging (builtin logging of warnings to stderr is always enabled). Note that this 
                                 is just a delay; logging and pipeline collection must be explicitly enabled.
                                 WARNING: Must not be specified with --debug-on-icount, --debug-on-roi
                                 WARNING: The CYCLE may only be partly included. It is dependent upon when the scheduler activates the 
                                 trigger. It is recommended to schedule a few ticks before your desired area.
                                 Examples: '--debug-on 5002 -z PREFIX_ --log top debug 1' or '--debug-on core_clk 5002 -z PREFIX_'
                                 begins pipeline collection to PREFIX_ and logging to stdout at some point within tick 5002 and will 
                                 include all of tick 5003
  --debug-on-icount INSTRUCTIONS 
                                 Delay the recording of useful information starting until a specified number of instructions.
                                 WARNING: Must not be specified with --debug-on, --debug-on-roi
                                 See also --debug-on.
                                 Examples: '--debug-on-icount 500 -z PREFIX_'
                                 Begins pipeline collection to PREFIX_ when instruction count from this simulator's counter with the 
                                 CSEM_INSTRUCTIONS semantic is equal to 500
  --debug-on-roi                 
                                 Delay the recoding of useful information when simulator detects ROIs. Pipeline collection, Pevents, and 
                                 loggers will generate output file for every ROI.
                                 WARNING: Must not be specified with --debug-on, --debug-on-icount
                                 

Report Options:
  --report DEF_FILE | PATTERN DEF_FILE DEST [FORMAT]                                   Specify a single definition file containing 
                                                                                       descriptions for more than one report. See the 
                                                                                       'ReportTriggers.txt' file in this directory for 
                                                                                       formatting information.
                                                                                       Example: "--report all_report_descriptions.yaml"
                                                                                       Note that the option '--report DEF_FILE' is the only
                                                                                       way to use report triggers of any kind, such as 
                                                                                       warmup.
                                                                                       You can also provide YAML keyword replacements on a 
                                                                                       per-report-yaml basis.
                                                                                       Example: "--report foo_descriptor.yaml foo.yaml 
                                                                                       --report bar_descriptor.yaml bar.yaml"
                                                                                       In this usage, foo.yaml contains %KEYWORDS% that 
                                                                                       replace those found in foo_descriptor.yaml,
                                                                                       while bar(_descriptor).yaml does the same without 
                                                                                       clashing with foo(_descriptor.yaml)
                                                                                       See foo*.yaml and bar*.yaml in 
                                                                                       <sparta>/example/CoreModel for more details.
                                                                                       You may also specify individual report descriptions 
                                                                                       one at a time with the options
                                                                                       'PATTERN DEF_FILE DEST [FORMAT]' as follows:
                                                                                       Specify a node in the simulator device tree at the 
                                                                                       node described by PATTERN (or nodes using '*' and 
                                                                                       '?' glob wildcards) at which generate a statistical 
                                                                                       report that examines the set of statistics based on 
                                                                                       the Report definition file DEF_FILE. At the end of 
                                                                                       simulation, the content of this report (or reports, 
                                                                                       if PATTERN refers to multiple nodes) is written to 
                                                                                       the file specified by DEST. DEST may also be  to 
                                                                                       refer to stdout and 2 to refer to stderr. Any number
                                                                                       of reports can be added anywhere in the device 
                                                                                       tree.An error is generated if PATTERN does not refer
                                                                                       to 1 or more nodes. FORMAT can be used to specify 
                                                                                       the format. See the report options section with 
                                                                                       --help for more details about formats.
                                                                                       Example: "--report top.core0 core_stats.yaml 
                                                                                       core_stats txt"
                                                                                       Example: "--report top.core* core_stats.yaml 
                                                                                       core_stats.%l"
                                                                                       Example: "--report _global global_stats.yaml 
                                                                                       global_stats"
  --report-all DEST [FORMAT]                                                           Generates a single report on the global simulation 
                                                                                       tree containing all counters and statistics below 
                                                                                       it. This report is written to the file specified by 
                                                                                       DEST using the format specified by FORMAT (if 
                                                                                       supplied). Otherwise, the format is inferred from 
                                                                                       DEST. DEST may be a filename or 1 to refer to stdout
                                                                                       and 2 to refer to stderr. See the report options 
                                                                                       setcion with --help for more details.This option can
                                                                                       be used multiple times and does not interfere with 
                                                                                       --report.
                                                                                       Example: "--report-all core_stats.txt"
                                                                                       Example: "--report-all output_file html"
                                                                                       Example: "--report-all 1"
                                                                                       Attaches a single report containing everything below
                                                                                       the global simulation tree and writes the output to 
                                                                                       destination
  --report-yaml-replacements <placeholder_name> <value> <placeholder_name> <value> ... Specify placeholder values to replace %PLACEHOLDER% 
                                                                                       specifiers in report description yaml files. 
                                                                                       
  --log-memory-usage [DEF_FILE]                                                        Example: "--log-memory-usage memory.yaml"
  --retired-inst-counter-path FILENAME                                                 From 'top.core*', what is the path to the counter 
                                                                                       specifying retired instructions on a given core? 
                                                                                       For example, if the paths are: 
                                                                                                    top.core0.rob.stats.total_number_retire
                                                                                       d 
                                                                                                    top.core1.rob.stats.total_number_retire
                                                                                       d 
                                                                                                Then the 'retired-inst-counter-path' is: 
                                                                                                    rob.stats.total_number_retired
  --generate-stats-mapping                                                             Automatically generate 1-to-1 mappings from CSV 
                                                                                       report column headers to StatisticInstance names
  --no-json-pretty-print                                                               Disable pretty print / verbose print for all JSON 
                                                                                       statistics reports
  --omit-zero-value-stats-from-json_reduced                                            Omit all statistics that have value 0 from 
                                                                                       json_reduced statistics reports
  --report-verif-output-dir DIR_NAME                                                   When SimDB report verification is enabled, this 
                                                                                       option will send all verification artifacts to the 
                                                                                       specified directory, relative to the current working
                                                                                       directory.
  --report-warmup-icount                                                               DEPRECATED
  --report-warmup-counter                                                              DEPRECATED
  --report-update-ns                                                                   DEPRECATED
  --report-update-cycles                                                               DEPRECATED
  --report-update-icount                                                               DEPRECATED
  --report-update-counter                                                              DEPRECATED
  --report-on-error                                                                    Write reports normally even if simulation that has 
                                                                                       made it into the 'running' stage is exiting because 
                                                                                       of an exception during a run. This includes the 
                                                                                       automatic summary. Normally, reports are only 
                                                                                       written if simulation succeeds. Note that this does 
                                                                                       not apply to exits caused by fatal signal such as 
                                                                                       SIGKILL/SIGSEGV/SIGABRT, etc.

SimDB Options:
  --simdb-dir DIR             Specify the location where the simulation database will be written
  --simdb-enabled-components  Specify which simulator components should be enabled for SimDB access.
                              Example: "--simdb-enabled-components dbaccess.yaml"

Application-Specific Options:
  -v [ --version ]                 produce version message
  -i [ --instruction-limit ] LIMIT Limit the simulation to retiring a specific number of instructions. 0 (default) means no limit. If -r is
                                   also specified, the first limit reached ends the simulation
  --num-cores CORES                The number of cores in simulation
  --show-factories                 Show the registered factories
  --workload workload              Specifies the instruction workload (trace, JSON)

Advanced Options:
  --no-colors                Disable color in most output. Including the colorization in --show-tree.
  --show-hidden              Show hidden nodes in the tree printout (--show-tree). Implicitly turns on --show-tree
  --verbose-config           Display verbose messages when parsing any files (e.g. parameters, report definitions,  etc.). This is not a 
                             generic verbose simulation option.
  --verbose-report-triggers  Display verbose messages whenever report triggers are hit
  --show-options             Show the options parsed from the command line
  --debug-sim                Turns on simulator-framework debugging output. This is unrelated to general debug logging
  --auto-summary OPTION      Controls automatic summary at destruction. Valid values include 'off': Do not write summary, 'on' or 'normal':
                             (default) Write summary after running, and 'verbose': Write summary with detailed descriptions of each 
                             statistic

Config:

  Note that parameters and configuration files specified by the -c (global config
file), -n (node config file), and -p (parameter value) options are applied in the
left-to-right order on the command line, overwriting any previous values.


Logging:

  The "--log" DEST parameter can be "1" to refer to stdout, "2" to refer to stderr, or a filename which can contain any extension shown
below for a particular type of formatting:

  ".log.basic" -> basic formatter. Contains message origin, category, and content
  ".log.verbose" -> verbose formatter. Contains all message meta-data
  ".log.raw" -> verbose formatter. Contains no message meta-data
  (default) -> Moderate information formatting. Contains most message meta-data excluding thread and message sequence.
Reports:

  The "--report" PATTERN parameter can refer to any number of nodes in the device tree. For each node referenced, a new Report will be created and appended to the file specified by DEST for that report. If these reports should be written to different files, variables can be used in the destination filename to differentiate:
    %l => Location in device tree of report instantiation
    %i => Index of report instantiation
    %p => Host process ID
    %t => Timestamp
    %s => Simulator name

  Additionaly, the DEST parameter can be a filename or "1", referring to stdout, or "2", referring to stderr
  If outputting to stdout/stderr. the optional report FORMAT parameter should be omitted or "txt" .

  Valid formats include:
  txt, text -> Plaintext report output
  html, htm -> Basic HTML Report Output
  csv, csv_cumulative -> CSV Report Output (supports updating)
  js_json, jsjson -> JavaScript Object Notation Report Output
  python, py -> Python dictionary output
  json, JSON -> JavaScript Object Notation Report Output
  json_reduced, JSON_reduced -> JavaScript Object Notation Report Output with only stat values reported
  json_detail, JSON_detail -> JavaScript Object Notation Report Output with only non-stat value information reported (desc, vis, etc...)
  gnuplot, gplt -> Gnuplot report output
  stats_mapping -> Mapping from CSV column headers to Statistic Instance locations


Tips:
  "--help-topic topics" will display specific help sections for more concise help
```
