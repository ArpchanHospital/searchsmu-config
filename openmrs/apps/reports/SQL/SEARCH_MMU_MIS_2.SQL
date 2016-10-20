Select 
PA.city_village Village,
PA.TotalPatientInVillage as 'Total eligible population',
TotalHTNConfirmedPerVillage.countpervillage as 'Total HTN patients confirmed',
TotalHTNFollowUpCount as 'Total HTN patients under follow up in the MMU',
Count_Patient_BP_Less_140_90 as 'HTN patients whose BP<140/90 (SBP less than 140 AND DBP<90)',
Count_Patient_BP_More_159_99 as 'HTN patients whose BP>159/99 (SBP >159 AND DBP>99)',
TotalDMConfirmedPerVillage.countpervillage as 'Total DM patients confirmed',
TotalDMFollowUpCount as 'Total DM patients under follow up in the MMU',
Count_Patient_RCBG_Less_200 as 'DM patients whose RCBG <200',
Count_Patient_RCBG_More_300 as 'DM patients whose RCBG>300',
TotalStrokeConfirmedPerVillage.countpervillage as 'Total Stroke patients confirmed',
TotalStrokeFollowUpCount as 'Total stroke patients under follow up in the MMU',
StrokeFollowUpAspirinCount as 'Stroke patients receiving aspirin',
Count_StrokeFollowPatient_BP_Less_140_90 as 'Stroke patients with BP<140/90  (SBP less than 140 AND DBP<90)'

from 

(
	Select city_village,  count(distinct person_id) TotalPatientInVillage from person_address
	group by city_village

) as PA

left join
(

Select paddr.city_village,Count(distinct pa.person_id) countpervillage
from person_attribute pa 
inner join person_attribute_type pt 
on pa.person_attribute_type_id=pt.person_attribute_type_id 
inner join person_address paddr 
on paddr.person_id=pa.person_id 
inner join concept_name cn 
on cn.concept_id=pa.value 
where pt.name ='htnConfirmed' 
and cn.concept_name_type='FULLY_SPECIFIED'
and cn.voided=0
and cn.name='Yes'
and pa.voided=0
and cast(coalesce(pa.date_changed,pa.date_created) as date) <='#endDate#'
Group by paddr.city_village

) as TotalHTNConfirmedPerVillage

On PA.city_village=TotalHTNConfirmedPerVillage.city_village

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

Select paddr.city_village,Count(distinct pa.person_id) countpervillage
from person_attribute pa 
inner join person_attribute_type pt 
on pa.person_attribute_type_id=pt.person_attribute_type_id 
inner join person_address paddr 
on paddr.person_id=pa.person_id 
inner join concept_name cn 
on cn.concept_id=pa.value 
where pt.name ='dmConfirmed' 
and cn.concept_name_type='FULLY_SPECIFIED'
and cn.voided=0
and cn.name='Yes'
and pa.voided=0
and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
Group by paddr.city_village

) as TotalDMConfirmedPerVillage

On PA.city_village=TotalDMConfirmedPerVillage.city_village

left join

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

Select paddr.city_village,Count(distinct pa.person_id) countpervillage
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
and pa.voided=0
and cast(coalesce(pa.date_changed,pa.date_created) as date) <= '#endDate#'
Group by paddr.city_village

) as TotalStrokeConfirmedPerVillage

On PA.city_village=TotalStrokeConfirmedPerVillage.city_village

left join

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