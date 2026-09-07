SELECT distinct Patient_Identifier,
	  		    Patient_Name,
	            Gender,
				Age,
				Age_Group,
				First_PNC_Attendance,
				Place_of_Delivery,
				FP_Counselling,
				FP_Method,
				Syphillis_Screening,
				Cancer_Screening,
				Cancer_Assessment_Method,
				HIV_Testing_Result,
				Breastfeeding,
				MUAC_less_than_23cm
FROM
(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Gender, Age, age_group as Age_Group
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS SEEN FOR PNC
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 4386 				 
						 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                         AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					     AND patient.voided = 0 AND o.voided = 0											
					)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('2022-12-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') as seen_for_pnc
				   )pnc_seen

left outer JOIN

(select
       o.person_id,
       case
	   -- First PNC Attendance
           when value_coded = 4394 then "1st Hour"
           when value_coded = 5274 then "6th Hour"
           when value_coded = 4395 then "12th Hour"
		   when value_coded = 4396 then "24th Hour"
           when value_coded = 4397 then "1st Week"
           when value_coded = 4398 then "6th Week"
		   when value_coded = 4399 then "10th Week"
           when value_coded = 4400 then "14th Week"
           when value_coded = 4401 then "6th Month"
           else ""
       end AS First_PNC_Attendance
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
		 from obs oss
		 where oss.concept_id = 4393 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4393
	and  o.obs_datetime = max_observation
) pnc_attendance
ON pnc_seen.Id = pnc_attendance.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Place of Delivery
           when value_coded = 1915 then "Institutional Delivery"
           when value_coded = 1916 then "Home Delivery"
           when value_coded = 5096 then "Born Before Arrival"
           else ""
       end AS Place_of_Delivery
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as delivery_location
		 from obs oss
		 where oss.concept_id = 1917 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 1917
	and  o.obs_datetime = max_observation
) place_delivery
ON pnc_seen.Id = place_delivery.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Family Planning Counselling
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS FP_Counselling
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as counselling_fp
		 from obs oss
		 where oss.concept_id = 4350 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4350
	and  o.obs_datetime = max_observation
) family_planning_counselling
ON pnc_seen.Id = family_planning_counselling.person_id

left outer JOIN			
								
(select
       o.person_id,
       case
	   -- Family Planning Method
           when value_coded = 5205 then "Progestrone only pill"
           when value_coded = 5206 then "Combined oral contraceptive"
		   when value_coded = 5207 then "DMPA-SC"
           when value_coded = 5208 then "DMPA-IM"
		   when value_coded = 5209 then "Noristrate"
           when value_coded = 2314 then "Implant"
		   when value_coded = 4551 then "Jadelle"
           when value_coded = 5212 then "Norplant"
		   when value_coded = 4441 then "Lactational Amenorrhea Method"
           when value_coded = 4552 then "Copper T380A"
		   when value_coded = 4440 then "Bilateral Tubal Ligation"
           when value_coded = 2497 then "Vasectomy"
		   when value_coded = 4229 then "Male Condoms"
           when value_coded = 4230 then "Female Condoms"
		   when value_coded = 4553 then "Standard Days Method"
           when value_coded = 5215 then "Emergency Pill"
		   when value_coded = 5214 then "IUCD"
           when value_coded = 1154 then "None"
           else ""
       		end AS FP_Method
			from obs o
			inner join
								(select B.person_id, B.obs_group_id, SUBSTRING(MAX(CONCAT(B.obs_datetime, B.value_coded)), 20) as method_fp
									from obs B
									inner join 
									(select oss.person_id, MAX(oss.obs_datetime) as max_observation,
									 SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs oss where oss.concept_id = 4386
									and oss.obs_datetime <= cast('#endDate#' as date)
									and oss.voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 2481
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) family_planning_method
								On family_planning_method.person_id = o.person_id
								where concept_id = 2481
								-- and  o.obs_datetime = max_observation
								and o.voided =0
)fp_method
ON pnc_seen.Id = fp_method.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Syphillis Screening
           when value_coded = 4306 then "Reactive"
           when value_coded = 4307 then "Non-Reactive"
		   when value_coded = 1975 then "N/A"
           else ""
       end AS Syphillis_Screening
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as screening_syphillis
		 from obs oss
		 where oss.concept_id = 5304 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 5304
	and  o.obs_datetime = max_observation
) Screening
ON pnc_seen.Id = Screening.person_id

left outer join 

(select
       o.person_id,
       case
	   -- Cervical Cancer Screening
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS Cancer_Screening
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as screening_cancer
		 from obs oss
		 where oss.concept_id = 4445 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4445
	and  o.obs_datetime = max_observation
) Cervical_Cancer
ON pnc_seen.Id = Cervical_Cancer.person_id

left outer join 

(select
       o.person_id,
       case
	   -- Cervical Cancer Assessment Method
           when value_coded = 4525 then "Pap Smear"
           when value_coded = 4528 then "VIA"
           else ""
       end AS Cancer_Assessment_Method
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as assessment_cancer
		 from obs oss
		 where oss.concept_id = 4618 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4618
	and  o.obs_datetime = max_observation
) Cervical_Cancer_Assessment
ON pnc_seen.Id = Cervical_Cancer_Assessment.person_id

left outer JOIN

(
	select
       o.person_id,
       case
	   -- HIV Testing Done in PNC
           when value_coded = 1738 then "Positive"
           when value_coded = 1016 then "Negative"
		   when value_coded = 4321 then "Declined"
           when value_coded = 1975 then "N/A"
           else ""
       end AS HIV_Testing_Result
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as result_HIV
		 from obs oss
		 where oss.concept_id = 4428 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4428
	and  o.obs_datetime = max_observation
)result_HIV_Testing
ON pnc_seen.Id = result_HIV_Testing.person_id

left outer JOIN

(
	select
       o.person_id,
       case
	   -- Breastfeeding Status
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS Breastfeeding
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as breastfeeding_status
		 from obs oss
		 where oss.concept_id = 5291 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 5291
	and  o.obs_datetime = max_observation
)status_breastfeeding
ON pnc_seen.Id = status_breastfeeding.person_id

left outer JOIN

(
	select
       o.person_id,
       case
	   -- MUAC < 23
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS MUAC_less_than_23cm
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as muac_status
		 from obs oss
		 where oss.concept_id = 4435 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4435
	and  o.obs_datetime = max_observation
)status_muac
ON pnc_seen.Id = status_muac.person_id