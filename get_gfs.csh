#!/bin/csh

module load wgrib2

foreach i (`seq 0 6 72`)
    if ( $i <= 6 ) then
        set i = `printf "%02d" $i`
    endif
    echo $i
    #set fname1 = https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20251010/12/atmos/gfs.t12z.pgrb2.0p25.f0$i
    #echo $fname1
    wget https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20260610/12/atmos/gfs.t12z.pgrb2.0p25.f0$i
    wget https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20260610/12/atmos/gfs.t12z.pgrb2b.0p25.f0$i
    cat gfs.t12z.pgrb2.0p25.f0$i gfs.t12z.pgrb2b.0p25.f0$i > atmanl_combined_f0$i.grib2
    wgrib2 atmanl_combined_f0$i.grib2 -submsg 1 | ./unique.pl | wgrib2 -i atmanl_combined_f0$i.grib2 -GRIB atmanl_f0$i.grib2

end
