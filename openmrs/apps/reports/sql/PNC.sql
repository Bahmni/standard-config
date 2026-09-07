SELECT exam_time,
IF(Id IS NULL, 0, SUM(IF(PNC_Visit = 'Vitamin_A', 1, 0))) AS Vitamin_A,
IF(Id IS NULL, 0, SUM(IF(PNC_Visit = 'Family_Planning', 1, 0))) AS Family_Planning,
IF(Id IS NULL, 0, SUM(IF(PNC_Visit = 'Cervical_Cancer', 1, 0))) AS Cervical_Cancer,
IF(Id IS NULL, 0, SUM(IF(PNC_Visit = 'Breast_Lactating', 1, 0))) AS Breast_Lactating,
IF(Id IS NULL, 0, SUM(IF(PNC_Visit = 'MUAC_Under_23', 1, 0))) AS MUAC_Under_23,
IF(Id IS NULL, 0, SUM(IF(PNC_Visit = 'Micro_Nutrient_supplied', 1, 0))) AS Micro_Nutrient_supplied,
IF(Id IS NULL, 0, SUM(IF(PNC_Visit = 'HIV_Positive', 1, 0))) AS HIV_Positive,
IF(Id IS NULL, 0, SUM(IF(PNC_Visit = 'Hb_Under_8', 1, 0))) AS Hb_Under_8
FROM 
(
SELECT Id, PNC_Visit,exam_time
FROM
-- MOTHER
	(	
		
-- Vitamin A within 6 weeks after delivery
(select o.person_id as Id, 'Vitamin_A' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where concept_id = 2471
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)

UNION
-- Family Planning counselling
(select o.person_id as Id,'Family_Planning' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where concept_id = 4350 and value_coded  = 2146
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)

UNION
-- Micro-nutrient within 14 weeks of delivery 
(select o.person_id as Id, 'Micro_Nutrient_supplied' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where concept_id = 4437 and value_coded = 2146
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)

UNION
-- Micro-nutrient within 14 weeks of delivery 
(select o.person_id as Id, 'Micro_Nutrient_supplied' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where concept_id = 4437 and value_coded = 2146
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)

UNION
-- Cervical cancer screening at 14 weeks 
(select o.person_id as Id, 'Cervical_Cancer' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where (concept_id = 4445 and value_coded = 2146)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)


UNION
-- lactating
(select o.person_id as Id,'Breast_Lactating' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where concept_id = 4421 and value_coded = 2146
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)


UNION
-- MUAC < 23 cm in lactating mothers at 14 weeks
(select o.person_id as Id,'MUAC_Under_23' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where (concept_id  = 4435 and value_coded = 2146)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)

UNION

-- HIV +ve at 6 weeks
(select o.person_id as Id,'HIV_Positive' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where (concept_id  = 4427 and value_coded = 1738)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)

UNION


-- Hb < 8 at 6 weeks
(select o.person_id as Id,'Hb_Under_8' as PNC_Visit,
case 
when value_coded = 4394 then '1st_Hour'
when value_coded = 4395 then '12_Hours'
when value_coded = 4396 then '24_Hours'
when value_coded = 4397 then '1_Week'
when value_coded = 4398 then '6_Weeks'
when value_coded = 4399 then '10_Weeks'
when value_coded = 4400 then '14_Weeks'
when value_coded = 4401 then '6_Months'
else 'Unknown Time' end as 'exam_time'
from obs o
		INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
		AND o.person_Id in (select person_id from obs where concept_id = 4614)
where (concept_id  = 4431 and value_coded = 4615)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
)

				
	)AS B
)AS C
group by exam_time
