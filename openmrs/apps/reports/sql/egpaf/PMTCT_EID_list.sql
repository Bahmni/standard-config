SELECT distinct Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Test_Sequence, Date_Sample_Taken, Test_Result
FROM 

		(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age_, Age, Gender, age_group, sort_order, group_id
		FROM
						(select distinct patient.patient_id AS Id,
										patient_identifier.identifier AS patientIdentifier,
										concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Age_,
										concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
										person.gender AS Gender,
										o.obs_group_id as group_id,
										observed_age_group.name AS age_group,
										observed_age_group.sort_order AS sort_order

						from obs o
						inner join patient ON o.person_id = patient.patient_id 
						inner join (
									select distinct oss.person_id, MAX(oss.obs_datetime) as max_observation,
										SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing, max(oss.encounter_id) as encounterId
									from obs oss
									where oss.concept_id = 4569
									and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
										group by oss.person_id
									)latest
									on latest.person_id = o.person_id
									INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
									INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
									INNER JOIN reporting_age_group AS observed_age_group ON
										CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									WHERE observed_age_group.report_group_name = 'Modified_Ages'
									AND o.concept_id = 4575
									AND o.voided=0
									AND cast(o.obs_datetime as date) = cast(max_observation as date)
									AND CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)

						UNION

						select distinct patient.patient_id AS Id,
										patient_identifier.identifier AS patientIdentifier,
										concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Age_,
										concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
										person.gender AS Gender,
										o.obs_group_id as group_id,
										observed_age_group.name AS age_group,
										observed_age_group.sort_order AS sort_order

						from obs o
						inner join patient ON o.person_id = patient.patient_id 
						inner join (
									select distinct  oss.person_id, MAX(oss.obs_datetime) as max_observation,
										SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing, max(oss.encounter_id) as encounterId
									from obs oss
									where oss.concept_id = 4588
									and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
										group by oss.person_id
									)latest
									on latest.person_id = o.person_id
									INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
									INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
									INNER JOIN reporting_age_group AS observed_age_group ON
										CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									WHERE observed_age_group.report_group_name = 'Modified_Ages'
									AND o.concept_id = 4575
									AND o.voided=0
									AND cast(o.obs_datetime as date) = cast(max_observation as date)
									AND CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)


						UNION

						select distinct patient.patient_id AS Id,
										patient_identifier.identifier AS patientIdentifier,
										concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Age_,
										concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
										person.gender AS Gender,
										o.obs_group_id as group_id,
										observed_age_group.name AS age_group,
										observed_age_group.sort_order AS sort_order

						from obs o
						inner join patient ON o.person_id = patient.patient_id 
						inner join (
									select distinct oss.person_id, MAX(oss.obs_datetime) as max_observation,
										SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing, max(oss.encounter_id) as encounterId
									from obs oss
									where oss.concept_id = 5095
									and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
										group by oss.person_id
									)latest
									on latest.person_id = o.person_id
									INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
									INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
									INNER JOIN reporting_age_group AS observed_age_group ON
										CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									WHERE observed_age_group.report_group_name = 'Modified_Ages'
									AND o.concept_id = 4575
									AND o.voided=0
									AND cast(o.obs_datetime as date) = cast(max_observation as date)
									AND CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 ) AS HEIClients_Status
                            having Age_ <= 12   



) AS HEI_Status_Detailed

left outer join 

(Select person_id,  Age_at_Test, obs_group_id, Test_Sequence
FROM
(
(select o.person_id, concat(value_numeric, ' ', 'weeks') as Age_at_Test, o.obs_group_id, 'First Test' as Test_Sequence
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        where concept_id = 4569 -- 6 weeks or first contact test done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4570 -- Age at test
            and o.voided = 0
    )

    UNION 

    (select o.person_id, concat(value_numeric, ' ', 'months') as Age_at_Test, o.obs_group_id,'Subsequent Test' as Test_Sequence
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        where concept_id in (4588, 5095) -- subsequent tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4587 -- Age at test
            and o.voided = 0
      )
)all_tests
)test_age
on test_age.obs_group_id = HEI_Status_Detailed.group_id

left outer join 

(select o.person_id, cast(value_datetime as date) as Date_Sample_Taken, o.obs_group_id
		from obs o
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        		where concept_id in (4569, 4588, 5095) -- Tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id
				) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4575 -- Date sample taken
            and o.voided = 0
			order by 1
            )sample_date
on sample_date.obs_group_id = HEI_Status_Detailed.group_id

left outer join 

(select distinct o.person_id,
        case
           when value_coded = 1738 then "Positive"
           when value_coded = 1016 then "Negative"
           when value_coded = 4220 then "Indeterminate"
           else ""
       end AS Test_Result
from obs o
		inner join
			(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
        from obs where concept_id in (4569,4588, 5095)  -- Tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as test_result
			on test_result.person_id = o.person_id
			where o.concept_id = 4578 -- HEI Test Result
            and o.voided = 0
            )results
on results.person_id = HEI_Status_Detailed.Id
Order by 2