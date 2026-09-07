SELECT Total_Child_nutrition.AgeGroup
		, Total_Child_nutrition.Height_Measured
		, Total_Child_nutrition.Weight_Measured
		, Total_Child_nutrition.Weight_and_Height_Taken
		, Total_Child_nutrition.EBF_at_3_months_UnExposed
		, Total_Child_nutrition.EBF_at_3_months_HIV_Exposed
		, Total_Child_nutrition.EBF_at_6_months_UnExposed
		, Total_Child_nutrition.EBF_at_6_months_HIV_Exposed
		, Total_Child_nutrition.EFF_at_6_months_UnExposed
		, Total_Child_nutrition.EFF_at_6_months_HIV_Exposed
		, Total_Child_nutrition.Mixedfed_at_6_months_UnExposed
		, Total_Child_nutrition.Mixedfed_at_6_months_HIV_Exposed
		, Total_Child_nutrition.Vitamin_A_at_6_11_Months
		, Total_Child_nutrition.Vitamin_A_at_12_56_Months

FROM

(
	SELECT ageGroup, 
IF(Id IS NULL, 0, SUM(IF(nutrition = 'Height Measured', 1, 0))) AS Height_Measured,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'Weight Measured', 1, 0))) AS Weight_Measured,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'Weight & Height Taken', 1, 0))) AS Weight_and_Height_Taken,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'EBF at 3 months UnExposed', 1, 0))) AS EBF_at_3_months_UnExposed,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'EBF at 3 months HIV Exposed', 1, 0))) AS EBF_at_3_months_HIV_Exposed,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'EBF at 6 months UnExposed', 1, 0))) AS EBF_at_6_months_UnExposed,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'EBF at 6 months HIV Exposed', 1, 0))) AS EBF_at_6_months_HIV_Exposed,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'EFF at 6 months UnExposed', 1, 0))) AS EFF_at_6_months_UnExposed,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'EFF at 6 months HIV Exposed', 1, 0))) AS EFF_at_6_months_HIV_Exposed,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'Mixedfed at 6 months UnExposed', 1, 0))) AS Mixedfed_at_6_months_UnExposed,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'Mixedfed at 6 months HIV Exposed', 1, 0))) AS Mixedfed_at_6_months_HIV_Exposed,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'Vitamin A at 6- 11 Months', 1, 0))) AS Vitamin_A_at_6_11_Months,
IF(Id IS NULL, 0, SUM(IF(nutrition = 'Vitamin A at 12-56 Months', 1, 0))) AS Vitamin_A_at_12_56_Months,
IF(Child_nutrition.Id IS NULL, 0, SUM(1)) as 'Total'
FROM 
	( 
		SELECT Id,patientName, ageGroup, nutrition
			FROM
		(
			-- Height Measured
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"0-59 Months" as ageGroup,
						"Height Measured" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 118
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 60

				UNION

			-- Weight Measured
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"0-59 Months" as ageGroup,
						"Weight Measured" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 119
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 60

				UNION
			-- Height and Weight Measured

			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"0-59 Months" as ageGroup,
						"Weight & Weight Taken" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 119
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 118
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 60

				 UNION

			-- Exclusive Breastfeeding Feeding at 3 Months for HIV Exposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"3 Months" as ageGroup,
						"EBF at 3 months HIV Exposed" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2373
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 3640
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 3

				UNION

			-- Exclusive Breastfeeding Feeding at 3 Months for Unexposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"3 Months" as ageGroup,
						"EBF at 3 months UnExposed" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2373
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 4294
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 3

				UNION

			-- Exclusive Breastfeeding Feeding at 6 Months for HIV Exposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"EBF at 3 months HIV Exposed" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2373
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 3640
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6

				UNION
			-- Exclusive Breastfeeding Feeding at 6 Months for Unexposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"EBF at 6 months UnExposed" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2373
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 4294
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6
			
			UNION

			-- Mixed Feeding at 6 Months for HIV Exposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"Mixedfed at 6 months HIV Exposed" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2375
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 3640
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6

				UNION
			-- Exclusive Replacement Feeding / EFF at 6 Months for Unexposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"EFF at 6 months UnExposed" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2374
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 4294
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6
			
			UNION

			-- Exclusive Replacement Feeding / EFF at 6 Months for HIV Exposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"EFF at 6 months HIV Exposed" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2374
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 3640
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6

				UNION
			-- Mixed Feeding at 6 Months for Unexposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"Mixedfed at 6 months UnExposed" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2375
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 4294
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6

			UNION
			-- Vitamin A (6-11 months)
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6-11 Months" as ageGroup,
						"Vitamin A at 6-11 Months" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.value_coded = 1679
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 7
				and Months < 12

			UNION
			-- Vitamin A (12-59 months)
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-59  Months" as ageGroup,
						"Vitamin A at 12-56 Months" as nutrition  
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.value_coded = 1679
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 60


) AS Nutrition
			

			
)as Child_nutrition
	group by ageGroup

	
	
	
