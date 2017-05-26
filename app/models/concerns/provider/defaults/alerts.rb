module Provider::Defaults::Alerts
  def self.included(base)
    base.class_eval do
      after_create :default_alerts, if: proc{ practice_role == :Provider }
    end
  end

  def default_alerts
    alerts_params = [{
      name: 'Controlling High Blood Pression',
      description: 'Alert for patients 18-85 years of age with a diagnosis of hypertension and whose blood pressure is not adequately controlled (greater than 140/90 mmHg).',
      resolution: 'Patient no longer has an active Dx code Hypertension (ICD 10 or SNOMED). Dx added with Start Date and Stop Date = Inactive Dx',
      bibliography: 'Centers for Disease Control and Prevention (CDC). Vital signs: awareness and treatment of uncontrolled hypertension among adults--United States, 2003-2010. MMWR Morb Mortal Wkly Rep. 2012 Sep 7;61:703-9. PubMed James PA, Oparil S, Carter BL, Cushman WC, Dennison-Himmelfarb C, Handler J, Lackland DT, LeFevre ML, MacKenzie TD, Ogedegbe O, Smith SC Jr, Svetkey LP, Taler SJ, Townsend RR, Wright JT Jr, Narva AS, Ortiz E. 2014 evidence-based guideline for the management of high blood pressure in adults: report from the panel members appointed to the Eighth Joint National Committee (JNC 8). JAMA. 2014 Feb 5;311(5):507-20. [45 references] PubMed National Committee for Quality Assurance (NCQA). HEDIS 2015: Healthcare Effectiveness Data and Information Set. Vol. 1, narrative. Washington (DC): National Committee for Quality Assurance (NCQA); 2014. various p.',
      developer: 'National Committee for Quality Assurance - Health Care Accreditation Organization',
      funding_source: 'None',
      release_date: '2012-01-01'.to_time,
      rule: :All
    },
    {
      name: 'Use of High Risk Medications in the Elderly',
      description: 'This measure is used to assess the percentage of patients 66 years of age and older who received at least one high-risk medication.',
      resolution: 'Patient no longer has an active high risk medication (Rx) in their Medication List. Inactive = High risk medication (Rx) with Start Date and Stop Date',
      bibliography: 'National Committee for Quality Assurance (NCQA). HEDIS 2015 technical specifications for ACO measurement. Washington (DC): National Committee for Quality Assurance (NCQA); 2014. various p. American Geriatrics Society 2012 Beers Criteria Update Expert Panel. American Geriatrics Society updated Beers Criteria for potentially inappropriate medication use in older adults. J Am Geriatr Soc. 2012 Apr;60(4):616-31. [35 references] PubMed External Web Site Policy Bates DW. Frequency, consequences and prevention of adverse drug events. J Qual Clin Pract. 1999 Mar;19(1):13-7. PubMed External Web Site Policy Families USA. Cost overdose: growth in drug spending for the elderly, 1992-2010. Washington (DC): Families USA; 2000. 2 p. Fick DM, Cooper JW, Wade WE, Waller JL, Maclean JR, Beers MH. Updating the Beers criteria for potentially inappropriate medication use in older adults: results of a US consensus panel of experts. Arch Intern Med. 2003 Dec 8-22;163(22):2716-24. PubMed External Web Site Policy Fu AZ, Liu GG, Christensen DB. Inappropriate medication use and health outcomes in the elderly. J Am Geriatr Soc. 2004 Nov;52(11):1934-9. PubMed External Web Site Policy Graal MB, Wolffenbuttel BH. The use of sulphonylureas in the elderly. Drugs Aging. 1999 Dec;15(6):471-81. [74 references] PubMed External Web Site Policy McLeod PJ, Huang AR, Tamblyn RM, Gayton DC. Defining inappropriate practices in prescribing for elderly people: a national consensus panel. CMAJ. 1997 Feb 1;156(3):385-91. PubMed External Web Site Policy Murray JB. Cardiac disorders and antidepressant medications. J Psychol. 2000 Mar;134(2):162-8. [42 references] PubMed External Web Site Policy National Committee for Quality Assurance (NCQA). HEDIS 2015: Healthcare Effectiveness Data and Information Set. Vol. 1, narrative. Washington (DC): National Committee for Quality Assurance (NCQA); 2014. various p. Roose SP, Spatz E. Treatment of depression in patients with heart disease. J Clin Psychiatry. 1999;60 Suppl 2:34-7. [37 references] PubMed External Web Site Policy Zhan C, Sangl J, Bierman AS, Miller MR, Friedman B, Wickizer SW, Meyer GS. Potentially inappropriate medication use in the community-dwelling elderly: findings from the 1996 Medical Expenditure Panel Survey. JAMA. 2001 Dec 12;286(22):2823-9. PubMed External Web Site Policy',
      developer: 'National Committee for Quality Assurance - Health Care Accreditation Organization',
      funding_source: 'Unspecified',
      release_date: '2012-01-01'.to_time,
      rule: :All
    },
    {
      name: 'Comprehensive diabetes care: percentage of members 18 to 75 years of age with diabetes (type 1 and type 2)  who had hemoglobin A1c (HbA1c) testing',
      description: 'This measure is used to assess the percentage of members 18 to 75 years of age with diabetes (type 1 and type 2) who had a hemoglobin A1c (HbA1c) test performed during the measurement year. This measure is a component of the Comprehensive Diabetes Care composite measure—one of 7 different rates—looking at how well an organization cares for the common and serious chronic disease of diabetes.',
      resolution: 'Dr. orders another Hemoglobin A1c Test under Lab Orders (LOINC) OR Dr. enters in recent Lab Results from a Hemoglobin A1c Test for date at least or more than 365 days from past Hemoglobin A1c Test',
      bibliography: 'National Committee for Quality Assurance (NCQA). HEDIS 2016: Healthcare Effectiveness Data and Information Set. Vol. 1, narrative. Washington (DC): National Committee for Quality Assurance (NCQA); 2015. various p. National Committee for Quality Assurance (NCQA). HEDIS 2016: Healthcare Effectiveness Data and Information Set. Vol. 2, technical specifications for health plans. Washington (DC): National Committee for Quality Assurance (NCQA); 2015. various p. American Diabetes Association. Economic costs of diabetes in the U.S. in 2012. Diabetes Care. 2013 Apr;36(4):1033-46.',
      developer: 'National Committee for Quality Assurance - Health Care Accreditation Organization',
      funding_source: 'Unspecified',
      release_date: '2014-09-01'.to_time,
      rule: :All
    },
    {
      name: 'Active Medication Allergies',
      description: 'This Clinical Decision Support Rule is used to provide alerts to providers and staff regarding a patient’s active Medication Allergies as well as the severity of his/her allergy to each medication in their Medication Allergy List.',
      resolution: 'Patient has no active Medication Allergies in their Medication Allergy List. Inactive = Medication Allergy has a start date and an end date',
      bibliography: 'Frew A. General principles of investigating and managing drug allergy. Br J Clin Pharmacol. 2011;71:642–6.',
      developer: 'EHR One, LLC',
      funding_source: 'None',
      release_date: '2016-06-01'.to_time,
      rule: :All
    },
    {
        name: 'Children who have tooth decay or cavities Children who have tooth decay or cavities',
        description: 'Children who have dental decay or cavities are less likely to be in very good or excellent overall health than children without decay or cavities. Children with decay are also more likely to have other oral health problems such as toothaches, broken teeth, and bleeding gums.',
        resolution: 'Patient has been provided related-Patient Education and consultation on proper brushing habits and hygiene, nutrition guidance, regular dental follow-up care appointments, and more.',
        bibliography: 'Child and Adolescent Health Measurement Initiative. 2007 National Survey of Children`s Health, Data Resource Center for Child Adolescent Health website. www.nschdata.org Edelstein BL, Chinn CH. Update on disparities in oral health and access to dental care for America`s children. Acad Pediatr.2009;9(6):415-419. Milgrom P, Zero DT, Tanzer JM. An examination of the advances in science and technology of prevention of tooth decay in young children since the Surgeon General`s Report on Oral Health. Acad Pediatr. 2009;9(6):404-409.',
        developer: 'National Committee for Quality Assurance',
        funding_source: 'None',
        release_date: '2014-01-01'.to_time,
        rule: :All
    }]
    triggers_params = [
      [ {description: 'Patient Age equals value between 18-85 years.'},
        {description: 'Patient has an active Dx code for Hypertension (ICD 10 or SNOMED). Dx added with Start Date but no Stop Date = Active Dx'},
        {description: 'Patient’s Blood Pressure is greater than 140/90 mmHg.'}],
      [ {description: 'Patient Age equals value 66 years or older.'},
        {description: 'Patient has an active high risk medication (Rx) in their Medication List: Active = High Risk medication has a start date but no end date, high risk medication reference list provided'}],
      [ {description: 'Patient Age equals value between 18 – 75 years of age.'},
        {description: 'Patient has an active Diabetes (type 1 or type 2) Active = Diabetes Dx has a start date but no end date'},
        {description: 'Patient has Lab Results for a Hemoglobin A1c Test (LOINC) in the last year (365 days from today’s date)'}],
      [ {description: 'Patient has active Medication Allergies in their Medication Allergy List. Active = Medication Allergy has a start date but no end date'}],
      [ {description: 'Patient’s age equals between 0-20 years.'},
        {description: 'Patient has had cavities or tooth decay recorded in the last 6 months.'}]]

    alert_ids = Alert.insert_all(alerts_params.map{ |params| params.merge(provider_id: id)})
    trigger_category_ids = TriggerCategory.insert_all(triggers_params.flatten.count.times.map{ {category: :Problem} })
    Trigger.insert_all(triggers_params.map.with_index{ |arr, i| arr.map{ |params| params.merge(alert_id: alert_ids[i]) } }
                                      .flatten
                                      .map.with_index{|params, i| params.merge(trigger_category_id: trigger_category_ids[i])})
  end
end