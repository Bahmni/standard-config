SELECT Total_Child_HEI.AgeGroup
		, Total_Child_HEI.Started_NVP_less_6_weeks
		, Total_Child_HEI.Started_CTX_4_to_6_weeks
		, Total_Child_HEI.Initial_NAT_Test_birth
		, Total_Child_HEI.Initial_NAT_Test_less_8_weeks
		, Total_Child_HEI.Initial_NAT_Test_2_months_plus
		, Total_Child_HEI.Second_NAT_Test_9_months
		, Total_Child_HEI.2nd_Confirmatory_Test_More_18
		, Total_Child_HEI.Infected_less_8_weeks
        , Total_Child_HEI.Infected_2_to_8_Months
		, Total_Child_HEI.Infected_9_to_11_Months
        , Total_Child_HEI.Infected_12_to_18_Months
		, Total_Child_HEI.Uninfected_by_18_months
        , Total_Child_HEI.Unknown_Outcome_at_18_months

FROM

(
	SELECT ageGroup, 
IF(Id IS NULL, 0, SUM(IF(HEI = 'Started on NVP prophylaxis less than 6 weeks', 1, 0))) AS Started_NVP_less_6_weeks,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Started on CTX prophylaxis_4-6 weeks', 1, 0))) AS Started_CTX_4_to_6_weeks,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Initial NAT Test at birth', 1, 0))) AS Initial_NAT_Test_birth,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Initial NAT Test_ < 8 weeks', 1, 0))) AS Initial_NAT_Test_less_8_weeks,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Initial NAT Test_2+ mths', 1, 0))) AS Initial_NAT_Test_2_months_plus,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Second NAT Test_9 months', 1, 0))) AS Second_NAT_Test_9_months,
IF(Id IS NULL, 0, SUM(IF(HEI = '2nd Confirmatory Parallel HIV Rapid Test > 18', 1, 0))) AS 2nd_Confirmatory_Test_More_18,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Infected_< 8 weeks', 1, 0))) AS Infected_less_8_weeks,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Infected_2-8 months', 1, 0))) AS Infected_2_to_8_Months,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Infected_9-11 months', 1, 0))) AS Infected_9_to_11_Months,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Infected_12-18 months', 1, 0))) AS Infected_12_to_18_Months,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Uninfected by 18 months', 1, 0))) AS Uninfected_by_18_months,
IF(Id IS NULL, 0, SUM(IF(HEI = 'Unknown Outcome at 18 months', 1, 0))) AS Unknown_Outcome_at_18_months,
IF(Child_HEI.Id IS NULL, 0, SUM(1)) as 'Total'
FROM 
	( 
				-- Started on NVP prophylaxis less than 6 weeks
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"" as ageGroup,
						"Started on NVP prophylaxis less than 6 weeks" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4562 and o.value_coded = 2146
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4558
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				
				UNION

				-- Started on CTX prophylaxis_4-6 weeks
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30 * 4) AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Started on CTX prophylaxis_4-6 weeks" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4590 and o.value_coded = 4594
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4558
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 3
				and Months < 7

				UNION

				-- Initial NAT Test at birth
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Initial NAT Test at birth" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4570
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4572
													and o.value_coded in (1,2)
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 0

				UNION

				-- Initial NAT Test_ < 8 weeks
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Initial NAT Test_ < 8 weeks" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4570
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4572
													and o.value_coded in (1,2)
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 0
				and Months < 8

				UNION

				-- Initial NAT Test_2+ mths
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Initial NAT Test_2+ mths" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4570
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4572
													and o.value_coded in (1,2)
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 7

				UNION

				-- Second NAT Test_9 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Second NAT Test_9 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4588
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 9

				UNION

				-- 2nd Confirmatory Parallel HIV Rapid Test(18 months or more)
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"2nd Confirmatory Parallel HIV Rapid Test > 18" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4589
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 17

				UNION

				-- Infected_< 8 weeks
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Infected_< 8 weeks" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4570
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4569 -- First DNA PCR at 6 weeks or 1st Contact
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1738
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 0
				and Months < 8

				UNION

				-- Infected_2-8 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Infected_2-8 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4588 -- Second DNA PCR Test
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1738 
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 1
				and Months < 9

				UNION

				-- Infected_9-11 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Infected_9-11 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4588 -- Second DNA PCR Test
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1738 
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 9
				and Months < 12

				UNION

				-- Infected_12-18 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Infected_12-18 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4589 -- 2nd Confirmatory Parallel HIV Rapid Test(18 months or more)
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1738 
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 19

				UNION

				-- Uninfected by 18 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Uninfected by 18 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4589 -- 2nd Confirmatory Parallel HIV Rapid Test(18 months or more)
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1016 
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 17

				UNION

				-- Unknown Outcome at 18 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Unknown Outcome at 18 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4589 -- 2nd Confirmatory Parallel HIV Rapid Test(18 months or more)
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 4220
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 17
		
			

			
)as Child_HEI
	group by ageGroup

	
	
	
UNION ALL


