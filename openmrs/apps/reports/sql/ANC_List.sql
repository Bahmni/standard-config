
SELECT patientIdentifier, patientName, Age, Visit_type, Subsequent_Visit_Number, Trimester, Estimated_Date_Delivery, High_Risk_Pregnancy, Syphilis_Screening_Results
     , Syphilis_Treatment_Completed, Haemoglobin, HIV_Status_Known_Before_Visit, Final_HIV_Status, Subsequent_HIV_Test_Results, MUAC, TB_Status, Iron, Folate, Blood_Group
FROM
(
select patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                        o.encounter_id,
						case 
							when o.value_coded = 4659 then 'First Visit'
							when o.value_coded = 4660 then 'Subsequent Visit'
						else '' end as Visit_type
from obs o
    -- ANC Clients
    INNER JOIN patient ON o.person_id = patient.patient_id
	AND patient.voided = 0 AND o.voided = 0
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	where concept_id =4658 -- ANC Visit types
    and o.voided = 0
	And CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	order by o.person_id
)AS ANC_Clients

left outer join 

(
	-- Trimester
select Id, encounter_id, value_numeric,
 case
 when value_numeric <= 12 then "1st Trimester"
 when value_numeric > 12 and value_numeric < 28 then "2nd Trimetser"
 when value_numeric >= 28 then "3rd Trimester"
else ""
end AS Trimester
from
(select B.person_id as Id, B.obs_group_id, B.value_numeric, B.encounter_id
from obs B
inner join 
(select person_id, obs_datetime,SUBSTRING(CONCAT(obs_datetime, obs_id), 20) AS observation_id
from obs where concept_id = 4296 -- ANC Examaninations section
and obs_datetime <= cast('#endDate#' as date)
and voided = 0
-- group by person_id
) as A
on A.observation_id = B.obs_group_id
where concept_id = 1923 -- Gestation period
and cast(B.obs_datetime as date) >= cast('#startDate#' as date)
and cast(B.obs_datetime as date) <= cast('#endDate#' as date)
and A.observation_id = B.obs_group_id
and voided = 0
)GA
) Gestational_Period
on ANC_Clients.encounter_id = Gestational_Period.encounter_id

left outer join
(
	select B.person_id as Id, B.obs_group_id, cast(B.value_datetime as date) AS Estimated_Date_Delivery, B.encounter_id
        from obs B
        inner join 
        (select person_id, obs_datetime,SUBSTRING(CONCAT(obs_datetime, obs_id), 20) AS observation_id
        from obs where concept_id = 4296 -- ANC Examaninations section
        and obs_datetime <= cast('#endDate#' as date)
        and voided = 0
		) as A
        on A.observation_id = B.obs_group_id
        where concept_id = 4627 -- EDD
        and A.observation_id = B.obs_group_id
        and voided = 0	
)edd_date
on ANC_Clients.encounter_id = edd_date.encounter_id

left outer join

(
 select o.person_id, o.encounter_id,
 case
    when o.value_coded = 1723 then '2'
    when o.value_coded = 1724 then '3'
    when o.value_coded = 4507 then '4'
    when o.value_coded = 4508 then '5'
    when o.value_coded = 4509 then '6'
    when o.value_coded = 5994 then '7'
    when o.value_coded = 5995 then '8'
    else ''
    end Subsequent_Visit_Number
    from obs o
    where o.concept_id = 4510  -- visit order 
 and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
 and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
 and o.voided = 0
)as visit
on ANC_Clients.encounter_id = visit.encounter_id

left outer join