UNION ALL


(SELECT  'Total' AS AgeGroup, 
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'Height Measured', 1, 0))) AS Height_Measured,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'Weight Measured', 1, 0))) AS Weight_Measured,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'Weight & Height Taken', 1, 0))) AS Weight_and_Height_Taken,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'EBF at 3 months UnExposed', 1, 0))) AS EBF_at_3_months_UnExposed,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'EBF at 3 months HIV Exposed', 1, 0))) AS EBF_at_3_months_HIV_Exposed,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'EBF at 6 months UnExposed', 1, 0))) AS EBF_at_6_months_UnExposed,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'EBF at 6 months HIV Exposed', 1, 0))) AS EBF_at_6_months_HIV_Exposed,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'EFF at 6 months UnExposed', 1, 0))) AS EFF_at_6_months_UnExposed,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'EFF at 6 months HIV Exposed', 1, 0))) AS EFF_at_6_months_HIV_Exposed,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'Mixedfed at 6 months UnExposed', 1, 0))) AS Mixedfed_at_6_months_UnExposed,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'Mixedfed at 6 months HIV Exposed', 1, 0))) AS Mixedfed_at_6_months_HIV_Exposed,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'Vitamin A at 6-11 Months', 1, 0))) AS Vitamin_A_at_6_11_Months,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.nutrition  = 'Vitamin A at 12-56 Months', 1, 0))) AS Vitamin_A_at_12_56_Months,
IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		
FROM

		(SELECT  Nutrition.Id
					, Nutrition.patientIdentifier AS "Patient Identifier"
					, Nutrition.patientName AS "Patient Name"
					, Nutrition.nutrition
				
		FROM
		
		(
			-- Height Measured
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"0-59 Months" as ageGroup,
						"Height Measured" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 118
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 60

				UNION

			-- Weight Measured
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"0-59 Months" as ageGroup,
						"Weight Measured" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 119
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 60

				UNION
			-- Height and Weight Measured

			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"0-59 Months" as ageGroup,
						"Weight & Weight Taken" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 119
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 118
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months < 60

				 UNION

			-- Exclusive Breastfeeding Feeding at 3 Months for HIV Exposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"3 Months" as ageGroup,
						"EBF at 3 months HIV Exposed" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2373
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 3640
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 3

				UNION

			-- Exclusive Breastfeeding Feeding at 3 Months for Unexposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"3 Months" as ageGroup,
						"EBF at 3 months UnExposed" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2373
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 4294
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 3

				UNION

			-- Exclusive Breastfeeding Feeding at 6 Months for HIV Exposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"EBF at 3 months HIV Exposed" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2373
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 3640
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6

				UNION
			-- Exclusive Breastfeeding Feeding at 6 Months for Unexposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"EBF at 6 months UnExposed" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2373
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 4294
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6
			
			UNION

			-- Mixed Feeding at 6 Months for HIV Exposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"Mixedfed at 6 months HIV Exposed" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2375
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 3640
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6

				UNION
			-- Exclusive Replacement Feeding / EFF at 6 Months for Unexposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"EFF at 6 months UnExposed" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2374
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 4294
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6
			
			UNION

			-- Exclusive Replacement Feeding / EFF at 6 Months for HIV Exposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"EFF at 6 months HIV Exposed" as nutrition
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2374
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 3640
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6

				UNION
			-- Mixed Feeding at 6 Months for Unexposed Infants
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6 Months" as ageGroup,
						"Mixedfed at 6 months UnExposed" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 2376 and o.value_coded = 2375
					AND o.person_id in (Select person_id 
											from obs o
												where o.concept_id = 4293 and o.value_coded = 4294
												and CAST(o.obs_datetime as date) >= CAST('#startDate#' as date)
												and CAST(o.obs_datetime as date) <= CAST('#endDate#' as date)
												and o.voided =0
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 6

			UNION
			-- Vitamin A (6-11 months)
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"6-11 Months" as ageGroup,
						"Vitamin A at 6-11 Months" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.value_coded = 1679
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 7
				and Months < 12

			UNION
			-- Vitamin A (12-59 months)
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"12-59  Months" as ageGroup,
						"Vitamin A at 12-56 Months" as nutrition 
				from obs o
								--  Children
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.value_coded = 1679
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 60


		)AS Nutrition

		
  ) AS Totals
 )
) AS Total_Child_nutrition

