Select date_collected as "Date Specimen Collected", Lab_Order_Number as "Lab Order Number"
From
(select distinct patient.patient_id AS Id,
                cast(o.date_created as date) as date_collected
            from orders o
            -- Viral Load Tests Sent
                    INNER JOIN patient ON o.patient_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1

                AND CAST(o.date_created AS DATE) >= CAST('#startDate#' AS DATE)
                AND CAST(o.date_created AS DATE) <= CAST('#endDate#' AS DATE)) as test

Left Outer Join
(
    
        select oss.person_id as pId, oss.value_text  as Lab_Order_Number
            from obs oss
            where oss.concept_id = 5498
            and oss.voided=0
            and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
            group by oss.person_id
    
) as lab_order
on test.Id = lab_order.pId
