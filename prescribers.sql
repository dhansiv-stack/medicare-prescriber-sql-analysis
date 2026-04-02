--For this exericse, you'll be working with a database derived from the Medicare Part D Prescriber Public Use File. More information about the data is contained in the Methodology PDF file. 
--See also the included entity-relationship diagram.

--Q1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi,
       SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC
LIMIT 1;

--Answer: I used SUM and GROUP BY to calculate total claims per prescriber, then used ORDER BY and LIMIT 1 to find the highest.

-- Q1. b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT p.nppes_provider_first_name,
       p.nppes_provider_last_org_name,
       p.specialty_description,
       SUM(pr.total_claim_count) AS total_claims
FROM prescriber p
JOIN prescription pr
  ON p.npi = pr.npi
GROUP BY p.nppes_provider_first_name,
         p.nppes_provider_last_org_name,
         p.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

--Answer: I joined the prescriber and prescription tables using the NPI. Then I grouped by the prescriber’s first name, last name, and specialty, and used the SUM function to calculate total claims. 
--I sorted the results in descending order and used LIMIT 1 to find the prescriber with the highest total number of claims.

--Q2. a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT p.specialty_description,
       SUM(pre.total_claim_count) AS total_claims
FROM prescriber p
JOIN prescription pre
  ON p.npi = pre.npi
GROUP BY p.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

--Answer: I joined the prescriber and prescription tables using NPI, then grouped by specialty description and used SUM to calculate the total number of claims for each specialty. 
--I sorted the totals in descending order and used LIMIT 1 to find the specialty with the highest total number of claims.

--Q2. b. Which specialty had the most total number of claims for opioids?

SELECT p.specialty_description,
       SUM(pr.total_claim_count) AS total_claims
FROM prescriber p
JOIN prescription pr
  ON p.npi = pr.npi
WHERE pr.drug_name IN (
    'ACETAMINOPHEN-CODEINE',
    'BUPRENORPHINE',
    'BUPRENORPHINE-NALOXONE',
    'CODEINE SULFATE',
    'DURAGESIC',
    'EMBEDA',
    'ENDOCET',
    'EXALGO',
    'FENTANYL',
    'HYDROCODONE-ACETAMINOPHEN',
    'HYDROCODONE-IBUPROFEN',
    'HYDROMORPHONE HCL',
    'HYDROMORPHONE ER',
    'METHADONE HCL'
)
GROUP BY p.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

--Answer: Opioid medications were identified by selecting drugs classified as opioid analgesics according to standard pharmaceutical drug classifications.

--Q2. c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT DISTINCT p.specialty_description
FROM prescriber p
LEFT JOIN prescription pre
  ON p.npi = pre.npi
WHERE pre.npi IS NULL;

--Answer: I used a LEFT JOIN and filtered for NULL values in the prescription table to find specialties with no associated prescriptions.

--Q2. d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?


SELECT p.specialty_description,

       SUM(pre.total_claim_count) AS total_claims,

       SUM(
           CASE 
               WHEN pre.drug_name IN (
                   'ACETAMINOPHEN-CODEINE',
                   'BUPRENORPHINE',
                   'BUPRENORPHINE-NALOXONE',
                   'CODEINE SULFATE',
                   'DURAGESIC',
                   'EMBEDA',
                   'ENDOCET',
                   'EXALGO',
                   'FENTANYL',
                   'HYDROCODONE-ACETAMINOPHEN',
                   'HYDROCODONE-IBUPROFEN',
                   'HYDROMORPHONE HCL',
                   'HYDROMORPHONE ER',
                   'METHADONE HCL'
               )
               THEN pre.total_claim_count
               ELSE 0
           END
       ) AS opioid_claims,

       ROUND(
           100.0 * SUM(
               CASE 
                   WHEN pre.drug_name IN (
                       'ACETAMINOPHEN-CODEINE',
                       'BUPRENORPHINE',
                       'BUPRENORPHINE-NALOXONE',
                       'CODEINE SULFATE',
                       'DURAGESIC',
                       'EMBEDA',
                       'ENDOCET',
                       'EXALGO',
                       'FENTANYL',
                       'HYDROCODONE-ACETAMINOPHEN',
                       'HYDROCODONE-IBUPROFEN',
                       'HYDROMORPHONE HCL',
                       'HYDROMORPHONE ER',
                       'METHADONE HCL'
                   )
                   THEN pre.total_claim_count
                   ELSE 0
               END
           ) / SUM(pre.total_claim_count), 2
       ) AS opioid_percentage

