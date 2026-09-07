SELECT distinct HTS_TOTALS_COLS_ROWS.AgeGroup
        	, HTS_TOTALS_COLS_ROWS.Gender
		    , HTS_TOTALS_COLS_ROWS.Positives
	    	, HTS_TOTALS_COLS_ROWS.Negatives
			, HTS_TOTALS_COLS_ROWS.Total

FROM (

			(SELECT HTS_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					, HTS_STATUS_DRVD_ROWS.Gender
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'PITC' 
							AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Positive'  AND Age <=4, 1, 0 ))) AS Positives
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'PITC'			
							AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Negative' AND Age <=4, 1, 0))) AS Negatives
							

					
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'PITC' AND  Age<=4, 1, 0))) as 'Total'
						, HTS_STATUS_DRVD_ROWS.sort_order
			FROM (

					(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, HIV_Status, 'PITC' AS 'HIV_Testing_Initiation'
							, 'PEADS' AS 'ENTRY', sort_order
					FROM
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365)  AS Age,
														   (select name from concept_name cn where cn.concept_id = o.value_coded and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status,
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   observed_age_group.sort_order AS sort_order

									from obs o
											-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											 AND o.concept_id = 2165
											 AND patient.voided = 0 AND o.voided = 0
											 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
											 
											 
											 -- PROVIDER INITIATED TESTING AND COUNSELING
											 AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4228 and os.value_coded = 4227
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 -- PEADS, MODE OF ENTRY POINT
											 AND o.person_id in (
												select distinct os.person_id
												from obs os
												where os.concept_id = 4238 and os.value_coded = 4788
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_Status
					WHERE Age<=4				   
					ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
                                           

					UNION

					(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, HIV_Status, 'PITC' AS 'HIV_Testing_Initiation'
							, 'PEADS' AS 'ENRTY' , sort_order
					FROM
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
														   (select name from concept_name cn where cn.concept_id = o.value_coded and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status,
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   observed_age_group.sort_order AS sort_order

									from obs o
											-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											 AND o.concept_id = 2165
											 AND patient.voided = 0 AND o.voided = 0
											 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
											 
											 -- PROVIDER INITIATED TESTING AND COUNSELING
											 AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4228 and os.value_coded = 4227
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 -- PEADS, MODE OF ENTRY POINT
											 AND o.person_id in (
												select distinct os.person_id
												from obs os
												where os.concept_id = 4238 and os.value_coded = 4788
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_Status
					WHERE Age<=4				   
					ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)


										UNION

					(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, HIV_Status, 'CITC' AS 'HIV_Testing_Initiation'
							, 'PEADS' AS 'ENRTY', sort_order
					FROM
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
														   (select name from concept_name cn where cn.concept_id = o.value_coded and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status,
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   observed_age_group.sort_order AS sort_order

									from obs o
											-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											 AND o.concept_id = 2165
											 AND patient.voided = 0 AND o.voided = 0
											 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
											 
											 -- CLIENT INITIATED TESTING AND COUNSELING
											 AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4228 and os.value_coded = 4226
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 -- PEADS, DOES NOT HAVE A HISTORY OF PREVIOUS TESTING
											 AND o.person_id in (
												select distinct os.person_id
												from obs os
												where os.concept_id = 4238 and os.value_coded = 4788
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )						 
											 
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_Status
					WHERE Age<=4				   
					ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

			) AS HTS_STATUS_DRVD_ROWS

			GROUP BY HTS_STATUS_DRVD_ROWS.age_group, HTS_STATUS_DRVD_ROWS.Gender
			ORDER BY HTS_STATUS_DRVD_ROWS.sort_order)
			
			
	UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					, 'All' AS 'Gender'
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'PITC' 
						AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Positive' , 1, 0))) AS Positives
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'PITC'			
					AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Negative' , 1, 0))) AS Negatives
						
					, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'PITC' , 1, 0))) as 'Total'
						, 99 AS sort_order
			FROM (

					(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", HIV_Status, 'PITC' AS 'HIV_Testing_Initiation'
							, 'Repeat' AS 'Testing_History'
					FROM
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
														   (select name from concept_name cn where cn.concept_id = o.value_coded and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status

									from obs o
											-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											 AND o.concept_id = 2165
											 AND patient.voided = 0 AND o.voided = 0
											 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
											 
											 -- PROVIDER INITIATED TESTING AND COUNSELING
											 AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4228 and os.value_coded = 4227
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 -- PEADS, MODE OF ENTRY POINT
											 AND o.person_id in (
												select distinct os.person_id
												from obs os
												where os.concept_id = 4238 and os.value_coded = 4788
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
									) AS HTSClients_HIV_Status_Total
					WHERE Age <=4				
					)

					UNION

					(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", HIV_Status, 'PITC' AS 'HIV_Testing_Initiation'
							, 'Repeat' AS 'Testing_History'
					FROM
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
														   (select name from concept_name cn where cn.concept_id = o.value_coded and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status

									from obs o
											-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											 AND o.concept_id = 2165
											 AND patient.voided = 0 AND o.voided = 0
											 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
											 
											 -- PROVIDER INITIATED TESTING AND COUNSELING
											 AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4228 and os.value_coded = 4227
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 -- NEW TESTER, DOES NOT HAVE A HISTORY OF PREVIOUS TESTING
											 AND o.person_id in (
												select distinct os.person_id
												from obs os
												where os.concept_id = 4238 and os.value_coded = 4788
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
									) AS HTSClients_HIV_Status_Total
					WHERE Age<=4				
					)

					UNION

					(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", HIV_Status, 'CITC' AS 'HIV_Testing_Initiation'
							, 'PEADS' AS 'ENTRY'
					FROM
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
														   (select name from concept_name cn where cn.concept_id = o.value_coded and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status

									from obs o
											-- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											 AND o.concept_id = 2165
											 AND patient.voided = 0 AND o.voided = 0
											 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
											 
											 -- PROVIDER INITIATED TESTING AND COUNSELING
											 AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4228 and os.value_coded = 4226
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )
											 
											 -- PEADS, MODE OF ENTRY POINT
											 AND o.person_id in (
												select distinct os.person_id
												from obs os
												where os.concept_id = 4238 and os.value_coded = 4788
												AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
											 )						 
											 
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
									) AS HTSClients_HIV_Status_Total
					WHERE Age<=4				
					)

			

			) AS HTS_STATUS_DRVD_COLS
			
		)
		
	) AS HTS_TOTALS_COLS_ROWS
	
ORDER BY HTS_TOTALS_COLS_ROWS.sort_order

