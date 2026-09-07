Select distinct Patient_Identifier, Patient_Name,age_group as Age_Group,Age,Gender,Outcome_Type, concat(Age_at_test, " months") as Age_at_test, sort_order
from
(SELECT distinct Id, patientIdentifier AS Patient_Identifier, patientName AS Patient_Name, Age , Gender, age_group,sort_order
							 
	FROM

			(select distinct patient.patient_id AS Id,
							patient_identifier.identifier AS patientIdentifier,
							concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
							person.gender AS Gender,
							observed_age_group.name AS age_group,
							observed_age_group.sort_order AS sort_order
							

			from obs o
					-- HIV EXPOSED INFANTS
						INNER JOIN patient ON o.person_id = patient.patient_id 
						AND o.concept_id = 996
						AND o.person_id in (
							select os.person_id
							from obs os
							where os.concept_id = 4558 -- HEI Register
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)
						AND o.person_id in (
							select os.person_id 
							from obs os
							where os.concept_id = 4587 and os.value_numeric >= 18 -- Age at Test
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)
						AND patient.voided = 0 AND o.voided = 0
						AND CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
					WHERE observed_age_group.report_group_name = 'Modified_Ages'
			) AS HTSClients_HIV_STATUS
		where Age = 2
			Group by Id
	ORDER BY HTSClients_HIV_STATUS.Age) as final_outcome
	-- Age at Test
Left Outer Join
(
	select distinct o.person_id, o.value_numeric as Age_at_test
	from obs o 
	inner join (
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing, max(oss.encounter_id) as encounterId
				from obs oss
				where oss.concept_id = 4589
				and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
					group by oss.person_id
			)latest
			on latest.person_id = o.person_id
			where o.concept_id = 4587
			and o.voided=0
			and cast(o.obs_datetime as date) = cast(max_observation as date)

)as ageAtTest
On final_outcome.Id = ageAtTest.person_id

-- final outcome
Left Outer Join
(
	select distinct o.person_id, 
		case
			when o.value_coded = 1738 then "Positive"
			when o.value_coded = 1016 then "Negative"
			when o.value_coded = 4220 then "Indeterminate"
			else "N/A"
			end as Outcome_Type
	from obs o 
	where o.concept_id = 4578
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)as outcome
On final_outcome.Id = outcome.person_id
Group by final_outcome.Id

