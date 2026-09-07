SELECT
IF(Id IS NULL, 0, SUM(IF(PostNatal = 'infant_births', 1, 0))) AS infant_births,
IF(Id IS NULL, 0, SUM(IF(PostNatal = 'Institutional_birth', 1, 0))) AS Institutional_birth,
IF(Id IS NULL, 0, SUM(IF(PostNatal = 'home_birth', 1, 0))) AS home_birth,
IF(Id IS NULL, 0, SUM(IF(PostNatal = 'ARV_prophylaxis', 1, 0))) AS ARV_prophylaxis,
IF(Id IS NULL, 0, SUM(IF(PostNatal = 'Seen_With_24hrs', 1, 0))) AS Seen_With_24hrs

FROM 
(
SELECT Id, PostNatal
FROM
-- MOTHER
	(
-- CHILD
select person_id as Id,'infant_births' as PostNatal
from obs
where concept_id = 1914
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as ID,'Institutional_birth' as PostNatal
from obs
where concept_id = 1917
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as ID,'home_birth' as PostNatal
from obs
where concept_id = 1916
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'ARV_prophylaxis' as PostNatal
from obs
where concept_id = 2372
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
select person_id as Id,'Seen_With_24hrs' as PostNatal
from obs
where (concept_id = 4393  and value_coded in(4394,4395,4396))
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
) as ab
)as bc
group by PostNatal