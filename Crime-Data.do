
	
	cd "C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Raw-Data\"
	insheet using "chicago_crime.csv"
	
	keep if year >=2001 & year <=2012
	
*generate time variables
	rename date stringdate
	gen double datatime = clock(stringdate, "MD20Yhms")
	rename datatime datetime
	format datetime %tc
	lab var datetime "Dates listed in MD20Yhms format"
	
	gen date = dofc(datetime) //converts a %td [17,126 (21nov2006) ] value to a %tc value [ 1,479,686,400,000 (21nov2006 00:00:00)]
	lab var date "Dates listed in MD20Y format"
	gen hour = hh(datetime)
	gen minutes = mm(datetime)
	gen seconds = ss(datetime)
	
*generate dummy for crimes
*FBI code inficates the crime classification as outlined 
*check https://gis.chicagopolice.org/pages/crime_details

*aggregate below crimes into violent crimes (homicide,forcible rape, assault and battery) 
	gen part1 = inlist(fbicode,"01A","02","03","04A", "04B", "05","06","07","09")==1
	gen violent = inlist(fbicode, "01A", "02", "04A", "04B","08A","08B")==1
*property crimes (burglary, robbery, larceny, arson, and grand theft auto).
*gen procime == "1" if inlist(fbicode, "05", "03", "06", "09", "07")

* FIX FBI CODE FOR ARSON;
	replace fbicode = "08" if fbicode == "09";
	
	compress

	drop stringdate
	preserve
	keep if part1 ==1
	save "C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data\chicago_part1_crimes.dta", replace

	restore
	drop block description locationdescription beat district ward communityarea xcoordinate ycoordinate location
	save "C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data\chicago_all_crimes.dta", replace
	