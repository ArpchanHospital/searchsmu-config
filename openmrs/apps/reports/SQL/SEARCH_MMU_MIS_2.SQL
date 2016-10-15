Select 
PA.city_village Village,
PA.TotalPatientInVillage as 'Total patients under a village',
TotalHTNFollowUpCount as 'Total HTN patients under follow up in the MMU',
Count_Patient_BP_Less_140_90 as 'HTN patients whose BP<140/90 (SBP less than 140 AND DBP<90)',
Count_Patient_BP_More_159_99 as 'HTN patients whose BP>159/99 (SBP >159 AND DBP>99)',
TotalDMFollowUpCount as 'Total DM patients under follow up in the MMU',
Count_Patient_RCBG_Less_200 as 'DM patients whose RCBG <200',
Count_Patient_RCBG_More_300 as 'DM patients whose RCBG>300',
TotalStrokeFollowUpCount as 'Total stroke patients under follow up in the MMU',
StrokeFollowUpAspirinCount as 'Stroke patients receiving aspirin',
Count_StrokeFollowPatient_BP_Less_140_90 as 'Stroke patients with BP<140/90  (SBP less than 140 AND DBP<90)'

from 

(
	Select city_village,  count(distinct person_id) TotalPatientInVillage from person_address
	group by city_village

) as PA

Left join 

(
	Select paddr.city_village, Count(distinct o.person_id) TotalHTNFollowUpCount from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name = 'HTN Follow-Up' 
	and cname.concept_name_type='FULLY_SPECIFIED' 
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	Group by paddr.city_village
) as HTNFollowTotal

on PA.city_village=HTNFollowTotal.city_village

Left join

(
	Select paddr.city_village, Count(distinct o.person_id) Count_Patient_BP_Less_140_90
	from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name in('Systolic') 
	and cname.concept_name_type='FULLY_SPECIFIED'
	and o.value_numeric < 140
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	and o.encounter_id in (
							Select o.encounter_id from obs o
							inner join concept_name cname
							on o.concept_id=cname.concept_id
							Where cname.name = 'HTN Follow-Up' 
							and cname.concept_name_type='FULLY_SPECIFIED'
	)
	and o.encounter_id in (
							Select o.encounter_id
							from obs o
							inner join concept_name cname
							on o.concept_id=cname.concept_id
							inner join person_address paddr
							on paddr.person_id=o.person_id
							Where cname.name in('Diastolic') 
							and cname.concept_name_type='FULLY_SPECIFIED'
                            and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
							and o.value_numeric < 90
							and o.encounter_id in (
													Select o.encounter_id from obs o
													inner join concept_name cname
													on o.concept_id=cname.concept_id
													Where cname.name = 'HTN Follow-Up' 
													and cname.concept_name_type='FULLY_SPECIFIED'
							)
	)Group by paddr.city_village 
) as HTNFollowLess14090

on HTNFollowLess14090.city_village=PA.city_village

Left join
(
	Select paddr.city_village, Count(distinct o.person_id) Count_Patient_BP_More_159_99
	from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name in('Systolic') 
	and cname.concept_name_type='FULLY_SPECIFIED'
	and o.value_numeric > 159
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	and o.encounter_id in (
							Select o.encounter_id from obs o
							inner join concept_name cname
							on o.concept_id=cname.concept_id
							Where cname.name = 'HTN Follow-Up' 
							and cname.concept_name_type='FULLY_SPECIFIED'
	)
	and o.encounter_id in (
							Select o.encounter_id
							from obs o
							inner join concept_name cname
							on o.concept_id=cname.concept_id
							inner join person_address paddr
							on paddr.person_id=o.person_id
							Where cname.name in('Diastolic') 
							and cname.concept_name_type='FULLY_SPECIFIED'
							and o.value_numeric > 99
                            and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
							and o.encounter_id in (
													Select o.encounter_id from obs o
													inner join concept_name cname
													on o.concept_id=cname.concept_id
													Where cname.name = 'HTN Follow-Up' 
													and cname.concept_name_type='FULLY_SPECIFIED'
							)
	)Group by paddr.city_village 
) as HTNFollowUpMore15999
On HTNFollowUpMore15999.city_village=PA.city_village

