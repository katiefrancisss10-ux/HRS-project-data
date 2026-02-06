*Cleaned up file
*****************************************************************************/
* Project: HRS Data Cleaning & Subsetting
* Data Source: RAND Health and Retirement Study
* Purpose: Prepare analytic dataset for health, stress,
*          and sleep analysis
* Notes: 
*	- Raw HRS data are not included due to data use restrictions
*	- Users must update file paths before running
****************************************************

*Environment Setup
clear all
global drop _all
label drop _all

*Set file path where RAND HRS data is stored
global rand_hrs C:\Users\katie\OneDrive\Econ_402\capstone
cd $rand_hrs

*Start log file
capture log close
log using subset_randhrs, replace text

*Import the rand longitudinal file
// use $rand_hrs\randhrs1992_2022v1, clear

* This code specifies specific variables to import from the dataset.
* The variable list inlcudes the variables you specified
* plus any activity, sleep, and stress variable that came up in a keyword search 
* along with some additional demographic data */

use hhidpn hacohort inw* *iwstat raspct ///
rabyear rabmonth rabdate radyear radmonth raddate *agey_e  ///
ragender raracem rahispan *cenreg *cendiv *work *retdtwv /// 
*shlt *shltc *shltcf *lbonchrstr *jstres ///
*ltactf *vgactf *lhtact *vigact *vgactp *ltactx *mdactx *vgactx *ltactp ///
*sleeprt *sleepx *sleepr *sleepfal *sleepwkn *sleepwke ///
*sleepq *sleepe *sleeps *sleepsn *sleepbr *sleept ///
using $rand_hrs\randhrs1992_2022v1, clear

* Display the current number of variables in dataset
display c(k)

*Sort and order data to preferences
sort hhidpn
order hhidpn hacohort inw* *iwstat 

/***Reshape dataset from wide to long format*/ 
reshape long inw r@iwstat s@iwstat r@shlt s@shlt r@agey_e s@agey_e r@cenreg s@cenreg r@cendiv s@cendiv r@work r@retdtwv r@shltc s@shltc r@shltcf s@shltcf r@lbonchrstr s@lbonchrstr r@jstres s@jstres r@ltactf s@ltactf r@vgactf s@vgactf r@lhtact s@lhtact r@vigact s@vigact r@vgactp s@vgactp r@ltactx s@ltactx r@mdactx s@mdactx r@vgactx s@vgactx r@ltactp s@ltactp r@sleeprt s@sleeprt r@sleepx s@sleepx r@sleepr s@sleepr r@sleepfal s@sleepfal r@sleepwkn s@sleepwkn r@sleepwke s@sleepwke r@sleepq s@sleepq r@sleepe s@sleepe r@sleeps s@sleeps r@sleepsn s@sleepsn r@sleepbr s@sleepbr r@sleept s@sleept, i(hhidpn) j(wave)

*Drop variables with spouse prefix
drop s*

*Save intermediate dataset
save subset_randhrs, replace
use subset_randhrs, clear

*Format date variables
format %td rabdate raddate

*Sort data by person and wave
sort hhidpn wave

*Order data to your preferences
order hhidpn wave inw riwstat hacohort ragey_e respagey_e rabmonth rabyear rabdate radmonth radyear raddate raspct ragender rahispan raracem  recendiv recenreg 

tab inw riwstat

//INCLUSION CRITERIA
*Including people in at least three waves 
by hhidpn: egen countinw = count(inw) if inw==1
bysort hhidpn: egen count_inw = max(countinw)
drop if count_inw < 3 //(at least 6 year time period)

*Individual must have worked in their lifetime
bysort hhidpn: egen max_rwork = max(rwork)
drop if max_rwork ==0 //(everyone who never worked has been dropped)

*identifying what was the last worked wave
bysort hhidpn: egen maxworkinw = max(wave) if rwork==1

