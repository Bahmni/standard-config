SELECT
IF(total_traced IS NULL, 0, SUM(IF(contacts = 'total_PTB', 1, 0))) AS Total_PTB_Cases,
IF(total_traced IS NULL, 0, SUM(IF(contacts = 'total_tracked', 1, 0))) AS PTB_Traced,
IF(total_traced IS NULL, 0, SUM(IF(contacts = 'total_screened', 1, 0))) AS PTB_Screened,
IF(total_traced IS NULL, 0, SUM(IF(contacts = 'total_IPT', 1, 0))) AS PTB_on_IPT

FROM	(
		select total_traced,contacts
		FROM(
-- Total Number of contacts of PTB cases  for TB	
select sum(value_numeric) as total_traced, 'total_PTB' as contacts
from obs 
where (concept_id = 3812 and value_numeric > 0)
and person_id in 
	(
	select person_id  
	from obs
	where concept_id = 1126 and value_coded = 1018
	AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
	AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
	)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
-- number of contacts traced
select sum(value_numeric) as total_traced, 'total_tracked' as contacts
from obs 
where (concept_id = 3813 and value_numeric > 0)
and person_id in 
	(
	select person_id  
	from obs
	where concept_id = 1126 and value_coded = 1018
	AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
	AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
	)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
-- number of contacts screened
select sum(value_numeric) as total_traced, 'total_screened' as contacts
from obs 
where (concept_id = 3811 and value_numeric > 0)
and person_id in 
	(
	select person_id  
	from obs
	where concept_id = 1126 and value_coded = 1018
	AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
	AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
	)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))

UNION
-- Number of contacts of PTB cases who are on IPT
select sum(value_numeric) as total_traced, 'total_IPT' as contacts
from obs 
where (concept_id = 3810 and value_numeric > 0)
and person_id in 
	(
	select person_id  
	from obs
	where concept_id = 1126 and value_coded = 1018
	AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
	AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
	)
AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
	)b
		) as a