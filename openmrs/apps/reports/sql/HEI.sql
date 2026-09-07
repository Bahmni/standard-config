SELECT
IF(Id IS NULL, 0, SUM(IF(exposure = 'Prophylaxis_received', 1, 0))) AS Prophylaxis_received,
IF(Id IS NULL, 0, SUM(IF(exposure = 'ARV_While_Pregnant', 1, 0))) AS ARV_While_Pregnant,
IF(Id IS NULL, 0, SUM(IF(exposure = 'ARV_during_delivery', 1, 0))) AS ARV_during_delivery,
IF(Id IS NULL, 0, SUM(IF(exposure = 'Exclusive_breastfeeding', 1, 0))) AS Exclusive_breastfeeding,
IF(Id IS NULL, 0, SUM(IF(exposure = 'Replacement_breastfeeding', 1, 0))) AS Replacement_breastfeeding,
IF(Id IS NULL, 0, SUM(IF(exposure = 'mixed_feeding', 1, 0))) AS mixed_feeding,
IF(Id IS NULL, 0, SUM(IF(exposure = 'Given_NVP', 1, 0))) AS Given_NVP,
IF(Id IS NULL, 0, SUM(IF(exposure = 'Given_CTX', 1, 0))) AS Given_CTX,
IF(Id IS NULL, 0, SUM(IF(exposure = 'Given_INH', 1, 0))) AS Given_INH,
IF(Id IS NULL, 0, SUM(IF(exposure = 'discharged_positive', 1, 0))) AS discharged_positive,
IF(Id IS NULL, 0, SUM(IF(exposure = 'discharged_negative', 1, 0))) AS discharged_negative

FROM 
(
SELECT Id, exposure
FROM
-- MOTHER
	(
-- prophylaxis received before 6wks
select person_id as Id,'Prophylaxis_received' as exposure
from obs
where concept_id = 2372 and value_coded in(4394,4395,4396,4398)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
-- mothers ARV

select person_id as Id,'ARV_While_Pregnant' as exposure
from obs
where concept_id = 4567 and value_coded = 2146
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'ARV_during_delivery' as exposure
from obs
where concept_id = 4568 and value_coded = 2146
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'Exclusive_breastfeeding' as exposure
from obs
where concept_id = 2376 and value_coded = 2373
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'Replacement_breastfeeding' as exposure
from obs
where concept_id = 2376 and value_coded = 2374
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'mixed_feeding' as exposure
from obs
where concept_id = 2376 and value_coded = 2375
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'Given_NVP' as exposure
from obs
where concept_id = 4591
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'Given_INH' as exposure
from obs
where concept_id = 4594
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'Given_CTX' as exposure
from obs
where concept_id = 4595
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'discharged_positive' as exposure
from obs
where concept_id = 4604 and value_coded = 1738
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'discharged_negative' as exposure
from obs
where concept_id = 4604 and value_coded = 1016
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
) ab
)bc
group by exposure
-- HIV status at 24mnths
-- 4606,4607,4608,4609,4610,4611,4612,3650,1143