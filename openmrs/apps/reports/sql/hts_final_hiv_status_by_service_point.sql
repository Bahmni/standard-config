SELECT 
    pi.identifier AS Patient_Identifier,
    CONCAT(pn.given_name, ' ', pn.family_name) AS Patient_Name,
    TIMESTAMPDIFF(YEAR, p.birthdate, CAST('#endDate#' AS DATE)) AS Age,
    p.gender AS Sex,
    ag.name AS Age_Group,
    
    CASE 
        WHEN o_initiation.value_coded = 4227 THEN 'PITC'
        WHEN o_initiation.value_coded = 4226 THEN 'CITC'
    END AS HIV_Testing_Initiation,

    MAX(CASE 
        WHEN o_history.value_coded = 2147 THEN 'New'
        WHEN o_history.value_coded = 2146 THEN 'Repeat'
    END) AS Testing_History,

    CASE tr.value_coded
        WHEN 1738 THEN 'Positive'
        WHEN 1016 THEN 'Negative'
        WHEN 4220 THEN 'Indeterminate'
    END AS HIV_Status,

    loc.name AS Location_Name,

    CASE o_entry.value_coded
        WHEN 4234 THEN 'Antiretroviral'
        WHEN 4233 THEN 'Anti Natal Care'
        WHEN 2191 THEN 'Outpatient'
        WHEN 2190 THEN 'Tuberculosis Entry Point'
        WHEN 4235 THEN 'VMMC'
        WHEN 4236 THEN 'Adolescent'
        WHEN 2192 THEN 'Inpatient'
        WHEN 3632 THEN 'PEP'
        WHEN 2139 THEN 'STI'
        WHEN 4788 THEN 'PEADS'
        WHEN 4789 THEN 'Malnutrition'
        WHEN 4790 THEN 'Subsequent ANC'
        WHEN 4791 THEN 'Emergency ward'
        WHEN 4792 THEN 'Index Testing'
        WHEN 4796 THEN 'Other Community'
        WHEN 4237 THEN 'Self Testing'
        WHEN 4963 THEN 'PNC'
        WHEN 4816 THEN 'PrEP'
        WHEN 2143 THEN 'Other'
    END AS Mode_of_Entry

FROM obs htc /*htc => HIV Testing and Counseling Intake Template*/
JOIN person p ON p.person_id = htc.person_id
JOIN patient_identifier pi ON pi.patient_id = htc.person_id
JOIN person_name pn ON pn.person_id = htc.person_id  AND pn.preferred = 1
JOIN location loc ON loc.location_id = htc.location_id

-- HIV Testing Initiation
LEFT JOIN obs o_initiation 
    ON o_initiation.person_id = htc.person_id
    AND o_initiation.encounter_id = htc.encounter_id
    AND o_initiation.concept_id = 4228
    AND o_initiation.voided = 0

-- Testing History
LEFT JOIN obs o_history 
    ON o_history.person_id = htc.person_id
    AND o_history.concept_id = 4798
    AND o_history.voided = 0
    AND o_history.encounter_id = htc.encounter_id

-- Mode of Entry
INNER JOIN obs o_entry 
    ON o_entry.person_id = htc.person_id
    AND o_entry.encounter_id = htc.encounter_id
    AND o_entry.concept_id = 4238
    AND o_entry.voided = 0
    AND o_entry.value_coded IS NOT NULL

JOIN reporting_age_group ag 
    ON CAST('#endDate#' AS DATE) BETWEEN 
        DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.min_years YEAR), INTERVAL ag.min_days DAY)
        AND DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.max_years YEAR), INTERVAL ag.max_days DAY)
    AND ag.report_group_name = 'Modified_Ages'

-- Post Test Counseling
INNER JOIN obs o_post_test 
    ON o_post_test.person_id = htc.person_id
    AND o_post_test.encounter_id = htc.encounter_id
    AND o_post_test.obs_group_id = htc.obs_id
    AND o_post_test.concept_id = 2385
    AND o_post_test.voided = 0

-- Testing results
INNER JOIN obs tr
    ON tr.person_id = htc.person_id
    AND tr.encounter_id = htc.encounter_id
    AND tr.obs_group_id = o_post_test.obs_id
    AND tr.concept_id = 2165
    AND tr.obs_datetime >= CAST('#startDate#' AS DATE) AND tr.obs_datetime < DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY)
    AND tr.voided = 0

WHERE htc.concept_id = 2386
  AND htc.voided = 0
  AND pi.identifier_type = 3 
  AND pi.preferred = 1 
  AND pi.voided = 0
  AND loc.retired = 0
  AND o_initiation.value_coded IN (4227,4226)
