SELECT distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group, Gender, Name_of_Test_Used, Resistance, GeneXpert_Results, LPA_Rifampicin_Resistance,LPA_INH_Resistance
				,TB_Treatment_History, Started_2nd_Line_Drugs, HIV_Status
FROM(
(Select distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group, Gender
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						pi2.identifier AS TB_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					--  TB Clients with Genotypic test type performed
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type in (7)
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3814
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)
)test_result

inner join

(select distinct person_id, "Yes" as "Resistance"
from obs o 
where o.voided = 0
-- Any Resistance picked
and 
(						 
		  	o.person_id in (
				select distinct o.person_id
				from obs o 
				-- LPA Susceptibility result; RR and INHR
				where o.concept_id = 4922 and o.value_coded in (137,3802)
				and o.voided = 0
				and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
				and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		 	)
		 
		 -- MTB Detected, RR
			OR o.person_id in (
				select distinct o.person_id
				from obs o 
				where o.concept_id = 3787 and o.value_coded = 3817
				and o.voided = 0
				and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
				and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		 	)
 )
) resistance_
on test_result.Id = resistance_.person_id

Left Outer Join
(
-- Name of test used
	select o.person_id,case
	when o.value_coded = 3824 then "GeneXpert"
	when o.value_coded = 3825 then "Line Probe Assay"
	else "N/A" 
	end AS Name_of_Test_Used
	from obs o
	where o.concept_id = 3814 and o.voided = 0
	Group by o.person_id
) Name_of_test
on test_result.Id = Name_of_test.person_id

Left Outer Join
(
-- MTB Detected, RR
	select o.person_id, "MTB Detected, RR" as "GeneXpert_Results"
	from obs o
	where o.concept_id = 3787 and o.value_coded = 3817
	and o.voided = 0
	and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	group by o.person_id
) as mtb_rr
on test_result.Id = mtb_rr.person_id

Left Outer Join
(
-- LPA Susceptibility result, RR
	select o.person_id, "Yes" as "LPA_Rifampicin_Resistance"
	from obs o
	where o.concept_id = 4922 and o.value_coded = 137
	and o.voided = 0
	and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	group by o.person_id
) as lpa_rr
on test_result.Id = lpa_rr.person_id

Left Outer Join
(
-- LPA Susceptibility result, RR
	select o.person_id, "Yes" as "LPA_INH_Resistance"
	from obs o
	where o.concept_id = 4922 and o.value_coded = 3802
	and o.voided = 0
	and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	group by o.person_id
) as lpa_inhr
on test_result.Id = lpa_inhr.person_id

Left Outer Join
(
-- Started 2nd Line Drugs
	select o.person_id, "Yes" as "Started_2nd_Line_Drugs"
	from obs o
	where o.concept_id = 3806 and o.value_coded = 3808
	and o.voided = 0
	and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	group by o.person_id
) as 2nd_line_drugs
on test_result.Id = 2nd_line_drugs.person_id

Left Outer Join
(
-- TB_Treatment_History
 select o.person_id,case
 when o.value_coded = 1034 then "New Patient"
 when o.value_coded = 1084 then "Relapse"
 when o.value_coded = 3786 then "Treatment after loss to follow up"
 when o.value_coded = 1037 then "Treatment after failure"
else "N/A" 
end AS TB_Treatment_History
from obs o
where o.concept_id = 3785 and o.voided = 0
Group by o.person_id
) History_TB_Treatment
on test_result.Id = History_TB_Treatment.person_id

-- HIV STATUS	
left outer join
	(
	select person_id, value_coded as Status_Code
	from obs where concept_id = 4666 and voided = 0
	)Status

	inner join
	(
		select concept_id, name AS HIV_Status
			from concept_name 
				where name in ('Known Positive', 'Known Negative', 'New Positive', 'New Negative') 
	) concept_name
	on concept_name.concept_id = Status.Status_Code 
on Status.person_id = test_result.Id 
