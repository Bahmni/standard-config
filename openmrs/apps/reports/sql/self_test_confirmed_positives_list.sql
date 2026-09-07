 (SELECT distinct patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Self-test' AS 'HIV_Testing_Initiation'
                                    , HIV_Status
                    FROM
                                    (select distinct patient.patient_id AS Id,
                                                        patient_identifier.identifier AS patientIdentifier,
                                                        concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                                        floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                                        (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED' and cn.voided = 0 and cn.locale = 'en' limit 1) AS HIV_Status,
                                                        person.gender AS Gender,
                                                        observed_age_group.name AS age_group,
                                                        observed_age_group.sort_order AS sort_order
                                    from obs o
                                            -- HTS SELF TEST STRATEGY
                                            INNER JOIN patient ON o.person_id = patient.patient_id 
                                            AND o.concept_id = 4845 and value_coded = 4822
                                            AND patient.voided = 0 AND o.voided = 0
                                            AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                            
                                            -- HAS HIV POSITIVE RESULTS 
                                            AND o.person_id in (
                                                select distinct os.person_id
                                                from obs os
                                                where os.concept_id = 4844 and os.value_coded = 1738
                                                AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND patient.voided = 0 AND o.voided = 0
                                            )
                                            
                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                            INNER JOIN reporting_age_group AS observed_age_group ON
                                            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                                    WHERE observed_age_group.report_group_name = 'Modified_Ages'
                                            ) AS HTSClients_HIV_Status
                    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)