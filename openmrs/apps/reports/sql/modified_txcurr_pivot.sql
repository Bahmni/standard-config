SELECT Total_Aggregated_TxCurr.AgeGroup
		, Total_Aggregated_TxCurr.Initiated_Males
		, Total_Aggregated_TxCurr.Initiated_Females
		, Total_Aggregated_TxCurr.Seen_Males
		, Total_Aggregated_TxCurr.Seen_Females
		, Total_Aggregated_TxCurr.SeenPrev_Males
		, Total_Aggregated_TxCurr.SeenPrev_Females
		, Total_Aggregated_TxCurr.Total

FROM

(
	(SELECT TXCURR_DETAILS.age_group AS 'AgeGroup'
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.Program_Status = 'Initiated' AND TXCURR_DETAILS.Gender = 'M', 1, 0))) AS Initiated_Males
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.Program_Status = 'Initiated' AND TXCURR_DETAILS.Gender = 'F', 1, 0))) AS Initiated_Females
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.Program_Status = 'Seen' AND TXCURR_DETAILS.Gender = 'M', 1, 0))) AS Seen_Males
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.Program_Status = 'Seen' AND TXCURR_DETAILS.Gender = 'F', 1, 0))) AS Seen_Females
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.Program_Status = 'Seen_Prev_Months' AND TXCURR_DETAILS.Gender = 'M', 1, 0))) AS SeenPrev_Males
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.Program_Status = 'Seen_Prev_Months' AND TXCURR_DETAILS.Gender = 'F', 1, 0))) AS SeenPrev_Females
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, TXCURR_DETAILS.sort_order			
			
	FROM

	(
	
(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Initiated' AS 'Program_Status', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) 
						 AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )	
						AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								
								select distinct os.person_id 
							   from obs os
							   where (os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime <= CAST('#endDate#' AS DATE)
							   AND person_id not in 
							   (select person_id from
									(select person_id who, max(value_datetime) latest
									from obs 
									where concept_ID = 2266
									and obs_datetime <= CAST('#endDate#' AS DATE)
									group by person_id) one,
									
									 (
									select person_id,obs_datetime 
									from obs 
									where concept_id = 3843
									and obs_datetime <= CAST('#endDate#' AS DATE)
									) two
									
									where who = person_id
									and DATE(obs_datetime) > DATE(latest)
								)
									)
						)						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age)

UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen' AS 'Program_Status', sort_order
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
                                 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
			select distinct patient.patient_id AS Id
			from obs o
				-- CLIENTS NEWLY INITIATED ON ART
			INNER JOIN patient ON o.person_id = patient.patient_id
			 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
			 AND patient.voided = 0 AND o.voided = 0
			 AND o.person_id not in (
					select distinct os.person_id from obs os
					where os.concept_id = 3634 
					AND os.value_coded = 2095 
					AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
		)
		AND Clients_Seen.Id not in (
			
								select distinct os.person_id 
							   from obs os
							   where (os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime <= CAST('#endDate#' AS DATE)
							   AND person_id not in 
							   (select person_id from
									(select person_id who, max(value_datetime) latest
									from obs 
									where concept_ID = 2266
									and obs_datetime <= CAST('#endDate#' AS DATE)
									group by person_id) one,
									
									 (
									select person_id,obs_datetime 
									from obs 
									where concept_id = 3843
									and obs_datetime <= CAST('#endDate#' AS DATE)
									) two
									
									where who = person_id
									and DATE(obs_datetime) > DATE(latest)
								)
									)
		)
		AND Clients_Seen.Id not in (
				select distinct person_id 
				from person
				where death_date < CAST('#endDate#' AS DATE)
				and dead = 1
		)


ORDER BY Clients_Seen.Age)

UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status', sort_order
FROM (
(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

        from obs o
				-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
				  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
				  AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247))
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				 INNER JOIN person_name ON person.person_id = person_name.person_id
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
                 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')
	   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')
		

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4175
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
										)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4176
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4177
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4245
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4246
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')		   
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.Id not in (
				SELECT os.person_id 
				FROM obs os
				WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
				AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						)
AND ARTCurrent_PrevMonths.Id not in (
				
								select distinct os.person_id 
							   from obs os
							   where (os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime <= CAST('#endDate#' AS DATE)
							   AND person_id not in 
							   (select person_id from
									(select person_id who, max(value_datetime) latest
									from obs 
									where concept_ID = 2266
									and obs_datetime <= CAST('#endDate#' AS DATE)
									group by person_id) one,
									
									 (
									select person_id,obs_datetime 
									from obs 
									where concept_id = 3843
									and obs_datetime <= CAST('#endDate#' AS DATE)
									) two
									
									where who = person_id
									and DATE(obs_datetime) > DATE(latest)
								)
									)
		)
AND ARTCurrent_PrevMonths.Id not in (
			select person_id 
			from person 
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)
ORDER BY ARTCurrent_PrevMonths.Age)	

	) AS TXCURR_DETAILS

	GROUP BY TXCURR_DETAILS.age_group
	ORDER BY TXCURR_DETAILS.sort_order)
	
	
UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'Initiated' AND Totals.Gender = 'M', 1, 0))) AS 'Initiated_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'Initiated' AND Totals.Gender = 'F', 1, 0))) AS 'Initiated_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'Seen' AND Totals.Gender = 'M', 1, 0))) AS 'Seen_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'Seen' AND Totals.Gender = 'F', 1, 0))) AS 'Seen_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'Seen_Prev_Months' AND Totals.Gender = 'M', 1, 0))) AS 'SeenPrev_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'Seen_Prev_Months' AND Totals.Gender = 'F', 1, 0))) AS 'SeenPrev_Females'
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_TxCurr.Id
					, Total_TxCurr.patientIdentifier AS "Patient Identifier"
					, Total_TxCurr.patientName AS "Patient Name"
					, Total_TxCurr.Age
					, Total_TxCurr.Gender
					, Total_TxCurr.Program_Status
				
		FROM

		(

		(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   'Initiated' AS Program_Status
						from obs o
								-- CLIENTS NEWLY INITIATED ON ART
								 INNER JOIN patient ON o.person_id = patient.patient_id AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) 
								 AND CAST('#endDate#' AS DATE))
								 AND patient.voided = 0 AND o.voided = 0
								 AND o.person_id not in (
									select distinct os.person_id from obs os
									where 
										os.concept_id = 3634 AND os.value_coded = 2095 AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								 )	
								AND o.person_id not in 
										(
										select distinct person_id 
															from person
															where death_date < CAST('#endDate#' AS DATE)
															and dead = 1
										)
								AND o.person_id not in 
										(
										select distinct os.person_id 
							   from obs os
							   where (os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime <= CAST('#endDate#' AS DATE)
							   AND person_id not in 
							   (select person_id from
									(select person_id who, max(value_datetime) latest
									from obs 
									where concept_ID = 2266
									and obs_datetime <= CAST('#endDate#' AS DATE)
									group by person_id) one,
									
									 (
									select person_id,obs_datetime 
									from obs 
									where concept_id = 3843
									and obs_datetime <= CAST('#endDate#' AS DATE)
									) two
									
									where who = person_id
									and DATE(obs_datetime) > DATE(latest)
								)
									)
								)						 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)


		UNION


		(SELECT Id, patientIdentifier, patientName, Age, Gender, 'Seen' AS 'Program_Status'
		FROM

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
										   person.gender AS Gender

				from obs o
																		-- CLIENTS SEEN FOR ART
										 INNER JOIN patient ON o.person_id = patient.patient_id
										 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
										 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
										 AND patient.voided = 0 AND o.voided = 0
										 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
										 INNER JOIN person_name ON person.person_id = person_name.person_id
										 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
		) AS Total_ClientsSeen

		WHERE Total_ClientsSeen.Id not in (
					select distinct patient.patient_id AS Id
					from obs o
						-- CLIENTS NEWLY INITIATED ON ART
					INNER JOIN patient ON o.person_id = patient.patient_id
					 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
					 AND patient.voided = 0 AND o.voided = 0
					 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				)
				AND Total_ClientsSeen.Id not in (
					select distinct os.person_id 
							   from obs os
							   where (os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime <= CAST('#endDate#' AS DATE)
							   AND person_id not in 
							   (select person_id from
									(select person_id who, max(value_datetime) latest
									from obs 
									where concept_ID = 2266
									and obs_datetime <= CAST('#endDate#' AS DATE)
									group by person_id) one,
									
									 (
									select person_id,obs_datetime 
									from obs 
									where concept_id = 3843
									and obs_datetime <= CAST('#endDate#' AS DATE)
									) two
									
									where who = person_id
									and DATE(obs_datetime) > DATE(latest)
								)
									)
				)
				AND Total_ClientsSeen.Id not in (
						select distinct person_id 
						from person
						where death_date < CAST('#endDate#' AS DATE)
						and dead = 1
				)
		)

		UNION

		(SELECT Id, patientIdentifier, patientName, Age, Gender, 'Seen_Prev_Months' AS 'Program_Status'
		FROM (


		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
										   person.gender AS Gender

				from obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
						  AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247))
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)
			   
		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4246 or o.value_coded = 4247)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)



		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4247
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)
				

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4175
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)
				   
		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4176
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)
				   
		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4177
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)
				   
		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4245
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)



		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4246
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)



		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender
						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4247
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3)   
				   
		) AS ARTCurrent_PrevMonths
		 
		WHERE ARTCurrent_PrevMonths.Id not in (
						SELECT os.person_id 
						FROM obs os
						WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
						AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
								)
		AND ARTCurrent_PrevMonths.Id not in (
						select distinct os.person_id 
							   from obs os
							   where (os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime <= CAST('#endDate#' AS DATE)
							   AND person_id not in 
							   (select person_id from
									(select person_id who, max(value_datetime) latest
									from obs 
									where concept_ID = 2266
									and obs_datetime <= CAST('#endDate#' AS DATE)
									group by person_id) one,
									
									 (
									select person_id,obs_datetime 
									from obs 
									where concept_id = 3843
									and obs_datetime <= CAST('#endDate#' AS DATE)
									) two
									
									where who = person_id
									and DATE(obs_datetime) > DATE(latest)
								)
									)
				)	
		AND ARTCurrent_PrevMonths.Id not in (
					select person_id 
					from person 
					where death_date < CAST('#endDate#' AS DATE)
					and dead = 1
					)
			   )
		) AS Total_TxCurr
  ) AS Totals
 )
) AS Total_Aggregated_TxCurr
ORDER BY Total_Aggregated_TxCurr.sort_order


