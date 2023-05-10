# Status of benchmarks

Table below shows current status of each benchmark.  In addition there
are ~450 ISA related tests. These tests are compliance tests. They are
not individually listed. They are all pass/or fail.

The models listed will change. At present VEER and SAIL are excluded.

Both VEER and SAIL are not fully compliant. They have not implemented
all elements of the pertinent ISA.

```
LOC1 = $BENCHMARKS/riscv-tests/share/riscv-tests/benchmarks
LOC2 = $BENCHMARKS/riscv-tests/share/riscv-tests/isa
LOC3 = $BENCHMARKS/bin
LOC4 = $BUILDROOT
```

<table>
<tr>
  <th>suite
  <th>test
  <th>dromajo
  <th>cam
  <th>spike
  <th>marss
  <th>loc
  <th>cmnts</tr>
<tr>
  <td rowspan=2 class="suite"  >o/s
  <td class="test"   >linux,k=5.8-rc4
  <td class="st_drom">?
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC4
  <td class="anno"   >
<tr>
  <td class="test"   >freeRTOS
  <td class="st_drom">?
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >?
  <td class="anno"   >
<tr>
  <td rowspan=2 class="suite"  >coremark
  <td class="test"   >coremark/bare
  <td class="st_drom">?
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC3
  <td class="anno"   >
<tr>
  <td class="test"   >coremark/linux 
  <td class="st_drom">PASS   
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC3
  <td class="anno"   >
<tr>
  <td rowspan=12 class="suite"  >riscv-tests-benchmarks
  <td class="test"   >dhrystone
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >median   
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >mm       
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >mt-matmul
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >mt-vvadd 
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >multiply 
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >pmp      
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >qsort    
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >rsort    
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >spmv     
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >towers   
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td class="test"   >vvadd    
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC1
  <td class="anno"   >
<tr>
  <td rowspan=1 class="suite"  >ISA compliance
  <td class="test"   >various    
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC2
  <td class="anno"   >
<tr>
  <td rowspan=1 class="suite"  >CSR compliance
  <td class="test"   >various    
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >LOC2
  <td class="anno"   >
<tr>
  <td rowspan=1 class="suite"  >Andes extension
  <td class="test"   >various    
  <td class="st_drom">?      
  <td class="st_cam" >?
  <td class="st_spik">?
  <td class="st_mars">?
  <td class="loc"    >?
  <td class="anno"   >
</table>
