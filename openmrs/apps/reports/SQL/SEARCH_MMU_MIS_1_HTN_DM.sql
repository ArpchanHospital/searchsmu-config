Select 
PatientCountPerVillage.city_village as 'Village',
TotalHtnDmStrokePatientConfirmed.CountOfPat as 'Total HTN, DM and Stroke Confirmed',
TotalFollowUpPatientSeenInThisVisit.TotalFollowUpCount as 'Number seem by MMU in this visit',
DMHTNPatientNeedingFollowUP.CountOfPat as 'Number needing follow up by MMU based on MMU physician evaluation',
DMHTNNumberSeenByMMUInThisVisit.TotalFollowUpCount as 'HTN or DM Patient seen by MMU in this visit',
DMHTNTotalPatientIdentifiedInVillage.CountOfPat as 'Total HTN or DM patients identified in the village who are eligible for treatment under MMU',
/*HTNPatientSeenInThisMonth.CountOfPat as 'HTN patients seen this month',*/
DMHTNPercentSeenThisMonth.PercentHTNPatSeen as '% of follow up HTN or DM patients seen this month',
NewDMHTNConfirmedPatient.CountOfPat as 'New HTN or DM patients seen in this visit',
DMHTNNumberOfPatientGivenMedByCHW.Count_Patient_Med_CHW as 'Number of patients whose medicines given to CHW as the pt did not/could not attend the clinic',
DMHTNPercentMedsGivenToCHW.PercentHTNCHW as '% number of patients whose medicines given to CHW',
DMHTNPatientAbsentInLastThreeVisits.CountOfAbsentPat as 'Number of patients who discontinued treatment from MMU',
DMHTNPercentPatientsDiscontinuedTreatment.PercentHTNDiscontinued as '% number of patients who discontinued treatment from MMU',
DMHTNPatientWithSideEffects.Count_Patient_ADR as 'HTN or DM patients reporting side effects due to medicines',
DMHTNPersentPatientWithSideEffects.PercentHTNPatientWithSideEffects as '% HTN or DM patients reporting side effects due to medicines',
DMHTNPatientWithSAE.Count_Patient_SAE as 'Serious adverse event due to HTN or DM medicines',
DMHTNPersentPatientWithSAE.PercentHTNPatientWithSideEffects as '% HTN or DM patients reporting SAE',
DMHTNPatientDeath.CountOfDeadPat as 'Number of HTN or DM patients whose deaths were reported this month',
DMHTNPersentPatientDeath.PercentHTNDead '% Number of HTN or DM patients deaths'
from 
(
/*Village*/
	Select PA.address4,PA.city_village, count(*) CountOfPatPerVill from person_address PA group by PA.city_village
) as PatientCountPerVillage
Left Join
(/*Total HTN, DM and Stroke Confirmed */
			Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
			from person_attribute pa 
			inner join person_attribute_type pt 
			on pa.person_attribute_type_id=pt.person_attribute_type_id 
			inner join person_address paddr 
			on paddr.person_id=pa.person_id 
			inner join concept_name cn 
			on cn.concept_id=pa.value 
			where pt.name in('htnConfirmed','strokeConfirmed','dmConfirmed')
			and cn.concept_name_type='FULLY_SPECIFIED'
			and cn.voided=0
			and cn.name='Yes'
			and cast(coalesce(pa.date_changed,pa.date_created) as date) < '#startDate#'
			Group by paddr.city_village
) as TotalHtnDmStrokePatientConfirmed
On TotalHtnDmStrokePatientConfirmed.city_village= PatientCountPerVillage.city_village
Left Join
(/*Number seen by MMU in this visit. Patient for which screening,initial and follow up forms were filled.*/
			Select paddr.city_village, Count(distinct o.person_id) TotalFollowUpCount from obs o
			inner join concept_name cname
			on o.concept_id=cname.concept_id
			inner join person_address paddr
			on paddr.person_id=o.person_id
			Where cname.name in ( 'DM Initial','HTN Initial','Stroke Initial',
            'DM Follow-up','Stroke Follow-Up','HTN Follow-Up', 'Screening Form') 
			and cname.concept_name_type='FULLY_SPECIFIED' 
            and o.voided=0
            and o.person_id not in 
            (/*Only patient who are present*/
					Select ino.person_id from obs ino
					inner join concept_name cn
					on cn.concept_id=ino.concept_id
					where cast(ino.obs_datetime as date) BETWEEN '2016-09-05' and '#endDate#'
					and cn.name ='Is the patient present?'
					and ino.value_coded in (select concept_id from concept_name where name ='No' and concept_name_type='FULLY_SPECIFIED')
					and cn.concept_name_type='SHORT'
                    and ino.voided=0
                    and ino.obs_group_id in (o.obs_id)
            )
            and cast(o.obs_datetime as date) BETWEEN '2016-09-05' and '#endDate#'
			Group by paddr.city_village
) as TotalFollowUpPatientSeenInThisVisit
On TotalFollowUpPatientSeenInThisVisit.city_village= PatientCountPerVillage.city_village
Left Join
(/*Number needing follow up by MMU based on MMU physician's evaluation */
			Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
			from person_attribute pa 
			inner join person_attribute_type pt 
			on pa.person_attribute_type_id=pt.person_attribute_type_id 
			inner join person_address paddr 
			on paddr.person_id=pa.person_id 
			inner join concept_name cn 
			on cn.concept_id=pa.value 
			where pt.name in ('htnConfirmed','dmConfirmed') 
			and cn.concept_name_type='FULLY_SPECIFIED'
			and cn.voided=0
			and cn.name='Yes'
			and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#startDate#'
			Group by paddr.city_village
) as DMHTNPatientNeedingFollowUP
On DMHTNPatientNeedingFollowUP.city_village= PatientCountPerVillage.city_village
Left Join
(
/*HTN Number seen by MMU in this visit*/
			Select paddr.city_village, Count(distinct o.person_id) TotalFollowUpCount from obs o
			inner join concept_name cname
			on o.concept_id=cname.concept_id
			inner join person_address paddr
			on paddr.person_id=o.person_id
			Where cname.name in ( 'HTN Initial','HTN Follow-Up','DM Initial','DM Follow-up') 
			and cname.concept_name_type='FULLY_SPECIFIED' 
            and o.voided=0
            and o.person_id not in 
            (/*Only patient who are present*/
					Select ino.person_id from obs ino
					inner join concept_name cn
					on cn.concept_id=ino.concept_id
					where cast(ino.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and cn.name ='Is the patient present?'
					and ino.value_coded in (select concept_id from concept_name where name ='No' and concept_name_type='FULLY_SPECIFIED')
					and cn.concept_name_type='SHORT'
                    and ino.voided=0
                    and ino.obs_group_id in (o.obs_id)
            )
            and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
			Group by paddr.city_village
) as DMHTNNumberSeenByMMUInThisVisit
on DMHTNNumberSeenByMMUInThisVisit.city_village=PatientCountPerVillage.city_village
Left Join
(
/*Total HTN patients identified in the village who are eligible for treatment under MMU.*/
			Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
			from person_attribute pa 
			inner join person_attribute_type pt 
			on pa.person_attribute_type_id=pt.person_attribute_type_id 
			inner join person_address paddr 
			on paddr.person_id=pa.person_id 
			inner join concept_name cn 
			on cn.concept_id=pa.value 
			where pt.name in ('htnConfirmed','dmConfirmed') 
			and cn.concept_name_type='FULLY_SPECIFIED'
			and cn.voided=0
			and cn.name='Yes'
			and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
			Group by paddr.city_village
) as DMHTNTotalPatientIdentifiedInVillage
on DMHTNTotalPatientIdentifiedInVillage.city_village =PatientCountPerVillage.city_village
/*Left Join
(
HTN patients seen this month
Select Innerpaddr.city_village,ifnull( Count(distinct o.person_id),0)+ifnull(
					(
						Select Count(distinct pa.person_id) TotalHTNConfirmed from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name in ('htnConfirmed','dmConfirmed')  
						and cn.concept_name_type='FULLY_SPECIFIED'
						and cn.voided=0
						and cn.name='Yes'
						and Innerpaddr.city_village=paddr.city_village
						and cast(coalesce(pa.date_changed,pa.date_created) as date) BETWEEN '#startDate#' and '#endDate#'
						Group by paddr.city_village
                    ),0) CountOfPat
			from obs o inner join concept_name cname
			on o.concept_id=cname.concept_id
			inner join person_address Innerpaddr
			on Innerpaddr.person_id=o.person_id
			Where cname.name in ( 'HTN Follow-Up') 
			and cname.concept_name_type='FULLY_SPECIFIED' 
            and o.voided=0
			and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
			Group by Innerpaddr.city_village
) as HTNPatientSeenInThisMonth
on HTNPatientSeenInThisMonth.city_village = PatientCountPerVillage.city_village
*/
Left Join
(
/*% of follow up HTN patients seen this month*/
					Select HTNFollowUPForAMonth.city_village, 
					ifnull(HTNFollowUPForAMonth.TotalHTNFollowUpCount,0)/ifnull(TotalHTNConfirmedTillDate.CountOfPat,0) *100 as PercentHTNPatSeen
                    from 
					(
						Select paddr.city_village, Count(distinct o.person_id) TotalHTNFollowUpCount from obs o
						inner join concept_name cname
						on o.concept_id=cname.concept_id
						inner join person_address paddr
						on paddr.person_id=o.person_id
						Where cname.name in ( 'HTN Initial','HTN Follow-Up','DM Initial','DM Follow-up') 
						and cname.concept_name_type='FULLY_SPECIFIED' 
						and o.voided=0
						and o.person_id not in 
						(/*Only patient who are present*/
								Select ino.person_id from obs ino
								inner join concept_name cn
								on cn.concept_id=ino.concept_id
								where cast(ino.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
								and cn.name ='Is the patient present?'
								and ino.value_coded in (select concept_id from concept_name where name ='No' and concept_name_type='FULLY_SPECIFIED')
								and cn.concept_name_type='SHORT'
								and ino.voided=0
								and ino.obs_group_id in (o.obs_id)
						)
						and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
						Group by paddr.city_village
					) as HTNFollowUPForAMonth
					inner join
					(	Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
						from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name in ('htnConfirmed','dmConfirmed')  
						and cn.concept_name_type='FULLY_SPECIFIED'
						and cn.voided=0
						and cn.name='Yes'
						and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
						Group by paddr.city_village 
                    ) as TotalHTNConfirmedTillDate
					on HTNFollowUPForAMonth.city_village=TotalHTNConfirmedTillDate.city_village
)DMHTNPercentSeenThisMonth
On DMHTNPercentSeenThisMonth.city_village = PatientCountPerVillage.city_village
Left Join
(/*New HTN patients seen in this visit */
			Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
			from person_attribute pa 
			inner join person_attribute_type pt 
			on pa.person_attribute_type_id=pt.person_attribute_type_id 
			inner join person_address paddr 
			on paddr.person_id=pa.person_id 
			inner join concept_name cn 
			on cn.concept_id=pa.value 
			where pt.name in ('htnConfirmed','dmConfirmed')  
			and cn.concept_name_type='FULLY_SPECIFIED'
			and cn.voided=0
			and cn.name='Yes'
			and cast(coalesce(pa.date_changed,pa.date_created) as date) BETWEEN '#startDate#' and '#endDate#'
			Group by paddr.city_village
) as NewDMHTNConfirmedPatient
On NewDMHTNConfirmedPatient.city_village= PatientCountPerVillage.city_village
Left Join
(
/*Number of patients whose medicines given to CHW as the pt did not/could not attend the clinic*/
					Select paddr.city_village, Count(distinct o.person_id) Count_Patient_Med_CHW
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('HTN Follow, Medicine dispensed to','DM Follow, Medicine dispensed to') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.voided=0
					and o.value_coded = (Select concept_id from concept_name where name ='CHW' and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'HTN Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					) 
					group by paddr.city_village
) as DMHTNNumberOfPatientGivenMedByCHW
on DMHTNNumberOfPatientGivenMedByCHW.city_village=PatientCountPerVillage.city_village
Left Join
(
/*% Number of patients whose medicines given to CHW as the pt did not/could not attend the clinic*/
					Select HTNFollowUPForAMonth.city_village, 
					ifnull(HTNFollowUPForAMonth.Count_Patient_Med_CHW,0)/ifnull(TotalHTNConfirmedTillDate.CountOfPat,0) *100 as PercentHTNCHW
                    from 
					(
						Select paddr.city_village, Count(distinct o.person_id) Count_Patient_Med_CHW
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('HTN Follow, Medicine dispensed to','DM Follow, Medicine dispensed to') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.voided=0
					and o.value_coded = (Select concept_id from concept_name where name ='CHW' and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'HTN Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					) 
					group by paddr.city_village
					) as HTNFollowUPForAMonth
					inner join
					(	Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
						from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name in ('htnConfirmed','dmConfirmed') 
						and cn.concept_name_type='FULLY_SPECIFIED'
						and cn.voided=0
						and cn.name='Yes'
						and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
						Group by paddr.city_village 
                    ) as TotalHTNConfirmedTillDate
					on HTNFollowUPForAMonth.city_village=TotalHTNConfirmedTillDate.city_village
)DMHTNPercentMedsGivenToCHW
On DMHTNPercentMedsGivenToCHW.city_village = PatientCountPerVillage.city_village
Left Join
(
/*HTN patients reporting side effects due to medicines*/
					Select paddr.city_village, Count(distinct o.person_id) Count_Patient_ADR
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in ('HTN Follow, ADRs','DM Follow, ADRs') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.value_coded not in (Select concept_id from concept_name where name in ('NONE','SAE') and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and o.voided=0
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'HTN Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					)
					group by paddr.city_village
)DMHTNPatientWithSideEffects
On DMHTNPatientWithSideEffects.city_village = PatientCountPerVillage.city_village
Left Join
(
/*% HTN patients reporting side effects due to medicines*/
					Select TotalHTNConfirmedTillDate.city_village, 
					ifnull(HTNPatientWithSideEffects.Count_Patient_ADR,0)/ifnull(TotalHTNConfirmedTillDate.CountOfPat,0) *100 as PercentHTNPatientWithSideEffects
                    from 
					(
					/*HTN patients reporting side effects due to medicines*/
					Select paddr.city_village, Count(distinct o.person_id) Count_Patient_ADR
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in ('HTN Follow, ADRs','DM Follow, ADRs') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.value_coded not in (Select concept_id from concept_name where name in ('NONE','SAE') and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and o.voided=0
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'HTN Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					)
					group by paddr.city_village
					)HTNPatientWithSideEffects
					inner join
					(	Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
						from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name in ('htnConfirmed','dmConfirmed') 
						and cn.concept_name_type='FULLY_SPECIFIED'
						and cn.voided=0
						and cn.name='Yes'
						and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
						Group by paddr.city_village 
                    ) as TotalHTNConfirmedTillDate
					on HTNPatientWithSideEffects.city_village=TotalHTNConfirmedTillDate.city_village
)DMHTNPersentPatientWithSideEffects
On DMHTNPersentPatientWithSideEffects.city_village = PatientCountPerVillage.city_village
Left join
(
/*Serious adverse event due to HTN medicines*/
					Select paddr.city_village, Count(distinct o.person_id) Count_Patient_SAE
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in ('HTN Follow, ADRs','DM Follow, ADRs') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.value_coded in (Select concept_id from concept_name where name ='SAE' and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and o.voided=0
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'HTN Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					)
					group by paddr.city_village
) as DMHTNPatientWithSAE
on DMHTNPatientWithSAE.city_village=PatientCountPerVillage.city_village
Left Join
(
/*% HTN patients reporting SAE due to medicines*/
					Select TotalHTNConfirmedTillDate.city_village, 
					ifnull(HTNPatientWithSAE.Count_Patient_SAE,0)/ifnull(TotalHTNConfirmedTillDate.CountOfPat,0) *100 as PercentHTNPatientWithSideEffects
                    from 
					(
					/*Serious adverse event due to HTN medicines*/
					Select paddr.city_village, Count(distinct o.person_id) Count_Patient_SAE
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in ('HTN Follow, ADRs','DM Follow, ADRs') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.value_coded in (Select concept_id from concept_name where name ='SAE' and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and o.voided=0
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'HTN Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					)
					group by paddr.city_village
					) as HTNPatientWithSAE
					inner join
					(	Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
						from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name in ('htnConfirmed','dmConfirmed')  
						and cn.concept_name_type='FULLY_SPECIFIED'
						and cn.voided=0
						and cn.name='Yes'
						and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
						Group by paddr.city_village 
                    ) as TotalHTNConfirmedTillDate
					on HTNPatientWithSAE.city_village=TotalHTNConfirmedTillDate.city_village
)DMHTNPersentPatientWithSAE
On DMHTNPersentPatientWithSAE.city_village = PatientCountPerVillage.city_village
Left Join
(
/*Number of HTN patients whose deaths were reported this month.*/
				Select paddr.city_village,count(distinct o.person_id) CountOfDeadPat 
                from obs o
				inner join concept_name cname
				on o.concept_id=cname.concept_id
				inner join person_address paddr
				on paddr.person_id=o.person_id
                inner join person p
                on p.person_id = o.person_id
				Where cname.name in ('HTN Follow-Up' ,'DM Follow-up')
				and cname.concept_name_type='FULLY_SPECIFIED'
                and p.dead = 1
                and o.voided=0
                and cast(p.death_date as date) BETWEEN '#startDate#' and '#endDate#' 
				and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
                group by paddr.city_village
) as DMHTNPatientDeath
on DMHTNPatientDeath.city_village=PatientCountPerVillage.city_village
Left Join
(
/*% HTN patients Dead*/
					Select TotalHTNConfirmedTillDate.city_village, 
					ifnull(HTNPatientDeath.CountOfDeadPat,0)/ifnull(TotalHTNConfirmedTillDate.CountOfPat,0) *100 as PercentHTNDead
                    from 
					(
						/*Number of HTN patients whose deaths were reported this month.*/
						Select paddr.city_village,count(distinct o.person_id) CountOfDeadPat 
						from obs o
						inner join concept_name cname
						on o.concept_id=cname.concept_id
						inner join person_address paddr
						on paddr.person_id=o.person_id
						inner join person p
						on p.person_id = o.person_id
						Where cname.name in ('HTN Follow-Up' ,'DM Follow-up')
						and cname.concept_name_type='FULLY_SPECIFIED'
						and p.dead = 1
						and o.voided=0
						and cast(p.death_date as date) BETWEEN '#startDate#' and '#endDate#' 
						and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
						group by paddr.city_village
					) as HTNPatientDeath
					inner join
					(	Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
						from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name in ('htnConfirmed','dmConfirmed')  
						and cn.concept_name_type='FULLY_SPECIFIED'
						and cn.voided=0
						and cn.name='Yes'
						and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
						Group by paddr.city_village 
                    ) as TotalHTNConfirmedTillDate
					on HTNPatientDeath.city_village=TotalHTNConfirmedTillDate.city_village
)DMHTNPersentPatientDeath
On DMHTNPersentPatientDeath.city_village = PatientCountPerVillage.city_village
left join
(
				Select city_village, sum(case when NoOfTimesAbsent >= 3 then 1  end ) 'CountOfAbsentPat'
				from (
				/*Getting the count for village and patient who were absent in last three visits*/
						Select paddr.city_village, o.person_id, count(o.obs_id) NoOfTimesAbsent 
						from obs o inner join concept_name cname
							on o.concept_id=cname.concept_id
							inner join person_address paddr
							on paddr.person_id=o.person_id
							Where cname.name in ('HTN Follow, Is the patient present?','DM Follow, Is the patient present?') 
							and cname.concept_name_type='FULLY_SPECIFIED'
							and o.value_coded  in (Select concept_id from concept_name where name in ('NO') and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
							and o.voided=0
							and date(o.date_created) in ( /*Getting the last three visit dates for a visit location using dense rank*/
											Select LastThreeVisitPerLocation.dcreated
											from (
													SELECT  Location_id,dcreated,denseRank 
													FROM
													(
														SELECT  Location_id,
														dcreated,
														@rn1 := if(@pk1=Location_id, if(@sal=dcreated, @rn1, @rn1+@val),1) as denseRank,
														@val := if(@pk1=Location_id, if(@sal=dcreated, @val+1, 1),1) as value,
														@pk1 := Location_id,
														@sal := dcreated     
														FROM
														(
															SELECT  distinct addr.city_village as Location_id,
															date(o.date_created) as dcreated
															FROM    obs o inner join person_address addr
															on o.person_id=addr.person_id
															ORDER BY Location_id,dcreated desc
														) A
													) B
													where denseRank <=3
											) LastThreeVisitPerLocation 
											where LastThreeVisitPerLocation.Location_id = paddr.city_village
						) group by paddr.city_village, o.person_id

				) ab group by ab.city_village

) DMHTNPatientAbsentInLastThreeVisits
on DMHTNPatientAbsentInLastThreeVisits.city_village=PatientCountPerVillage.city_village
Left Join
(
/*% Number of patients who discontinued treatment from MMU*/
					Select TotalHTNConfirmedTillDate.city_village, 
					ifnull(HTNPatientAbsentInLastThreeVisits.CountOfAbsentPat,0)/ifnull(TotalHTNConfirmedTillDate.CountOfPat,0) *100 as PercentHTNDiscontinued
                    from 
					(
						Select city_village, sum(case when NoOfTimesAbsent >= 3 then 1  end ) 'CountOfAbsentPat'
						from (
						/*Getting the count for village and patient who were absent in last three visits*/
								Select paddr.city_village, o.person_id, count(o.obs_id) NoOfTimesAbsent 
								from obs o inner join concept_name cname
									on o.concept_id=cname.concept_id
									inner join person_address paddr
									on paddr.person_id=o.person_id
									Where cname.name in ('HTN Follow, Is the patient present?','DM Follow, Is the patient present?') 
									and cname.concept_name_type='FULLY_SPECIFIED'
									and o.value_coded  in (Select concept_id from concept_name where name in ('NO') and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
									and o.voided=0
									and date(o.date_created) in ( /*Getting the last three visit dates for a visit location using dense rank*/
													Select LastThreeVisitPerLocation.dcreated
													from (
															SELECT  Location_id,dcreated,denseRank 
															FROM
															(
																SELECT  Location_id,
																dcreated,
																@rn1 := if(@pk1=Location_id, if(@sal=dcreated, @rn1, @rn1+@val),1) as denseRank,
																@val := if(@pk1=Location_id, if(@sal=dcreated, @val+1, 1),1) as value,
																@pk1 := Location_id,
																@sal := dcreated     
																FROM
																(
																	SELECT  distinct addr.city_village as Location_id,
																	date(o.date_created) as dcreated
																	FROM    obs o inner join person_address addr
																	on o.person_id=addr.person_id
																	ORDER BY Location_id,dcreated desc
																) A
															) B
															where denseRank <=3
													) LastThreeVisitPerLocation 
													where LastThreeVisitPerLocation.Location_id = paddr.city_village
								) group by paddr.city_village, o.person_id

						) ab group by ab.city_village
					) HTNPatientAbsentInLastThreeVisits
					inner join
					(	Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
						from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name in ('htnConfirmed','dmConfirmed')  
						and cn.concept_name_type='FULLY_SPECIFIED'
						and cn.voided=0
						and cn.name='Yes'
						and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
						Group by paddr.city_village 
                    ) as TotalHTNConfirmedTillDate
					on HTNPatientAbsentInLastThreeVisits.city_village=TotalHTNConfirmedTillDate.city_village
)DMHTNPercentPatientsDiscontinuedTreatment
On DMHTNPercentPatientsDiscontinuedTreatment.city_village = PatientCountPerVillage.city_village
order by PatientCountPerVillage.address4,PatientCountPerVillage.city_village;