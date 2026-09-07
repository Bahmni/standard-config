SELECT distinct patientIdentifier
				,ART_Number
			   ,ANC_Number
			   ,patientName
			   ,Gender
			   ,Age
			   ,First_Visit_Date
			   ,Gravida
			   ,Parity
			   ,Gestation_Age
			   ,Iron
			   ,Folate
			   ,Calcium
			   ,EDD
			   ,MUAC
			   ,Syphilis_Screening_Results
			   ,Syphilis_Treatment_Completed
			   ,Rhesus_Factor
			   ,TT_Current_Doses
			   ,TT_Current_Doses
			   ,HIV_Status_Known_Before_Visit
			   ,Initial_HIV_Test_Done_During_Pregnancy
			   ,Initial_HIV_Test_Results 
			   ,Final_HIV_Status
			   ,Subsequent_HIV_Test_Results
			   ,WHO_Clinical_Staging
			   ,TB_Treatment 
			   ,Baseline_Viral_Load_Results
			   ,Subsequent_Viral_Load_Results
			   ,TB_Status
			   ,Initiated_on_CTX
			   ,Initiated_on_PrEP
			   ,Initiated_on_ART
			   ,Infant_Feeding_Counselling
			   ,Family_Planning_Counselling
			   ,GBV_Counselling

			   
FROM
(Select distinct Id, patientIdentifier, ART_Number, ANC_Number, patientName,Gender, Age, age_group
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						pi2.identifier AS ANC_Number,
						p.identifier AS ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					--  ANC Clients 
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type = 8
						LEFT JOIN patient_identifier p ON p.patient_id = o.person_id AND p.identifier_type = 5
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4663
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS ANC_CLIENTS
)anc_patients

left outer join 

(
	select oss.person_id, CAST(MAX(oss.obs_datetime) AS DATE) as First_Visit_Date,
 	SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		 from obs oss
		 where oss.concept_id = 4658 and oss.value_coded = 4659
		 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
)as First_Visit_Date
on anc_patients.Id = First_Visit_Date.person_id

left outer JOIN

(
	select oss.person_id, CAST(MAX(oss.obs_datetime) AS DATE) as max_observation, oss.value_numeric as Gravida,
 	SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		 from obs oss
		 where oss.concept_id = 1718
		 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
)as gravida
on anc_patients.Id = gravida.person_id

left outer JOIN

(
	select oss.person_id, CAST(MAX(oss.obs_datetime) AS DATE) as max_observation, oss.value_numeric as Parity,
 	SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		 from obs oss
		 where oss.concept_id = 1719
		 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
)as parity
on anc_patients.Id = parity.person_id

left outer JOIN

(
	select oss.person_id, CAST(MAX(oss.obs_datetime) AS DATE) as max_observation, oss.value_numeric as Gestation_Age,
 	SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		 from obs oss
		 where oss.concept_id in (2423, 1923)
		 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
)as gestation
on anc_patients.Id = gestation.person_id

left outer join
(select o.person_id,CAST(estimated_delivery_date AS DATE) as EDD
from obs o 
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as estimated_delivery_date
		 from obs oss
		 where oss.concept_id in (4627,1721) and oss.voided=0
		 and oss.obs_datetime < cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id in (4627,1721)
	and  o.obs_datetime = max_observation	
	)edd
ON anc_patients.Id = edd.person_id

-- Syphilis_Screening_Results
left outer join
	(
		select o.person_id,
			case 
				when latest.Syphilis_Coded = 4306 then 'Reactive'
				when latest.Syphilis_Coded = 4307 then 'Non Reactive'
				when latest.Syphilis_Coded = 4308 then 'Not done'
			else 'NewResult' end as Syphilis_Screening_Results
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Syphilis_Coded
				from obs oss
				where oss.concept_id = 4305 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 4305
			and  o.obs_datetime = max_observation
	) Syphilis_Screening_Res

on Syphilis_Screening_Res.person_id = anc_patients.Id

left outer join
	(
	-- Syphilis Treatment Completed
	select o.person_id,
			case 
				when latest.treatment_Coded = 2146 then "Yes"
				when latest.treatment_Coded = 2147 then "No"
				when latest.treatment_Coded = 1975 then "Not applicable"
			else 'N/A' end as Syphilis_Treatment_Completed
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as treatment_Coded
				from obs oss
				where oss.concept_id = 1732 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 1732
			and  o.obs_datetime = max_observation
		
		) Syphilis_Treatment_Comp
		on anc_patients.Id = Syphilis_Treatment_Comp.person_id

