Select PA.city_village as Village,
HTNFollowUpCounter.Percent_of_patients_on_Hydrochlorothiazide as 'HTN Percent of patients on Hydrochlorothiazide',
HTNFollowUpCounter.Percent_of_patients_on_Amlodipine as 'HTN Percent of patients on Amlodipine',
HTNFollowUpCounter.Percent_of_patients_on_Atenolol as 'HTN Percent of patients on Atenolol',
HTNFollowUpCounter.Percent_of_patients_on_one_drug as 'HTN Percent of patients on one drug',
HTNFollowUpCounter.Percent_of_patients_on_two_drug as 'HTN Percent of patients on two drug',
HTNFollowUpCounter.Percent_of_patients_on_three_drug as 'HTN Percent of patients on three drug',          
DMFollowUpCounter.PerCent_of_patients_on_Metformin as 'DM Percent of patients on Metformin',
DMFollowUpCounter.Percent_of_patients_on_Glipizide as 'DM Percent of patients on Glipizide',
DMFollowUpCounter.Percent_of_patients_on_one_drug as 'DM Percent of patients on one drug',
DMFollowUpCounter.Percent_of_patients_on_two_drug as 'DM Percent of patients on two drug',
StrokeFollowUpCounter.PerCent_of_patients_on_Aspirin as 'Stroke Percent of patients on Aspirin',
StrokeFollowUpCounter.Percent_of_patients_on_Atorvastatin as 'Stroke Percent of patients on Atorvastatin',
StrokeFollowUpCounter.Percent_of_patients_on_one_drug as 'Stroke Percent of patients on one drug',
StrokeFollowUpCounter.Percent_of_patients_on_two_drug as 'Stroke Percent of patients on two drug'
from 
(/*To get the list of all the villages to join with the obs*/
Select Distinct city_village from person_address
) as PA

