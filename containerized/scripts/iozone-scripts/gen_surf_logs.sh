#!/bin/bash
printf ' \t4\t8\t16\t32
32\t%s\t%s\t%s\t%s
16\t%s\t%s\t%s\t%s
8\t%s\t%s\t%s\t%s
4\t%s\t%s\t%s\t%s\n' \
"$(cat iozone_i0_i1_t32_s4g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t32_s8g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t32_s16g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t32_s32g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t16_s4g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t16_s8g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t16_s16g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t16_s32g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t8_s4g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t8_s8g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t8_s16g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t8_s32g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t4_s4g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t4_s8g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t4_s16g.out | grep writers | awk '{print $9}')" \
"$(cat iozone_i0_i1_t4_s32g.out | grep writers | awk '{print $9}')" \
> write_surf.log 

printf ' \t4\t8\t16\t32
32\t%s\t%s\t%s\t%s
16\t%s\t%s\t%s\t%s
8\t%s\t%s\t%s\t%s
4\t%s\t%s\t%s\t%s\n' \
"$(cat iozone_i0_i1_t32_s4g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t32_s8g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t32_s16g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t32_s32g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t16_s4g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t16_s8g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t16_s16g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t16_s32g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t8_s4g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t8_s8g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t8_s16g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t8_s32g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t4_s4g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t4_s8g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t4_s16g.out | grep readers | awk '{print $8}')" \
"$(cat iozone_i0_i1_t4_s32g.out | grep readers | awk '{print $8}')" \
> read_surf.log
