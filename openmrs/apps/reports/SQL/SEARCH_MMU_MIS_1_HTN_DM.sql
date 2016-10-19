Select 
PatientCountPerVillage.city_village as 'Village',
HTNDMPatientNeedingFollowUP.CountOfPat as 'Number needing follow up by MMU based on MMU physician evaluation',
HTNDMNumberSeenByMMUInThisVisit.TotalHTNFollowUpCount as 'Number seen by MMU in this visit',
HTNDMTotalPatientIdentifiedInVillage.CountOfPat as 'Total HTN/DM patients identified in the village who are eligible for treatment under MMU',
HTNDMPatientSeenInThisMonth.CountOfPat as 'HTN/DM patients seen this month',
HTNDMPercentSeenThisMonth.PercentHTNPatSeen as '% of follow up HTN/DM patients seen this month',
HTNDMNumberOfPatientGivenMedByCHW.Count_Patient_Med_CHW as 'Number of patients whose medicines given to CHW as the pt did not/could not attend the clinic',
HTNDMPatientAbsentInLastThreeVisits.CountOfAbsentPat as 'Number of patients who discontinued treatment from MMU',
HTNDMPatientWithSideEffects.Count_Patient_ADR as 'HTN/DM patients reporting side effects due to medicines',
HTNDMPatientWithSAE.Count_Patient_SAE as 'Serious adverse event due to HTN/DM medicines',
HTNDMPatientDeath.CountOfDeadPat as 'Number of HTN/DM patients whose deaths were reported this month'
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
			where pt.name in('htnConfirmed','dmConfirmed')
			and cn.concept_name_type='FULLY_SPECIFIED'
			and cn.voided=0
			and cn.name='Yes'
			/*and cast(coalesce(pa.date_changed,pa.date_created) as date) < '#startDate#'*/
			Group by paddr.city_village
) as HTNDMPatientNeedingFollowUP
On HTNDMPatientNeedingFollowUP.city_village= PatientCountPerVillage.city_village
Left Join
(
/*number seen by MMU in this visit*/
			Select paddr.city_village, Count(distinct o.person_id) TotalHTNFollowUpCount from obs o
			inner join concept_name cname
			on o.concept_id=cname.concept_id
			inner join person_address paddr
			on paddr.person_id=o.person_id
			Where cname.name in ( 'HTN Follow-Up','DM Follow-up', 'Screening Form') 
			and cname.concept_name_type='FULLY_SPECIFIED' 
			/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
			Group by paddr.city_village
) as HTNDMNumberSeenByMMUInThisVisit
on HTNDMNumberSeenByMMUInThisVisit.city_village=PatientCountPerVillage.city_village
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
			/*and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'*/
			Group by paddr.city_village
) as HTNDMTotalPatientIdentifiedInVillage
on HTNDMTotalPatientIdentifiedInVillage.city_village =PatientCountPerVillage.city_village
Left Join
(
/*HTN patients seen this month*/
Select paddr.city_village,Count(distinct pa.person_id)+ifnull((
						Select  Count(distinct o.person_id) TotalHTNFollowUpCount
                        from obs o inner join concept_name cname
						on o.concept_id=cname.concept_id
						inner join person_address Innerpaddr
						on Innerpaddr.person_id=o.person_id
						Where cname.name in ( 'HTN Follow-Up','DM Follow-up') 
						and cname.concept_name_type='FULLY_SPECIFIED' 
						and Innerpaddr.city_village=paddr.city_village
						/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
						Group by Innerpaddr.city_village
					),0) CountOfPat
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
                    /*and cast(coalesce(pa.date_changed,pa.date_created) as date) BETWEEN '#startDate#' and '#endDate#'*/
					Group by paddr.city_village
) as HTNDMPatientSeenInThisMonth
on HTNDMPatientSeenInThisMonth.city_village = PatientCountPerVillage.city_village
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
						Where cname.name in ( 'HTN Follow-Up','DM Follow-up') 
						and cname.concept_name_type='FULLY_SPECIFIED' 
						/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
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
						/*and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'*/
						Group by paddr.city_village 
                    ) as TotalHTNConfirmedTillDate
					on HTNFollowUPForAMonth.city_village=TotalHTNConfirmedTillDate.city_village
)HTNDMPercentSeenThisMonth
On HTNDMPercentSeenThisMonth.city_village = PatientCountPerVillage.city_village
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
					/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name in( 'HTN Follow-Up','DM Follow-up') 
												and cname.concept_name_type='FULLY_SPECIFIED'
												/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
					) 
					group by paddr.city_village
) as HTNDMNumberOfPatientGivenMedByCHW
on HTNDMNumberOfPatientGivenMedByCHW.city_village=PatientCountPerVillage.city_village
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
					/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name in( 'HTN Follow-Up','DM Follow-up')
												and cname.concept_name_type='FULLY_SPECIFIED'
												/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
					)
					group by paddr.city_village
)HTNDMPatientWithSideEffects
On HTNDMPatientWithSideEffects.city_village = PatientCountPerVillage.city_village
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
					/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
					and o.encounter_id in (
												Select o.encounter_id from obs o
												inner join concept_name cname
												on o.concept_id=cname.concept_id
												Where cname.name in( 'HTN Follow-Up','DM Follow-up') 
												and cname.concept_name_type='FULLY_SPECIFIED'
												/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
					)
					group by paddr.city_village
) as HTNDMPatientWithSAE
on HTNDMPatientWithSAE.city_village=PatientCountPerVillage.city_village
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
				Where cname.name in( 'HTN Follow-Up' ,'DM Follow-up')
				and cname.concept_name_type='FULLY_SPECIFIED'
                and p.dead = 1
                /*and cast(p.death_date as date) BETWEEN '#startDate#' and '#endDate#'*/ 
				/*and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'*/
                group by paddr.city_village
) as HTNDMPatientDeath
on HTNDMPatientDeath.city_village=PatientCountPerVillage.city_village
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
							Where cname.name in ('HTN Follow, Is the patient absent?','DM Follow, Is the patient absent?') 
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

) HTNDMPatientAbsentInLastThreeVisits
on HTNDMPatientAbsentInLastThreeVisits.city_village=PatientCountPerVillage.city_village;
                    
                    


