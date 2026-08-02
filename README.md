# CRF Design

## Overview
This repository showcases the design and documentation of Case Report Forms (CRFs) for clinical data management.  
It provides electronic CRFs (eCRFs), annotated CRFs (aCRFs), specification sheets, and edit check logic to ensure data integrity and compliance with CDISC standards.  
The repository also demonstrates mapping specifications from CRFs to SDTM domains, ensuring traceability from data collection to standardized datasets.

## Live CRF Form
You can view and interact with the working CRF form here:  
👉 [Access the CRF Form](https://tally.so/r/WOXXWe)

## Deliverables
- **crf_artifacts/** → eCRF, aCRF, specification sheet, edit check list  
- **edit_checks/** → Edit check definitions and logic  
- **sdtm_mapping/** → Mapping specifications from CRF to SDTM domains  
- **discrepancy_logs/** → Logs of identified data discrepancies for review  

## Example Edit Checks
- **EC-001 (DM):** Patient ID must be unique per site  
- **EC-003 (DM):** Age must meet protocol eligibility (placeholder 18–100)  
- **EC-006 (AE):** AE end date must not precede start date  
- **EC-007 (AE/DM):** Fatal outcome requires Date of Death in DM  

## Repository Structure
crf-design/
│
├── crf_artifacts/        # eCRF, aCRF, spec sheet, edit check list
├── edit_checks/          # Edit check definitions and logic
├── sdtm_mapping/         # Mapping specifications from CRF to SDTM domains
├── discrepancy_logs/     # Data discrepancy reports
├── README.md             # Project documentation
└── .gitignore            # Git ignore rules

## CDM Philosophy
> *"CRF design ensures traceability from data collection to SDTM mapping, enabling clean and compliant datasets."*
"@ | Out-File "README.md" -Encoding utf8 -Force

git push origin main
