SELECT Total_Child_Drug_Resistant.AgeGroup
		, Total_Child_Drug_Resistant.New_Patients_tested_using_WRD
		, Total_Child_Drug_Resistant.Relapse_Patients_tested_using_WRD
		, Total_Child_Drug_Resistant.Treatment_After_LTFU_Patients_tested_using_WRD
		, Total_Child_Drug_Resistant.Treatment_After_failure_Patients_tested_using_WRD
		, Total_Child_Drug_Resistant.New_Patients_tested_for_rifampicin_susceptibility
		, Total_Child_Drug_Resistant.Relapse_Patients_tested_for_rifampicin_susceptibility
		, Total_Child_Drug_Resistant.Treatment_After_LTFU_Patients_tested_for_rifampicin_susceptibility
		, Total_Child_Drug_Resistant.Treatment_After_Failure_Patients_tested_for_rifampicin_susceptibility
		, Total_Child_Drug_Resistant.New_Patients_tested_for_rifampicin_resistance
		, Total_Child_Drug_Resistant.Relapse_Patients_tested_for_rifampicin_resistance
		, Total_Child_Drug_Resistant.Treatment_After_LTFU_Patients_tested_for_rifampicin_resistance
        , Total_Child_Drug_Resistant.Treatment_After_failure_Patients_tested_for_rifampicin_resistance
		, Total_Child_Drug_Resistant.New_Patients_tested_for_INHR
        , Total_Child_Drug_Resistant.Relapse_Patients_tested_for_INHR
		, Total_Child_Drug_Resistant.Treatment_After_LTFU_Patients_tested_for_INHR
        , Total_Child_Drug_Resistant.Treatment_After_failure_Patients_tested_for_INHR
        , Total_Child_Drug_Resistant.New_Patients_Started_2nd_Line_Drugs
        , Total_Child_Drug_Resistant.Relapse_Patients_Started_2nd_Line_Drugs
		, Total_Child_Drug_Resistant.Treatment_After_LTFU_Patients_Started_2nd_Line_Drugs
        , Total_Child_Drug_Resistant.Treatment_After_failure_Patients_Started_2nd_Line_Drugs

FROM