left outer join
	(
		-- HIV Status Known Before Visit
	select o.person_id,
			case 
				when latest.Status_Coded = 1738 then "Positive"
				when latest.Status_Coded = 1016 then "Negative"
				when latest.Status_Coded = 1739 then "Unknown"
			else 'N/A' end as HIV_Status_Known_Before_Visit
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Status_Coded
				from obs oss
				where oss.concept_id = 4427 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 4427
			and  o.obs_datetime = max_observation
	)Status
		on anc_patients.Id = Status.person_id

left outer join
	(
		-- Final HIV Status 
	select o.person_id,
			case 
				when latest.Final_Status_Coded = 1738 then "Positive"
				when latest.Final_Status_Coded = 1016 then "Negative"
			else 'N/A' end as Final_HIV_Status
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Final_Status_Coded
				from obs oss
				where oss.concept_id = 2165 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 2165
			and  o.obs_datetime = max_observation
	)Final_Status
		on anc_patients.Id = Final_Status.person_id

left outer join
	(
		-- Subsequent HIV Test Results 
	select o.person_id,
			case 
				when latest.Subsequent_Status_Coded = 1738 then "Positive"
				when latest.Subsequent_Status_Coded = 1016 then "Negative"
				when latest.Subsequent_Status_Coded = 4321 then "Declined"
				when latest.Subsequent_Status_Coded = 1975 then "Not Applicable"
			else 'N/A' end as Subsequent_HIV_Test_Results 
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Subsequent_Status_Coded
				from obs oss
				where oss.concept_id = 	4325 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 4325
			and  o.obs_datetime = max_observation
	)Final_Subsequent_Status
		on anc_patients.Id = Final_Subsequent_Status.person_id

left outer join
	(
		-- Initial HIV Test Done During this Pregnancy 
 
	select o.person_id,
			case 
				when latest.Pregnancy_Status_Coded = 2146 then "Yes"
				when latest.Pregnancy_Status_Coded = 2147 then "No"
				when latest.Pregnancy_Status_Coded = 4321 then "Declined"
				when latest.Pregnancy_Status_Coded = 1975 then "Not Applicable"
			else 'N/A' end as Initial_HIV_Test_Done_During_Pregnancy 
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Pregnancy_Status_Coded
				from obs oss
				where oss.concept_id = 	1726 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 1726
			and  o.obs_datetime = max_observation
	)Final_Pregnancy_Status
		on anc_patients.Id = Final_Pregnancy_Status.person_id

left outer join
	(
		-- Initial HIV Test Results 
 
	select o.person_id,
			case 
				when latest.Initial_Test_Coded = 1738 then "Positive"
				when latest.Initial_Test_Coded = 1016 then "Negative"
				when latest.Initial_Test_Coded = 4321 then "Declined"
				when latest.Initial_Test_Coded = 1975 then "Not Applicable"
			else 'N/A' end as Initial_HIV_Test_Results  
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Initial_Test_Coded
				from obs oss
				where oss.concept_id = 	1740 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 1740
			and  o.obs_datetime = max_observation
	)Final_Initial_Test
		on anc_patients.Id = Final_Initial_Test.person_id

left outer join
	(
		-- TB Treatment/TPT

	select o.person_id,
			case 
				when latest.TB_Treatment_Coded = 4333 then "Client on INH"
				when latest.TB_Treatment_Coded = 4334 then "Still Undergoing Investigations"
				when latest.TB_Treatment_Coded = 4335 then "Has been on TB Treatment in the past two years"
				when latest.TB_Treatment_Coded = 3639 then "On TB treatment"
				when latest.TB_Treatment_Coded = 4336 then "Previous taken INH"
				when latest.TB_Treatment_Coded = 1975 then "Not Applicable"
				when latest.TB_Treatment_Coded = 2227 then "Isoniazid started"

			else 'N/A' end as TB_Treatment  
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as TB_Treatment_Coded
				from obs oss
				where oss.concept_id = 	4337 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 4337
			and  o.obs_datetime = max_observation
	)Final_TB_Treatment
		on anc_patients.Id = Final_TB_Treatment.person_id

