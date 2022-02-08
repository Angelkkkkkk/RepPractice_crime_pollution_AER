global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data
global figures C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Figures



use "$data/chicago_part1_crimes.dta",clear

	gen majorcat="violent" if inlist(fbicode,"01A","02","04A","04B")
	replace majorcat = "property" if !inlist(fbicode,"01A","02","04A","04B")

	graph twoway histogram hour if majorcat=="violent", ///
	fraction gap(0) discrete ///
	xlabel(0(4)24) ///
	xscale(range(0 24)) ///
	ytitle("Fraction of Crimes") ///
	xtitle("Hour of Day") /// 
	title("Violent Crimes") 
	
	graph export "$figures/hourofdayviolent.png", replace
	
	graph twoway histogram hour if majorcat=="property", ///
	fraction gap(0) discrete ///
	xlabel(0(4)24) ///
	xscale(range(0 24)) ///
	ytitle("Fraction of Crimes") ///
	xtitle("Hour of Day") /// 
	title("Property Crimes") 
	
	graph export "$figures/hourofdayprorperty.png", replace
	