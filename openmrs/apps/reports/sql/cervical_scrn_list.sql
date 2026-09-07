
(SELECT patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB, Gender, Screening_Status, Screening_Type, VIA_Result, PapSmear_Result
    FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group
									  

                from obs o
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0 and o.concept_id = 4511 -- Cervical Cancer Screening Register
                          AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
				          AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)		 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 -- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						 -- LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Cervical_Cancer_Screened

left outer join 
(
        select distinct os.person_id,
       case
       -- Screening Type
           when os.value_coded = 4757 then "Cervical VIA Test"
           when os.value_coded = 4525 then "Pap Smear"
           when os.value_coded = 4526 then "Both VIA&Pap Smear"
           else ""
       end AS Screening_Type
       from obs os 
       where os.concept_id = 4527
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)screening_type
on screening_type.person_id = Cervical_Cancer_Screened.Id

left outer join 

(
        select distinct os.person_id,
       -- Results of VIA Test
       case
           when os.value_coded = 328 then "VIA +ve"
           when os.value_coded = 329 then "VIA -ve"
           when os.value_coded = 4793 then "VIA +ve Suspected Cancer"
           else ""
       end AS VIA_Result
       from obs os 
       where os.concept_id = 327 and os.concept_id = 4511
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)via_result
on via_result.person_id = Cervical_Cancer_Screened.Id

left outer join 

(select distinct o.person_id,
       case
           when o.value_coded = 2147 then "New"
		   when o.value_coded = 2146 then "Repeat"
           else ""
       end AS Screening_Status
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4513 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4513
	and  o.obs_datetime = max_observation

)Screening
on Screening.person_id = Cervical_Cancer_Screened.Id

left outer join 

(
        select distinct os.person_id,
       -- Results of Pap Smear Test
       case
           when os.value_coded = 324 then "Normal"
           when os.value_coded = 4748 then "LSIL"
           when os.value_coded = 4529 then "HSIL"
           when os.value_coded = 4530 then "ASCUS"
           when os.value_coded = 4531 then "ASCUS - H AGC AGUS"
           when os.value_coded = 550 then "	Malignant Cells AIS"
           else ""
       end AS PapSmear_Result
       from obs os 
       where os.concept_id = 4532
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)pap_smear_result
on pap_smear_result.person_id = Cervical_Cancer_Screened.Id

ORDER BY Cervical_Cancer_Screened.Age)



