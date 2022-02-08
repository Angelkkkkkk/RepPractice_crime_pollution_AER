global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data
global figures C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Figures


use "$data/chicago_part1_crimes.dta",clear
	gen majorcat="violent" if inlist(fbicode,"01A","02","04A","04B")
	replace majorcat = "property" if !inlist(fbicode,"01A","02","04A","04B")
	
	gen crimecount =1
	collapse (sum) crimecount, by(year majorcat)
	
*Normalize # of crimes in 2001 ==100
	bys majorcat: egen crime2001 = max(crimecount)
	gen normcrime = 100*crimecount/crime2001
	
	reshape wide crimecount crime2001 normcrime, i(year) j(majorcat) string
	
*bys year majorcat: gen annualmajcat =_N
*bys majorcat: egen crime2001 = max(annualmajcat)
*bys majorcat: gen normanncrime = 100*annualmajcat/crime2001
	
	
* formatting graph
local labopts "ylabel(, labsize(small) angle(horizontal)) xlabel(2000(4)2012, labsize(vsmall)) ytitle("Annual Crime, 2001 total==100", size(small)) xtitle("Year", size(small)) xscale(range(2000 2013))"


*Plot
twoway connected normcrimeproperty normcrimeviolent year, sort ///
legend(order(1 "Property" 2 "Violent")) lp(solid dash) `labopts'

	graph export "$figures/chicago_annual_bymajcat.png", replace
