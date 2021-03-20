#!/bin/bash
export RSH=ssh
n_th=(4 8 16 32)
size=(4g 8g 16g 32g)
for i in $(seq 0 `expr "${#n_th[@]}" - 1`)
do
    for j in $(seq 0 `expr "${#size[@]}" - 1`)
    do
        iozone -r 1024k -t "${n_th[$i]}" -s "${size[$j]}" -i0 -i1 -+n -w -+m /scripts/iozone_th_files/iozone_"${n_th[$i]}"th > /scripts/iozone_i0_i1_t"${n_th[$i]}"_s"${size[$j]}".out 2>&1
        for k in $(seq 1 "${n_th[$i]}"); do rm -f /stor/lustrefs/iozone/test"$k"/*; done
    done
done
