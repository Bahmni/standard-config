SELECT HTS_TOTALS_COLS_ROWS.AgeGroup
		, HTS_TOTALS_COLS_ROWS.Positive_Males
		, HTS_TOTALS_COLS_ROWS.Positive_Females
		, HTS_TOTALS_COLS_ROWS.Total

FROM

(
	(SELECT HTS_DETAILS.age_group AS 'AgeGroup'
			, IF(HTS_DETAILS.Id IS NULL, 0, SUM(IF(HTS_DETAILS.HIV_Status = 'Positive' AND HTS_DETAILS.Gender = 'M', 1, 0))) AS Positive_Males
			, IF(HTS_DETAILS.Id IS NULL, 0, SUM(IF(HTS_DETAILS.HIV_Status = 'Positive' AND HTS_DETAILS.Gender = 'F', 1, 0))) AS Positive_Females
			, IF(HTS_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, HTS_DETAILS.sort_order
			
	FROM

         (
                    Select distinct Id, Patient_Identifier, Patient_Name,Age, Gender, age_group,HIV_Testing_Initiation, HIV_Status,sort_order
            from(
            SELECT Id,Patient_Identifier, Patient_Name, Age, Gender, age_group, HIV_Testing_Initiation  , HIV_Status,sort_order
            FROM (
            (SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Self-test' AS 'HIV_Testing_Initiation'
                                    , HIV_Status, sort_order
                    FROM
                                    (select distinct patient.patient_id AS Id,
                                                        patient_identifier.identifier AS patientIdentifier,
                                                        concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                                        floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                                        (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status,
                                                        person.gender AS Gender,
                                                        observed_age_group.name AS age_group,
                                                        observed_age_group.sort_order AS sort_order
                                    from obs o
                                            -- HTS SELF TEST STRATEGY
                                            INNER JOIN patient ON o.person_id = patient.patient_id 
                                            AND o.concept_id = 4845 and value_coded = 4822
                                            AND patient.voided = 0 AND o.voided = 0
                                            AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                            
                                            -- HAS HIV POSITIVE RESULTS 
                                            AND o.person_id in (
                                                select distinct os.person_id
                                                from obs os
                                                where os.concept_id = 4844 and os.value_coded = 1738
                                                AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND patient.voided = 0 AND o.voided = 0
                                            )
                                            
                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
											INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                            INNER JOIN reporting_age_group AS observed_age_group ON
                                            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                                    WHERE observed_age_group.report_group_name = 'Modified_Ages'
                                            ) AS HTSClients_HIV_Status
                    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
                    
            ) AS HTS_Status_Detailed
            ORDER BY HTS_Status_Detailed.HIV_Testing_Initiation
                        , HTS_Status_Detailed.sort_order) AS SelfTest

        ) AS HTS_DETAILS

	GROUP BY HTS_DETAILS.age_group
	ORDER BY HTS_DETAILS.sort_order)
	
	
UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Status = 'Positive' AND Totals.Gender = 'M', 1, 0))) AS 'Positive_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Status = 'Positive' AND Totals.Gender = 'F', 1, 0))) AS 'Positive_Females'
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_HTS.Id
					, Total_HTS.Patient_Identifier AS "Patient Identifier"
					, Total_HTS.Patient_Name AS "Patient Name"
					, Total_HTS.Age
					, Total_HTS.Gender
					, Total_HTS.HIV_Status
				
		FROM

		(

                            Select distinct Id, Patient_Identifier, Patient_Name,Age, Gender, age_group,HIV_Testing_Initiation, HIV_Status,sort_order
                    from(
                    SELECT Id,Patient_Identifier, Patient_Name, Age, Gender, age_group, HIV_Testing_Initiation  , HIV_Status,sort_order
                    FROM (
                    (SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Self-test' AS 'HIV_Testing_Initiation'
                                            , HIV_Status, sort_order
                            FROM
                                            (select distinct patient.patient_id AS Id,
                                                                patient_identifier.identifier AS patientIdentifier,
                                                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                                                (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status,
                                                                person.gender AS Gender,
                                                                observed_age_group.name AS age_group,
                                                                observed_age_group.sort_order AS sort_order
                                            from obs o
                                                    -- HTS SELF TEST STRATEGY
                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                    AND o.concept_id = 4845 and value_coded = 4822
                                                    AND patient.voided = 0 AND o.voided = 0
                                                    AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                    AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                    
                                                    -- HAS HIV POSITIVE RESULTS 
                                                    AND o.person_id in (
                                                        select distinct os.person_id
                                                        from obs os
                                                        where os.concept_id = 4844 and os.value_coded = 1738
                                                        AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                    AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                        AND patient.voided = 0 AND o.voided = 0
                                                    )
                                                    
                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
													INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                    INNER JOIN reporting_age_group AS observed_age_group ON
                                                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                                            WHERE observed_age_group.report_group_name = 'Modified_Ages'
                                                    ) AS HTSClients_HIV_Status
                            ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
                            
                            
                            
                    ) AS HTS_Status_Detailed
                    ORDER BY HTS_Status_Detailed.HIV_Testing_Initiation
                                , HTS_Status_Detailed.sort_order) AS SelfTest

                            ) AS Total_HTS
  ) AS Totals
 )
) AS HTS_TOTALS_COLS_ROWS
ORDER BY HTS_TOTALS_COLS_ROWS.sort_order