*net from https://www.sealedenvelope.com/
xfill maxworkinw , i(hhidpn)
drop if wave <= maxworkinw
*dropping people who are currently working (only focusing on currently retired - done)

*******************
*Declare panel data
xtset hhidpn wave

**Create a new variable for frequency (more than once a week)
gen freqPA = .

replace rmdactx =. if rmdactx == .d
replace rmdactx =. if rmdactx == .j
replace rmdactx =. if rmdactx == .m
replace rmdactx =. if rmdactx == .r

replace rltactx =. if rltactx == .d
replace rltactx =. if rltactx == .j
replace rltactx =. if rltactx == .m
replace rltactx =. if rltactx == .r

replace rvgactx =. if rvgactx == .d
replace rvgactx =. if rvgactx == .j
replace rvgactx =. if rvgactx == .m
replace rvgactx =. if rvgactx == .r

*1
replace freqPA=1 if rltactx <=2 & rltactx!=.
replace freqPA=1 if rmdactx <=2 & rmdactx!=. & freqPA ==.
replace freqPA=1 if rvgactx <=2 & rvgactx!=. & freqPA ==.
br freqPA rltactx rmdactx rvgactx
*0
replace freqPA = 0 if freqPA==. & !mi(rltactx,rmdactx,rvgactx)

replace freqPA = 0 if freqPA==. & !mi(rltactx)
replace freqPA = 0 if freqPA==. & !mi(rmdactx)
replace freqPA = 0 if freqPA==. & !mi(rvgactx)
*1 = activity more than once a week
*0 = activity less than once a week

//creating low PA for easier readability (coding bad thing as higher value)
gen lowfreqPA=1 if freqPA==0
replace lowfreqPA=0 if freqPA==1

//INTENSITY PA
gen light1 = 0 if rltactx ==5
replace light1 =1 if rltactx!=5 & !mi(rltactx)

gen moderate1 = 0 if rmdactx ==5
replace moderate1 =1 if rmdactx!=5 & !mi(rmdactx)

gen vig1 = 0 if rvgactx ==5
replace vig1 =1 if rvgactx!=5 & !mi(rvgactx)

gen noPA=1 if rltactx==5 & rmdactx==5 & rvgactx==5
replace noPA=0 if light1==1 | moderate1==1 | vig1==1

*0 = none/light intensity and 1 = mod/vig intensity
gen intensityPA=.
replace intensityPA=0 if light1 ==1 
replace intensityPA=1 if moderate1 ==1 | vig1 ==1 
replace intensityPA=0 if noPA==1

*replacing missing values for outcome variable
replace rsleepr =. if rsleepr == .d
replace rsleepr =. if rsleepr == .j
replace rsleepr =. if rsleepr == .m
replace rsleepr =. if rsleepr == .r
replace rsleepr =. if rsleepr == .s

//recoding stress variable
recode rlbonchrstr (0 = 0 none) (1 2 3 4 5 6 7 8 = 1 stress), gen(stress) label(stress)
order rlbonchrstr stress

*--- Summarize key variables
estpost summarize wave rsleepr freqPA intensityPA stress rshlt ragey_e ragender raracem 

rename rsleepr restless
rename rshlt health
rename ragey_e age
rename ragender gender
rename raracem race

* Create a clean, no-dash summary statistics table
esttab . using "sstats.rtf", ///
cells("mean(fmt(3)) sd(fmt(3)) min(fmt(2)) max(fmt(2)) count(fmt(0))") ///
label noobs nonum collabels("Mean" "Std. Dev." "Min" "Max" "N") ///
title("Table 1. Summary Statistics for Retiree Sample (HRS 1992–2022)") ///
replace

eststo clear
*PREFERRED MODEL
*NO stress
eststo m1: xtlogit restless freqPA i.health age i.wave, fe or

eststo m2: xtlogit restless intensityPA i.health age i.wave, fe or

eststo m3: xtlogit restless freqPA intensityPA i.health age i.wave, fe or

