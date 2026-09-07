select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   'Initiated 6 months ago' as 'Status'

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART 6 MONTHS AGO
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
								and CAST(o.value_datetime AS DATE) >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -6 MONTH)
								and CAST(o.value_datetime AS DATE) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)
								and o.voided = 0
						 )

						 AND patient.voided = 0 AND o.voided = 0
						 -- HAVE NOT DRAWN BLOOD
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 4276
							AND os.value_coded = 4277
							and os.voided = 0
						 )	

						 and o.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'

UNION

select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   'Initiated 12 months ago' as 'Status'

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART 12 MONTHS AGO
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
								and CAST(o.value_datetime AS DATE) >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -12 MONTH)
								and CAST(o.value_datetime AS DATE) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
								and o.voided = 0
						 )

						 AND patient.voided = 0 AND o.voided = 0
						 -- HAVE NOT DRAWN BLOOD
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 4276
							AND os.value_coded = 4277
							and os.voided = 0
						 )	

						 and o.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'

UNION

select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   'Annual Bload draw' as 'Status'

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART IN THE SAME MONTH BUT PAST YEARS
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
								and MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								and YEAR(o.value_datetime) < YEAR(CAST('#endDate#' AS DATE))
								and o.voided = 0
						 )

						 AND patient.voided = 0 AND o.voided = 0
						 -- HAVE NOT DRAWN BLOOD
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 4276
							AND os.value_coded = 4277
							and cast(os.obs_datetime as date) >= CAST('#startDate#' AS DATE)
							and cast(os.obs_datetime as date) <= CAST('#endDate#' AS DATE)
							and os.voided = 0
						 )	

						 and o.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'


UNION

select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   'More than 1000 copies' as 'Status'

                from obs o
						-- CLIENTS WITH MORE THAN 1000 COPIES - FROM THE OLD and NEW LAB CONCEPT
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND o.person_id in
                                (
                                    select person_id
                                        from obs o
                                        where o.concept_id = 5485 
                                        and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -3 MONTH)
                                        and CAST(o.obs_datetime AS DATE) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
                                        and o.voided = 0
                                        and o.value_numeric > 1000
                                    
                                    UNION

                                    select person_id
                                        from obs o
                                        where o.concept_id = 2254 
                                        and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -3 MONTH)
                                        and CAST(o.obs_datetime AS DATE) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
                                        and o.voided = 0
                                        and o.value_numeric > 1000
						 )

						 AND patient.voided = 0 AND o.voided = 0
						 -- HAVE NOT DRAWN BLOOD
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 4276
							AND os.value_coded = 4277
							and cast(os.obs_datetime as date) >= CAST('#startDate#' AS DATE)
							and cast(os.obs_datetime as date) <= CAST('#endDate#' AS DATE)
							and os.voided = 0
						 )	

						 and o.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'