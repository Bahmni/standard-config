select patient_type,CPT_Dapsone_Females,CPT_Dapsone_Males,On_ART_Females,On_ART_Males,Documented_HIV_Status_Females,Documented_HIV_Status_Males,HIV_Positive_Females,HIV_Positive_Males
FROM(
select patient_type
			, IF(Id IS NULL, 0, SUM(IF(treatment = 'On_CPT_Dapsone' AND a.gender = 'F', 1, 0))) AS CPT_Dapsone_Females
			, IF(Id IS NULL, 0, SUM(IF(treatment = 'On_CPT_Dapsone' AND a.gender = 'M', 1, 0))) AS CPT_Dapsone_Males
			, IF(Id IS NULL, 0, SUM(IF(treatment = 'On_ART' AND a.gender = 'F', 1, 0))) AS On_ART_Females
			, IF(Id IS NULL, 0, SUM(IF(treatment = 'On_ART' AND a.gender = 'M', 1, 0))) AS On_ART_Males
			, IF(Id IS NULL, 0, SUM(IF(treatment = 'Documented_HIV_Status' AND a.gender = 'F', 1, 0))) AS Documented_HIV_Status_Females
			, IF(Id IS NULL, 0, SUM(IF(treatment = 'Documented_HIV_Status' AND a.gender = 'M', 1, 0))) AS Documented_HIV_Status_Males
			, IF(Id IS NULL, 0, SUM(IF(treatment = 'HIV_Positive' AND a.gender = 'F', 1, 0))) AS HIV_Positive_Females
			, IF(Id IS NULL, 0, SUM(IF(treatment = 'HIV_Positive' AND a.gender = 'M', 1, 0))) AS HIV_Positive_Males
FROM(
	select id,treatment,b.gender,patient_type
	
	FROM(
			select o.person_id as id,'On_CPT_Dapsone' as treatment,'New_relapse' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
													from obs
													where (concept_id = 3785 and value_coded in  (1034,1084)
													AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE)))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (2330,4619)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_CPT_Dapsone' as treatment,'Retreatment' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			 AND o.person_id in (select person_id 
												from obs o
												where (concept_id = 3780 and value_coded in (3786,1037))
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (2330,4619)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_CPT_Dapsone' as treatment,'children' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			 AND o.person_id in (select id
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
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (2330,4619)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_CPT_Dapsone' as treatment,'miners' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			 AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (2330,4619)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_CPT_Dapsone' as treatment,'ex_miners' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (2330,4619)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_CPT_Dapsone' as treatment,'HHCM' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (2330,4619)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_CPT_Dapsone' as treatment,'HHEM' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (2330,4619)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_CPT_Dapsone' as treatment,'factory' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (2330,4619)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			-- ON ART
			select o.person_id as id,'On_ART' as treatment,'New_relapse' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												WHERE concept_id = 3785 and value_coded in (1034,1084)  
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in (
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (4669,4670)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
			
			UNION
			
			select o.person_id as id,'On_ART' as treatment,'Retreatment' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			 AND o.person_id in (select person_id 
												from obs
												WHERE concept_id = 3785 and value_coded in (3786,1037)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (4669,4670)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_ART' as treatment,'children' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			 AND o.person_id in (select id
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
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (4669,4670)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_ART' as treatment,'miners' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			 AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (4669,4670)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_ART' as treatment,'ex_miners' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (4669,4670)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_ART' as treatment,'HHCM' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (4669,4670)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_ART' as treatment,'HHEM' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (4669,4670)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

			UNION
			
			select o.person_id as id,'On_ART' as treatment,'factory' as patient_type,gender
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
												)									
												
            INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
			where concept_id = 4666 and value_coded in (4323,4664)
			and o.person_id in 
					(
					select person_id
					from obs
					where concept_id = 4667 and value_coded in (4669,4670)
					AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
					AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
					)
			AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
			
			UNION
			
			 (select o.person_id as id,'Documented_HIV_Status' as treatment,'New_relapse' as patient_type,gender
				
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- new and relapse tb patients
                                    where concept_id = 3785 
                                    and value_coded in (1034,1084)
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4324,4664,4665)     -- Known HIV status     
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
						
						    UNION

            -- Retreatment excluding Relapse client - Documented and known HIV statae
            -- Documented HIV status - Males and Females
                 -- Females
                (select distinct o.person_id as id, 'Documented_HIV_Status' as treatment, 'Retreatment excluding Relapse' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Retreatment Excluding Relapse
                                    where concept_id = 3785
					                and value_coded in (3786,1037)
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4324,4664,4665)     -- Known HIV status 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
						
						 UNION
                -- Children who are 14 or less - Documented and known HIV statae
                -- Documented HIV status - Males and Females
                -- Females
                (select distinct o.person_id as id, 'Documented_HIV_Status' as treatment, 'Children who are 14 or less' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Children (0 - 14)
                                    where FLOOR(DATEDIFF(current_date(),p.birthdate)/365) <=14
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4324,4664,4665)     -- Known HIV status  
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
						
						 UNION
                -- Miners - Documented and known HIV statae
                -- Documented HIV status - Males and Females
                -- Females
                (select distinct o.person_id as id, 'Documented_HIV_Status' as treatment, 'Miners' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Miners
                                    where concept_id = 3776
                                    and value_coded = 3667
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4324,4664,4665)     -- Known HIV status 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
						
						 UNION
                -- Ex-Miners - Documented and known HIV statae
                -- Documented HIV status - Males and Females
                -- Females
                (select distinct o.person_id as id, 'Documented_HIV_Status' as treatment, 'Ex-Miners' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Ex Miners
                                    where concept_id = 3776
                                    and value_coded = 3668
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4324,4664,4665)     -- Known HIV status  
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
						
						  UNION
                -- HouseHold Ex Miner - Documented and known HIV statae
                -- Documented HIV status - Males and Females
                -- Females
                (select distinct o.person_id as id, 'Documented_HIV_Status' as treatment, 'HHEM' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- HouseHold EX Miner
                                    where concept_id = 3776
                                    and value_coded = 3778
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4324,4664,4665)     -- Known HIV status     
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
						
						      UNION
                -- HouseHold Current Miner - Documented and known HIV statae
                -- Documented HIV status - Males and Females
                -- Females
                (select distinct o.person_id as id, 'Documented_HIV_Status' as treatment, 'HHCM' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- HouseHold Current Miner
                                    where concept_id = 3776
                                    and value_coded = 3777
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4324,4664,4665)     -- Known HIV status 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
						
						 UNION
                -- Factory workers - Documented and known HIV statae
                -- Documented HIV status - Males and Females
                -- Females
                (select distinct o.person_id as id, 'Documented_HIV_Status' as treatment, 'Factory workers' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Factory Workers
                                    where concept_id = 3776
                                    and value_coded = 3669
																		AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4324,4664,4665)     -- Known HIV status  
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
                                       
                    
                UNION


                -- Females and Males HIV Positive
                -- Females
                (select distinct o.person_id as id, 'HIV_Positive' as treatment, 'New and Relapse' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- new and relapse tb patients
                                    where concept_id = 3785 
                                    and value_coded in (1034,1084)  
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))									
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4664)     -- Positive HIV status 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                        )
             
            
           
                UNION


                -- Females and Males HIV Positive
                -- Females
                (select distinct o.person_id as id, 'HIV_Positive' as treatment, 'Retreatment excluding Relapse' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Retreatment Excluding Relapse
                                    where concept_id = 3785
					                and value_coded in (3786,1037)  
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))									
									
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4664)     -- Positive HIV status 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                )

               
             
                UNION
                -- Females and Males HIV Positive
                -- Females
                (select distinct o.person_id as id, 'HIV_Positive' as treatment, 'Children who are 14 or less' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Children (0 - 14)
                                    where FLOOR(DATEDIFF(current_date(),p.birthdate)/365) <=14  
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4664)     -- Positive HIV status   
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                )
                                     
                

               
             
              
                UNION


                -- Females and Males HIV Positive
                -- Females
                (select distinct o.person_id as id, 'HIV_Positive' as treatment, 'Miners' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Miners
                                    where concept_id = 3776
                                    and value_coded = 3667  
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))									
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4664)     -- Positive HIV status  
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                )
           

               
           
              
                UNION


                -- Females and Males HIV Positive
                -- Females
                (select distinct o.person_id as id, 'HIV_Positive' as treatment, 'Ex-Miners' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Ex Miners
                                    where concept_id = 3776
                                    and value_coded = 3668 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))									
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4664)     -- Positive HIV status    
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                )
             

          
           
                UNION


                -- Females and Males HIV Positive
                -- Females
                (select distinct o.person_id as id, 'HIV_Positive' as treatment, 'HHCM' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- HouseHold Current Miner
                                    where concept_id = 3776
                                    and value_coded = 3777
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))									
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4664)     -- Positive HIV status 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                )
               

              
                UNION
                


                -- Females and Males HIV Positive
                -- Females
                (select distinct o.person_id as id, 'HIV_Positive' as treatment, 'HHEM' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- HouseHold EX Miner
                                    where concept_id = 3776
                                    and value_coded = 3778 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4664)     -- Positive HIV status 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                )
                
                
               
                UNION
                


                -- Females and Males HIV Positive
                -- Females
                (select distinct o.person_id as id, 'HIV_Positive' as treatment, 'Factory workers' as patient_type,gender
				    from obs o inner join person p
                        on o.person_id = p.person_id 
                        and p.voided = 0 
                        and o.person_id in (
                                    select person_id
                                    from obs
                                    -- Factory Workers
                                    where concept_id = 3776
                                    and value_coded = 3669 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))									
                                    )
                        inner join patient_identifier on patient_identifier.patient_id = o.person_id and patient_identifier.identifier_type = 3
                        where o.concept_id = 4666 
                        and value_coded in(4323,4664)     -- Positive HIV status 
									AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
									AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))						
                )
		) as b
	) as a 
)as final
	group by patient_type