left outer join
	(
		-- Baseline Viral Load Results 

	select o.person_id, o.obs_datetime as datetime,
			case 
				when latest.Baseline_Viral_Coded = 4265 then ">=20"
				when latest.Baseline_Viral_Coded = 4264 then "<20"
				when latest.Baseline_Viral_Coded = 4335 then "Undetectable"
			else 'N/A' end as Baseline_Viral_Load_Results  
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Baseline_Viral_Coded
				from obs oss
				where oss.concept_id = 4266 -- Results
				-- and oss.obs_datetime >= CAST('#startDate#' AS DATE)
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where o.concept_id = 4658 and value_coded = 4659 -- First ANC 
			and  o.obs_datetime = max_observation
	)Final_Baseline_Viral
		on anc_patients.Id = Final_Baseline_Viral.person_id

left outer join
	(
		-- Subsequent Viral Load Results 

	select o.person_id, o.obs_datetime as datetime,
			case 
				when latest.Subsequent_Viral_Coded = 4265 then ">=20"
				when latest.Subsequent_Viral_Coded = 4264 then "<20"
				when latest.Subsequent_Viral_Coded = 4263 then "Undetectable"
			else 'N/A' end as Subsequent_Viral_Load_Results  
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Subsequent_Viral_Coded
				from obs oss
				where oss.concept_id = 4266 -- Results
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where o.concept_id = 4658 and value_coded = 4660 -- Subsequent ANC 
			and  o.obs_datetime = max_observation
	)Final_Subsequent_Viral
		on anc_patients.Id = Final_Subsequent_Viral.person_id

left outer join
	(
		-- WHO Clinical Staging

	select o.person_id, o.obs_datetime as datetime,
			case 
				when latest.WHO_Staging_Coded = 2167 then "Stage I"
				when latest.WHO_Staging_Coded = 2168 then "Stage II"
				when latest.WHO_Staging_Coded = 2169 then "Stage III"
				when latest.WHO_Staging_Coded = 2170 then "Stage IV"
			else 'N/A' end as WHO_Clinical_Staging  
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as WHO_Staging_Coded
				from obs oss
				where oss.concept_id = 2342 -- WHO Clinical Staging
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where o.concept_id = 2342 
			and  o.obs_datetime = max_observation
	)Final_WHO_Staging
		on anc_patients.Id = Final_WHO_Staging.person_id

left outer join
	(
		-- Initiated on CTX

	select o.person_id, o.obs_datetime as datetime,
			case 
				when latest.Initiated_CTX_Coded = 2146 then "Yes"
				when latest.Initiated_CTX_Coded = 2147 then "No"
				when latest.Initiated_CTX_Coded = 1975 then "Not Applicable"
			else 'N/A' end as Initiated_on_CTX  
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Initiated_CTX_Coded
				from obs oss
				where oss.concept_id = 4214 -- Initiated on CTX
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where o.concept_id = 4214 
			and  o.obs_datetime = max_observation
	)Final_Initiated_CTX
		on anc_patients.Id = Final_Initiated_CTX.person_id

left outer join
	(
		-- Initiated on ART

	select o.person_id, o.obs_datetime as datetime,
			case 
				when latest.Initiated_ART_Coded = 4341 then "Already on ART"
				when latest.Initiated_ART_Coded = 4342 then "Initiated on ART during pregnancy"
				when latest.Initiated_ART_Coded = 2459 then "Referred for Initiation of ART"
				when latest.Initiated_ART_Coded = 4321 then "Declined"
				when latest.Initiated_ART_Coded = 1975 then "Not Applicable"
			else 'N/A' end as Initiated_on_ART 
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Initiated_ART_Coded
				from obs oss
				where oss.concept_id = 4343 -- Initiated on ART
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where o.concept_id = 4343 
			and  o.obs_datetime = max_observation
	)Final_Initiated_ART
		on anc_patients.Id = Final_Initiated_ART.person_id

left outer join
	(
		-- Initiated on PrEP

	select o.person_id, o.obs_datetime as datetime,
			case 
				when latest.Initiated_PrEP_Coded = 2146 then "Yes"
				when latest.Initiated_PrEP_Coded = 2147 then "No"
				when latest.Initiated_PrEP_Coded = 1975 then "Not Applicable"
			else 'N/A' end as Initiated_on_PrEP 
		from obs o 
		inner join 
				(
				select oss.person_id, MAX(oss.obs_datetime) as max_observation,
				SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Initiated_PrEP_Coded
				from obs oss
				where oss.concept_id = 5482 -- Initiated on PrEP
				and oss.obs_datetime <= cast('#endDate#' as date)
				group by oss.person_id
				)latest 
			on latest.person_id = o.person_id
			where o.concept_id = 5482 
			and  o.obs_datetime = max_observation
	)Final_Initiated_PrEP
		on anc_patients.Id = Final_Initiated_PrEP.person_id

