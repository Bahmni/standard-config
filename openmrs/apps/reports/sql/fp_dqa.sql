

SELECT distinct Patient_Identifier
			   ,FP_Number
			   ,Date
			   ,Patient_Name
			   ,Age
			   ,Sex
			   ,FP_Visit as 'Type of visit'
			   ,Known_HIV_Status
			   ,HIV_Status
			   ,OnART
			   ,Prep_Provided
			   ,Initial_FP_Method
			   ,Switched_FP_Method
			   ,Method_Provided
			   ,Subsequent_visit_date
FROM
( 

	 (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Sex,       
                             CASE
                                WHEN code = 2093 THEN 'New'
                                WHEN code = 4539 THEN 'Revisit'
                                WHEN code = 2303 THEN 'Restarted'
                             ELSE 'typeOfFpVisit'
                             END AS 'FP_Visit', sort_order
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Sex,
											   observed_age_group.sort_order AS sort_order,
                                               o.value_coded as 'code'

						from obs o
								-- FP Attendance 

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4538 and o.value_coded IN (2093,4539,2303)
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
						   and o.voided = 0
						) AS new_fp
		    ORDER BY new_fp.sort_order desc
			
			)FP_VISITS 

	LEFT OUTER JOIN 

			(
				select
				o.person_id, o.value_numeric as FP_Number
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as FPNumber, value_numeric as number
					from obs oss
					where oss.concept_id = 4557 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 5446
				and  cast(o.obs_datetime as date) = max_observation
				and o.voided = 0
			) FPNumber
			ON FP_VISITS.Id =  FPNumber.person_id

	LEFT OUTER JOIN 

			(
					select oss.person_id, cast(MAX(oss.obs_datetime) as Date) as Date,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as ObsDate
					from obs oss
					where oss.concept_id = 4557 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					and oss.voided = 0
					group by oss.person_id
					
			)ObsDate
			ON FP_VISITS.Id = ObsDate.person_id

	LEFT OUTER JOIN 

			(
				select
				o.person_id,
				case
					when value_coded = 4323 then "Known Positive"
					when value_coded = 4324 then "Know Negative"
					when value_coded = 1739 then "Unknown"
					else ""
				end AS Known_HIV_Status
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as known_testing
					from obs oss
					where oss.concept_id = 4557 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 5201
				and  o.obs_datetime = max_observation
				and o.voided = 0
			)known_testing
			ON FP_VISITS.Id = known_testing.person_id


	LEFT OUTER JOIN 

			(
				select
				o.person_id,
				case
					when value_coded = 1738 then "Positive"
					when value_coded = 1016 then "Negative"
					when value_coded = 1739 then "Unknown"
					else ""
				end AS HIV_Status
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as hiv_testing
					from obs oss
					where oss.concept_id = 4557 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 5202
				and  o.obs_datetime = max_observation
				and o.voided = 0
			)hiv_testing
			ON FP_VISITS.Id = hiv_testing.person_id

	LEFT JOIN 

			(
				select distinct person_id as Id, CASE
				when OnART ='Yes' then 'Yes'
				else 'No'
				end as OnART
					from   
					(select on_art.person_id, OnART
					from
					(
					select distinct o.person_id, 'Yes' as 'OnART'
					from obs o
					where o.concept_id = 2403 and o.voided = 0
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					and o.voided = 0
					)on_art
				)On_ART
			)art
			ON FP_VISITS.Id = art.Id

	LEFT JOIN
			(select
				o.person_id,
				case
					when value_coded = 2146 then "Yes"
					when value_coded = 2147 then "No"
					when value_coded = 1975 then "N/A"
					else " "
				end AS Prep_Provided
			from obs o
			inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as prep_taken
					from obs oss
					where oss.concept_id = 4557 and oss.voided=0
					and oss.obs_datetime < cast('#endDate#' as date)
					group by oss.person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 5204
				and  o.obs_datetime = max_observation
				and o.voided = 0
				) prep_taken
			ON FP_VISITS.Id = prep_taken.person_id

	LEFT OUTER JOIN 
			(
				select distinct
				B.person_id,
				case
						WHEN value_coded = 5205 THEN 'Progestrone only pill' 
						WHEN value_coded = 5206 THEN 'Combined oral contraceptive' 
						WHEN value_coded = 5207 THEN 'Depo medroxy progestrone acetate subcutatneous (DMPA-SC)' 
						WHEN value_coded = 5208 THEN 'Depo medroxy progestrone acetate intramusc' 
						WHEN value_coded = 5209 THEN 'Noristrate (NTE)' 
						WHEN value_coded = 2314 THEN 'Implant' 
						WHEN value_coded = 4551 THEN 'Jadelle' 
						WHEN value_coded = 5212 THEN 'Norplant' 
						WHEN value_coded = 4441 THEN 'Lactational Amenorrhea Method' 
						WHEN value_coded = 4552 THEN 'Copper T380A' 
						WHEN value_coded = 5214 THEN 'Intra Uterine Contraceptive Device(IUCD)' 
						WHEN value_coded = 4440 THEN 'Bilateral Tubal Ligation (BTL)' 
						WHEN value_coded = 2497 THEN 'Vasectomy' 
						WHEN value_coded = 4229 THEN 'Male Condoms' 
						WHEN value_coded = 4230 THEN 'Female Condoms' 
						WHEN value_coded = 4553 THEN 'Standard Days Method' 
						WHEN value_coded = 5215 THEN 'Emegency Pill' 
						WHEN value_coded = 1154 THEN 'None' 
						ELSE ''
				end AS Initial_FP_Method
				from obs B 
				
					inner join 
						(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs 
						where concept_id = 4540 -- initial fp method form
						and obs_datetime <= cast('#endDate#' as date)
						and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						where B.concept_id = 2481
						and A.observation_id = B.obs_group_id
						and B.voided = 0	
						AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				
			) fp_method
			ON FP_VISITS.Id = fp_method.person_id

	LEFT JOIN
			(select
				o.person_id,
				case
					when value_coded = 1 then "Yes"
					when value_coded = 2 then "No"
					else " "
				end AS Switched_FP_Method
			from obs o
			inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as switched_FP
					from obs oss
					where oss.concept_id = 4557 and oss.voided=0
					and oss.obs_datetime < cast('#endDate#' as date)
					group by oss.person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 5217
				and  o.obs_datetime = max_observation
				and o.voided = 0
				) switched_FP
			ON FP_VISITS.Id = switched_FP.person_id

	
	LEFT OUTER JOIN 
			(
				select distinct
				B.person_id,
				case
						WHEN value_coded = 5205 THEN 'Progestrone only pill' 
						WHEN value_coded = 5206 THEN 'Combined oral contraceptive' 
						WHEN value_coded = 5207 THEN 'Depo medroxy progestrone acetate subcutatneous (DMPA-SC)' 
						WHEN value_coded = 5208 THEN 'Depo medroxy progestrone acetate intramusc' 
						WHEN value_coded = 5209 THEN 'Noristrate (NTE)' 
						WHEN value_coded = 2314 THEN 'Implant' 
						WHEN value_coded = 4551 THEN 'Jadelle' 
						WHEN value_coded = 5212 THEN 'Norplant' 
						WHEN value_coded = 4441 THEN 'Lactational Amenorrhea Method' 
						WHEN value_coded = 4552 THEN 'Copper T380A' 
						WHEN value_coded = 5214 THEN 'Intra Uterine Contraceptive Device(IUCD)' 
						WHEN value_coded = 4440 THEN 'Bilateral Tubal Ligation (BTL)' 
						WHEN value_coded = 2497 THEN 'Vasectomy' 
						WHEN value_coded = 4229 THEN 'Male Condoms' 
						WHEN value_coded = 4230 THEN 'Female Condoms' 
						WHEN value_coded = 4553 THEN 'Standard Days Method' 
						WHEN value_coded = 5215 THEN 'Emegency Pill' 
						WHEN value_coded = 1154 THEN 'None' 
						ELSE ''
				end AS Method_Provided
				from obs B 
				
					inner join 
						(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs 
						where concept_id = 5225 -- initial fp method form
						and obs_datetime <= cast('#endDate#' as date)
						and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						where B.concept_id = 2481
						and A.observation_id = B.obs_group_id
						and B.voided = 0	
						AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				
			) method
			ON FP_VISITS.Id = method.person_id

	LEFT OUTER JOIN 

			(
				select
				o.person_id, cast(o.value_datetime as date) as Subsequent_visit_date
				from obs o
				inner join
					(
					select oss.person_id, cast(MAX(oss.obs_datetime) as date) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as followup
					from obs oss
					where oss.concept_id = 4554 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 149
				and  cast(o.obs_datetime as date) = max_observation
				and o.voided = 0
			) Follow_up
		ON FP_VISITS.Id = Follow_up.person_id
)




			