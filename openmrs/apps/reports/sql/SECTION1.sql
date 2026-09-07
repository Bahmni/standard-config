SELECT Status,	   
 IFNULL(SUM(IF(Persons = 'Children' AND Gender = 'M', 1, 0)),0) AS Children_Males, 
 IFNULL(SUM(IF(Persons = 'Children' AND Gender = 'F', 1, 0)),0) AS Children_Females,
 IFNULL(SUM(IF(Persons = 'Adults' AND Gender = 'M', 1, 0)),0) AS Adults_Males, 
 IFNULL(SUM(IF(Persons = 'Adults' AND Gender = 'F', 1, 0)),0) AS Adults_Females

FROM
    (    SELECT Id,Gender,Status,Persons, patientName
        FROM(
        (SELECT  Id,Gender,'Enrolled_This_Month' as Status,'Children' as Persons, patientName
        FROM(
                select distinct o.person_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
				 concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group
        from obs o 	
				INNER JOIN person ON person.person_id = o.person_id	
				-- Retesting Results Pos
				AND o.concept_id = 4817 and o.value_coded = 1738
				AND o.voided = 0
				AND o.obs_datetime >= (CAST('#startDate#' AS DATE))
        		AND o.obs_datetime <= (CAST('#endDate#' AS DATE))
				AND o.person_id in(
						select distinct os.person_id
						from obs os
						-- Not Linked to Care
						where os.concept_id = 4239 and os.value_coded = 2147
						and os.voided = 0
						and o.obs_datetime >= (CAST('#startDate#' AS DATE))
        				and o.obs_datetime <= (CAST('#endDate#' AS DATE))
						)
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                INNER JOIN reporting_age_group AS observed_age_group ON
                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
        WHERE observed_age_group.report_group_name = 'Modified_Ages'
            ) enrolled_a
        WHERE age < 15 )

        UNION
        (SELECT  Id,Gender,'Enrolled_This_Month' as Status,'Adults', patientName
                FROM(
                        select distinct o.person_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
				 concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group
        from obs o 	
				INNER JOIN person ON person.person_id = o.person_id	
				-- Retesting Results Pos
				AND o.concept_id = 4817 and o.value_coded = 1738
				AND o.voided = 0
				AND o.obs_datetime >= (CAST('#startDate#' AS DATE))
        		AND o.obs_datetime <= (CAST('#endDate#' AS DATE))
				AND o.person_id in(
						select distinct os.person_id
						from obs os
						-- Not Linked to Care
						where os.concept_id = 4239 and os.value_coded = 2147
						and os.voided = 0
						and o.obs_datetime >= (CAST('#startDate#' AS DATE))
        				and o.obs_datetime <= (CAST('#endDate#' AS DATE))
						)
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                INNER JOIN reporting_age_group AS observed_age_group ON
                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
        WHERE observed_age_group.report_group_name = 'Modified_Ages'
        ) enrolled_b
        WHERE age > 15 
		) 

        UNION
        (SELECT  Id,Gender,'Ever_enrolled_PreART' as Status,'Children' as Persons, patientName
        FROM(

                        select distinct o.person_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
				 concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group
        from obs o 	
				INNER JOIN person ON person.person_id = o.person_id	
				-- Retesting Results Pos
				AND o.concept_id = 4817 and o.value_coded = 1738
				AND o.voided = 0
				AND o.obs_datetime >= (CAST('#startDate#' AS DATE))
        		AND o.obs_datetime <= (CAST('#endDate#' AS DATE))
				AND o.person_id in(
						select distinct os.person_id
						from obs os
						-- Not Linked to Care
						where os.concept_id = 4239 and os.value_coded = 2147
						and os.voided = 0
						and o.obs_datetime >= (CAST('#startDate#' AS DATE))
        				and o.obs_datetime <= (CAST('#endDate#' AS DATE))
						)
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                INNER JOIN reporting_age_group AS observed_age_group ON
                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
        WHERE observed_age_group.report_group_name = 'Modified_Ages'
                )preart_a
        WHERE age < 15)

        UNION

        (
        SELECT  Id,Gender,'Ever_enrolled_PreART' as Status,'Adults' as Persons, patientName
        FROM(
                select distinct o.person_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
				 concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group
        from obs o 	
				INNER JOIN person ON person.person_id = o.person_id	
				-- Retesting Results Pos
				AND o.concept_id = 4817 and o.value_coded = 1738
				AND o.voided = 0
				AND o.obs_datetime >= (CAST('#startDate#' AS DATE))
        		AND o.obs_datetime <= (CAST('#endDate#' AS DATE))
				AND o.person_id in(
						select distinct os.person_id
						from obs os
						-- Not Linked to Care
						where os.concept_id = 4239 and os.value_coded = 2147
						and os.voided = 0
						and o.obs_datetime >= (CAST('#startDate#' AS DATE))
        				and o.obs_datetime <= (CAST('#endDate#' AS DATE))
						)
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                INNER JOIN reporting_age_group AS observed_age_group ON
                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
        WHERE observed_age_group.report_group_name = 'Modified_Ages'
                )preart_b
        WHERE age > 15   
        )
		

        )all_enrolled
) all_joined
GROUP BY Status
ORDER BY FIELD (Status,'Enrolled_This_Month','Ever_enrolled_PreART') 

