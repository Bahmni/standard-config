Select distinct Id,patientName, Height, Weight, 2SD,HIV_Exposure_Status, Feeding_Options, Growth_Monitoring
FROM
(
	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
			person.gender AS Gender,
			MAX(obs_datetime)  obs_date
	from obs o
					--  Children
		INNER JOIN patient ON o.person_id = patient.patient_id
		AND o.concept_id = 4285
		AND patient.voided = 0 AND o.voided = 0
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
	Group by Id
	having Months < 60

) As Child
 
 -- Height
left outer join
	(select o.person_id, o.value_numeric as Height, CAST(obs_datetime AS DATE) as height_obs_date
	from obs o 
	inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) as height_obs
		 from obs oss
		 where oss.concept_id = 118 and oss.voided=0
		 and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 118
	and o.voided=0
	and  o.obs_datetime = max_observation	
	)hheight
on Child.Id = hheight.person_id


-- Weight

left outer join
	(select o.person_id, o.value_numeric as Weight, CAST(obs_datetime AS DATE) as weight_obs_date
	from obs o 
	inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) as Weight_obs
		 from obs oss
		 where oss.concept_id = 119 
		 and oss.voided=0
		 and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where o.concept_id = 119
	and o.voided=0
	and  o.obs_datetime = max_observation	
	)hWeight
on Child.Id = hWeight.person_id

-- 2SDa

left outer join
	(select o.person_id, CAST(obs_datetime AS DATE) as 2sd_obs_date, 2SD
	from obs o 
	inner join 
		(
		  select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 		SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) as Weight_obs, 
			case
			when oss.value_coded = 4465 then "Under5, <-2SD"
			when oss.value_coded = 4466 then "Under5, <-3SD"
			else "N/A"
			end AS 2SD
			from obs oss
			where oss.concept_id = 4602 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 4602
	and o.voided=0
	and  o.obs_datetime = max_observation	
	)2SD
on Child.Id = 2SD.person_id

-- Feeding Options

left outer join
	(
		select o.person_id,case 
			when o.value_coded = 2373 then "Exclusive Breast Feeding"
			when o.value_coded = 2374 then "Exclusive Replacement Feeding"
			when o.value_coded = 2375 then "Mixed Breast Feeding"
			else "N/A" 
			end AS Feeding_Options
			from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
		 from obs oss
		 where oss.concept_id = 2376 and oss.voided=0
		 and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 2376
	and o.voided=0
	and  o.obs_datetime = max_observation	
	)feedingoptions
on Child.Id = feedingoptions.person_id

-- HIV Exposure

left outer join
	(
		select o.person_id,case 
			when o.value_coded = 3640 then "HIV Exposed Infant"
			when o.value_coded = 4294 then "Not Exposed Infant"
			else "Unknown" 
			end AS HIV_Exposure_Status
			from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
		 from obs oss
		 where oss.concept_id = 4293 and oss.voided=0
		 and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 4293
	and o.voided=0
	and  o.obs_datetime = max_observation	
	)HEI_Status
on Child.Id = HEI_Status.person_id


-- Growth Monitoring

left outer join
	(
		Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "7 days"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 4475 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 4475
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 7days

	UNION

	Select pId , Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "6 weeks"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 4476 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
			and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 4476
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 6Weeks

	UNION

	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "10 weeks"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 4477 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 4477
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 10Weeks

	UNION
	
	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "14 weeks"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 4478 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 4478
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 14Weeks

	UNION
	
	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "18 weeks"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 4479 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 4479
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 18Weeks

	UNION
	
	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "5 Months"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 4480 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 4480
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 5Months

	UNION
	
	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 2376 then "Feeding Options"
			when o.value_coded = 1679 then "Vitamin A"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 4481 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 4481
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 6Months

	UNION
	
	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "7 Months"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 1058 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 1058
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 7Month

	UNION

	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "9 Months"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 1060 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 1060
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 9Months

	UNION

	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "10 Months"
			else "" 
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 3142 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 3142
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 10Months

	UNION

	Select pId, Growth_Monitoring
		FROM
		(
			select o.person_id as pId,
		case 
			when o.value_coded = 1 then "11 Months"
			else ""
			end AS Growth_Monitoring
			from obs o
		inner join 
			(
			select oss.person_id, MAX(oss.obs_datetime) as max_observation,
			SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as feeding_obs
			from obs oss
			where oss.concept_id = 3143 and oss.voided=0
			and CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		 	and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			)latest 
		on latest.person_id = o.person_id
		where concept_id = 3143
		and o.voided=0
		and  o.obs_datetime = max_observation

		) As 11Months
			
	)Growth
on Child.Id = Growth.pId




