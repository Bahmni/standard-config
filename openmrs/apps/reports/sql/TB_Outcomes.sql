SELECT Patient_Type,
IF(Id IS NULL, 0, SUM(IF(outcome = 'Completed', 1, 0))) AS Completed,
IF(Id IS NULL, 0, SUM(IF(outcome = 'Cured', 1, 0))) AS Cured,
IF(Id IS NULL, 0, SUM(IF(outcome = 'Died', 1, 0))) AS Died,
IF(Id IS NULL, 0, SUM(IF(outcome = 'Lost', 1, 0))) AS Lost,
IF(Id IS NULL, 0, SUM(IF(outcome = 'Failed', 1, 0))) AS Failed,
IF(Id IS NULL, 0, SUM(IF(outcome = 'Resistant', 1, 0))) AS Resistant

FROM 
(
SELECT Id, outcome,Patient_Type
FROM
(	-- CASE OUTCOMES FROM ALL Completed
                (select distinct o.person_id AS Id , 'Completed' as outcome, 'New and relapse' as Patient_Type
                                        from obs o

                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3785 and value_coded in  (1034,1084))
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
												
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                  WHERE concept_id = 3792 and value_coded = 2242
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
							UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'Retreatment Excluding Relapse' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded in (3786,1037))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'All HIV Positive' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where concept_id in (4153,1158)
												and obs.person_id in (select person_id from obs where concept_id = 2249)
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
																		AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'All Children' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'All Adolescents' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 19 and age >= 10
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'Female' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from person
												where gender = 'F'
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'Ex miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'Factory' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Completed' as outcome, 'Staff & inmates' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2242
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								
						UNION
						
						-- Cured
						(select distinct o.person_id AS Id , 'Cured' as outcome, 'New and relapse' as Patient_Type
                                        from obs o

                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3785 and value_coded in  (1034,1084)
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE)))
												)
												
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                  WHERE concept_id = 3792 and value_coded = 1068
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
							UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'Retreatment Excluding Relapse' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded in (3786,1037))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'All HIV Positive' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where concept_id in (4153,1158)
												and obs.person_id in (select person_id from obs where concept_id = 2249)
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
																		AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'All Children' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'All Adolescents' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 19 and age >= 10
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'Female' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from person
												where gender = 'F'
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'Ex miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'Factory' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Cured' as outcome, 'Staff & inmates' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 1068
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								
							UNION
							
							-- Died
							(select distinct o.person_id AS Id , 'Died' as outcome, 'New and relapse' as Patient_Type
                                        from obs o

                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3785 and value_coded in  (1034,1084)
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE)))
												)
												
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                  WHERE concept_id = 3792 and value_coded = 3650
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
							UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'Retreatment Excluding Relapse' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded in (3786,1037))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'All HIV Positive' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where concept_id in (4153,1158)
												and obs.person_id in (select person_id from obs where concept_id = 2249)
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
																		AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'All Children' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'All Adolescents' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 19 and age >= 10
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'Female' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from person
												where gender = 'F'
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'Ex miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'Factory' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Died' as outcome, 'Staff & inmates' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3650
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								
								UNION
								-- LTFU
								
								(select distinct o.person_id AS Id , 'Lost' as outcome, 'New and relapse' as Patient_Type
                                        from obs o

                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3785 and value_coded in  (1034,1084)
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE)))
												)
												
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                  WHERE concept_id = 3792 and value_coded = 2302
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
							UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'Retreatment Excluding Relapse' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded in (3786,1037))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'All HIV Positive' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where concept_id in (4153,1158)
												and obs.person_id in (select person_id from obs where concept_id = 2249)
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
																		AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'All Children' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'All Adolescents' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 19 and age >= 10
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'Female' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from person
												where gender = 'F'
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'Ex miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'Factory' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Lost' as outcome, 'Staff & inmates' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 2302
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								
								UNION
								
								-- Failed
								
								(select distinct o.person_id AS Id , 'Failed' as outcome, 'New and relapse' as Patient_Type
                                        from obs o

                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3785 and value_coded in  (1034,1084)
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE)))
												)
												
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                  WHERE concept_id = 3792 and value_coded = 3793
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
							UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'Retreatment Excluding Relapse' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded in (3786,1037))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'All HIV Positive' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where concept_id in (4153,1158)
												and obs.person_id in (select person_id from obs where concept_id = 2249)
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
																		AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'All Children' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'All Adolescents' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 19 and age >= 10
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'Female' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from person
												where gender = 'F'
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'Ex miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'Factory' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Failed' as outcome, 'Staff & inmates' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3793
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								
								-- NOT EVALUATED
								UNION
								(select distinct o.person_id AS Id , 'Resistant' as outcome, 'New and relapse' as Patient_Type
                                        from obs o

                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3785 and value_coded in  (1034,1084)
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE)))
												)
												
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                  WHERE concept_id = 3792 and value_coded = 3794
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
							UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'Retreatment Excluding Relapse' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded in (3786,1037))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'All HIV Positive' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where concept_id in (4153,1158)
												and obs.person_id in (select person_id from obs where concept_id = 2249)
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
																		AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'All Children' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'All Adolescents' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 19 and age >= 10
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'Female' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from person
												where gender = 'F'
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'Ex miner' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'Factory' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'Resistant' as outcome, 'Staff & inmates' as Patient_Type
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id = 3792 and value_coded = 3794
							AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
                                )
				) as B

) AS BB
group by Patient_Type