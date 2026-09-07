SELECT distinct TREATMENT_TOTALS_COLS_ROWS.AgeGroup
		    , TREATMENT_TOTALS_COLS_ROWS.Cryotherapy_Outcomes
	    	, TREATMENT_TOTALS_COLS_ROWS.Colposcopy_Outcomes
			, TREATMENT_TOTALS_COLS_ROWS.LLETZ_Outcomes
			, TREATMENT_TOTALS_COLS_ROWS.Conisation_Outcomes

FROM (

			(SELECT TREATMENT_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					
						, IF(TREATMENT_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(TREATMENT_STATUS_DRVD_ROWS.Treatment_Type = 'Cryotherapy', 1, 0))) AS Cryotherapy_Outcomes
						, IF(TREATMENT_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(TREATMENT_STATUS_DRVD_ROWS.Treatment_Type = 'Colposcopy', 1, 0))) AS Colposcopy_Outcomes
						, IF(TREATMENT_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(TREATMENT_STATUS_DRVD_ROWS.Treatment_Type = 'LLETZ', 1, 0))) AS LLETZ_Outcomes
						, IF(TREATMENT_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(TREATMENT_STATUS_DRVD_ROWS.Treatment_Type = 'Conisation', 1, 0))) AS Conisation_Outcomes
						, TREATMENT_STATUS_DRVD_ROWS.sort_order
			FROM (

					
(
	SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, File_Number, patientName AS "Patient_Name", Age,DOB, Gender,age_group,sort_order, Treatment_Type
    FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   pi.identifier as File_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.sort_order AS sort_order,
									   observed_age_group.name AS age_group
									  

                from obs o
						-- CLIENTS Marked as HIV Cryotherapy
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0
						  AND o.concept_id = 4515 and o.value_coded = 1738
						  AND o.voided = 0
						  -- Cryotherapy Screening Result
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
				   
			inner join 
(
        select
       os.person_id,
       case
       -- Treatment Type
           when os.value_coded = 4533 then "Cryotherapy"
           when os.value_coded = 4794 then "Colposcopy"
           when os.value_coded = 4534 then "LLETZ"
		   when os.value_coded = 4795 then "Conisation"
           else ""
       end AS Treatment_Type
       from obs os 
       where os.concept_id = 4535
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)treatment_type
on treatment_type.person_id = HIV_CXCA.Id
)



			) AS TREATMENT_STATUS_DRVD_ROWS

			GROUP BY TREATMENT_STATUS_DRVD_ROWS.age_group, TREATMENT_STATUS_DRVD_ROWS.Gender
			ORDER BY TREATMENT_STATUS_DRVD_ROWS.sort_order
			)
			
			
	 UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					
						, IF(TREATMENT_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(TREATMENT_STATUS_DRVD_COLS.Treatment_Type = 'Cryotherapy', 1, 0))) AS Cryotherapy_Outcomes
						, IF(TREATMENT_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(TREATMENT_STATUS_DRVD_COLS.Treatment_Type = 'Colposcopy', 1, 0))) AS Colposcopy_Outcomes
						, IF(TREATMENT_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(TREATMENT_STATUS_DRVD_COLS.Treatment_Type = 'LLETZ', 1, 0))) AS LLETZ_Outcomes
						, IF(TREATMENT_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(TREATMENT_STATUS_DRVD_COLS.Treatment_Type = 'Conisation', 1, 0))) AS Conisation_Outcomes
						, 99 AS sort_order
			FROM (

					
(
	SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, File_Number, patientName AS "Patient_Name", Age,DOB, Gender,age_group,sort_order, Treatment_Type
    FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   pi.identifier as File_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.sort_order AS sort_order,
									   observed_age_group.name AS age_group
									  

                from obs o
						-- CLIENTS Marked as HIV Cryotherapy
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0
						  AND o.concept_id = 4515 and o.value_coded = 1738
						  AND o.voided = 0
						  -- Cryotherapy Screening Result
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
				   
			inner join 
(
        select
       os.person_id,
       case
       -- Treatment Type
           when os.value_coded = 4533 then "Cryotherapy"
           when os.value_coded = 4794 then "Colposcopy"
           when os.value_coded = 4534 then "LLETZ"
		   when os.value_coded = 4795 then "Conisation"
           else ""
       end AS Treatment_Type
       from obs os 
       where os.concept_id = 4535
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)treatment_type
on treatment_type.person_id = HIV_CXCA.Id
)



			) AS TREATMENT_STATUS_DRVD_COLS
		)
		
	) AS TREATMENT_TOTALS_COLS_ROWS
ORDER BY TREATMENT_TOTALS_COLS_ROWS.sort_order

