SELECT
	IFNULL(rolled_up.age_group, 'Total') AS "Age Group",
	rolled_up.with_contacts AS "With Contacts",
	rolled_up.without_contacts AS "Without Contacts",
	rolled_up.total AS "Total"
FROM (

SELECT
	ap.age_group AS age_group,
	SUM(CASE WHEN EXISTS (
			SELECT 1 FROM person_attribute pa
			WHERE pa.person_id = ap.Id AND pa.person_attribute_type_id = 26 AND pa.voided = 0
		) THEN 1 ELSE 0 END) AS with_contacts,
	SUM(CASE WHEN NOT EXISTS (
			SELECT 1 FROM person_attribute pa
			WHERE pa.person_id = ap.Id AND pa.person_attribute_type_id = 26 AND pa.voided = 0
		) THEN 1 ELSE 0 END) AS without_contacts,
	COUNT(*) AS total
FROM (

SELECT DISTINCT Id, age_group FROM (

-- CLIENTS NEWLY INITIATED ON ART
select distinct patient.patient_id AS Id, observed_age_group.name AS age_group
from obs o
		 INNER JOIN patient ON o.person_id = patient.patient_id 
		 AND (o.concept_id = 2249 
		AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
		AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
		 )
		 AND patient.voided = 0 AND o.voided = 0
		 AND o.person_id not in (
			select distinct os.person_id from obs os
			where os.concept_id = 3634 
			AND os.value_coded = 2095 
			and os.voided = 0
			AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
		 )	
		 and o.person_id not in (
					select person_id 
					from person 
					where death_date <= cast('#endDate#' as date)
					and dead = 1 and voided = 0
		 )
		 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		 INNER JOIN reporting_age_group AS observed_age_group ON
		  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
		  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
WHERE observed_age_group.report_group_name = 'Modified_Ages'

UNION

-- CLIENTS SEEN FOR ART
select distinct patient.patient_id AS Id, observed_age_group.name AS age_group
from obs o
		 INNER JOIN patient ON o.person_id = patient.patient_id
		 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
		 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
		 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
		 AND patient.voided = 0 AND o.voided = 0
		 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		 INNER JOIN reporting_age_group AS observed_age_group ON
			  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
			  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
WHERE observed_age_group.report_group_name = 'Modified_Ages'
AND patient.patient_id not in (
		select distinct patient.patient_id
		from obs o
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 
							AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						)		
				 AND patient.voided = 0 AND o.voided = 0
				 AND o.person_id not in (
					select distinct os.person_id from obs os
					where os.concept_id = 3634 
					AND os.value_coded = 2095 
					and os.voided = 0
					AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
				 )	
)
AND patient.patient_id not in (
		select distinct(o.person_id)
		from obs o
		where o.person_id in (
				select firstquery.person_id
				from
				(
				select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
				from obs oss
						where oss.voided=0 
						and oss.concept_id=3752 
						and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
						group by oss.person_id) firstquery
				inner join (
						select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
						from obs os
						where concept_id = 3752 and os.voided = 0
						and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						group by os.person_id
						having last_ap < 0
				) secondquery
				on firstquery.person_id = secondquery.person_id
		) and o.person_id in (
				select distinct(person_id)
				from
				(
					select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
					from obs os
					where os.concept_id=2266 and os.voided = 0
					group by os.person_id
					having latest_transferout <= CAST('#endDate#' AS DATE)
				) as TOUTS
		)					
)
AND patient.patient_id not in (
		select distinct(o.person_id)
		from obs o
		where o.person_id in (
				select firstquery.person_id
				from
				(
				select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
				from obs oss
						where oss.voided=0 
						and oss.concept_id=3752 
						and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
						group by oss.person_id) firstquery
				inner join (
						select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
						from obs os
						where concept_id = 3752 and os.voided = 0
						and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						group by os.person_id
						having last_ap < 0
				) secondquery
				on firstquery.person_id = secondquery.person_id
		)
		and o.person_id in (
				select distinct p.person_id
				from person p
				where dead = 1
				and death_date <= CAST('#endDate#' AS DATE)	
				and voided = 0	
		)
)
AND patient.patient_id not in (
		select o.person_id
		from obs o
		inner join
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
				from obs oss
				where oss.concept_id IN (3753, 6515)
				and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
				group by oss.person_id
				)latest
			on latest.person_id = o.person_id
			where concept_id = 5416
			and o.value_coded =1 and o.voided=0
			and  cast(o.obs_datetime as date) = cast(max_observation as date)
)
AND patient.patient_id not in (
		select distinct p.person_id as Id
		from person p
		where dead = 1
		and death_date <= CAST('#endDate#' AS DATE)	
		and voided = 0
)

UNION

-- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
select distinct patient.patient_id AS Id, observed_age_group.name AS age_group
from obs o
		 INNER JOIN patient ON o.person_id = patient.patient_id
		 AND o.person_id in (
			select active_clients.person_id
					from
					(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
						from obs B
						inner join 
						(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs where concept_id IN (3753, 6515)
						and obs_datetime <= cast('#endDate#' as date)
						and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						where concept_id = 3752
						and A.observation_id = B.obs_group_id
						and voided = 0	
						group by B.person_id
					) as active_clients
					where active_clients.latest_follow_up < cast('#endDate#' as date)
					and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <= 28
			and active_clients.person_id not in (
						select distinct os.person_id
						from obs os
						where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
						AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						and os.voided = 0
						)
			and active_clients.person_id not in (
						select distinct os.person_id
						from obs os
						where concept_id = 2249
						AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						and os.voided = 0
						)
			and active_clients.person_id not in (
						select tout_clients.person_id
						from
						(select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
							from obs B
							inner join
							(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
							from obs where concept_id = 2403
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
							group by person_id) as A
							on A.observation_id = B.obs_group_id
							where concept_id = 2398
							and A.observation_id = B.obs_group_id
							and voided = 0
							group by B.person_id
						) as tout_clients
						where tout_clients.latest_consultation < cast('#endDate#' as date)
						)
			and active_clients.person_id not in (
						select person_id 
						from person 
						where death_date <= cast('#endDate#' as date)
						and dead = 1 and voided = 0
						 )
			and active_clients.person_id not in(
						select o.person_id
						from obs o
						inner join
								(
								select oss.person_id, MAX(oss.obs_datetime) as max_observation,
								SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
								from obs oss
								where oss.concept_id IN (3753, 6515) 
								and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
								group by oss.person_id
								)latest
							on latest.person_id = o.person_id
							where concept_id = 5416
							and o.value_coded =1 and o.voided=0
							and  cast(o.obs_datetime as date) = cast(max_observation as date)
					)				 
				 )
		 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		 INNER JOIN reporting_age_group AS observed_age_group ON
		  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
		  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
WHERE observed_age_group.report_group_name = 'Modified_Ages'

UNION

-- CLIENTS SEEN, PREVIOUS PERIOD (still active, next appointment in the future)
select distinct patient.patient_id AS Id, observed_age_group.name AS age_group
from obs o
		 INNER JOIN patient ON o.person_id = patient.patient_id
		 AND o.person_id in (
			select active_clients.person_id
					from
					(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
						from obs B
						inner join 
						(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs where concept_id IN (3753, 6515)
						and obs_datetime <= cast('#endDate#' as date)
						and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						where concept_id = 3752
						and A.observation_id = B.obs_group_id
						and voided = 0	
						group by B.person_id	
					) as active_clients
					where active_clients.latest_follow_up >= cast('#endDate#' as date)
			and active_clients.person_id not in (
						select distinct os.person_id
						from obs os
						where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
						AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND os.voided = 0
						)
			and active_clients.person_id not in (
						select distinct os.person_id
						from obs os
						where concept_id = 2249
						AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND os.voided = 0
						)
			and active_clients.person_id not in (
						select distinct(o.person_id)
						from obs o
						where o.person_id in (
								select firstquery.person_id
								from
								(
								select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
								from obs oss
											where oss.voided=0 
											and oss.concept_id=3752 
											and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
											group by oss.person_id) firstquery
								inner join (
											select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
											from obs os
											where concept_id = 3752 and os.voided = 0
											and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											group by os.person_id
											having last_ap < 0
								) secondquery
								on firstquery.person_id = secondquery.person_id
						) and o.person_id in (
								select distinct(person_id)
								from
								(
									select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
									from obs os
									where os.concept_id=2266 and os.voided = 0
									group by os.person_id
									having latest_transferout <= CAST('#endDate#' AS DATE)
								) as TOUTS
						)			
									)
			and active_clients.person_id not in (
						select person_id 
						from person 
						where death_date <= cast('#endDate#' as date)
						and dead = 1 and voided = 0
						 )
			and active_clients.person_id not in (
						select o.person_id
						from obs o
						inner join
								(
								select oss.person_id, MAX(oss.obs_datetime) as max_observation,
								SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
								from obs oss
								where oss.concept_id IN (3753, 6515) 
								and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
								group by oss.person_id
								)latest
							on latest.person_id = o.person_id
							where concept_id = 5416
							and o.value_coded =1 and o.voided=0
							and  cast(o.obs_datetime as date) = cast(max_observation as date)
						 )
						 )
		 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		 INNER JOIN reporting_age_group AS observed_age_group ON
		  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
		  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
WHERE observed_age_group.report_group_name = 'Modified_Ages'

) AS ART_Patients

) ap
GROUP BY ap.age_group WITH ROLLUP

) AS rolled_up
ORDER BY (rolled_up.age_group IS NULL), rolled_up.age_group;