SELECT distinct Patient_Identifier, Patient_Name, Age, Gender, age_group, HIV_Status
FROM (

		(SELECT distinct patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											 (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
								 -- HIV STATUS KNOWN						 
							 AND o.person_id in (
											    select distinct os.person_id 
												from obs os
											    where os.concept_id=4427 and os.value_coded = 1738
												AND os.obs_group_id in (
												     select oss.obs_id 
													 from obs oss 
													 where oss.concept_id=4655
													 )
												AND value_coded=1738)
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_KNOWN_POS
								 Group by Id
		)

		UNION
		
		(SELECT distinct patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											 (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )

								 	-- TESTED Positive at ANC
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 1740 and os.value_coded = 1738
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_NEW_POS
								 Group by Id
		)
		
		

) AS ANC_Status_Detailed

