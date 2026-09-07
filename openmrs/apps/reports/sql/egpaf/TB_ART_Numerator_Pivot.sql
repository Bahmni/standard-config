SELECT distinct HTS_TOTALS_COLS_ROWS.AgeGroup
		    , HTS_TOTALS_COLS_ROWS.New_Positive_HIV_Status
	    	, HTS_TOTALS_COLS_ROWS.Known_HIV_Positive_Status
			, HTS_TOTALS_COLS_ROWS.New_ART
			, HTS_TOTALS_COLS_ROWS.Already_ART
			

FROM (

			(SELECT HIV_MAN_DRVD_ROWS.age_group AS 'AgeGroup'
					
						, IF(HIV_MAN_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HIV_MAN_DRVD_ROWS.HIV_Status = 'New Positive', 1, 0))) AS New_Positive_HIV_Status
						, IF(HIV_MAN_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HIV_MAN_DRVD_ROWS.HIV_Status = 'Known Positive', 1, 0))) AS Known_HIV_Positive_Status
						, IF(HIV_MAN_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HIV_MAN_DRVD_ROWS.HIV_Management = 'New ART', 1, 0))) AS New_ART
						, IF(HIV_MAN_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HIV_MAN_DRVD_ROWS.HIV_Management = 'Already ART', 1, 0))) AS Already_ART
						, HIV_MAN_DRVD_ROWS.sort_order
			FROM (
					SELECT distinct Id, patientIdentifier,TB_Number, patientName, Age, age_group,sort_order, Gender,consultation_date, HIV_Status, HIV_Management
						FROM 
						(

						(Select distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group,sort_order, Gender, consultation_date
								From(
										select distinct patient.patient_id AS Id,
												patient_identifier.identifier AS patientIdentifier,
												pi2.identifier AS TB_Number,
												concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												observed_age_group.name AS age_group,
												person.gender AS Gender,
												observed_age_group.sort_order AS sort_order,
												cast(o.obs_datetime as date) as consultation_date

											from obs o
											--  TB Clients 
												INNER JOIN patient ON o.person_id = patient.patient_id 
												INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
												INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
												INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
												LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type in (7)
												AND o.voided=0
												INNER JOIN reporting_age_group AS observed_age_group ON
												CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
												WHERE observed_age_group.report_group_name = 'Modified_Ages'
												AND o.concept_id  = 3785 and o.value_coded in (1038, 1084)
												AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
												AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
												Group by o.person_id) AS TB_TESTING
						)

						)diagnosis_type

						left outer join

						(select
							o.person_id,
							case
								when value_coded = 4323 then "New Positive"
								when value_coded = 4324 then "Known Positive"
							end AS HIV_Status
						from obs o
							inner join
								(
								select oss.person_id, MAX(oss.obs_datetime) as max_observation,
								SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
								from obs oss
								where oss.concept_id = 4666 and oss.voided=0
								and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
								group by oss.person_id
								)latest
							on latest.person_id = o.person_id
							where concept_id = 4666
							and  o.obs_datetime = max_observation
							) status
						ON diagnosis_type.Id = status.person_id

						left outer join

						(select
							o.person_id,
							case
								when o.value_coded = 4669 then "New ART"
								when o.value_coded = 4670 then "Already on ART"
							end AS HIV_Management
						from obs o
						inner join
								(
								select oss.person_id, MAX(oss.obs_datetime) as max_observation,
								SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
								from obs oss
								where oss.concept_id = 4667 and oss.voided=0
								and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
								group by oss.person_id
								)latest
							on latest.person_id = o.person_id
							where concept_id = 4667
							and  o.obs_datetime = max_observation
							) Management
						ON diagnosis_type.Id = Management.person_id



			) AS HIV_MAN_DRVD_ROWS

			GROUP BY HIV_MAN_DRVD_ROWS.age_group, HIV_MAN_DRVD_ROWS.Gender
			ORDER BY HIV_MAN_DRVD_ROWS.sort_order
			)
			
			
	 UNION ALL

			( SELECT 'Total' AS 'AgeGroup'
						, IF(HIV_MAN_DRVD_COLS.Id IS NULL, 0, SUM(IF(HIV_MAN_DRVD_COLS.HIV_Status = 'New Positive', 1, 0))) AS New_Positive_HIV_Status
						, IF(HIV_MAN_DRVD_COLS.Id IS NULL, 0, SUM(IF(HIV_MAN_DRVD_COLS.HIV_Status = 'Known Positive', 1, 0))) AS Known_HIV_Positive_Status
						, IF(HIV_MAN_DRVD_COLS.Id IS NULL, 0, SUM(IF(HIV_MAN_DRVD_COLS.HIV_Management = 'New ART', 1, 0))) AS New_ART
						, IF(HIV_MAN_DRVD_COLS.Id IS NULL, 0, SUM(IF(HIV_MAN_DRVD_COLS.HIV_Management = 'Already ART', 1, 0))) AS Already_ART
						, 99 AS sort_order
			FROM (

					SELECT distinct Id, patientIdentifier,TB_Number, patientName, Age, age_group,sort_order, Gender,consultation_date, HIV_Status, HIV_Management
						FROM 
						(

						(Select distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group,sort_order,Gender, consultation_date
								From(
										select distinct patient.patient_id AS Id,
												patient_identifier.identifier AS patientIdentifier,
												pi2.identifier AS TB_Number,
												concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												observed_age_group.name AS age_group,
												person.gender AS Gender,
												observed_age_group.sort_order AS sort_order,
												cast(o.obs_datetime as date) as consultation_date

											from obs o
											--  TB Clients 
												INNER JOIN patient ON o.person_id = patient.patient_id 
												INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
												INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
												INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
												LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type in (7)
												AND o.voided=0
												INNER JOIN reporting_age_group AS observed_age_group ON
												CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
												WHERE observed_age_group.report_group_name = 'Modified_Ages'
												AND o.concept_id  = 3785 and o.value_coded in (1038, 1084)
												AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
												AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND o.voided = 0
												Group by o.person_id) AS TB_TESTING
						)

						)diagnosis_type

						left outer join

						(select
							o.person_id,
							case
								when value_coded = 4323 then "New Positive"
								when value_coded = 4324 then "Known Positive"
							end AS HIV_Status
						from obs o
							inner join
								(
								select oss.person_id, MAX(oss.obs_datetime) as max_observation,
								SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
								from obs oss
								where oss.concept_id = 4666 and oss.voided=0
								and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
								group by oss.person_id
								)latest
							on latest.person_id = o.person_id
							where concept_id = 4666
							and  o.obs_datetime = max_observation
							) status
						ON diagnosis_type.Id = status.person_id

						left outer join

						(select
							o.person_id,
							case
								when o.value_coded = 4669 then "New ART"
								when o.value_coded = 4670 then "Already on ART"
							end AS HIV_Management
						from obs o
						inner join
								(
								select oss.person_id, MAX(oss.obs_datetime) as max_observation,
								SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
								from obs oss
								where oss.concept_id = 4667 and oss.voided=0
								and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
								group by oss.person_id
								)latest
							on latest.person_id = o.person_id
							where concept_id = 4667
							and  o.obs_datetime = max_observation
							) Management
						ON diagnosis_type.Id = Management.person_id




			) AS HIV_MAN_DRVD_COLS
		)
		
	) AS HTS_TOTALS_COLS_ROWS
ORDER BY HTS_TOTALS_COLS_ROWS.sort_order

