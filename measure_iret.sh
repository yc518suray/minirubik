# solver_heuristic
/usr/bin/time -v -o measurement/target/time_report_1.txt \
Ripes --mode cli --src solver_heuristic_elf -t elf --proc RV32_ISS --output measurement/target/iret_report_1.txt \
--iret --exectime --runinfo --cpi

/usr/bin/time -v -o measurement/target/time_report_2.txt \
Ripes --mode cli --src solver_heuristic_elf -t elf --proc RV32_SS --output measurement/target/iret_report_2.txt \
--iret --exectime --runinfo --cpi

/usr/bin/time -v -o measurement/target/time_report_3.txt \
Ripes --mode cli --src solver_heuristic_elf -t elf --proc RV32_5S --output measurement/target/iret_report_3.txt \
--iret --exectime --runinfo --cpi

# solver_heuristic_fast
/usr/bin/time -v -o measurement/target/time_report_fast_1.txt \
Ripes --mode cli --src solver_heuristic_fast_elf -t elf --proc RV32_ISS --output measurement/target/iret_report_fast_1.txt \
--iret --exectime --runinfo --cpi

/usr/bin/time -v -o measurement/target/time_report_fast_2.txt \
Ripes --mode cli --src solver_heuristic_fast_elf -t elf --proc RV32_SS --output measurement/target/iret_report_fast_2.txt \
--iret --exectime --runinfo --cpi

/usr/bin/time -v -o measurement/target/time_report_fast_3.txt \
Ripes --mode cli --src solver_heuristic_fast_elf -t elf --proc RV32_5S --output measurement/target/iret_report_fast_3.txt \
--iret --exectime --runinfo --cpi

# solver_heuristic_ref
/usr/bin/time -v -o measurement/target/time_report_ref_1.txt \
Ripes --mode cli --src solver_heuristic_ref_elf -t elf --proc RV32_ISS --output measurement/target/iret_report_ref_1.txt \
--iret --exectime --runinfo --cpi

/usr/bin/time -v -o measurement/target/time_report_ref_2.txt \
Ripes --mode cli --src solver_heuristic_ref_elf -t elf --proc RV32_SS --output measurement/target/iret_report_ref_2.txt \
--iret --exectime --runinfo --cpi

/usr/bin/time -v -o measurement/target/time_report_ref_3.txt \
Ripes --mode cli --src solver_heuristic_ref_elf -t elf --proc RV32_5S --output measurement/target/iret_report_ref_3.txt \
--iret --exectime --runinfo --cpi