Left join 
( 

/*Count for the DM follow up*/

Select 		CntOfDMFollowPatPerVill.city_village,
			CntOfDMFollowPatPerVill.CountOfPat,
            CountOfMetforminPerVill.CountOfMetformin,
            CountOfGlipizidePerVill.CountOfGlipizide,
            VillDrugCnt.PatCntOneDrug,
            VillDrugCnt.PatCntTwoDrug,
			CountOfMetforminPerVill.CountOfMetformin/ CntOfDMFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_metformin',
			CountOfGlipizidePerVill.CountOfGlipizide/ CntOfDMFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_Glipizide',		
            VillDrugCnt.PatCntOneDrug/ CntOfDMFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_one_drug',
			VillDrugCnt.PatCntTwoDrug/ CntOfDMFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_two_drug'
            from 
			( 		
					Select paddr.city_village,Count(distinct pa.person_id) CountOfPat   /* To get the total patient count in DM Follow up*/
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
					and cast(coalesce(pa.date_changed,pa.date_created) as date) BETWEEN '#startDate#' and '#endDate#'
					Group by paddr.city_village
			) as CntOfDMFollowPatPerVill

			Left join

			(
					Select paddr.city_village, Count(distinct o.person_id) CountOfMetformin /*Count of patients who were prescribed Metformin*/
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('DM Follow, Metformin Afternoon','DM Follow, Metformin Morning','DM Follow, Metformin Night') 
                    and o.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
					and o.voided =0 
                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.encounter_id in (
											Select o.encounter_id from obs o
											inner join concept_name cname
											on o.concept_id=cname.concept_id
											Where cname.name = 'DM Follow-up' 
											and cname.concept_name_type='FULLY_SPECIFIED'
										  ) 
					group by paddr.city_village
			) as CountOfMetforminPerVill

			On CountOfMetforminPerVill.city_village = CntOfDMFollowPatPerVill.city_village

			Left join

			(        
					Select paddr.city_village,Count(distinct o.person_id) CountOfGlipizide  /*Count of patients who were prescribed Glipizide*/
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('DM Follow, Glipizide Afternoon','DM Follow, Glipizide Morning','DM Follow, Glipizide Night') 
                    and o.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
					and o.voided =0 
                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and cname.concept_name_type='FULLY_SPECIFIED'
					and o.encounter_id in (
											Select o.encounter_id from obs o
											inner join concept_name cname
											on o.concept_id=cname.concept_id
											Where cname.name = 'DM Follow-up' 
											and cname.concept_name_type='FULLY_SPECIFIED'
										  ) 
					group by paddr.city_village
			) as CountOfGlipizidePerVill
			on CountOfGlipizidePerVill.city_village = CntOfDMFollowPatPerVill.city_village

left join 

(   /*Pivoting the count of patients per village based on the number of drugs given*/
		select
		city_village,
		sum(OneDrug) as PatCntOneDrug,
		sum(TwoDrug) as PatCntTwoDrug,
		sum(ThreeDrug) as PatCntThreeDrug
		from (
			select
			RowToColumnPatMedCount.*,
			case when CountOfMedTakenPerPerson = "1" then counter end as OneDrug,
			case when CountOfMedTakenPerPerson = "2" then counter end as TwoDrug,
			case when CountOfMedTakenPerPerson = "3" then counter end as ThreeDrug
			from (
						  Select A.city_village,A.CountOfMedTakenPerPerson,Count(1) Counter 
						  from (
									Select paddr.city_village,o.person_id,Count(distinct o.person_id) counter,
									Case when 	(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('DM Follow, Glipizide Afternoon','DM Follow, Glipizide Morning','DM Follow, Glipizide Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) is null then 0 else (
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('DM Follow, Glipizide Afternoon','DM Follow, Glipizide Morning','DM Follow, Glipizide Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) end
									+
									Case when 	(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('DM Follow, Metformin Afternoon','DM Follow, Metformin Morning','DM Follow, Metformin Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')  
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) is null then 0 else 
												(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('DM Follow, Metformin Afternoon','DM Follow, Metformin Morning','DM Follow, Metformin Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) end  as CountOfMedTakenPerPerson /*Counts the number of drugs dispensed per village per person*/

									 from obs o
									inner join concept_name cname
									on o.concept_id=cname.concept_id
									Inner join person_address paddr
									on paddr.person_id=o.person_id
									Where cname.name = 'DM Follow-up' 
									and cname.concept_name_type='FULLY_SPECIFIED'
                                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
									Group by paddr.city_village,o.person_id
						) as A
						Where CountOfMedTakenPerPerson <> 0
						Group by A.city_village,A.CountOfMedTakenPerPerson
				) as RowToColumnPatMedCount
		) as PivotTablePatMedCount
		group by city_village
) as VillDrugCnt
on VillDrugCnt.city_village=CntOfDMFollowPatPerVill.city_village
) as DMFollowUpCounter
On PA.city_village=DMFollowUpCounter.city_village

Left join
(
/*Count for the stroke follow up*/
	Select 		
			CntOfStrokeFollowPatPerVill.city_village,
			CntOfStrokeFollowPatPerVill.CountOfPat,
            CountOfAspirinPerVill.CountOfAspirin,
            CountOfAtorvastatinPerVill.CountOfAtorvastatin,
            VillDrugCnt.PatCntOneDrug,
            VillDrugCnt.PatCntTwoDrug,
			CountOfAspirinPerVill.CountOfAspirin/ CntOfStrokeFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_Aspirin',
			CountOfAtorvastatinPerVill.CountOfAtorvastatin/ CntOfStrokeFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_Atorvastatin',
            VillDrugCnt.PatCntOneDrug/ CntOfStrokeFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_one_drug',
			VillDrugCnt.PatCntTwoDrug/ CntOfStrokeFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_two_drug'
            from 
			( 		
					Select paddr.city_village,Count(distinct pa.person_id) CountOfPat  /* To get the total patient count in Stroke Follow up*/
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
					and cast(coalesce(pa.date_changed,pa.date_created) as date) BETWEEN '#startDate#' and '#endDate#'
					Group by paddr.city_village
                    
			) as CntOfStrokeFollowPatPerVill

			Left join

			(
					Select paddr.city_village, Count(distinct o.person_id) CountOfAspirin /*Count of patients who were prescribed Aspirin*/
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('Stroke Follow, Aspirin Morning','Stroke Follow, Aspirin Afternoon','Stroke Follow, Aspirin Night') 
                    and o.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
					and o.voided =0 
					and cname.concept_name_type='FULLY_SPECIFIED'
                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
											Select o.encounter_id from obs o
											inner join concept_name cname
											on o.concept_id=cname.concept_id
											Where cname.name = 'Stroke Follow-up' 
											and cname.concept_name_type='FULLY_SPECIFIED'
										  ) 
					group by paddr.city_village
			) as CountOfAspirinPerVill

			On CountOfAspirinPerVill.city_village = CntOfStrokeFollowPatPerVill.city_village

			Left join

			(        
					Select paddr.city_village,Count(distinct o.person_id) CountOfAtorvastatin  /*Count of patients who were prescribed Atorvastatin*/
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('Stroke Follow, Atorvastatin Morning','Stroke Follow, Atorvastatin Afternoon','Stroke Follow, Atorvastatin Night') 
                    and o.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
					and o.voided =0 
					and cname.concept_name_type='FULLY_SPECIFIED'
                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
											Select o.encounter_id from obs o
											inner join concept_name cname
											on o.concept_id=cname.concept_id
											Where cname.name = 'Stroke Follow-up' 
											and cname.concept_name_type='FULLY_SPECIFIED'
										  ) 
					group by paddr.city_village
			) as CountOfAtorvastatinPerVill
			on CountOfAtorvastatinPerVill.city_village = CntOfStrokeFollowPatPerVill.city_village

left join 

(   /*Pivoting the count of patients per village based on the number of drugs given*/
		select
		city_village,
		sum(OneDrug) as PatCntOneDrug,
		sum(TwoDrug) as PatCntTwoDrug,
		sum(ThreeDrug) as PatCntThreeDrug
		from (
			select
			RowToColumnPatMedCount.*,
			case when CountOfMedTakenPerPerson = "1" then counter end as OneDrug,
			case when CountOfMedTakenPerPerson = "2" then counter end as TwoDrug,
			case when CountOfMedTakenPerPerson = "3" then counter end as ThreeDrug
			from (
						  Select A.city_village,A.CountOfMedTakenPerPerson,Count(1) Counter 
						  from (
									Select paddr.city_village,o.person_id,Count(distinct o.person_id) counter,
									Case when 	(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('Stroke Follow, Atorvastatin Morning','Stroke Follow, Atorvastatin Afternoon','Stroke Follow, Atorvastatin Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) is null then 0 else (
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('Stroke Follow, Atorvastatin Morning','Stroke Follow, Atorvastatin Afternoon','Stroke Follow, Atorvastatin Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) end
									+
									Case when 	(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('Stroke Follow, Aspirin Morning','Stroke Follow, Aspirin Afternoon','Stroke Follow, Aspirin Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) is null then 0 else 
												(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('Stroke Follow, Aspirin Morning','Stroke Follow, Aspirin Afternoon','Stroke Follow, Aspirin Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) end  as CountOfMedTakenPerPerson /*Counts the number of drugs dispensed per village per person*/

									 from obs o
									inner join concept_name cname
									on o.concept_id=cname.concept_id
									Inner join person_address paddr
									on paddr.person_id=o.person_id
									Where cname.name = 'Stroke Follow-up' 
									and cname.concept_name_type='FULLY_SPECIFIED'
                                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
									Group by paddr.city_village,o.person_id
						) as A
						Where CountOfMedTakenPerPerson <> 0
						Group by A.city_village,A.CountOfMedTakenPerPerson
				) as RowToColumnPatMedCount
		) as PivotTablePatMedCount
		group by city_village
) as VillDrugCnt
on VillDrugCnt.city_village=CntOfStrokeFollowPatPerVill.city_village	

) as StrokeFollowUpCounter

On StrokeFollowUpCounter.city_village =PA.city_village


Left join
(
/*Count for the HTN follow up*/

Select 		CntOfHTNFollowPatPerVill.city_village,
			CntOfHTNFollowPatPerVill.CountOfPat,
            CountOfAmlodipinePerVill.CountOfAmlodipine,
            CountOfHydrochlorothiazidePerVill.CountOfHydrochlorothiazide,
            CountOfAtenololPerVill.CountOfAtenolol,
            VillDrugCnt.PatCntOneDrug,
            VillDrugCnt.PatCntTwoDrug,
            VillDrugCnt.PatCntThreeDrug,
			CountOfAmlodipinePerVill.CountOfAmlodipine/ CntOfHTNFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_Amlodipine',
			CountOfHydrochlorothiazidePerVill.CountOfHydrochlorothiazide/ CntOfHTNFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_Hydrochlorothiazide',
            CountOfAtenololPerVill.CountOfAtenolol/ CntOfHTNFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_Atenolol',
			VillDrugCnt.PatCntOneDrug/ CntOfHTNFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_one_drug',
			VillDrugCnt.PatCntTwoDrug/ CntOfHTNFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_two_drug',
            VillDrugCnt.PatCntThreeDrug/ CntOfHTNFollowPatPerVill.CountOfPat * 100 as 'Percent_of_patients_on_three_drug'
            from 
			( 		
					Select paddr.city_village,Count(distinct pa.person_id) CountOfPat   /* To get the total patient count in HTN Follow up*/
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
					and cast(coalesce(pa.date_changed,pa.date_created) as date) BETWEEN '#startDate#' and '#endDate#'
					Group by paddr.city_village
                    
			) as CntOfHTNFollowPatPerVill

			Left join

			(
					Select paddr.city_village, Count(distinct o.person_id) CountOfAmlodipine /*Count of patients who were prescribed Amlodipine*/
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('HTN Follow, Amlodipine Morning','HTN Follow, Amlodipine Afternoon','HTN Follow, Amlodipine Night') 
                    and o.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
					and o.voided =0 
					and cname.concept_name_type='FULLY_SPECIFIED'
                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
											Select o.encounter_id from obs o
											inner join concept_name cname
											on o.concept_id=cname.concept_id
											Where cname.name = 'HTN Follow-up' 
											and cname.concept_name_type='FULLY_SPECIFIED'
										  ) 
					group by paddr.city_village
			) as CountOfAmlodipinePerVill

			On CountOfAmlodipinePerVill.city_village = CntOfHTNFollowPatPerVill.city_village

			Left join

			(        
					Select paddr.city_village,Count(distinct o.person_id) CountOfHydrochlorothiazide  /*Count of patients who were prescribed Hydrochlorothiazide*/
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('HTN Follow, Hydrochlorothiazide Morning','HTN Follow, Hydrochlorothiazide Afternoon','HTN Follow, Hydrochlorothiazide Night') 
                    and o.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
					and o.voided =0 
					and cname.concept_name_type='FULLY_SPECIFIED'
                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
											Select o.encounter_id from obs o
											inner join concept_name cname
											on o.concept_id=cname.concept_id
											Where cname.name = 'HTN Follow-up' 
											and cname.concept_name_type='FULLY_SPECIFIED'
										  ) 
					group by paddr.city_village
			) as CountOfHydrochlorothiazidePerVill
			on CountOfHydrochlorothiazidePerVill.city_village = CntOfHTNFollowPatPerVill.city_village
            
            Left join

			(        
					Select paddr.city_village,Count(distinct o.person_id) CountOfAtenolol  /*Count of patients who were prescribed Atenolol*/
					from obs o
					inner join concept_name cname
					on o.concept_id=cname.concept_id
					inner join person_address paddr
					on paddr.person_id=o.person_id
					Where cname.name in('HTN Follow, Atenolol Morning','HTN Follow, Atenolol Afternoon','HTN Follow, Atenolol Night') 
                    and o.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
					and o.voided =0 
					and cname.concept_name_type='FULLY_SPECIFIED'
                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
					and o.encounter_id in (
											Select o.encounter_id from obs o
											inner join concept_name cname
											on o.concept_id=cname.concept_id
											Where cname.name = 'HTN Follow-up' 
											and cname.concept_name_type='FULLY_SPECIFIED'
										  ) 
					group by paddr.city_village
			) as CountOfAtenololPerVill
			on CountOfAtenololPerVill.city_village = CntOfHTNFollowPatPerVill.city_village

left join 

(   /*Pivoting the count of patients per village based on the number of drugs given*/
		select
		city_village,
		sum(OneDrug) as PatCntOneDrug,
		sum(TwoDrug) as PatCntTwoDrug,
		sum(ThreeDrug) as PatCntThreeDrug
		from (
			select
			RowToColumnPatMedCount.*,
			case when CountOfMedTakenPerPerson = "1" then counter end as OneDrug,
			case when CountOfMedTakenPerPerson = "2" then counter end as TwoDrug,
			case when CountOfMedTakenPerPerson = "3" then counter end as ThreeDrug
			from (
						  Select A.city_village,A.CountOfMedTakenPerPerson,Count(1) Counter 
						  from (
									Select paddr.city_village,o.person_id,Count(distinct o.person_id) counter,
									Case when 	(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('HTN Follow, Hydrochlorothiazide Morning','HTN Follow, Hydrochlorothiazide Afternoon','HTN Follow, Hydrochlorothiazide Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) is null then 0 else (
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('HTN Follow, Hydrochlorothiazide Morning','HTN Follow, Hydrochlorothiazide Afternoon','HTN Follow, Hydrochlorothiazide Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) end
									+
									Case when 	(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('HTN Follow, Amlodipine Morning','HTN Follow, Amlodipine Afternoon','HTN Follow, Amlodipine Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) is null then 0 else 
												(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('HTN Follow, Amlodipine Morning','HTN Follow, Amlodipine Afternoon','HTN Follow, Amlodipine Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED')
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) end +
                                                Case when 	(
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('HTN Follow, Atenolol Morning','HTN Follow, Atenolol Afternoon','HTN Follow, Atenolol Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) is null then 0 else (
													Select Count(distinct o1.person_id) 
													from obs o1
													inner join concept_name cname
													on o1.concept_id=cname.concept_id
													inner join person_address paddr1
													on paddr1.person_id=o1.person_id
													Where cname.name in('HTN Follow, Atenolol Morning','HTN Follow, Atenolol Afternoon','HTN Follow, Atenolol Night') 
													and o1.value_coded not in(Select concept_id from concept_name where name ='0' and concept_name_type='FULLY_SPECIFIED') 
													and o1.voided =0 
													and cname.concept_name_type='FULLY_SPECIFIED'
													and paddr1.city_village=paddr.city_village
													and o1.person_id=o.person_id
                                                    and cast(o1.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
													Group by paddr1.city_village,o1.person_id
												) end
                                                as CountOfMedTakenPerPerson  /*Counts the number of drugs dispensed per village per person*/

									 from obs o
									inner join concept_name cname
									on o.concept_id=cname.concept_id
									Inner join person_address paddr
									on paddr.person_id=o.person_id
									Where cname.name = 'HTN Follow-up' 
									and cname.concept_name_type='FULLY_SPECIFIED'
                                    and cast(o.obs_datetime as date) BETWEEN '#startDate#' and '#endDate#'
									Group by paddr.city_village,o.person_id
						) as A
						Where CountOfMedTakenPerPerson <> 0
						Group by A.city_village,A.CountOfMedTakenPerPerson
				) as RowToColumnPatMedCount
		) as PivotTablePatMedCount
		group by city_village
) as VillDrugCnt
on VillDrugCnt.city_village=CntOfHTNFollowPatPerVill.city_village		

) as HTNFollowUpCounter

On HTNFollowUpCounter.city_village =PA.city_village
Where coalesce(  /*To remove the villages which doesn't have any data recorded*/
			HTNFollowUpCounter.Percent_of_patients_on_Hydrochlorothiazide,
			HTNFollowUpCounter.Percent_of_patients_on_Amlodipine,
			HTNFollowUpCounter.Percent_of_patients_on_Atenolol,
			HTNFollowUpCounter.Percent_of_patients_on_one_drug,
			HTNFollowUpCounter.Percent_of_patients_on_two_drug,
			HTNFollowUpCounter.Percent_of_patients_on_three_drug,          
			DMFollowUpCounter.PerCent_of_patients_on_Metformin,
			DMFollowUpCounter.Percent_of_patients_on_Glipizide,
			DMFollowUpCounter.Percent_of_patients_on_one_drug,
			DMFollowUpCounter.Percent_of_patients_on_two_drug,
			StrokeFollowUpCounter.PerCent_of_patients_on_Aspirin,
			StrokeFollowUpCounter.Percent_of_patients_on_Atorvastatin,
			StrokeFollowUpCounter.Percent_of_patients_on_one_drug,
			StrokeFollowUpCounter.Percent_of_patients_on_two_drug
			) is not null;