(
	SELECT ageGroup, 
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'New Patients tested using WRD', 1, 0))) AS New_Patients_tested_using_WRD,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Relapse Patients tested using WRD', 1, 0))) AS Relapse_Patients_tested_using_WRD,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After LTFU Patients tested using WRD', 1, 0))) AS Treatment_After_LTFU_Patients_tested_using_WRD,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After failure Patients tested using WRD', 1, 0))) AS Treatment_After_failure_Patients_tested_using_WRD,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'New Patients tested for rifampicin susceptibility', 1, 0))) AS New_Patients_tested_for_rifampicin_susceptibility,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Relapse Patients tested for rifampicin susceptibility', 1, 0))) AS Relapse_Patients_tested_for_rifampicin_susceptibility,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After LTFU Patients tested for rifampicin susceptibility', 1, 0))) AS Treatment_After_LTFU_Patients_tested_for_rifampicin_susceptibility,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After Failure Patients tested for rifampicin susceptibility', 1, 0))) AS Treatment_After_Failure_Patients_tested_for_rifampicin_susceptibility,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'New Patients tested for rifampicin resistance', 1, 0))) AS New_Patients_tested_for_rifampicin_resistance,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Relapse Patients tested for rifampicin resistance', 1, 0))) AS Relapse_Patients_tested_for_rifampicin_resistance,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After LTFU Patients tested for rifampicin resistance', 1, 0))) AS Treatment_After_LTFU_Patients_tested_for_rifampicin_resistance,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After failure Patients tested for rifampicin_resistance', 1, 0))) AS Treatment_After_failure_Patients_tested_for_rifampicin_resistance,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'New Patients tested for INHR', 1, 0))) AS New_Patients_tested_for_INHR,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Relapse Patients tested for INHR', 1, 0))) AS Relapse_Patients_tested_for_INHR,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After LTFU Patients tested for INHR', 1, 0))) AS Treatment_After_LTFU_Patients_tested_for_INHR,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After failure Patients tested for INHR', 1, 0))) AS Treatment_After_failure_Patients_tested_for_INHR,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'New Patients Started 2nd Line Drugs', 1, 0))) AS New_Patients_Started_2nd_Line_Drugs,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Relapse Patients Started 2nd Line Drugs', 1, 0))) AS Relapse_Patients_Started_2nd_Line_Drugs,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After LTFU Patients Started 2nd Line Drugs', 1, 0))) AS Treatment_After_LTFU_Patients_Started_2nd_Line_Drugs,
IF(Id IS NULL, 0, SUM(IF(Drug_Resistant = 'Treatment After failure Patients Started 2nd Line Drugs', 1, 0))) AS Treatment_After_failure_Patients_Started_2nd_Line_Drugs,
IF(Child_Drug_Resistant.Id IS NULL, 0, SUM(1)) as 'Total'
FROM 
	(
        select distinct patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		person.gender AS Gender, 
        observed_age_group.name as ageGroup,
		"New Patients tested using WRD" AS Drug_Resistant
from obs o
	-- New_Patients_tested_using_WRD
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	AND o.voided=0
	INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
    AND o.concept_id = 3814
	And o.person_id in 
				(
					select person_id
						from obs ob	
						where ob.concept_id = 3785 and ob.value_coded = 1034
						and voided = 0
						and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				)
	AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

select distinct patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		person.gender AS Gender, 
        observed_age_group.name as ageGroup,
		"Relapse Patients tested using WRD" AS Drug_Resistant
from obs o
	-- Relapse_Patients_tested_using_WRD
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	AND o.voided=0
	INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
    AND o.concept_id = 3814
	And o.person_id in 
				(
					select person_id
						from obs ob	
						where ob.concept_id = 3785 and ob.value_coded = 1084
						and voided = 0
						and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				)
	AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

select distinct patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		person.gender AS Gender, 
        observed_age_group.name as ageGroup,
		"Treatment After LTFU Patients tested using WRD" AS Drug_Resistant
from obs o
	-- Treatment_After_LTFU_Patients_tested_using_WRD
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	AND o.voided=0
	INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
    AND o.concept_id = 3814
	And o.person_id in 
				(
					select person_id
						from obs ob	
						where ob.concept_id = 3785 and ob.value_coded = 3786
						and voided = 0
						and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				)
	AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

select distinct patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		person.gender AS Gender, 
        observed_age_group.name as ageGroup,
		"Treatment After failure Patients tested using WRD" AS Drug_Resistant
from obs o
	-- Treatment_After_failure_Patients_tested_using_WRD
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	AND o.voided=0
	INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
    AND o.concept_id = 3814
	And o.person_id in 
				(
					select person_id
						from obs ob	
						where ob.concept_id = 3785 and ob.value_coded = 1037
						and voided = 0
						and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				)
	AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"New Patients tested for rifampicin susceptibility" AS Drug_Resistant
	from obs o
		-- New Patients tested for rifampicin susceptibility
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3816, 3803)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1034
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Relapse Patients tested for rifampicin susceptibility" AS Drug_Resistant
	from obs o
		-- Relapse Patients tested for rifampicin susceptibility
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3816, 3803)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1084
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After LTFU Patients tested for rifampicin susceptibility" AS Drug_Resistant
	from obs o
		-- Treatment After LTFU Patients tested for rifampicin susceptibility
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3816, 3803)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 3786
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After failure Patients tested for rifampicin susceptibility" AS Drug_Resistant
	from obs o
		-- Treatment After failure Patients tested for rifampicin susceptibility
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3816, 3803)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1037
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"New Patients tested for rifampicin resistance" AS Drug_Resistant
	from obs o
		-- New Patients tested for rifampicin resistance
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3817, 137)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1034
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Relapse Patients tested for rifampicin resistance" AS Drug_Resistant
	from obs o
		-- Relapse Patients tested for rifampicin resistance
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3817, 137)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1084
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After LTFU Patients tested for rifampicin resistance" AS Drug_Resistant
	from obs o
		-- Treatment After LTFU Patients tested for rifampicin resistance
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3817, 137)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 3786
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After failure Patients tested for rifampicin resistance" AS Drug_Resistant
	from obs o
		-- Treatment After failure Patients tested for rifampicin resistance
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3817, 137)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1037
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"New Patients tested for INHR" AS Drug_Resistant
	from obs o
		-- New Patients tested for INHR
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3802
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1034
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Relapse Patients tested for INHR" AS Drug_Resistant
	from obs o
		-- Relapse Patients tested for INHR
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3802
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1084
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After LTFU Patients tested for INHR" AS Drug_Resistant
	from obs o
		-- Treatment After LTFU Patients tested for INHR
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3802
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 3786
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After failure Patients tested for INHR" AS Drug_Resistant
	from obs o
		-- Treatment After failure Patients tested for INHR
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3802
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1037
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"New Patients Started 2nd Line Drugs" AS Drug_Resistant
	from obs o
		-- New Patients Started 2nd Line Drugs
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3808
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1034
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Relapse Patients Started 2nd Line Drugs" AS Drug_Resistant
	from obs o
		-- Relapse Patients Started 2nd Line Drugs
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3808
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1084
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After LTFU Patients Started 2nd Line Drugs" AS Drug_Resistant
	from obs o
		-- Treatment After LTFU Patients Started 2nd Line Drugs
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3808
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 3786
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After failure Patients Started 2nd Line Drugs" AS Drug_Resistant
	from obs o
		-- Treatment After failure Patients Started 2nd Line Drugs
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3808
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1037
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0 
        
		
			

			
)as Child_Drug_Resistant
	group by ageGroup

	
	
	
