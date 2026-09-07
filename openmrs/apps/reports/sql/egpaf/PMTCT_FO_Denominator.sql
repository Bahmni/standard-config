Select Patient_Identifier, patientName, Gender
FROM
(select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS Patient_Identifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#startDate#' AS DATE), person.birthdate)/365) AS Age,
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
)HEI_clients
where Age = 2