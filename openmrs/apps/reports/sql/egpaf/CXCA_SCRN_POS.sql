(SELECT patientIdentifier AS "Patient_Identifier",ART_Number, File_Number, patientName AS "Patient_Name", Age,DOB, Gender, Screening_Result
    FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   pi.identifier as File_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
                                       "Positive" As Screening_Result
									  

                from obs o
						-- CLIENTS Marked as HIV Positive
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0
						  AND o.concept_id = 4515 and o.value_coded = 1738
						  AND o.voided = 0
						  -- Positive Screening Result
                          inner join  (
							select distinct os.person_id from obs os
							where os.concept_id = 4521
							AND os.value_coded = 1738
                            and os.voided = 0
                            AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                            AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 ) as hiv_pos
                         on hiv_pos.person_id = o.person_id
					 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						 LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HIV_CXCA
				   
	
)