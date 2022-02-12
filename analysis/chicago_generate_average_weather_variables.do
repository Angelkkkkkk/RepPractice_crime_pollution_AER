global rawdata C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Raw-Data
global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data

/**********************************************************
chicago_generate_average_weather_variables.do

DESCRIPTION: Generate daily averages of hourly weather variables
************************************************************/

pause on
clear all
set more off
set mem 1000m
set matsize 2000



* ZERO DEGREES (ZERO RADIANS) IS NORTH
#delimit 
use "$rawdata/chicago_hourly_weather_stations.dta", clear

keep usaf wban month day year hour min latitude longitude wind_angle ///
wind_angle_qual wind_obs_type wind_speed wind_speed_qual temp temp_qual ///
dewpoint dewpoint_qual sealevel_pressure sealevel_pressure_qual stationname

/**************************************
						Wind stuff
**************************************/
* SET ANGLE OF CALM WIND OBERSEVATIONS TO ZERO
replace wind_speed = . if wind_speed == 9999 | (wind_angle == 999 & wind_speed != 0)
replace wind_angle = . if (wind_angle == 999 & wind_speed != 0) | mi(wind_speed)
replace wind_angle = 0 if wind_speed == 0

* KEEP ONLY OBSERVATIONS WITH VALID WIND SPEED AND ANGLE
keep if inlist(wind_speed_qual,"1","5","9") & inlist(wind_angle_qual,"1","5","9")

* CONVERT DEGREES TO RADIANS
gen wind_angle_radians = wind_angle*(3.14159265)*2/360

* GENERATE VECTOR COMPONENTS
gen xwind = cos(wind_angle_radians)
gen ywind = sin(wind_angle_radians)

* SPEED WEIGHTED
gen xwind_speed = xwind*wind_speed
gen ywind_speed = ywind*wind_speed

* WEIGHTED PROPORTIONAL TO POWER
gen xwind_power = xwind*wind_speed^3
gen ywind_power = ywind*wind_speed^3

gen windobsind = !mi(wind_speed) & !mi(wind_angle)
bys usaf wban year month day: egen windobs = sum(windobsind)

* GENERATE AVERAGES;
bys usaf wban year month day: egen xwind_avg = mean(xwind)
bys usaf wban year month day: egen xwind_speed_avg = mean(xwind_speed)
bys usaf wban year month day: egen xwind_power_avg = mean(xwind_power)
bys usaf wban year month day: egen ywind_avg = mean(ywind)
bys usaf wban year month day: egen ywind_speed_avg = mean(ywind_speed)
bys usaf wban year month day: egen ywind_power_avg = mean(ywind_power)

* GENERATE NORMS;
gen speed_norm = sqrt(xwind_speed_avg^2 + ywind_speed_avg^2)
label var speed_norm "norm of net speed vector, 10 m/s"
gen power_norm = (sqrt(xwind_power_avg^2 + ywind_power_avg^2))^1/3
* RESCALE POWER NORM
replace power_norm = power_norm/(1000)
label var power_norm "proportional to norm of net power vector (speed^3), normalized by 1000"

* GENERATE AVERAGE ANGLES;
gen wind_dir_avg = .
replace wind_dir_avg = atan2(ywind_avg,xwind_avg) + 2*3.14159265 if ywind_avg < 0
replace wind_dir_avg = atan2(ywind_avg,xwind_avg) if ywind_avg >= 0

gen wind_speed_dir_avg = . 
replace wind_speed_dir_avg = atan2(ywind_speed_avg,xwind_speed_avg) + 2*3.14159265 if ywind_speed_avg < 0
replace wind_speed_dir_avg = atan2(ywind_speed_avg,xwind_speed_avg) if ywind_speed_avg >= 0

gen wind_power_dir_avg = .
replace wind_power_dir_avg = atan2(ywind_power_avg,xwind_power_avg) + 2*3.14159265 if ywind_power_avg < 0
replace wind_power_dir_avg = atan2(ywind_power_avg,xwind_power_avg) if ywind_power_avg >= 0

* GENERATE CALM DUMMY
gen calmday = (speed_norm == 0)
count if calmday == 1 & power_norm !=0
assert r(N) == 0

* GENERATE SIMPLE AVERAGE WIND SPEED
bys usaf wban year month day: egen avg_wind_speed = mean(wind_speed)

* GENERATE WIND POWER (is proportional to the cube of speed);
gen wind_power = avg_wind_speed^3

/**************************************
						Temperature
**************************************/
* GENERATE AVERAGE, MAX, MIN TEMPERATURE
* KEEP IF THERE ARE AT LEAST 18 OBSERVATIONS IN A DAY
gen temp_new = temp
replace temp_new = . if temp_qual == "6" | temp_qual == "7" | temp_qual == "3" | temp_qual == "2"
replace temp_new = . if temp_new == 9999
gen observed = !mi(temp_new)
bys usaf wban year month day: egen totobs = sum(observed)
tab totobs

tab hour if totobs < 18
tab hour if totobs >= 18
gen tempdataflag = (totobs < 18)
label var tempdataflag "This day is based on less than 18 valid temperature observations" 

bys usaf wban year month day: egen tmax = max(temp_new)
bys usaf wban year month day: egen tavg = mean(temp_new)
bys usaf wban year month day: egen tmin = min(temp_new)

/***************************************
							Dew point
***************************************/
gen dewpoint_new = dewpoint
replace dewpoint_new = . if dewpoint_qual == "6" | dewpoint_qual == "7" | dewpoint_qual == "3" | dewpoint_qual == "2"
replace dewpoint_new = . if dewpoint_new == 9999
bys usaf wban year month day: egen dew_point_avg = mean(dewpoint_new)

/***************************************
							Sea level pressure
***************************************/
gen sealevel_pressure_new = sealevel_pressure
replace sealevel_pressure_new = . if sealevel_pressure_qual == "6" | sealevel_pressure_qual == "7" | sealevel_pressure_qual == "3" | sealevel_pressure_qual == "2"
replace sealevel_pressure_new = . if sealevel_pressure_new == 99999
bys usaf wban year month day: egen sealevel_pressure_avg = mean(sealevel_pressure_new)

gen date = mdy(month,day,year)
format date %td

notes: All wind variables are the direction the wind blows from
notes: Wind from the North is 0, then it's clockwise radians (i.e., wind from the South = 3.1415)


keep usaf wban date year month day wind_dir_avg wind_speed_dir_avg wind_power_dir_avg ///
	avg_wind_speed windobs speed_norm power_norm calmday tempdataflag ///
	tmax tavg tmin dew_point_avg sealevel_pressure_avg

* KEEP ONE DAILY OBSERVATION
egen tag = tag(usaf wban date)
keep if tag == 1
duplicates report usaf date
	
compress

save "$data/chicago_weather_daily_from_hourly.dta", replace



