SELECT age_group AS 'AgeGroup'
			, IF(Id IS NULL, 0, SUM(IF(Program_Status = 'Enrolled' AND Gender = 'M', 1, 0))) AS Enrolled_Males
			, IF(Id IS NULL, 0, SUM(IF(Program_Status = 'Enrolled' AND Gender = 'F', 1, 0))) AS Enrolled_Females
FROM(		
	select distinct o.person_id AS Id,
			floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS Age,
									   p.gender AS Gender,'Enrolled' as Program_Status,
									   observed_age_group.name AS age_group
 from obs o
		INNER JOIN person p ON o.person_id = p.person_id 
		AND (o.concept_id = 2223 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
		AND p.voided = 0 AND o.voided = 0
		INNER JOIN patient_identifier ON patient_identifier.patient_id = p.person_id AND patient_identifier.identifier_type = 3
		INNER JOIN reporting_age_group AS observed_age_group ON
		  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(p.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
		  AND (DATE_ADD(DATE_ADD(p.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_ART_Clients
						
	