FROM prescriber p
JOIN prescription pre
  ON p.npi = pre.npi

GROUP BY p.specialty_description
ORDER BY opioid_percentage DESC;

--Answer: I calculated opioid claims as a percentage of total claims for each specialty and found that surgical and pain-related specialties had the highest opioid percentages.

--Q3. a. Which drug (generic_name) had the highest total drug cost?

SELECT drug_name,
       SUM(total_drug_cost) AS total_cost
FROM prescription
GROUP BY drug_name
ORDER BY total_cost DESC
LIMIT 1;

--Answer: I grouped the prescription data by drug name and used the SUM function to calculate the total drug cost for each drug. 
--Then I sorted the results in descending order and used LIMIT 1 to find the drug with the highest total cost

--Q3. b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT drug_name,
       ROUND(SUM(total_drug_cost) / SUM(total_day_supply), 2) AS cost_per_day
FROM prescription
GROUP BY drug_name
ORDER BY cost_per_day DESC
LIMIT 1;

--Answer: I grouped the data by drug name and calculated cost per day by dividing the total drug cost by the total day supply. 
--I used the ROUND function to round the result to two decimal places, then sorted the results in descending order and selected the highest value.

--Q4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. 
--See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT drug_name,
       CASE
           WHEN opioid_drug_flag = 'Y' THEN 'opioid'
           WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
           ELSE 'neither'
       END AS drug_type
FROM drug;

--Answer: I used a CASE expression to create a new column called drug_type. Drugs with opioid_drug_flag = 'Y' were labeled as 'opioid', drugs with antibiotic_drug_flag = 'Y' were labeled as 'antibiotic', and all other drugs were labeled as 'neither'.

--Q4. b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
    CASE
        WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
        WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
        ELSE 'neither'
    END AS drug_type,

    SUM(pre.total_drug_cost)::money AS total_cost

FROM drug d
JOIN prescription pre
  ON d.drug_name = pre.drug_name

GROUP BY drug_type
ORDER BY total_cost DESC;

--Answer: I classified each drug as opioid, antibiotic, or neither using a CASE statement. 
--Then I joined the drug and prescription tables and summed the total drug cost for each drug type. After comparing the totals, more was spent on opioids than on antibiotics.

--Q5. a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(DISTINCT cbsa) AS number_of_cbsa
FROM cbsa
WHERE cbsaname LIKE '%, TN';

--Answer: I filtered the cbsa table for rows where cbsaname ends with , TN to include only Tennessee CBSAs, then used COUNT(DISTINCT cbsa) to count the unique CBSAs.

--Q5. b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population

-- Largest CBSA population
SELECT c.cbsaname,
       SUM(p.population) AS total_population
FROM cbsa c
JOIN population p
  ON c.fipscounty = p.fipscounty
GROUP BY c.cbsaname
ORDER BY total_population DESC
LIMIT 1;


--Smallest CBSA population

SELECT c.cbsaname,
       SUM(p.population) AS total_population
FROM cbsa c
JOIN population p
  ON c.fipscounty = p.fipscounty
GROUP BY c.cbsaname
ORDER BY total_population ASC
LIMIT 1;

