SELECT Total_Child_Attendance.AgeGroup
		, Total_Child_Attendance.Attendance_child_health
		, Total_Child_Attendance.BCG
		, Total_Child_Attendance.Polio_0
		, Total_Child_Attendance.Polio_1
		, Total_Child_Attendance.Pentavalent_1
		, Total_Child_Attendance.Rotavirus_1
		, Total_Child_Attendance.Pneumococal_1
		, Total_Child_Attendance.Polio_2
		, Total_Child_Attendance.Pentavalent_2
		, Total_Child_Attendance.Rotavirus_2
		, Total_Child_Attendance.Pneumococal_2
		, Total_Child_Attendance.Polio_3
		, Total_Child_Attendance.Pentavalent_3
		, Total_Child_Attendance.Rotavirus_3
		, Total_Child_Attendance.Pneumococal_3
		, Total_Child_Attendance.Measles_1
		, Total_Child_Attendance.Measles_2
		, Total_Child_Attendance.Fully_Immunised
		, Total_Child_Attendance.DT_Dose_1
		, Total_Child_Attendance.Total

FROM

(
	SELECT ageGroup, 
IF(Id IS NULL, 0, SUM(IF(child_health = 'Attendance child health', 1, 0))) AS Attendance_child_health,
IF(Id IS NULL, 0, SUM(IF(child_health = 'BCG', 1, 0))) AS BCG,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Polio 0', 1, 0))) AS Polio_0,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Polio 1', 1, 0))) AS Polio_1,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Pentavalent 1', 1, 0))) AS Pentavalent_1,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Rotavirus 1', 1, 0))) AS Rotavirus_1,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Pneumococal 1', 1, 0))) AS Pneumococal_1,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Polio 2', 1, 0))) AS Polio_2,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Pentavalent 2', 1, 0))) AS Pentavalent_2,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Rotavirus 2', 1, 0))) AS Rotavirus_2,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Pneumococal 2', 1, 0))) AS Pneumococal_2,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Polio 3', 1, 0))) AS Polio_3,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Pentavalent 3', 1, 0))) AS Pentavalent_3,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Rotavirus 3', 1, 0))) AS Rotavirus_3,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Pneumococal 3', 1, 0))) AS Pneumococal_3,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Measles 1', 1, 0))) AS Measles_1,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Measles 2', 1, 0))) AS Measles_2,
IF(Id IS NULL, 0, SUM(IF(child_health = 'Fully Immunised', 1, 0))) AS Fully_Immunised,
IF(Id IS NULL, 0, SUM(IF(child_health = 'DT Dose 1', 1, 0))) AS DT_Dose_1,
IF(Child_Attendance.Id IS NULL, 0, SUM(1)) as 'Total'
FROM 
	( 
			Select distinct Id,patientName, ageGroup, child_health
			from
			(
				-- Attendance child health
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Attendance child health" as child_health
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
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Attendance child health" as child_health
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
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Attendance child health" as child_health
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
				having Months > 23
				and Months < 57

				-- BASE DOSE (BCG)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"BCG" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4453
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"BCG" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4453
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"BCG" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4453
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- Base DOSE (POLIO)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Polio 0" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4454
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Polio 0" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Polio 0" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 1st DOSE (POLIO)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Polio 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4454
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Polio 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Polio 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 1st DOSE (Pentavalent)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pentavalent 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4456
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pentavalent 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pentavalent 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 1st DOSE (Rotavirus(RV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Rotavirus 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4457
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Rotavirus 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Rotavirus 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 1st DOSE (Pneumococal(PCV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pneumococal 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4458
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pneumococal 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pneumococal 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 2nd DOSE (POLIO)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Polio 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4454
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Polio 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Polio 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 2nd DOSE (Pentavalent)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pentavalent 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4456
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pentavalent 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pentavalent 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 2nd DOSE (Rotavirus(RV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Rotavirus 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4457
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Rotavirus 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Rotavirus 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 2nd DOSE (Pneumococal(PCV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pneumococal 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4458
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pneumococal 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pneumococal 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 3rd DOSE (POLIO)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Polio 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4454
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Polio 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Polio 3" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 3rd DOSE (Pentavalent)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pentavalent 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4456
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pentavalent 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pentavalent 3" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 3rd DOSE (Rotavirus(RV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Rotavirus 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4457
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Rotavirus 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Rotavirus 3" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 3rd DOSE (Pneumococal(PCV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pneumococal 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4458
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pneumococal 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pneumococal 3" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- Measles 1st Dose

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Measles 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4461 and o.value_coded = 1
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Measles 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4461 and o.value_coded = 1 
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Measles 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4461 and o.value_coded = 1
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- Measles 2nd Dose

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Measles 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4483
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Measles 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4483
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Measles 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4483
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

			-- Fully Immunised

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Fully Immunised" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4462 and o.value_coded = 1
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Fully Immunised" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4462 and o.value_coded = 1
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Fully Immunised" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4462 and o.value_coded = 1
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- DT Dose 1

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"DT Dose 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4484
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"DT Dose 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4484
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24 -59 Months" as ageGroup,
						"DT Dose 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4484
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57



			) As Child
)as Child_Attendance
	group by ageGroup

	
	
	
UNION ALL


(SELECT 'Total' AS AgeGroup,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Attendance child health', 1, 0))) AS Attendance_child_health,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'BCG', 1, 0))) AS BCG,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Polio 0', 1, 0))) AS Polio_0,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Polio 1', 1, 0))) AS Polio_1,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Pentavalent 1', 1, 0))) AS Pentavalent_1,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Rotavirus 1', 1, 0))) AS Rotavirus_1,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Pneumococal 1', 1, 0))) AS Pneumococal_1,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Polio 2', 1, 0))) AS Polio_2,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Pentavalent 2', 1, 0))) AS Pentavalent_2,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Rotavirus 2', 1, 0))) AS Rotavirus_2,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Pneumococal 2', 1, 0))) AS Pneumococal_2,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Polio 3', 1, 0))) AS Polio_3,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Pentavalent 3', 1, 0))) AS Pentavalent_3,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Rotavirus 3', 1, 0))) AS Rotavirus_3,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Pneumococal 3', 1, 0))) AS Pneumococal_3,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Measles 1', 1, 0))) AS Measles_1,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Measles 2', 1, 0))) AS Measles_2,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'Fully Immunised', 1, 0))) AS Fully_Immunised,
		IF(Totals.Id IS NULL, 0, SUM(IF(Totals.child_health = 'DT Dose 1', 1, 0))) AS DT_Dose_1,
		IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		