(
	-- ANC High Risk Pregnancy
    select o.person_id,o.encounter_id, value_coded as high_risk_preg_code, group_concat(distinct name separator ', ') as High_Risk_Pregnancy
    from obs o join concept_name cn on o.value_coded = cn.concept_id
    where o.concept_id = 4352 
    and name in ('No Risk','Age less than 16 years','Age more than 40 years','Previous SB or NND',
    'History 3 or more consecutive spontaneous miscarriages','Birth Weight< 2500g','Birth Weight > 4500g',
    'Previous Hx of Hypertension/pre-eclampsia/eclampsia','Isoimmunization Rh(-)','Renal Disease','Cardiac Disease','Diabetes',
    'Known Substance Abuse','Pelvic Mass','Primigravida','Previous Surgery on Reproductive Tract','Other Answer','Hypertension',
    'Reduced Fetal Movements','UTI','STI','Anaemia','Malpresentation','Multiple pregnancy','GBV','HIV infection','Covid19','Syphillis','')
    and o.voided = 0
    and cast(o.obs_datetime as date) >= CAST('2025-08-01' AS DATE)
    and cast(o.obs_datetime as date) <= CAST('2025-09-04' AS DATE)
    group by o.person_id
) High_Risk_Preg
on ANC_Clients.encounter_id = High_Risk_Preg.encounter_id

-- Syphilis_Screening_Results
left outer join
(
   select o.person_id, o.encounter_id,
    case 
    when o.value_coded = 4306 then 'Reactive'
    when o.value_coded = 4307 then 'Non Reactive'
    when o.value_coded = 4308 then 'Not done'
    else '' end as Syphilis_Screening_Results
    from obs o 
    where o.concept_id = 4305 -- Syphilis Screening Results
    and o.voided = 0
    and cast(o.obs_datetime as date) >= CAST('#startDate#' AS DATE)
    and cast(o.obs_datetime as date) <= CAST('#endDate#' AS DATE)
) Syphilis_Screening_Res
on Syphilis_Screening_Res.encounter_id = ANC_Clients.encounter_id

left outer join
(
-- Syphilis Treatment Completed
select o.person_id, o.encounter_id,
    case 
    when o.value_coded = 2146 then "Yes"
    when o.value_coded = 2147 then "No"
    when o.value_coded = 1975 then "Not applicable"
    else '' end as Syphilis_Treatment_Completed
from obs o 
where o.concept_id = 1732
and o.obs_datetime >= cast('#startDate#' as date)
and o.obs_datetime <= cast('#endDate#' as date)
and o.voided = 0
) Syphilis_Treatment_Comp
on ANC_Clients.encounter_id = Syphilis_Treatment_Comp.encounter_id

left outer join
(select o.person_id, o.value_numeric as Haemoglobin, o.encounter_id
from obs o 
where o.concept_id = 3204
and o.voided = 0
and o.obs_datetime >= cast('#startDate#' as date)
and o.obs_datetime <= cast('#endDate#' as date)	
)Haemoglobin_Anemia
ON ANC_Clients.encounter_id = Haemoglobin_Anemia.encounter_id

left outer join
(
	select distinct o.person_id as Id, o.encounter_id,
    case 
    when o.value_coded = 1016 then 'Negative'
    when o.value_coded = 1738 then 'Positive'
    when o.value_coded = 1739 then 'Unknown'
    else 'N/A' end as HIV_Status_Known_Before_Visit
    from obs o 
    where concept_id = 4427 -- HIV Status Known Before Visit
    and o.obs_datetime >= cast('#startDate#' as date)
    and o.obs_datetime <= cast('#endDate#' as date)
    and o.voided = 0
) HIV_Status
on ANC_Clients.encounter_id = HIV_Status.encounter_id

-- Final HIV Status	
left outer join
(
	select distinct o.person_id as Id, o.encounter_id,
    case 
    when o.value_coded = 1016 then 'Negative'
    when o.value_coded = 1738 then 'Positive'
    when o.value_coded = 4321 then 'Declined'
    when o.value_coded = 1975 then 'N/A'
    else '' end as Final_HIV_Status
	from obs o 
    where concept_id = 1740
    and o.voided = 0
    and o.obs_datetime >= cast('#startDate#' as date)
    and o.obs_datetime <= cast('#endDate#' as date)
) F_HIV_Status
on F_HIV_Status.encounter_id = ANC_Clients.encounter_id

