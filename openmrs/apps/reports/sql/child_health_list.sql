Select distinct patientIdentifier as Patient_Identifier , patientName, Months, Gender, Base_Dose, 1st_Dose, 2nd_Dose, 3rd_Dose, Fully_Immunized, Measles_1stDose, Measles_2nd_Dose, Dt_1stDose
From
(
	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			timestampdiff(month, person.birthdate, CAST('#endDate#' AS DATE)) AS Months,
			person.gender AS Gender
	from obs o
					--  Children
		INNER JOIN patient ON o.person_id = patient.patient_id
		AND o.concept_id = 4285
		AND patient.voided = 0 AND o.voided = 0
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
	Group by Id
	having Months < 56

) As Child

left outer join 

(
	-- Base Dose
select o.person_id, value_coded as Base_dose_code, group_concat(distinct name separator ', ') as Base_dose
from obs o join concept_name cn on o.value_coded = cn.concept_id
where o.concept_id = 4452 
	and o.voided = 0
	and name in ('BCG', 'Polio(OPV)')
Group by o.person_id
) BaseDose
on Child.Id = BaseDose.person_id



 -- 1st Dose
left outer join
	(
	select person_id, value_coded as 1st_Code, group_concat(distinct name separator ', ') as 1st_dose, CAST(obs_datetime AS Date) as feeding_obs_date
	from obs join concept_name cn on obs.value_coded = cn.concept_id
	where obs.concept_id = 4455
		and obs.voided = 0
		and name in ('Polio(OPV)', 'Pentavalent', 'Rotavirus(RV)', 'Pneumococal(PCV)')
	group by person_id
	) 1stDose
	on 1stDose.person_id = Child.Id
	
 -- 2nd Dose
left outer join
	(
	select person_id, value_coded as 2nd_Code, group_concat(distinct name separator ', ') as 2nd_dose, CAST(obs_datetime AS Date) as feeding_obs_date
	from obs join concept_name cn on obs.value_coded = cn.concept_id
	where obs.concept_id = 4459
		and obs.voided = 0
		and name in ('Polio(OPV)', 'Pentavalent', 'Rotavirus(RV)', 'Pneumococal(PCV)')
	group by person_id

	) As 2nd_Dose
	on 2nd_Dose.person_id = Child.Id

 -- 3rd Dose
left outer join
	(
		Select person_id, value_coded as 3rd_Code, group_concat(distinct name separator ', ') as 3rd_dose, CAST(obs_datetime AS Date) as feeding_obs_date
	  from obs join concept_name cn on obs.value_coded = cn.concept_id
	  where obs.concept_id = 4460
		and obs.voided = 0
		and name in ('Polio(OPV)', 'Pentavalent', 'Rotavirus(RV)', 'Pneumococal(PCV)')
		group by person_id

	) As 3rd_Dose
	on 3rd_Dose.person_id = Child.Id

left outer join 
(
	-- fully immunized
 select o.person_id,case
 when o.value_coded = 1 then "Yes"
 when o.value_coded = 2 then "No"
else "N/A"
end AS Fully_Immunized
from obs o
where o.concept_id = 4462 and o.voided = 0
Group by o.person_id
) fullyImmunized
on Child.Id = fullyImmunized.person_id

left outer join 
(
	-- Measles 1st Dose
 select o.person_id,case
 when o.value_coded = 1 then "Yes"
 when o.value_coded = 2 then "No"
else "N/A"
end AS Measles_1stDose
from obs o
where o.concept_id = 4461 and o.voided = 0
Group by o.person_id
) Measles1stDose
on Child.Id = Measles1stDose.person_id

left outer join 
(
	-- Measles 2nd Dose
 select o.person_id,case
 when o.value_coded = 4483 then "Measles 2nd Dose"
else "N/A"
end AS Measles_2nd_Dose
from obs o
where o.concept_id = 4487 and o.voided = 0
Group by o.person_id
) Measles2ndDose
on Child.Id = Measles2ndDose.person_id

left outer join 
(
	-- Dt 1st Dose
 select o.person_id,case
 when o.value_coded = 4484 then "DT Booster"
else "N/A"
end AS Dt_1stDose
from obs o
where o.concept_id = 4487 and o.voided = 0
Group by o.person_id
) Dt1stDose
on Child.Id = Dt1stDose.person_id