(SELECT  'Total' AS AgeGroup,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = 'Started on NVP prophylaxis less than 6 weeks', 1, 0))) AS Started_NVP_less_6_weeks,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = 'Started on CTX prophylaxis_4-6 weeks', 1, 0))) AS Started_CTX_4_to_6_weeks,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = 'Initial NAT Test at birth', 1, 0))) AS Initial_NAT_Test_birth,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = 'Initial NAT Test_ < 8 weeks', 1, 0))) AS Initial_NAT_Test_less_8_weeks,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = 'Initial NAT Test_2+ mths', 1, 0))) AS Initial_NAT_Test_2_months_plus,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = 'Second NAT Test_9 months', 1, 0))) AS Second_NAT_Test_9_months,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = '2nd Confirmatory Parallel HIV Rapid Test > 18', 1, 0))) AS 2nd_Confirmatory_Test_More_18,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = 'Infected_< 8 weeks', 1, 0))) AS Infected_less_8_weeks,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI  = 'Infected_2-8 months', 1, 0))) AS Infected_9_to_11_Months,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI = 'Infected_9-11 months', 1, 0))) AS Infected_9_to_11_Months,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI = 'Infected_12-18 months', 1, 0))) AS Infected_12_to_18_Months,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI = 'Uninfected by 18 months', 1, 0))) AS Uninfected_by_18_months,
IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HEI = 'Unknown Outcome at 18 months', 1, 0))) AS Unknown_Outcome_at_18_months,
IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		
FROM

		(SELECT  eMTCT.Id
					, eMTCT.patientIdentifier AS "Patient Identifier"
					, eMTCT.patientName AS "Patient Name"
					, eMTCT.HEI
				
		FROM
		
		(

				-- Started on NVP prophylaxis less than 6 weeks
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Months,
						person.gender AS Gender,
						"" as ageGroup,
						"Started on NVP prophylaxis less than 6 weeks" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4562 and o.value_coded = 2146
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4558
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				
				UNION

				-- Started on CTX prophylaxis_4-6 weeks
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30 * 4) AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Started on CTX prophylaxis_4-6 weeks" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4590 and o.value_coded = 4594
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4558
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 3
				and Months < 7

				UNION

				-- Initial NAT Test at birth
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Initial NAT Test at birth" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4570
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4572
													and o.value_coded in (1,2)
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 0

				UNION

				-- Initial NAT Test_ < 8 weeks
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Initial NAT Test_ < 8 weeks" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4570
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4572
													and o.value_coded in (1,2)
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 0
				and Months < 8

				UNION

				-- Initial NAT Test_2+ mths
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Initial NAT Test_2+ mths" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4570
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4572
													and o.value_coded in (1,2)
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 7

				UNION

				-- Second NAT Test_9 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Second NAT Test_9 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4588
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months = 9

				UNION

				-- 2nd Confirmatory Parallel HIV Rapid Test(18 months or more)
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"2nd Confirmatory Parallel HIV Rapid Test > 18" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
										(
											Select person_id
												from obs o
													where o.concept_id = 4589
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 17

				UNION

				-- Infected_< 8 weeks
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, -- Weeks not Month, maintained the naming for UNION
						person.gender AS Gender,
						"" as ageGroup,
						"Infected_< 8 weeks" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4570
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4569 -- First DNA PCR at 6 weeks or 1st Contact
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1738
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 0
				and Months < 8

				UNION

				-- Infected_2-8 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Infected_2-8 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4588 -- Second DNA PCR Test
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1738 
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 1
				and Months < 9

				UNION

				-- Infected_9-11 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Infected_9-11 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4588 -- Second DNA PCR Test
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1738 
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 9
				and Months < 12

				UNION

				-- Infected_12-18 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Infected_12-18 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4589 -- 2nd Confirmatory Parallel HIV Rapid Test(18 months or more)
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1738 
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 11
				and Months < 19

				UNION

				-- Uninfected by 18 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Uninfected by 18 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4589 -- 2nd Confirmatory Parallel HIV Rapid Test(18 months or more)
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 1016 
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 17

				UNION

				-- Unknown Outcome at 18 months
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						o.value_numeric AS Months, 
						person.gender AS Gender,
						"" as ageGroup,
						"Unknown Outcome at 18 months" as HEI
				from obs o
					INNER JOIN patient ON o.person_id = patient.patient_id
					AND o.concept_id = 4587
					AND o.person_id in
									(select B.person_id as pId
										from obs B
											inner join
												(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs 
														where concept_id = 4589 -- 2nd Confirmatory Parallel HIV Rapid Test(18 months or more)
														and obs_datetime <= cast('2022-10-31' as date)
														and voided = 0
													group by person_id) as A
														on A.observation_id = B.obs_group_id
															where concept_id = 4578 and value_coded = 4220
															and A.observation_id = B.obs_group_id
															and voided = 0
														group by B.person_id
										)
					AND patient.voided = 0 AND o.voided = 0
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
				Group by Id
				having Months > 17
		)AS eMTCT

		
  ) AS Totals
 )
) AS Total_Child_HEI

