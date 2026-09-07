
select AgeGroup,Index_Males,Index_Females,self_tested_Males,self_tested_Females

from  (select age_group as AgeGroup
		, IF(Id IS NULL, 0, SUM(IF(outcome = 'Indexing' AND gender = 'M', 1, 0))) AS Index_Males
		, IF(Id IS NULL, 0, SUM(IF(outcome = 'Indexing' AND gender = 'F', 1, 0))) AS Index_Females
		, IF(Id IS NULL, 0, SUM(IF(outcome = 'Self_testing' AND gender = 'M', 1, 0))) AS self_tested_Males
		, IF(Id IS NULL, 0, SUM(IF(outcome = 'Self_testing' AND gender = 'F', 1, 0))) AS self_tested_Females

		FROM
		(
						select o.person_id as Id,  'indexing' as outcome,
										floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS Age,
									   p.gender AS Gender,
									   observed_age_group.name AS age_group
									   from obs o
						INNER JOIN person p ON o.person_id = p.person_id
						AND o.person_id in (select person_id
										from obs
										where concept_id = 4662 and value_coded = 4661
										)
						INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(p.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(p.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  UNION
						  
						 select o.person_id as Id,  'self_testing' as outcome,
						floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS Age,
									   p.gender AS Gender,
									   observed_age_group.name AS age_group
									   from obs o
						INNER JOIN person p ON o.person_id = p.person_id
						AND o.person_id in (select person_id
										from obs 
										where concept_id = 4662 and value_coded = 4237
										)
						INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(p.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(p.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
		) as a
		
		) as b group by AgeGroup