#!/bin/tcsh

# =============================================================
# SETUP: Set your case study's true start date (June 10)
# =============================================================
set init_date = "2026-06-10 12:00 UTC"

# Loop every 3 hours to match your simulation verification steps
foreach i (`seq 3 3 104`)

    # Compute target calendar dates and hours separately for the AWS URL
    set valid_date = `date -d "$init_date + $i hours" +"%Y%m%d"`
    set valid_hour = `date -d "$init_date + $i hours" +"%H"`
    set timestamp  = `date -d "$init_date + $i hours" +"%Y%m%d%H"`

    echo "------------------------------------------------"
    echo "Downloading AWS Archived HRRR Analysis for: ${timestamp}"
    echo "------------------------------------------------"

    # Fetch the 3km CONUS surface analysis file (f00) from the long-term AWS S3 mirror
    wget -q -O hrrr_surface_obs_${timestamp}.grib2 \
    "https://noaa-hrrr-bdp-pds.s3.amazonaws.com/hrrr.${valid_date}/conus/hrrr.t${valid_hour}z.wrfsfcf00.grib2"

end

echo "HRRR surface observation archive download complete!"
