Select distinct Patient_Identifier, patientName as "Patient_Name", Infant_Prophylaxis, First_DNA_PCR, First_DNA_PCR_Results, Second_DNA_PCR_Results,
				1st_Parallel_HIV_Rapid_Results, 2nd_Confirmatory_Parallel_HIV_Rapid_Results
FROM
(
	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS Patient_Identifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
			person.gender AS Gender,
			MAX(obs_datetime)  obs_date
	from obs o
		--  HEI
		INNER JOIN patient ON o.person_id = patient.patient_id
		AND o.concept_id = 4558
		AND patient.voided = 0 AND o.voided = 0
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
	Group by Id

) As HEI

left outer join 

(
	--  Infant Prophylaxis
	select o.person_id,
		case
			when o.value_coded = 4593 then "Nevirapine"
			when o.value_coded = 4594 then "Cotrimoxazole"
			when o.value_coded = 4595 then "INH"
		else "N/A"
		end AS Infant_Prophylaxis
	from obs o
		where o.concept_id = 4590 and o.voided = 0
		Group by o.person_id
) Prophylaxis
on HEI.Id = Prophylaxis.person_id

left outer join 

(
	--  Initial NAT Test at birth
	select o.person_id,
		case
			when o.value_coded = 1 then "Initial"
			when o.value_coded = 2 then "Repeat"
		else "N/A"
		end AS First_DNA_PCR
	from obs o
		where o.concept_id = 4572 and o.voided = 0
		Group by o.person_id
) Initial_DNA
on HEI.Id = Initial_DNA.person_id

left outer join 

(
	--  First_DNA_PCR_Results
	select o.person_id,
		case
			when o.value_coded = 1738 then "Positive"
			when o.value_coded = 1016 then "Negative"
			when o.value_coded = 4220 then "Indeterminate"
		else "N/A"
		end AS First_DNA_PCR_Results
	from obs o
		where o.concept_id = 4578 and o.voided = 0
		and o.person_id in
						(
							Select person_id
								from obs o
									where concept_id = 4569
						)
		Group by o.person_id
) Results_First_DNA_PCR
on HEI.Id = Results_First_DNA_PCR.person_id


left outer join 

(
	--  First_DNA_PCR_Results
	select B.person_id as pId, B.obs_group_id, B.obs_datetime, B.concept_id, B.value_coded AS latest_consultation, 
        case
			when B.value_coded = 1738 then "Positive"
			when B.value_coded = 1016 then "Negative"
			when B.value_coded = 4220 then "Indeterminate"
		else "N/A"
		end AS Second_DNA_PCR_Results

			from obs B
				inner join
                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs 
							where concept_id = 4588
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						    where concept_id = 4578
							and A.observation_id = B.obs_group_id
							and voided = 0
							group by B.person_id
) Results_Second_DNA_PCR
on HEI.Id = Results_Second_DNA_PCR.pId

left outer join 

(
	--  First Parallel HIV rapid test Results
	select B.person_id as pId, B.obs_group_id, B.obs_datetime, B.concept_id, B.value_coded AS latest_consultation, 
        case
			when B.value_coded = 1738 then "Positive"
			when B.value_coded = 1016 then "Negative"
			when B.value_coded = 4220 then "Indeterminate"
		else "N/A"
		end AS 1st_Parallel_HIV_Rapid_Results

			from obs B
				inner join
                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs 
							where concept_id = 4586
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						    where concept_id = 4578
							and A.observation_id = B.obs_group_id
							and voided = 0
							group by B.person_id
) First_Parallel_DNA_PCR
on HEI.Id = First_Parallel_DNA_PCR.pId

left outer join 

(
	--  Second Confirmatory Parallel HIV rapid test Results
	select B.person_id as pId, B.obs_group_id, B.obs_datetime, B.concept_id, B.value_coded AS latest_consultation, 
        case
			when B.value_coded = 1738 then "Positive"
			when B.value_coded = 1016 then "Negative"
			when B.value_coded = 4220 then "Indeterminate"
		else "N/A"
		end AS 2nd_Confirmatory_Parallel_HIV_Rapid_Results

			from obs B
				inner join
                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs 
							where concept_id = 4589
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						    where concept_id = 4578
							and A.observation_id = B.obs_group_id
							and voided = 0
							group by B.person_id
) Second_Parallel_DNA_PCR
on HEI.Id = Second_Parallel_DNA_PCR.pId