FROM

		(SELECT  Child.Id
					, Child.Id AS "Patient Identifier"
					, Child.patientName AS "Patient Name"
					, Child.child_health
				
		FROM
		
			(
				-- Attendance child health
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Attendance child health" as child_health
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
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Attendance child health" as child_health
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
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Attendance child health" as child_health
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
				having Months > 23
				and Months < 57

				-- BASE DOSE (BCG)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"BCG" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4453
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"BCG" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4453
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"BCG" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4453
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- Base DOSE (POLIO)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Polio 0" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4454
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Polio 0" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Polio 0" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4452 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 1st DOSE (POLIO)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Polio 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4454
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Polio 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Polio 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 1st DOSE (Pentavalent)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pentavalent 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4456
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pentavalent 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pentavalent 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 1st DOSE (Rotavirus(RV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Rotavirus 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4457
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Rotavirus 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Rotavirus 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 1st DOSE (Pneumococal(PCV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pneumococal 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4458
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pneumococal 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pneumococal 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4455 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 2nd DOSE (POLIO)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Polio 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4454
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Polio 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Polio 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 2nd DOSE (Pentavalent)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pentavalent 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4456
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pentavalent 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pentavalent 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 2nd DOSE (Rotavirus(RV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Rotavirus 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4457
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Rotavirus 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Rotavirus 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 2nd DOSE (Pneumococal(PCV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pneumococal 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4458
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pneumococal 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pneumococal 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4459 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 3rd DOSE (POLIO)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Polio 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4454
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Polio 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Polio 3" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4454
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 3rd DOSE (Pentavalent)

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pentavalent 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4456
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pentavalent 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pentavalent 3" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4456
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 3rd DOSE (Rotavirus(RV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Rotavirus 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4457
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Rotavirus 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Rotavirus 3" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4457
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- 3rd DOSE (Pneumococal(PCV))

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Pneumococal 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4458
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Pneumococal 3" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Pneumococal 3" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4460 and o.value_coded = 4458
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- Measles 1st Dose

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Measles 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4461 and o.value_coded = 1
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Measles 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4461 and o.value_coded = 1 
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Measles 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4461 and o.value_coded = 1
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- Measles 2nd Dose

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Measles 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4483
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Measles 2" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4483
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Measles 2" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4483
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

			-- Fully Immunised

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"Fully Immunised" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4462 and o.value_coded = 1
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"Fully Immunised" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4462 and o.value_coded = 1
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24-59 Months" as ageGroup,
						"Fully Immunised" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4462 and o.value_coded = 1
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57

				-- DT Dose 1

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"<12 Months" as ageGroup,
						"DT Dose 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4484
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 12

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-23 Months" as ageGroup,
						"DT Dose 1" as child_health
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4484
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 24

				UNION

				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"24 -59 Months" as ageGroup,
						"DT Dose 1" as child_healthh
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4487 and o.value_coded = 4484
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 23
				and Months < 57


			) As Child

		
  ) AS Totals
 )
) AS Total_Child_Attendance

