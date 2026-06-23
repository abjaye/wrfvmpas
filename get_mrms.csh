#!/bin/tcsh
module load wgrib2

# =============================================================
# SETUP: Set your case study's start date and cycle hour
# =============================================================
set init_date = "2026-06-10 12:00 UTC"

# Loop every 3 hours to match your verification steps (3 to 104 hours out)
foreach i (`seq 3 3 104`)

    # Compute target calendar timestamps
    set valid_date = `date -d "$init_date + $i hours" +"%Y%m%d%H"`

    set ymd0       = `date -d "$init_date + $i hours" +"%Y/%m/%d"`
    set mrms_0     = `date -d "$init_date + $i hours" +"%Y%m%d-%H0000"`

    echo "========================================================"
    echo "Processing Combined MRMS Obs for Valid Time: ${valid_date}"
    echo "========================================================"

    # --------------------------------------------------------
    # 1. PRECIPITATION: Get previous 2 hours + current hour
    # --------------------------------------------------------
    set ymd1   = `date -d "$init_date + $i hours - 1 hour" +"%Y/%m/%d"`
    set mrms_1 = `date -d "$init_date + $i hours - 1 hour" +"%Y%m%d-%H0000"`

    set ymd2   = `date -d "$init_date + $i hours - 2 hours" +"%Y/%m/%d"`
    set mrms_2 = `date -d "$init_date + $i hours - 2 hours" +"%Y%m%d-%H0000"`

    wget -q -O hr0.grib.gz "https://mtarchive.geol.iastate.edu/$ymd0/mrms/ncep/MultiSensor_QPE_01H_Pass2/MultiSensor_QPE_01H_Pass2_00.00_${mrms_0}.grib2.gz"
    wget -q -O hr1.grib.gz "https://mtarchive.geol.iastate.edu/$ymd1/mrms/ncep/MultiSensor_QPE_01H_Pass2/MultiSensor_QPE_01H_Pass2_00.00_${mrms_1}.grib2.gz"
    wget -q -O hr2.grib.gz "https://mtarchive.geol.iastate.edu/$ymd2/mrms/ncep/MultiSensor_QPE_01H_Pass2/MultiSensor_QPE_01H_Pass2_00.00_${mrms_2}.grib2.gz"

    gunzip -f hr0.grib.gz
    gunzip -f hr1.grib.gz
    gunzip -f hr2.grib.gz

    # --------------------------------------------------------
    # 2. RADAR REFLECTIVITY: Get current hour snapshot
    # --------------------------------------------------------
    set product = "SeamlessHSR"
    wget -q -O refl.grib.gz "https://mtarchive.geol.iastate.edu/$ymd0/mrms/ncep/${product}/${product}_00.00_${mrms_0}.grib2.gz"

    if ( -e refl.grib.gz && ! -z refl.grib.gz ) then
        gunzip -f refl.grib.gz
    else
        echo "--> [WARNING] Reflectivity missing on server for: ${mrms_0}"
        touch refl.grib
    endif

    # --------------------------------------------------------
    # 3. CONCATENATE EVERYTHING: Merge rain and radar messages
    # --------------------------------------------------------
    cat hr0.grib hr1.grib hr2.grib > mrms_rain_obs_${valid_date}.grib2
    
    # Move the radar snapshot out safely
    if ( -e refl.grib && ! -z refl.grib ) then
        mv refl.grib mrms_refl_obs_${valid_date}.grib2
        echo "--> Saved Rain & Radar files for: ${valid_date}"
    else
        # Create an empty file placeholder if the server missed a timestamp
        touch mrms_refl_obs_${valid_date}.grib2
        echo "--> Saved Rain file (Radar Missing) for: ${valid_date}"
    endif

    # Clean up the temporary workspace files
    rm -f hr0.grib hr1.grib hr2.grib refl.grib refl.grib.gz
    #cat hr0.grib hr1.grib hr2.grib refl.grib > mrms_3hr_obs_${valid_date}.grib2
    #echo "--> Saved: mrms_3hr_obs_${valid_date}.grib2"

    ## Clean up the temporary workspace files
    #rm -f hr0.grib hr1.grib hr2.grib refl.grib refl.grib.gz
end

echo "All MRMS observations downloaded and combined successfully!"
