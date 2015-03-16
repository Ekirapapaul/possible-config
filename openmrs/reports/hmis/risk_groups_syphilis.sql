SELECT
  answer_concept_name as 'Risk Groups/Key Population Group',
  IF(form.diagnosed_count is not null, form.diagnosed_count, 0) as 'Diagnosed'
FROM concept_answer_view
  LEFT OUTER JOIN
    (SELECT risk_group.value_coded, count(*) AS diagnosed_count, diagnosis_obs.person_id as ruled FROM obs diagnosis_obs
      INNER JOIN concept_name risk_group_concept ON risk_group_concept.name='STI, Risk Group'
                                                    AND risk_group_concept.concept_name_type='FULLY_SPECIFIED'
      INNER JOIN obs risk_group ON diagnosis_obs.person_id = risk_group.person_id AND risk_group.concept_id = risk_group_concept.concept_id
                                                                                  AND risk_group.voided = FALSE
      INNER JOIN concept_name syphilis_concept ON syphilis_concept.name='Syphilis'
                                                    AND syphilis_concept.concept_name_type='FULLY_SPECIFIED'
      INNER JOIN concept_name ruled_out_concept ON ruled_out_concept.name='Ruled Out Diagnosis'
                                                    AND ruled_out_concept.concept_name_type='FULLY_SPECIFIED'
      LEFT OUTER JOIN obs ruled_out ON ruled_out.value_coded=ruled_out_concept.concept_id
                                                    AND ruled_out.obs_group_id = diagnosis_obs.obs_group_id
      WHERE diagnosis_obs.value_coded = syphilis_concept.concept_id
          AND CAST(diagnosis_obs.obs_datetime AS DATE) BETWEEN "#startDate#" AND "#endDate#"
          AND diagnosis_obs.voided = FALSE
          AND ruled_out.value_coded is NULL
      GROUP BY  risk_group.value_coded) form ON concept_answer_view.answer_concept_id = form.value_coded
WHERE question_concept_name = 'STI, Risk Group';