--Answer: I joined the cbsa and population tables using the fipscounty column, grouped by CBSA name, and summed the population to calculate total population for each CBSA. 
--I then sorted the totals in descending order to find the largest CBSA and ascending order to find the smallest CBSA.

--Q5. c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.


SELECT f.county,
       p.population
FROM population p
LEFT JOIN fips_county f
  ON p.fipscounty = f.fipscounty
LEFT JOIN cbsa c
  ON p.fipscounty = c.fipscounty
WHERE c.cbsa IS NULL
ORDER BY p.population DESC
LIMIT 1;

--Answer: I used a LEFT JOIN to join the population and cbsa tables by county FIPS code and filtered for counties not included in a CBSA by selecting rows where the cbsa value was NULL. 
--I then joined to the fips_county table to get the county name and selected the county with the largest population.

--Q6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name,
       total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--Answer: I filtered the prescription table to include only rows where total_claim_count was greater than or equal to 3000 and selected the drug name and total claim count.

--Q6. b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT p.drug_name,
       p.total_claim_count,
       CASE
           WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
           ELSE 'not opioid'
       END AS opioid_status
FROM prescription p
JOIN drug d
  ON p.drug_name = d.drug_name
WHERE p.total_claim_count >= 3000;


--Answer: I joined the prescription and drug tables using drug name, filtered for rows where total_claim_count was at least 3000, and used a CASE expression to create a column indicating whether each drug was an opioid based on the opioid_drug_flag.


--Q6. c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT 
    p.drug_name,
    p.total_claim_count,
    pr.nppes_provider_first_name,
    pr.nppes_provider_last_org_name,
    CASE
        WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
        ELSE 'not opioid'
    END AS opioid_status
FROM prescription p
JOIN drug d
  ON p.drug_name = d.drug_name
JOIN prescriber pr
  ON p.npi = pr.npi
WHERE p.total_claim_count >= 3000;

--Answer: I joined the prescription, drug, and prescriber tables using drug name and NPI. I filtered for prescriptions with at least 3000 total claims and used a CASE expression to indicate whether each drug was an opioid. 
--I also included the prescriber’s first and last name for each row.

--Q7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.
--Q7. a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. 
--You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT p.npi,
       d.drug_name
FROM prescriber p
CROSS JOIN drug d
WHERE p.specialty_description = 'Pain Management'
  AND p.nppes_provider_city = 'NASHVILLE'
  AND d.opioid_drug_flag = 'Y';

--Answer: I filtered the prescriber table for pain management specialists in Nashville and filtered the drug table for opioid drugs. 
--Then I used a CROSS JOIN to create all possible combinations of NPI and opioid drug names.

--Q7. b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. 
--You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p.npi,
       d.drug_name,
       COALESCE(pr.total_claim_count, 0) AS total_claim_count
FROM prescriber p
CROSS JOIN drug d
LEFT JOIN prescription pr
  ON p.npi = pr.npi
 AND d.drug_name = pr.drug_name
WHERE p.specialty_description = 'Pain Management'
  AND p.nppes_provider_city = 'NASHVILLE'
  AND d.opioid_drug_flag = 'Y';

--Answer: I used a CROSS JOIN to create all combinations of Nashville pain management prescribers and opioid drugs, then used a LEFT JOIN to join the prescription table to get the number of claims for each combination. 
--I used COALESCE to show 0 when there were no claims.

--Q7. c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT p.npi,
       d.drug_name,
       COALESCE(pr.total_claim_count, 0) AS total_claim_count
FROM prescriber p
CROSS JOIN drug d
LEFT JOIN prescription pr
  ON p.npi = pr.npi
 AND d.drug_name = pr.drug_name
WHERE p.specialty_description = 'Pain Management'
  AND p.nppes_provider_city = 'NASHVILLE'
  AND d.opioid_drug_flag = 'Y';

--Answer: I used COALESCE to replace NULL values in total_claim_count with 0 after performing a CROSS JOIN and LEFT JOIN.