Left Join

(
	Select paddr.city_village, Count(distinct o.person_id) TotalDMFollowUpCount from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name = 'DM Follow-up' 
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	and cname.concept_name_type='FULLY_SPECIFIED' 
	Group by paddr.city_village
) as DMFollowTotal
On DMFollowTotal.city_village=PA.city_village

Left Join

(
	Select paddr.city_village, Count(distinct o.person_id) Count_Patient_RCBG_Less_200
	from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name in('Random Blood Sugar') 
	and cname.concept_name_type='FULLY_SPECIFIED'
	and o.value_numeric < 200
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	and o.encounter_id in (
							Select o.encounter_id from obs o
							inner join concept_name cname
							on o.concept_id=cname.concept_id
							Where cname.name = 'DM Follow-up' 
							and cname.concept_name_type='FULLY_SPECIFIED'
						  ) 
	group by paddr.city_village
)as DMFollow_RCBG_Less_200
on DMFollow_RCBG_Less_200.city_village=PA.city_village

Left Join

(
	Select paddr.city_village, Count(distinct o.person_id) Count_Patient_RCBG_More_300
	from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name in('Random Blood Sugar') 
	and cname.concept_name_type='FULLY_SPECIFIED'
	and o.value_numeric > 300
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	and o.encounter_id in (
							Select o.encounter_id from obs o
							inner join concept_name cname
							on o.concept_id=cname.concept_id
							Where cname.name = 'DM Follow-up' 
							and cname.concept_name_type='FULLY_SPECIFIED'
						  ) 
	group by paddr.city_village
)as DMFollow_RCBG_More_300
on DMFollow_RCBG_More_300.city_village=PA.city_village

Left join

(
	Select paddr.city_village, Count(distinct o.person_id) TotalStrokeFollowUpCount from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name = 'Stroke Follow-Up' 
	and cname.concept_name_type='FULLY_SPECIFIED' 
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	Group by paddr.city_village
) as StrokeFollowTotal
on StrokeFollowTotal.city_village=PA.city_village

Left join

(
	Select  paddr.city_village, Count(distinct o.person_id) StrokeFollowUpAspirinCount from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name in('Stroke Follow, Aspirin Morning','Stroke Follow, Aspirin Afternoon','Stroke Follow, Aspirin Night') 
	and o.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
    and o.voided=0
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	and cname.concept_name_type='FULLY_SPECIFIED'
	Group by paddr.city_village

) as StrokeFollowUpAspirin

on StrokeFollowUpAspirin.city_village= PA.city_village

Left join

(
	Select paddr.city_village, Count(distinct o.person_id) Count_StrokeFollowPatient_BP_Less_140_90
	from obs o
	inner join concept_name cname
	on o.concept_id=cname.concept_id
	inner join person_address paddr
	on paddr.person_id=o.person_id
	Where cname.name in('Systolic') 
	and cname.concept_name_type='FULLY_SPECIFIED'
	and o.value_numeric < 140
    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
	and o.encounter_id in (
							Select o.encounter_id from obs o
							inner join concept_name cname
							on o.concept_id=cname.concept_id
							Where cname.name = 'Stroke Follow-Up' 
							and cname.concept_name_type='FULLY_SPECIFIED'
	)
	and o.encounter_id in (
							Select o.encounter_id
							from obs o
							inner join concept_name cname
							on o.concept_id=cname.concept_id
							inner join person_address paddr
							on paddr.person_id=o.person_id
							Where cname.name in('Diastolic') 
							and cname.concept_name_type='FULLY_SPECIFIED'
							and o.value_numeric < 90
							and o.encounter_id in (
													Select o.encounter_id from obs o
													inner join concept_name cname
													on o.concept_id=cname.concept_id
													Where cname.name = 'Stroke Follow-Up' 
													and cname.concept_name_type='FULLY_SPECIFIED'
							)
	)Group by paddr.city_village 
) as StrokeFollowPatientBP

on PA.city_village=StrokeFollowPatientBP.city_village
Order by Village;