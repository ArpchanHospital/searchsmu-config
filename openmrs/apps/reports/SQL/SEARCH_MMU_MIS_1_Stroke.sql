Select 
PatientCountPerVillage.city_village as 'Village',
StrokePatientNeedingFollowUP.CountOfPat as 'Number needing follow up by MMU based on MMU physician evaluation',
StrokeNumberSeenByMMUInThisVisit.TotalStrokeFollowUpCount as 'Number seen by MMU in this visit',
StrokeTotalPatientIdentifiedInVillage.CountOfPat as 'Total Stroke patients identified in the village who are eligible for treatment under MMU',
StrokePatientSeenInThisMonth.CountOfPat as 'Stroke patients seen this month',
StrokePercentSeenThisMonth.PercentStrokePatSeen as '% of follow up Stroke patients seen this month',
StrokeNumberOfPatientGivenMedByCHW.Count_Patient_Med_CHW as 'Number of patients whose medicines given to CHW as the pt did not/could not attend the clinic',
StrokePatientAbsentInLastThreeVisits.CountOfAbsentPat as 'Number of patients who discontinued treatment from MMU',
StrokePatientWithSideEffects.Count_Patient_ADR as 'Stroke patients reporting side effects due to medicines',
StrokePatientWithSAE.Count_Patient_SAE as 'Serious adverse event due to Stroke medicines',
StrokePatientDeath.CountOfDeadPat as 'Number of Stroke patients whose deaths were reported this month'
from 
(
/*Village*/
	Select PA.city_village, count(*) CountOfPatPerVill from person_address PA group by PA.city_village
) as PatientCountPerVillage
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
			where pt.name ='strokeConfirmed' 
			and cn.concept_name_type='FULLY_SPECIFIED'
			and cn.voided=0
			and cn.name='Yes'
			and cast(coalesce(pa.date_changed,pa.date_created) as date) < '#startDate#'
			Group by paddr.city_village
) as StrokePatientNeedingFollowUP
On StrokePatientNeedingFollowUP.city_village= PatientCountPerVillage.city_village
Left Join
(
/*number seen by MMU in this visit*/
			Select paddr.city_village, Count(distinct o.person_id) TotalStrokeFollowUpCount from obs o
			inner join concept_name cname
			on o.concept_id=cname.concept_id
			inner join person_address paddr
			on paddr.person_id=o.person_id
			Where cname.name in ( 'Stroke Follow-Up', 'Screening Form') 
			and cname.concept_name_type='FULLY_SPECIFIED' 
			and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
			Group by paddr.city_village
) as StrokeNumberSeenByMMUInThisVisit
on StrokeNumberSeenByMMUInThisVisit.city_village=PatientCountPerVillage.city_village
Left Join
(
/*Total Stroke patients identified in the village who are eligible for treatment under MMU.*/
			Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
			from person_attribute pa 
			inner join person_attribute_type pt 
			on pa.person_attribute_type_id=pt.person_attribute_type_id 
			inner join person_address paddr 
			on paddr.person_id=pa.person_id 
			inner join concept_name cn 
			on cn.concept_id=pa.value 
			where pt.name ='strokeConfirmed' 
			and cn.concept_name_type='FULLY_SPECIFIED'
			and cn.voided=0
			and cn.name='Yes'
			and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
			Group by paddr.city_village
) as StrokeTotalPatientIdentifiedInVillage
on StrokeTotalPatientIdentifiedInVillage.city_village =PatientCountPerVillage.city_village
Left Join
(
/*Stroke patients seen this month*/
Select Innerpaddr.city_village,ifnull( Count(distinct o.person_id),0)+ifnull(
					(
						Select Count(distinct pa.person_id) TotalHTNConfirmed from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name ='strokeConfirmed' 
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
			Where cname.name in ( 'Stroke Follow-Up') 
			and cname.concept_name_type='FULLY_SPECIFIED' 
			and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
			Group by Innerpaddr.city_village
) as StrokePatientSeenInThisMonth
on StrokePatientSeenInThisMonth.city_village = PatientCountPerVillage.city_village
Left Join
(
/*% of follow up Stroke patients seen this month*/
					Select StrokeFollowUPForAMonth.city_village, 
					ifnull(StrokeFollowUPForAMonth.TotalStrokeFollowUpCount,0)/ifnull(TotalStrokeConfirmedTillDate.CountOfPat,0) *100 as PercentStrokePatSeen
                    from 
					(
						Select paddr.city_village, Count(distinct o.person_id) TotalStrokeFollowUpCount from obs o
						inner join concept_name cname
						on o.concept_id=cname.concept_id
						inner join person_address paddr
						on paddr.person_id=o.person_id
						Where cname.name in ( 'Stroke Follow-Up') 
						and cname.concept_name_type='FULLY_SPECIFIED' 
						and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
						Group by paddr.city_village 
					) as StrokeFollowUPForAMonth
					inner join
					(	Select paddr.city_village,Count(distinct pa.person_id) CountOfPat
						from person_attribute pa 
						inner join person_attribute_type pt 
						on pa.person_attribute_type_id=pt.person_attribute_type_id 
						inner join person_address paddr 
						on paddr.person_id=pa.person_id 
						inner join concept_name cn 
						on cn.concept_id=pa.value 
						where pt.name ='strokeConfirmed' 
						and cn.concept_name_type='FULLY_SPECIFIED'
						and cn.voided=0
						and cn.name='Yes'
						and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
						Group by paddr.city_village 
                    ) as TotalStrokeConfirmedTillDate
					on StrokeFollowUPForAMonth.city_village=TotalStrokeConfirmedTillDate.city_village
)StrokePercentSeenThisMonth
On StrokePercentSeenThisMonth.city_village = PatientCountPerVillage.city_village
Left Join
(
/*Number of patients whose medicines given to CHW as the pt did not/could not attend the clinic*/
					Select paddr.city_village, Count(distinct o.person_id) Count_Patient_Med_CHW
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('Stroke Follow, Medicine dispensed to') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.voided=0
					and o.value_coded = (Select concept_id from concept_name where name ='CHW' and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'Stroke Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					) 
					group by paddr.city_village
) as StrokeNumberOfPatientGivenMedByCHW
on StrokeNumberOfPatientGivenMedByCHW.city_village=PatientCountPerVillage.city_village
Left Join
(
/*Stroke patients reporting side effects due to medicines*/
					Select paddr.city_village, Count(distinct o.person_id) Count_Patient_ADR
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in ('Stroke Follow, ADRs') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.value_coded not in (Select concept_id from concept_name where name in ('NONE','SAE') and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and o.voided=0
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'Stroke Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					)
					group by paddr.city_village
)StrokePatientWithSideEffects
On StrokePatientWithSideEffects.city_village = PatientCountPerVillage.city_village
Left join
(
/*Serious adverse event due to Stroke medicines*/
					Select paddr.city_village, Count(distinct o.person_id) Count_Patient_SAE
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in ('Stroke Follow, ADRs') 
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.value_coded in (Select concept_id from concept_name where name ='SAE' and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
					and o.voided=0
					and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name = 'Stroke Follow-Up' 
												and cname.concept_name_type='FULLY_SPECIFIED'
												and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					)
					group by paddr.city_village
) as StrokePatientWithSAE
on StrokePatientWithSAE.city_village=PatientCountPerVillage.city_village
Left Join
(
/*Number of Stroke patients whose deaths were reported this month.*/
				Select paddr.city_village,count(distinct o.person_id) CountOfDeadPat 
                from obs o
				inner join concept_name cname
				on o.concept_id=cname.concept_id
				inner join person_address paddr
				on paddr.person_id=o.person_id
                inner join person p
                on p.person_id = o.person_id
				Where cname.name = 'Stroke Follow-Up' 
				and cname.concept_name_type='FULLY_SPECIFIED'
                and p.dead = 1
                and cast(p.death_date as date) BETWEEN '#startDate#' and '#endDate#' 
				and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
                group by paddr.city_village
) as StrokePatientDeath
on StrokePatientDeath.city_village=PatientCountPerVillage.city_village
left join
(
				Select city_village, sum(case when NoOfTimesAbsent >= 3 then 1 else 0 end ) 'CountOfAbsentPat'
				from (
				/*Getting the count for village and patient who were absent in last three visits*/
						Select paddr.city_village, o.person_id, count(o.obs_id) NoOfTimesAbsent 
						from obs o inner join concept_name cname
							on o.concept_id=cname.concept_id
							inner join person_address paddr
							on paddr.person_id=o.person_id
							Where cname.name in ('Stroke Follow, Is the patient absent?') 
							and cname.concept_name_type='FULLY_SPECIFIED'
							and o.value_coded  in (Select concept_id from concept_name where name in ('YES') and cname.concept_name_type='FULLY_SPECIFIED' and voided=0)
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
												SELECT  distinct Location_id,
														
														date(date_created) as dcreated
												FROM    visit
												ORDER BY Location_id,dcreated desc
												) A
											) B
											where denseRank <=3
											) LastThreeVisitPerLocation inner join location loc on loc.location_id=LastThreeVisitPerLocation.Location_id
											where loc.address4 = paddr.address4
						) group by paddr.city_village, o.person_id

				) ab group by ab.city_village

) StrokePatientAbsentInLastThreeVisits
on StrokePatientAbsentInLastThreeVisits.city_village=PatientCountPerVillage.city_village;