UNION ALL


(SELECT  'Total' AS AgeGroup, 
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'New Patients tested using WRD', 1, 0))) AS New_Patients_tested_using_WRD,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Relapse Patients tested using WRD', 1, 0))) AS Relapse_Patients_tested_using_WRD,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Treatment After LTFU Patients tested using WRD', 1, 0))) AS Treatment_After_LTFU_Patients_tested_using_WRD,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Treatment_After_failure_Patients_tested_using_WRD', 1, 0))) AS Treatment_After_failure_Patients_tested_using_WRD,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'New Patients tested for rifampicin susceptibility', 1, 0))) AS New_Patients_tested_for_rifampicin_susceptibility,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Relapse Patients tested for rifampicin susceptibility', 1, 0))) AS Relapse_Patients_tested_for_rifampicin_susceptibility,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Treatment After LTFU Patients tested for rifampicin susceptibility', 1, 0))) AS Treatment_After_LTFU_Patients_tested_for_rifampicin_susceptibility,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Treatment After Failure Patients tested for rifampicin susceptibility', 1, 0))) AS Treatment_After_Failure_Patients_tested_for_rifampicin_susceptibility,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'New Patients tested for rifampicin resistance', 1, 0))) AS New_Patients_tested_for_rifampicin_resistance,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Relapse Patients tested for rifampicin resistance', 1, 0))) AS Relapse_Patients_tested_for_rifampicin_resistance,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Treatment After LTFU Patients tested for rifampicin resistance', 1, 0))) AS Treatment_After_LTFU_Patients_tested_for_rifampicin_resistance,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant  = 'Treatment After failure Patients tested for rifampicin_resistance', 1, 0))) AS Treatment_After_failure_Patients_tested_for_rifampicin_resistance,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant = 'New Patients tested for INHR', 1, 0))) AS New_Patients_tested_for_INHR,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant = 'Relapse Patients tested for INHR', 1, 0))) AS Relapse_Patients_tested_for_INHR,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant = 'Treatment After LTFU Patients tested for INHR', 1, 0))) AS Treatment_After_LTFU_Patients_tested_for_INHR,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant = 'Treatment After failure Patients tested for INHR', 1, 0))) AS Treatment_After_failure_Patients_tested_for_INHR,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant = 'New Patients Started 2nd Line Drugs', 1, 0))) AS New_Patients_Started_2nd_Line_Drugs,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant = 'Relapse Patients Started 2nd Line Drugs', 1, 0))) AS Relapse_Patients_Started_2nd_Line_Drugs,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant = 'Treatment After LTFU Patients Started 2nd Line Drugs', 1, 0))) AS Treatment_After_LTFU_Patients_Started_2nd_Line_Drugs,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Drug_Resistant = 'Treatment After failure Patients Started 2nd Line Drugs', 1, 0))) AS Treatment_After_failure_Patients_Started_2nd_Line_Drugs,
IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		
FROM

		(SELECT  Resistance.Id
					, Resistance.patientIdentifier AS "Patient Identifier"
					, Resistance.patientName AS "Patient Name"
					, Resistance.Drug_Resistant
				
		FROM
		
		(
            select distinct patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		person.gender AS Gender, 
        observed_age_group.name as ageGroup,
		"New Patients tested using WRD" AS Drug_Resistant
from obs o
	-- New_Patients_tested_using_WRD
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	AND o.voided=0
	INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
    AND o.concept_id = 3814
	And o.person_id in 
				(
					select person_id
						from obs ob	
						where ob.concept_id = 3785 and ob.value_coded = 1034
						and voided = 0
						and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				)
	AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

select distinct patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		person.gender AS Gender, 
        observed_age_group.name as ageGroup,
		"Relapse Patients tested using WRD" AS Drug_Resistant
from obs o
	-- Relapse_Patients_tested_using_WRD
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	AND o.voided=0
	INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
    AND o.concept_id = 3814
	And o.person_id in 
				(
					select person_id
						from obs ob	
						where ob.concept_id = 3785 and ob.value_coded = 1084
						and voided = 0
						and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				)
	AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

select distinct patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		person.gender AS Gender, 
        observed_age_group.name as ageGroup,
		"Treatment After LTFU Patients tested using WRD" AS Drug_Resistant
from obs o
	-- Treatment_After_LTFU_Patients_tested_using_WRD
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	AND o.voided=0
	INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
    AND o.concept_id = 3814
	And o.person_id in 
				(
					select person_id
						from obs ob	
						where ob.concept_id = 3785 and ob.value_coded = 3786
						and voided = 0
						and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				)
	AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

select distinct patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		person.gender AS Gender, 
        observed_age_group.name as ageGroup,
		"Treatment After failure Patients tested using WRD" AS Drug_Resistant
from obs o
	-- Treatment_After_failure_Patients_tested_using_WRD
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	AND o.voided=0
	INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
    AND o.concept_id = 3814
	And o.person_id in 
				(
					select person_id
						from obs ob	
						where ob.concept_id = 3785 and ob.value_coded = 1037
						and voided = 0
						and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				)
	AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"New Patients tested for rifampicin susceptibility" AS Drug_Resistant
	from obs o
		-- New Patients tested for rifampicin susceptibility
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3816, 3803)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1034
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Relapse Patients tested for rifampicin susceptibility" AS Drug_Resistant
	from obs o
		-- Relapse Patients tested for rifampicin susceptibility
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
		AND o.value_coded in (3816, 3803)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1084
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After LTFU Patients tested for rifampicin susceptibility" AS Drug_Resistant
	from obs o
		-- Treatment After LTFU Patients tested for rifampicin susceptibility
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3816, 3803)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 3786
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After failure Patients tested for rifampicin susceptibility" AS Drug_Resistant
	from obs o
		-- Treatment After failure Patients tested for rifampicin susceptibility
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3816, 3803)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1037
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"New Patients tested for rifampicin resistance" AS Drug_Resistant
	from obs o
		-- New Patients tested for rifampicin resistance
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3817, 137)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1034
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Relapse Patients tested for rifampicin resistance" AS Drug_Resistant
	from obs o
		-- Relapse Patients tested for rifampicin resistance
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3817, 137)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1084
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After LTFU Patients tested for rifampicin resistance" AS Drug_Resistant
	from obs o
		-- Treatment After LTFU Patients tested for rifampicin resistance
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3817, 137)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 3786
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After failure Patients tested for rifampicin resistance" AS Drug_Resistant
	from obs o
		-- Treatment After failure Patients tested for rifampicin resistance
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded in (3817, 137)
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1037
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"New Patients tested for INHR" AS Drug_Resistant
	from obs o
		-- New Patients tested for INHR
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3802
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1034
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Relapse Patients tested for INHR" AS Drug_Resistant
	from obs o
		-- Relapse Patients tested for INHR
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3802
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1084
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After LTFU Patients tested for INHR" AS Drug_Resistant
	from obs o
		-- Treatment After LTFU Patients tested for INHR
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3802
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 3786
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After failure Patients tested for INHR" AS Drug_Resistant
	from obs o
		-- Treatment After failure Patients tested for INHR
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3802
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1037
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"New Patients Started 2nd Line Drugs" AS Drug_Resistant
	from obs o
		-- New Patients Started 2nd Line Drugs
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3808
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1034
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Relapse Patients Started 2nd Line Drugs" AS Drug_Resistant
	from obs o
		-- Relapse Patients Started 2nd Line Drugs
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.value_coded = 3808
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1084
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After LTFU Patients Started 2nd Line Drugs" AS Drug_Resistant
	from obs o
		-- Treatment After LTFU Patients Started 2nd Line Drugs
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
        AND o.voided=0
		AND o.value_coded = 3808
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 3786
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	AND patient.voided = 0 AND o.voided = 0

UNION

	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender, 
            observed_age_group.name as ageGroup,
			"Treatment After failure Patients Started 2nd Line Drugs" AS Drug_Resistant
	from obs o
		-- Treatment After failure Patients Started 2nd Line Drugs
		INNER JOIN patient ON o.person_id = patient.patient_id 
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		AND o.voided=0
        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
		AND o.value_coded = 3808
		And o.person_id in 
					(
						select person_id
							from obs ob	
							where ob.concept_id = 3785 and ob.value_coded = 1037
							and voided = 0
							and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		AND patient.voided = 0 AND o.voided = 0
			
		)AS Resistance

		
  ) AS Totals
 )
) AS Total_Child_Drug_Resistant