*Everything
eststo m4: xtlogit restless freqPA intensityPA stress i.health age i.wave, fe or 

*--- Export both tables
esttab m1 m2 m3 m4 using "logitresults.rtf", eform ///
b(3) p(3) star(* 0.1 ** 0.05 *** 0.01) ///
stats(N r2_p, fmt(%9.0g 3) labels()) ///
order(freqPA intensityPA stress health age wave) ///
title("Table 2: Fixed-Effects Logistic Regression — Odds Ratios") ///
drop(*wave* age) ///
mtitles() ///
note("Robust standard errors in parentheses. Odds ratios are exponentiated coefficients.") ///
replace

*PATHWAY DIAGRAM USING REGRESSIONS
*PA on sleep (B)
xtlogit restless freqPA intensityPA i.health age i.wave, fe
*a = -0.176 (intensityPA)

*Stress on sleep (C)
xtlogit restless stress i.health age i.wave, fe
*c = 0.32 (stress)

*PA on stress (A)
xtologit stress freqPA intensityPA i.health i.wave
*b = -0.541 (intensityPA)
*TOTAL EFFECT OF PA ON SLEEP = -0.541 + (-0.176*0.32) = -0.597

*w/ regressions (although not ideal, it shows relatively the same effects as the logit making it okay for robustness??)
*PA on sleep (B) 
eststo m5: xtreg restless freqPA intensityPA i.health age i.gender i.race, vce(r)
*for respondents who engaged in moderate-vigorous physical activity we see a 4% reduction in restless sleep. (compared to those who did no-light activity)
*COMPARE TO STUDY DONE
esttab m5 using "pathwaybresults.rtf", ///
b(3) p(3) star(* 0.1 ** 0.05 *** 0.01) ///
stats(N r2_p, fmt(%9.0g 3) labels()) ///
order(freqPA intensityPA health age) ///
title("Table 3: Pathway(B) Panel Regression") ///
mtitles() ///
drop(*gender* *race*)

*Stress on sleep (C)
eststo m6: xtreg restless stress i.health age i.gender i.race, vce(r) 
*respondents who are stressed are 9% more likely to experience restless sleep
*COMPARE TO STUDY DONE
*for respondents who engaged in moderate-vigorous physical activity we see a 4% reduction in restless sleep. (compared to those who did no-light activity)
*COMPARE TO STUDY DONE
esttab m6 using "pathwaycresults.rtf", ///
b(3) p(3) star(* 0.1 ** 0.05 *** 0.01) ///
stats(N r2_p, fmt(%9.0g 3) labels()) ///
order(restless stress health age) ///
title("Table 4: Pathway(C) Panel Regression") ///
mtitles() ///
drop(*gender* *race*)

*PA on stress (A)
eststo m7: xtreg stress freqPA intensityPA i.health age i.gender i.race, vce(r)
*for respondents who engaged in moderate-vigorous physical activity we see a 7% reduction in stress. (compared to those who did no-light activity)
esttab m7 using "pathwayaresults.rtf", ///
b(3) p(3) star(* 0.1 ** 0.05 *** 0.01) ///
stats(N r2_p, fmt(%9.0g 3) labels()) ///
order(freqPA intensityPA health age) ///
title("Table 5: Pathway(C) Panel Regression") ///
mtitles() ///
drop(*gender* *race*)

*ROBUSTNESS 
/*gsem (stress <- freqPA intensityPA rshlt ragey_e) ///
     (rsleepr <- stress freqPA intensityPA rshlt ragey_e), ///
     family(bernoulli) link(logit)

eststo gsem_model
esttab gsem_model using "gsem_results.rtf", ///
    replace ///
    b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
    title("GSEM Results: Mediation of Stress between Physical Activity and Sleep Quality") ///
    label ///
    mtitles("Logit Coefficients") ///
    alignment(D)*/
	 
save subset_randhrs, replace
use subset_randhrs, clear

log close