left outer join
(
    select distinct o.person_id,o.encounter_id,
    case
    when o.value_coded = 1738 then "Positive"
    when o.value_coded = 1016 then "Negative"
    when o.value_coded = 4321 then "Decline"
    when o.value_coded = 1975 then "Not applicable"
    else ""
    end AS Subsequent_HIV_Test_Results
    from obs o
    where o.concept_id = 4325 and o.voided = 0 -- Subsequent HIV test results
    and o.obs_datetime >= CAST('#startDate#' AS DATE)
    and o.obs_datetime <= CAST('#endDate#'AS DATE)
) Subsequent_HIV_Status
on ANC_Clients.encounter_id = Subsequent_HIV_Status.encounter_id

-- MUAC
left outer join
(select distinct o.person_id, o.value_numeric as MUAC, o.encounter_id
from obs o 
where o.concept_id = 2086
and o.voided = 0
and o.obs_datetime >= cast('#startDate#' as date)
and o.obs_datetime <= cast('#endDate#' as date)
)muac
ON ANC_Clients.encounter_id = muac.encounter_id

-- TB STATUS
left outer join

(select
    distinct o.person_id,o.encounter_id,
    case
    when value_coded = 3709 then "No Signs"
    when value_coded = 1876 then "TB Suspect"
    when value_coded = 3639 then "On TB Treatment"
    else "" end AS TB_Status
from obs o
where concept_id = 3710
and o.voided = 0
and o.obs_datetime >= cast('#startDate#' as date)
and o.obs_datetime <= cast('#endDate#' as date)
) TBStatus
ON ANC_Clients.encounter_id = TBStatus.encounter_id

-- Iron
left outer join

(select distinct o.person_id,o.encounter_id,
    case
    when o.value_coded = 4668 then "Prophylaxis"
    when o.value_coded = 1067 then "On Treatment"
    when o.value_coded = 4298 then "Not Given"
    else "" end AS Iron
from obs o
where o.concept_id = 4299
and o.voided = 0
and o.obs_datetime >= cast('#startDate#' as date)
and o.obs_datetime <= cast('#endDate#' as date)
) Iron
ON ANC_Clients.encounter_id = Iron.encounter_id

-- Folate
left outer join

(select distinct o.person_id, o.encounter_id,
    case
    when o.value_coded = 4668 then "Prophylaxis"
    when o.value_coded = 1067 then "On Treatment"
    when o.value_coded = 4298 then "Not Given"
    else "" end AS Folate
from obs o
where o.concept_id = 4300
and o.obs_datetime >= cast('#startDate#' as date)
and o.obs_datetime <= cast('#endDate#' as date)
and o.voided = 0
) Folate
ON ANC_Clients.encounter_id = Folate.encounter_id

left outer join 
(
-- Blood Group
    select distinct o.person_id, o.encounter_id,
    case
    when o.value_coded = 4309 then "Blood Group, A+"
    when o.value_coded = 4310 then "Blood Group, A-"
    when o.value_coded = 4311 then "Blood Group, B+"
    when o.value_coded = 4312 then "Blood Group, B-"
    when o.value_coded = 4313 then "Blood Group, O+"
    when o.value_coded = 4314 then "Blood Group, O-"
    when o.value_coded = 4315 then "Blood Group, AB+"
    when o.value_coded = 4316 then "Blood Group, AB-"
    else "N/A"
    end AS Blood_Group
    from obs o
    where o.concept_id = 1179 and o.voided = 0
    and o.obs_datetime >= CAST('#startDate#' AS DATE)
    and o.obs_datetime <= CAST('#endDate#' AS DATE)
) Blood_Group_Status
on ANC_Clients.encounter_id = Blood_Group_Status.encounter_id
order by patientName