-- Infant Feeding Counselling
left outer join

(select
       o.person_id,
       case
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS Infant_Feeding_Counselling
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4211 and oss.voided=0
		 and cast(oss.obs_datetime as date) >= cast('#startDate#' as date)
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4211
	and  o.obs_datetime = max_observation
	) infant_feeding
ON anc_patients.Id = infant_feeding.person_id

-- Family Planning Counselling
left outer join

(select
       o.person_id,
       case
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS Family_Planning_Counselling
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4350 and oss.voided=0
		 and cast(oss.obs_datetime as date) >= cast('#startDate#' as date)
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4350
	and  o.obs_datetime = max_observation
	) family_planning
ON anc_patients.Id = family_planning.person_id

-- Gender Based Violence Counselling
left outer join

(select
       o.person_id,
       case
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS GBV_Counselling
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 5303 and oss.voided=0
		 and cast(oss.obs_datetime as date) >= cast('#startDate#' as date)
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 5303
	and  o.obs_datetime = max_observation
	) GBV_Counselling
ON anc_patients.Id = GBV_Counselling.person_id


-- Iron

left outer join

(select
       o.person_id,
       case
           when o.value_coded = 4668 then "Prophylaxis"
           when o.value_coded = 1067 then "On Treatment"
		   when o.value_coded = 4298 then "Not Given"
           else ""
       end AS Iron
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4299 and oss.voided=0
		and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 	4299
	and  o.obs_datetime = max_observation
	) Iron
ON anc_patients.Id = Iron.person_id

-- Folate

left outer join

(select
       o.person_id,
       case
           when o.value_coded = 4668 then "Prophylaxis"
           when o.value_coded = 1067 then "On Treatment"
		   when o.value_coded = 4298 then "Not Given"
           else ""
       end AS Folate
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4300 and oss.voided=0
		and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 	4300
	and  o.obs_datetime = max_observation
	) Folate
ON anc_patients.Id = Folate.person_id

-- Calcium

left outer join

(select
       o.person_id,
       case
           when o.value_coded = 4668 then "Prophylaxis"
           when o.value_coded = 1067 then "On Treatment"
		   when o.value_coded = 4298 then "Not Given"
           else ""
       end AS Calcium
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 5418 and oss.voided=0
		and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 5418
	and  o.obs_datetime = max_observation
	) Calcium
ON anc_patients.Id = Calcium.person_id

-- MUAC
left outer join
(select o.person_id, muac as MUAC
from obs o 
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) as muac
		 from obs oss
		 where oss.concept_id = 2086 and oss.voided=0
		 and oss.obs_datetime < cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 2086
	and  o.obs_datetime = max_observation	
	)muac
ON anc_patients.Id = muac.person_id


-- Rhesus
left outer join

(select
       o.person_id,
       case
           when value_coded = 5332 then "Rh+"
           when value_coded = 5333 then "Rh-"
           else ""
       end AS Rhesus_Factor
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 5331 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 5331
	and  o.obs_datetime = max_observation
	) Rhesus
ON anc_patients.Id = Rhesus.person_id

-- TT Previous Doses
left outer join
(select o.person_id, TT_Previous as TT_Previous_Doses
from obs o 
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) as TT_Previous
		 from obs oss
		 where oss.concept_id = 4318 and oss.voided=0
		 and oss.obs_datetime < cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 4318
	and  o.obs_datetime = max_observation	
	)TT_Previous_Doses
ON anc_patients.Id = TT_Previous_Doses.person_id

-- TT Current Doses
left outer join
(select o.person_id, TT_Current as TT_Current_Doses
from obs o 
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) as TT_Current
		 from obs oss
		 where oss.concept_id = 4319 and oss.voided=0
		 and oss.obs_datetime < cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 4319
	and  o.obs_datetime = max_observation	
	)TT_Current_Doses
ON anc_patients.Id = TT_Current_Doses.person_id

-- TB STATUS
left outer join

(select
       o.person_id,
       case
           when value_coded = 3709 then "No Signs"
           when value_coded = 1876 then "TB Suspect"
		   when value_coded = 3639 then "On TB Treatment"
           else ""
       end AS TB_Status
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 3710 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 3710
	and  o.obs_datetime = max_observation
	) TBStatus
ON anc_patients.Id = TBStatus.person_id