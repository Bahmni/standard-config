(SELECT distinct patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group as "Age Group", HIV_Status_Before_Visit-- , HIV_Status, sort_order
		FROM
						(select  patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   observed_age_group.sort_order AS sort_order,
											   o.encounter_id
						from obs o
								-- VMMC Client Record
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 6122 -- VMMC Client Record
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                				 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
					) AS VMMC_Clients
		
left outer join

(
	-- HIV Status Known Before Visit
	select distinct o.person_id, o.encounter_id,
			case 
				when o.value_coded = 1016 then 'Negative'
				when o.value_coded = 1738 then 'Positive'
				when o.value_coded = 1739 then 'Unknown'
			else 'N/A' end as HIV_Status_Before_Visit
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation
				from obs oss
				where oss.concept_id = 4427 and oss.voided=0
				and oss.obs_datetime >= cast('#startDate#' as date)
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 4427
			and o.obs_datetime >= cast('#startDate#' as date)
			and o.obs_datetime <= cast('#endDate#' as date)
			and o.voided = 0
) HIV_Status
on HIV_Status.encounter_id = VMMC_Clients.encounter_id

left outer join

(
	-- Accepted HIV Testing ?
	select distinct o.person_id, o.encounter_id,
			case 
				when o.value_coded = 1 then 'Yes'
				when o.value_coded = 2 then 'No'
			else '' end as Accepted_HIV_Test
		from obs o 
		where concept_id = 6130
			and o.obs_datetime >= cast('#startDate#' as date)
			and o.obs_datetime <= cast('#endDate#' as date)
			and o.voided = 0
)HIV_Testing_Acceptance
on HIV_Testing_Acceptance.encounter_id = VMMC_Clients.encounter_id

)
-- ORDER BY VMMC_Clients.HIV_Status, VMMC_Clients.Age